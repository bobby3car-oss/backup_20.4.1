import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../firebase/firebase_paths.dart';
import '../firebase/migration_service.dart';
import '../firebase/timeline_repository.dart';
import 'task_orchestrator.dart';
import 'timeline_engine.dart';

/// Cloud-synced wrapper around [TaskOrchestrator].
///
/// Offline-first: the local [TaskOrchestrator] remains the source of truth
/// for the in-app stream. State changes are mirrored to Firestore via
/// [TimelineRepository]. On first launch the [MigrationService] uploads
/// any existing local items.
class TaskOrchestratorSync {
  TaskOrchestratorSync._internal()
      : _orchestrator = TaskOrchestrator(autoSeed: false),
        _repo = TimelineRepository(),
        _migration = MigrationService();

  static final TaskOrchestratorSync instance = TaskOrchestratorSync._internal();

  factory TaskOrchestratorSync() => instance;

  final TaskOrchestrator _orchestrator;
  final TimelineRepository _repo;
  final MigrationService _migration;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _initialized = false;

  String? get _uid => _auth.currentUser?.uid;

  /// The operation date discovered from Firestore or set locally.
  DateTime? get operationDate => _orchestrator.operationDate;

  /// Whether initialization has completed.
  bool get isInitialized => _initialized;

  // ─── Lifecycle ──────────────────────────────────────────────────────

  /// Loads local data, runs migration, and fetches the operation date
  /// from Firestore. If an operation date exists but no local items were
  /// generated yet, generates the care plan automatically.
  Future<void> initialize() async {
    if (_initialized) return;

    // 1. Load local items (no demo auto-seed).
    await _orchestrator.loadFromDisk();

    // 2. One-time migration of local items → Firestore.
    try {
      await _migration.migrateTimelineIfNeeded();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[TaskOrchestratorSync] Migration skipped: $e');
      }
    }

    // 3. Fetch operation date from Firestore.
    final opDate = await _fetchOperationDate();

    // 4. If we have an OP date but no items yet, generate the care plan.
    if (opDate != null && _orchestrator.items.isEmpty) {
      await _orchestrator.generateForOperation(
        operationDate: opDate,
        days: 30,
      );
      // Upload freshly generated items to Firestore.
      try {
        await _repo.migrateLocalItems(_orchestrator.items);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[TaskOrchestratorSync] Upload after generate failed: $e');
        }
      }
    }

    _initialized = true;
  }

  // ─── Stream ─────────────────────────────────────────────────────────

  /// Watches timeline items in the given date range (offline-first).
  Stream<List<TimelineItem>> watch({
    required DateTime from,
    required DateTime to,
  }) {
    return _orchestrator.watch(from: from, to: to);
  }

  // ─── Actions ────────────────────────────────────────────────────────

  /// Sets the state of a task locally **and** syncs to Firestore.
  Future<void> setState(String id, TaskState state) async {
    await _orchestrator.setState(id, state);
    try {
      await _repo.setItemState(id, state);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[TaskOrchestratorSync] setItemState sync failed: $e');
      }
    }
  }

  /// Snooze a task for 30 minutes (local only – no Firestore write needed).
  Future<void> snoozeItem30Minutes(String id) {
    return _orchestrator.snoozeItem30Minutes(id);
  }

  /// Picks a new operation date, generates the care plan, stores the date
  /// in Firestore, and uploads the items.
  Future<void> setOperationDate(DateTime date) async {
    // Generate plan locally.
    await _orchestrator.generateForOperation(operationDate: date, days: 30);

    final uid = _uid;
    if (uid == null) return;

    // Persist OP date to Firestore.
    try {
      await _firestore.doc(FirestorePaths.patientDoc(uid)).set(
        <String, dynamic>{
          'opDate': date.toIso8601String(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[TaskOrchestratorSync] opDate write failed: $e');
      }
    }

    // Upload generated items.
    try {
      await _repo.migrateLocalItems(_orchestrator.items);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[TaskOrchestratorSync] item upload failed: $e');
      }
    }
  }

  void dispose() {
    _orchestrator.dispose();
  }

  // ─── Helpers ────────────────────────────────────────────────────────

  /// Reads `opDate` from `patients/{uid}` (same parsing as
  /// DoctorPatientRepository).
  Future<DateTime?> _fetchOperationDate() async {
    final uid = _uid;
    if (uid == null) return null;

    try {
      final doc = await _firestore
          .doc(FirestorePaths.patientDoc(uid))
          .get();
      if (!doc.exists) return null;
      final data = doc.data();
      if (data == null) return null;

      // Support both top-level and nested profile.opDate.
      final raw = (data['profile'] is Map
              ? (data['profile'] as Map)['opDate']
              : null) ??
          data['opDate'];

      if (raw is Timestamp) return raw.toDate();
      if (raw is String && raw.isNotEmpty) return DateTime.tryParse(raw);
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[TaskOrchestratorSync] fetchOperationDate failed: $e');
      }
      return null;
    }
  }
}
