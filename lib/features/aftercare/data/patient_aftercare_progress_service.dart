import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../firebase/firebase_paths.dart';
import '../domain/aftercare_item_progress.dart';
import '../domain/plan_status.dart';

/// Service for managing patient aftercare item progress (check-offs).
///
/// Progress is stored as a single document per plan at:
/// `patient_aftercare_plans/{planId}/progress/items`
///
/// Only the owning patient can read/write progress data.
/// Archived plans are read-only — toggle calls are rejected.
class PatientAftercareProgressService {
  PatientAftercareProgressService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    Connectivity? connectivity,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _connectivity = connectivity ?? Connectivity();

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final Connectivity _connectivity;

  static const _queueStorageKey = 'aftercare_progress_queue_v1';
  static const _maxSyncRetries = 6;

  /// Reference to the single progress document for a plan.
  DocumentReference<Map<String, dynamic>> _progressRef(String planId) =>
      _firestore.doc(FirestorePaths.aftercareProgressDoc(planId));

  /// Streams the progress state for all items in a plan.
  Stream<AftercareItemProgress> watchProgress(String planId) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(_emptyProgress(planId));

    return _progressRef(planId).snapshots().asyncMap((snap) async {
      if (!snap.exists || snap.data() == null) {
        final empty = AftercareItemProgress.empty(
          patientId: uid,
          planId: planId,
        );
        return _applyPendingOverrides(planId, empty);
      }
      final serverProgress = AftercareItemProgress.fromJson(
        snap.data()!,
        planId: planId,
      );
      return _applyPendingOverrides(planId, serverProgress);
    });
  }

  /// Fetches progress once (non-streaming).
  Future<AftercareItemProgress> getProgress(String planId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return _emptyProgress(planId);

    final snap = await _progressRef(planId).get();
    if (!snap.exists || snap.data() == null) {
      final empty = AftercareItemProgress.empty(
        patientId: uid,
        planId: planId,
      );
      return _applyPendingOverrides(planId, empty);
    }
    final serverProgress =
        AftercareItemProgress.fromJson(snap.data()!, planId: planId);
    return _applyPendingOverrides(planId, serverProgress);
  }

  /// Returns whether a specific item is completed.
  Future<bool> isItemCompleted(String planId, String itemId) async {
    final progress = await getProgress(planId);
    return progress.isCompleted(itemId);
  }

  /// Toggles the completion state of a single item.
  ///
  /// Only works for active plans — checks plan status before writing.
  /// Returns completion and queue metadata.
  Future<ToggleItemResult> toggleItemCompleted({
    required String planId,
    required String itemId,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('Nicht angemeldet');

    final current = await getProgress(planId);
    final newCompleted = !current.isCompleted(itemId);
    return setItemCompleted(
      planId: planId,
      itemId: itemId,
      completed: newCompleted,
    );
  }

  /// Sets a specific item to the given completion state (no toggle).
  Future<ToggleItemResult> setItemCompleted({
    required String planId,
    required String itemId,
    required bool completed,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('Nicht angemeldet');
    }

    final action = _PendingProgressAction(
      planId: planId,
      itemId: itemId,
      completed: completed,
      queuedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
      attempts: 0,
    );

    if (!await _hasUsableConnection()) {
      await _enqueueAction(action);
      return ToggleItemResult(
        isCompleted: completed,
        queuedOffline: true,
      );
    }

    try {
      await _applyActionToFirestore(action, uid: uid);
      await syncPendingActions(planId: planId);
      return ToggleItemResult(
        isCompleted: completed,
        queuedOffline: false,
      );
    } catch (e, st) {
      if (_isRecoverableSyncError(e)) {
        await _enqueueAction(action);
        return ToggleItemResult(
          isCompleted: completed,
          queuedOffline: true,
        );
      }
      Error.throwWithStackTrace(e, st);
    }
  }

  /// Attempts to sync queued actions. Uses last-write-wins semantics.
  Future<void> syncPendingActions({String? planId}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    if (!await _hasUsableConnection()) return;

    final queue = await _readQueue();
    if (queue.isEmpty) return;

    final toSync = _coalesceActions(queue)
        .where((a) => planId == null || a.planId == planId)
        .toList(growable: false);
    if (toSync.isEmpty) return;

    final untouched = queue
        .where((a) => planId != null && a.planId != planId)
        .toList(growable: true);
    final remaining = <_PendingProgressAction>[];

    for (final action in toSync) {
      try {
        await _applyActionToFirestore(action, uid: uid);
      } catch (e) {
        if (e is StateError) {
          final message = e.message.toLowerCase();
          final isTerminalStatus = message.contains('nur aktive plaene');
          final isNotFound = message.contains('plan nicht gefunden');
          if (isTerminalStatus || isNotFound) {
            continue;
          }
        }
        if (_isRecoverableSyncError(e)) {
          final nextAttempts = action.attempts + 1;
          if (nextAttempts < _maxSyncRetries) {
            remaining.add(action.copyWith(attempts: nextAttempts));
          }
        } else {
          remaining.add(action.copyWith(attempts: action.attempts + 1));
        }
      }
    }

    await _writeQueue([...untouched, ...remaining]);
  }

  /// Returns count of pending actions for a specific plan.
  Future<int> getPendingCount(String planId) async {
    final queue = await _readQueue();
    return queue.where((a) => a.planId == planId).length;
  }

  Future<AftercareItemProgress> _applyPendingOverrides(
    String planId,
    AftercareItemProgress progress,
  ) async {
    final queue = await _readQueue();
    final map = <String, bool>{};
    for (final action in _coalesceActions(queue)) {
      if (action.planId == planId) {
        map[action.itemId] = action.completed;
      }
    }
    if (map.isEmpty) return progress;
    return progress.withPendingOverrides(map);
  }

  Future<void> _applyActionToFirestore(
    _PendingProgressAction action, {
    required String uid,
  }) async {
    final planSnap = await _firestore
        .collection(FirestorePaths.patientAftercarePlans)
        .doc(action.planId)
        .get();

    if (!planSnap.exists) {
      throw StateError('Plan nicht gefunden');
    }
    final status = planSnap.data()?['status']?.toString();
    if (status != PlanStatus.active.name) {
      throw StateError('Nur aktive Plaene koennen bearbeitet werden');
    }
    if (planSnap.data()?['patientId'] != uid) {
      throw StateError('Kein Zugriff');
    }

    final ref = _progressRef(action.planId);
    final snap = await ref.get();
    final nowIso = DateTime.now().toIso8601String();
    final update = action.completed
        ? {
            'completed': true,
            'completedAt': nowIso,
          }
        : {
            'completed': false,
          };

    if (!snap.exists) {
      await ref.set({
        'patientId': uid,
        'planId': action.planId,
        'items': {action.itemId: update},
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return;
    }

    await ref.update({
      'items.${action.itemId}': update,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  bool _isRecoverableSyncError(Object error) {
    if (error is FirebaseException) {
      return error.code == 'unavailable' ||
          error.code == 'deadline-exceeded' ||
          error.code == 'network-request-failed';
    }
    return false;
  }

  Future<bool> _hasUsableConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return !results.contains(ConnectivityResult.none);
    } catch (_) {
      return true;
    }
  }

  Future<void> _enqueueAction(_PendingProgressAction action) async {
    final queue = await _readQueue();
    queue.add(action);
    await _writeQueue(_coalesceActions(queue));
  }

  Future<List<_PendingProgressAction>> _readQueue() async {
    if (kIsWeb) return const [];
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_queueStorageKey);
    if (raw == null || raw.isEmpty) return <_PendingProgressAction>[];

    try {
      final list = jsonDecode(raw);
      if (list is! List) return <_PendingProgressAction>[];
      return list
          .whereType<Map>()
          .map((e) => _PendingProgressAction.fromJson(
                Map<String, dynamic>.from(e),
              ))
          .toList(growable: true);
    } catch (_) {
      return <_PendingProgressAction>[];
    }
  }

  Future<void> _writeQueue(List<_PendingProgressAction> queue) async {
    if (kIsWeb) return;
    final prefs = await SharedPreferences.getInstance();
    if (queue.isEmpty) {
      await prefs.remove(_queueStorageKey);
      return;
    }
    final payload = queue.map((a) => a.toJson()).toList(growable: false);
    await prefs.setString(_queueStorageKey, jsonEncode(payload));
  }

  List<_PendingProgressAction> _coalesceActions(
    List<_PendingProgressAction> input,
  ) {
    if (input.isEmpty) return <_PendingProgressAction>[];
    final latestByKey = <String, _PendingProgressAction>{};
    for (final action in input) {
      final key = '${action.planId}|${action.itemId}';
      final existing = latestByKey[key];
      if (existing == null ||
          existing.queuedAtEpochMs <= action.queuedAtEpochMs) {
        latestByKey[key] = action;
      }
    }
    final output = latestByKey.values.toList(growable: false)
      ..sort((a, b) => a.queuedAtEpochMs.compareTo(b.queuedAtEpochMs));
    return output;
  }

  AftercareItemProgress _emptyProgress(String planId) =>
      AftercareItemProgress.empty(
        patientId: '',
        planId: planId,
      );
}

class ToggleItemResult {
  const ToggleItemResult({
    required this.isCompleted,
    required this.queuedOffline,
  });

  final bool isCompleted;
  final bool queuedOffline;
}

class _PendingProgressAction {
  const _PendingProgressAction({
    required this.planId,
    required this.itemId,
    required this.completed,
    required this.queuedAtEpochMs,
    required this.attempts,
  });

  final String planId;
  final String itemId;
  final bool completed;
  final int queuedAtEpochMs;
  final int attempts;

  _PendingProgressAction copyWith({int? attempts}) {
    return _PendingProgressAction(
      planId: planId,
      itemId: itemId,
      completed: completed,
      queuedAtEpochMs: queuedAtEpochMs,
      attempts: attempts ?? this.attempts,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'planId': planId,
      'itemId': itemId,
      'completed': completed,
      'queuedAtEpochMs': queuedAtEpochMs,
      'attempts': attempts,
    };
  }

  factory _PendingProgressAction.fromJson(Map<String, dynamic> json) {
    return _PendingProgressAction(
      planId: (json['planId'] ?? '').toString(),
      itemId: (json['itemId'] ?? '').toString(),
      completed: json['completed'] == true,
      queuedAtEpochMs: (json['queuedAtEpochMs'] as num?)?.toInt() ??
          DateTime.now().millisecondsSinceEpoch,
      attempts: (json['attempts'] as num?)?.toInt() ?? 0,
    );
  }
}
