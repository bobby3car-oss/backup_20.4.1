import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../features/aftercare/data/aftercare_timeline_mapper.dart';
import '../features/aftercare/data/aftercare_timeline_resolver.dart';
import '../features/aftercare/data/patient_aftercare_progress_service.dart';
import '../features/aftercare/domain/aftercare_item_progress.dart';
import '../features/aftercare/domain/patient_aftercare_plan.dart';
import '../features/calendar/calendar_service.dart';
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
  final AftercareTimelineResolver _aftercareResolver =
      AftercareTimelineResolver();

  /// Exposes the underlying [TaskOrchestrator] for context gathering.
  TaskOrchestrator get orchestrator => _orchestrator;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _initialized = false;
  Future<void>? _initializeFuture;

  /// The currently active aftercare plan driving post-OP medical items.
  /// `null` means the standard system-generated care plan is used.
  PatientAftercarePlan? _activeAftercarePlan;
  StreamSubscription<PatientAftercarePlan?>? _aftercareSub;

  /// Whether the post-OP timeline is driven by an aftercare plan.
  bool get hasActiveAftercarePlan => _activeAftercarePlan != null;

  /// The active aftercare plan (if any). Used by UI for banner display.
  PatientAftercarePlan? get activeAftercarePlan => _activeAftercarePlan;

  /// Completes as soon as the local disk data is loaded (fast).
  /// Callers that only need locally-persisted items should await this
  /// instead of [initialize()] to avoid blocking on Firestore.
  Future<void> get localReady => _orchestrator.ready;

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

    // 2. Migration + Firestore OP-date fetch run in parallel (independent).
    late final ({DateTime? opDate, String? opType, String? opModus}) opInfo;
    await Future.wait(<Future<void>>[
      () async {
        try {
          await _migration.migrateTimelineIfNeeded()
              .timeout(const Duration(seconds: 4));
        } catch (e) {
          if (kDebugMode) {
            debugPrint('[TaskOrchestratorSync] Migration skipped: $e');
          }
        }
      }(),
      () async {
        opInfo = await _fetchOperationInfo();
      }(),
    ]);

    // 3. If Firestore has a real OP date and the current local plan was
    //    seeded from another anchor, regenerate the timeline to match.
    final (:opDate, :opType, :opModus) = opInfo;
    final shouldRegenerateFromFirestore =
        opDate != null &&
        (_orchestrator.items.isEmpty ||
            !_isSameDate(_orchestrator.operationDate, opDate));

    if (shouldRegenerateFromFirestore) {
      try {
        await _orchestrator.generateForOperation(
          operationDate: opDate,
          days: 30,
          opType: opType,
          opModus: opModus,
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
    } else if (opDate != null) {
      // Same date but opType/opModus may have changed in Firestore.
      _orchestrator.updateOpMeta(opType: opType, opModus: opModus);
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
          opType: opType,
          opModus: opModus,
        );
        await _orchestrator.saveToDisk();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[TaskOrchestratorSync] fallback seed failed: $e');
        }
      }
    }

    // 5. Upload locally available items to Firestore (best-effort, non-blocking).
    if (_orchestrator.items.isNotEmpty) {
      unawaited(() async {
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
      }());
    }

    // 6. Check for an active aftercare plan and inject its items.
    await _resolveAftercarePlan();

    _initialized = true;
    if (kDebugMode) {
      debugPrint(
        '[TaskOrchestratorSync] initialize complete – '
        '${_orchestrator.items.length} items, opDate=$opDate, '
        'aftercarePlan=${_activeAftercarePlan?.id ?? 'none'}',
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

  /// Snooze a task for 30 minutes locally **and** sync to Firestore.
  Future<void> snoozeItem30Minutes(String id) async {
    await _orchestrator.snoozeItem30Minutes(id);
    try {
      await _orchestrator.saveToDisk();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[TaskOrchestratorSync] saveToDisk after snooze failed: $e');
      }
    }
    // Find the updated item so we can sync its full state to Firestore.
    final updated = _orchestrator.items
        .where((item) => item.id == id)
        .firstOrNull;
    if (updated != null) {
      try {
        await _repo.upsertItem(updated);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[TaskOrchestratorSync] snooze sync failed: $e');
        }
      }
    }
  }

  /// Picks a new operation date, generates the care plan, stores the date
  /// in Firestore, and uploads the items.
  ///
  /// [opType] and [opModus] control which templates are included in the
  /// generated plan. When omitted the previously stored values are reused.
  Future<void> setOperationDate(
    DateTime date, {
    String? opType,
    String? opModus,
  }) async {
    // Mark as initialized early so a concurrent initialize() call
    // (e.g. from _bootstrap) doesn't overwrite freshly generated items.
    _initialized = true;

    // Generate plan locally.
    await _orchestrator.generateForOperation(
      operationDate: date,
      days: 30,
      opType: opType,
      opModus: opModus,
    );

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

    // Add Op-Termin to device calendar.
    try {
      await CalendarService.instance
          .saveOpDateToCalendar(date, opType: opType);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[TaskOrchestratorSync] calendar sync failed: $e');
      }
    }
  }

  void dispose() {
    _aftercareSub?.cancel();
    _aftercareSub = null;
    _orchestrator.dispose();
  }

  // ─── Aftercare Plan Integration ─────────────────────────────────────

  /// Non-medical system hints that remain visible even when post-OP
  /// medical items are sourced from an active aftercare plan.
  static const _nonMedicalPostOpTemplateIds = <String>{
    'week1_hydration',
    'week1_redflags',
  };

  /// Phases whose template-generated items are considered medical
  /// post-OP content. Items from these phases are replaced unless they are
  /// listed in [_nonMedicalPostOpTemplateIds].
  static const _medicalPostOpPhases = <String>{
    'week1',
    'week2',
    'followup',
  };

  /// Checks for an active aftercare plan and, if found, replaces the
  /// standard medical post-OP items with items from the plan.
  Future<void> _resolveAftercarePlan() async {
    final uid = _uid;
    if (uid == null) return;

    try {
      final plan = await _aftercareResolver
          .fetchActivePlan(uid)
          .timeout(const Duration(seconds: 4));

      if (plan != null) {
        await _injectAftercarePlanItems(plan);
      }

      // Start watching for plan changes so the timeline updates
      // reactively when a plan is activated or archived.
      _startWatchingAftercarePlan(uid);
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[TaskOrchestratorSync] aftercare plan resolve failed: $e',
        );
      }
    }
  }

  /// Subscribes to real-time aftercare plan changes so the timeline
  /// auto-updates when a plan is activated or archived.
  void _startWatchingAftercarePlan(String patientId) {
    _aftercareSub?.cancel();
    _aftercareSub = _aftercareResolver
        .watchActivePlan(patientId)
        .listen((plan) {
      if (plan?.id == _activeAftercarePlan?.id &&
          plan?.updatedAt == _activeAftercarePlan?.updatedAt) {
        return; // No meaningful change.
      }

      if (plan != null) {
        unawaited(_injectAftercarePlanItems(plan));
      } else if (_activeAftercarePlan != null) {
        unawaited(_clearAftercarePlanItems());
      }
    }, onError: (Object e) {
      if (kDebugMode) {
        debugPrint(
          '[TaskOrchestratorSync] aftercare watch error: $e',
        );
      }
    });
  }

  /// Replaces standard medical post-OP items with items from the given
  /// [plan]. Non-medical items (hydration, pain tracking, etc.) and
  /// pre-OP items are preserved.
  Future<void> _injectAftercarePlanItems(PatientAftercarePlan plan) async {
    _activeAftercarePlan = plan;

    // 1. Remove any previously injected aftercare items.
    _orchestrator.removeWhere(
      (item) => item.metadata['source'] == 'aftercare_plan',
    );

    // 2. Remove standard medical post-OP items.
    _orchestrator.removeWhere((item) {
      final source = item.metadata['source'] as String?;
      if (source != 'care_plan') return false;
      final phase = item.metadata['phase'] as String?;
      if (phase == null || !_medicalPostOpPhases.contains(phase)) {
        return false;
      }
      final templateId = item.metadata['templateId'] as String?;
      if (templateId == null) return false;
      return !_nonMedicalPostOpTemplateIds.contains(templateId);
    });

    // 3. Map aftercare plan items to timeline items and inject them.
    //    Fetch patient progress to reflect completed items in the timeline.
    AftercareItemProgress? progress;
    try {
      progress = await PatientAftercareProgressService()
          .getProgress(plan.id);
    } catch (_) {
      // Progress fetch is best-effort — missing progress is acceptable.
    }

    final mapped = AftercareTimelineMapper.mapPlanToTimelineItems(
      plan,
      progress: progress,
      planStatus: plan.status,
    );
    for (final item in mapped) {
      _orchestrator.upsertInMemoryOnly(item);
    }

    // Re-emit and save.
    _orchestrator.emitAndSave();

    if (kDebugMode) {
      debugPrint(
        '[TaskOrchestratorSync] injected ${mapped.length} aftercare items, '
        'plan=${plan.id}',
      );
    }
  }

  /// Restores the standard care plan by removing aftercare items.
  ///
  /// Called when the active aftercare plan is archived or removed.
  Future<void> _clearAftercarePlanItems() async {
    _activeAftercarePlan = null;

    _orchestrator.removeWhere(
      (item) => item.metadata['source'] == 'aftercare_plan',
    );

    final opDate = _orchestrator.operationDate;
    if (opDate != null) {
      await _orchestrator.generateForOperation(
        operationDate: opDate,
        days: 30,
        opType: _orchestrator.opType,
        opModus: _orchestrator.opModus,
      );
      await _orchestrator.saveToDisk();
    } else {
      // Fallback if no OP date is available.
      _orchestrator.emitAndSave();
    }

    if (kDebugMode) {
      debugPrint('[TaskOrchestratorSync] cleared aftercare plan items');
    }
  }

  // ─── Helpers ────────────────────────────────────────────────────────

  /// Reads `opDate`, `opType` and `opModus` from `patients/{uid}`, falling
  /// back to `users/{uid}` if the patient document does not contain them.
  ///
  /// Both documents are fetched in parallel for speed; the canonical
  /// `patients/` result is preferred when available.
  Future<({DateTime? opDate, String? opType, String? opModus})>
      _fetchOperationInfo() async {
    final uid = _uid;
    if (uid == null) {
      return (opDate: null, opType: null, opModus: null);
    }

    // Fetch both docs in parallel.
    late final ({DateTime? opDate, String? opType, String? opModus}) patientResult;
    late final ({DateTime? opDate, String? opType, String? opModus}) userResult;

    await Future.wait(<Future<void>>[
      () async {
        try {
          patientResult = await _parseOpInfoFromDoc(
            _firestore.doc(FirestorePaths.patientDoc(uid)),
          );
        } catch (e) {
          if (kDebugMode) {
            debugPrint('[TaskOrchestratorSync] fetchOpInfo patients/ failed: $e');
          }
          patientResult = (opDate: null, opType: null, opModus: null);
        }
      }(),
      () async {
        try {
          userResult = await _parseOpInfoFromDoc(
            _firestore.doc(FirestorePaths.userDoc(uid)),
          );
        } catch (e) {
          if (kDebugMode) {
            debugPrint('[TaskOrchestratorSync] fetchOpInfo users/ failed: $e');
          }
          userResult = (opDate: null, opType: null, opModus: null);
        }
      }(),
    ]);

    // Prefer the canonical patients/ doc.
    if (patientResult.opDate != null) return patientResult;

    // Fallback to users/ doc and mirror to patients/ for next time.
    if (userResult.opDate != null) {
      unawaited(_firestore.doc(FirestorePaths.patientDoc(uid)).set(
        <String, dynamic>{'opDate': userResult.opDate!.toIso8601String()},
        SetOptions(merge: true),
      ).catchError((_) {}));
    }
    return userResult;
  }

  /// Parses `opDate`, `opType` and `opModus` from a Firestore document.
  ///
  /// Uses the local Firestore cache when available to avoid a network
  /// round trip on every startup.
  Future<({DateTime? opDate, String? opType, String? opModus})>
      _parseOpInfoFromDoc(
    DocumentReference<Map<String, dynamic>> ref,
  ) async {
    // Try the local Firestore cache first (populated by prior listeners).
    DocumentSnapshot<Map<String, dynamic>> doc;
    try {
      doc = await ref.get(const GetOptions(source: Source.cache));
    } catch (_) {
      // Cache miss – fall back to network with a timeout.
      try {
        doc = await ref.get().timeout(const Duration(seconds: 4));
      } catch (e) {
        if (kDebugMode) debugPrint('[TaskOrchestratorSync] opInfo fetch failed: $e');
        return (opDate: null, opType: null, opModus: null);
      }
    }
    if (!doc.exists) {
      return (opDate: null, opType: null, opModus: null);
    }
    final data = doc.data();
    if (data == null) {
      return (opDate: null, opType: null, opModus: null);
    }

    // Support both top-level and nested profile.opDate.
    final raw = (data['profile'] is Map
            ? (data['profile'] as Map)['opDate']
            : null) ??
        data['opDate'];

    DateTime? opDate;
    if (raw is Timestamp) {
      opDate = raw.toDate();
    } else if (raw is String && raw.isNotEmpty) {
      opDate = DateTime.tryParse(raw);
    }

    final opType = data['opType'] as String?;
    final opModus = data['opModus'] as String?;

    return (opDate: opDate, opType: opType, opModus: opModus);
  }

  bool _isSameDate(DateTime? left, DateTime? right) {
    if (left == null || right == null) return left == right;
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }
}
