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
      : _orchestrator = TaskOrchestrator(autoSeed: true),
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
  Future<void>? _initializeFuture;

  String? get _uid => _auth.currentUser?.uid;

  /// The operation date discovered from Firestore or set locally.
  DateTime? get operationDate => _orchestrator.operationDate;

  /// Whether initialization has completed.
  bool get isInitialized => _initialized;

  // ─── Lifecycle ──────────────────────────────────────────────────────

  /// Ensures the timeline is populated.
  ///
  /// Guarantees that [_orchestrator.items] is non-empty after this
  /// method completes. The local orchestrator self-seeds fallback items
  /// when no persisted timeline exists. If Firestore later provides a
  /// real OP date that differs from the locally anchored plan, the care
  /// plan is regenerated from that date.
  Future<void> initialize() async {
    if (_initialized && _orchestrator.items.isNotEmpty) {
      if (kDebugMode) {
        debugPrint(
          '[TaskOrchestratorSync] initialize – already initialized, '
          '${_orchestrator.items.length} items',
        );
      }
      return;
    }

    // Guard against concurrent calls – reuse the in-flight future.
    if (_initializeFuture != null) {
      await _initializeFuture;
      return;
    }

    final completer = Completer<void>();
    _initializeFuture = completer.future;
    try {
      await _doInitialize();
      completer.complete();
    } catch (e, st) {
      completer.complete(); // don't propagate – callers handle empty state
      if (kDebugMode) {
        debugPrint('[TaskOrchestratorSync] initialize error: $e\n$st');
      }
    } finally {
      _initializeFuture = null;
    }
  }

  Future<void> _doInitialize() async {
    // 1. Wait for the constructor's loadFromDisk to complete.
    //    Do NOT call loadFromDisk() again – it clears _items and re-seeds,
    //    which races with setOperationDate() and causes the timeline to
    //    appear empty when the screen subscribes to the broadcast stream.
    try {
      await _orchestrator.ready;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[TaskOrchestratorSync] initial load failed: $e');
      }
    }

    // 2. One-time migration of legacy local items → Firestore.
    try {
      await _migration.migrateTimelineIfNeeded()
          .timeout(const Duration(seconds: 8));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[TaskOrchestratorSync] Migration skipped: $e');
      }
    }

    // 3. If Firestore has a real OP date and the current local plan was
    //    seeded from another anchor, regenerate the timeline to match.
    final opDate = await _fetchOperationDate();
    final shouldRegenerateFromFirestore =
        opDate != null &&
        (_orchestrator.items.isEmpty ||
            !_isSameDate(_orchestrator.operationDate, opDate));

    if (shouldRegenerateFromFirestore) {
      try {
        await _orchestrator.generateForOperation(
          operationDate: opDate,
          days: 30,
        );
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[TaskOrchestratorSync] generateForOperation failed: $e');
        }
      }

      try {
        await _orchestrator.saveToDisk();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[TaskOrchestratorSync] saveToDisk failed: $e');
        }
      }
    }

    // 4. Safety net: if items are STILL empty after all steps, force
    //    a generation so the user never sees an empty timeline when an
    //    opDate exists (either from Firestore or from the local file).
    if (_orchestrator.items.isEmpty) {
      final fallbackDate = opDate ?? _orchestrator.operationDate;
      if (kDebugMode) {
        debugPrint(
          '[TaskOrchestratorSync] items still empty after init – '
          'forcing seed with fallbackDate=$fallbackDate',
        );
      }
      try {
        await _orchestrator.generateForOperation(
          operationDate: fallbackDate ?? DateTime.now(),
          days: 30,
        );
        await _orchestrator.saveToDisk();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[TaskOrchestratorSync] fallback seed failed: $e');
        }
      }
    }

    // 5. Upload locally available items to Firestore (best-effort).
    if (_orchestrator.items.isNotEmpty) {
      try {
        await _repo.migrateLocalItems(_orchestrator.items)
            .timeout(const Duration(seconds: 10));
      } catch (e) {
        if (kDebugMode) {
          debugPrint(
            '[TaskOrchestratorSync] Upload after generate failed: $e',
          );
        }
      }
    }

    _initialized = true;
    if (kDebugMode) {
      debugPrint(
        '[TaskOrchestratorSync] initialize complete – '
        '${_orchestrator.items.length} items, opDate=$opDate',
      );
    }
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
    // Force immediate disk save so state changes survive app restarts.
    try {
      await _orchestrator.saveToDisk();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[TaskOrchestratorSync] saveToDisk after setState failed: $e');
      }
    }
    try {
      await _repo.setItemState(id, state);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[TaskOrchestratorSync] setItemState sync failed: $e');
      }
    }
  }

  /// Inserts or updates a timeline item locally **and** syncs to Firestore.
  Future<void> upsert(TimelineItem item) async {
    if (kDebugMode) {
      debugPrint(
        '[TaskOrchestratorSync] upsert called – '
        'id=${item.id}, type=${item.type}, title="${item.title}", '
        'items before: ${_orchestrator.items.length}',
      );
    }
    await _orchestrator.upsert(item);
    if (kDebugMode) {
      debugPrint(
        '[TaskOrchestratorSync] upsert done – '
        'items after: ${_orchestrator.items.length}',
      );
    }
    // Force immediate disk save so the item survives app restarts.
    try {
      await _orchestrator.saveToDisk();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[TaskOrchestratorSync] saveToDisk after upsert failed: $e');
      }
    }
    try {
      await _repo.upsertItem(item);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[TaskOrchestratorSync] upsertItem sync failed: $e');
      }
    }
  }

  /// Removes a timeline item locally **and** deletes it from Firestore.
  Future<void> deleteItem(String id) async {
    await _orchestrator.deleteItem(id);
    try {
      await _orchestrator.saveToDisk();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[TaskOrchestratorSync] saveToDisk after delete failed: $e');
      }
    }
    try {
      await _repo.deleteItem(id);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[TaskOrchestratorSync] deleteItem sync failed: $e');
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
    // Mark as initialized early so a concurrent initialize() call
    // (e.g. from _bootstrap) doesn't overwrite freshly generated items.
    _initialized = true;

    // Generate plan locally.
    await _orchestrator.generateForOperation(operationDate: date, days: 30);

    if (kDebugMode) {
      debugPrint(
        '[TaskOrchestratorSync] setOperationDate($date) – '
        '${_orchestrator.items.length} items generated',
      );
    }

    // Force an immediate save so items survive app restarts.
    try {
      await _orchestrator.saveToDisk();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[TaskOrchestratorSync] saveToDisk failed: $e');
      }
    }

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

  /// Reads `opDate` from `patients/{uid}`, falling back to `users/{uid}`
  /// if the patient document does not contain it.
  Future<DateTime?> _fetchOperationDate() async {
    final uid = _uid;
    if (uid == null) return null;

    // Try patients/{uid} first (canonical location).
    try {
      final result = await _parseOpDateFromDoc(
        _firestore.doc(FirestorePaths.patientDoc(uid)),
      );
      if (result != null) return result;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[TaskOrchestratorSync] fetchOpDate patients/ failed: $e');
      }
    }

    // Fallback: users/{uid} (ProfileSettingsScreen writes here).
    try {
      final result = await _parseOpDateFromDoc(
        _firestore.doc(FirestorePaths.userDoc(uid)),
      );
      if (result != null) {
        // Mirror to patients/{uid} so future lookups find it directly.
        try {
          await _firestore.doc(FirestorePaths.patientDoc(uid)).set(
            <String, dynamic>{'opDate': result.toIso8601String()},
            SetOptions(merge: true),
          );
        } catch (_) {}
      }
      return result;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[TaskOrchestratorSync] fetchOpDate users/ failed: $e');
      }
      return null;
    }
  }

  /// Parses `opDate` from a Firestore document reference.
  Future<DateTime?> _parseOpDateFromDoc(DocumentReference<Map<String, dynamic>> ref) async {
    final doc = await ref.get().timeout(const Duration(seconds: 8));
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
  }

  bool _isSameDate(DateTime? left, DateTime? right) {
    if (left == null || right == null) return left == right;
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }
}
