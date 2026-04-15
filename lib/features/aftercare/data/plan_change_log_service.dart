import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../firebase/firebase_paths.dart';
import '../domain/plan_change_log.dart';

/// Firestore service for the immutable plan change audit trail.
///
/// Collection: `patient_aftercare_plans/{planId}/change_log/{logId}`
///
/// Change logs are append-only — they cannot be updated or deleted.
class PlanChangeLogService {
  PlanChangeLogService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  /// Appends a new change log entry for the given plan.
  ///
  /// Automatically sets [changedBy] from the current user and
  /// [changedAt] via server timestamp.
  Future<void> log({
    required String planId,
    required PlanChangeType changeType,
    required String description,
    Map<String, dynamic>? details,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || planId.isEmpty) return;

    final collectionPath =
        FirestorePaths.aftercareChangeLogCollection(planId);
    final docRef = _firestore.collection(collectionPath).doc();

    final entry = PlanChangeLog(
      id: docRef.id,
      planId: planId,
      changedBy: uid,
      changedAt: DateTime.now(),
      changeType: changeType,
      description: description,
      details: details,
    );

    final data = entry.toJson();
    data['changedAt'] = FieldValue.serverTimestamp();
    await docRef.set(data);
  }

  /// Streams all change log entries for a plan, newest first.
  Stream<List<PlanChangeLog>> watchLogs(String planId) {
    if (planId.isEmpty) return Stream.value(const []);

    final collectionPath =
        FirestorePaths.aftercareChangeLogCollection(planId);
    return _firestore
        .collection(collectionPath)
        .orderBy('changedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => PlanChangeLog.fromJson({...d.data(), 'id': d.id}))
            .toList(growable: false));
  }

  /// Fetches all change log entries for a plan once, newest first.
  Future<List<PlanChangeLog>> getLogs(String planId) async {
    if (planId.isEmpty) return const [];

    final collectionPath =
        FirestorePaths.aftercareChangeLogCollection(planId);
    final snap = await _firestore
        .collection(collectionPath)
        .orderBy('changedAt', descending: true)
        .get();

    return snap.docs
        .map((d) => PlanChangeLog.fromJson({...d.data(), 'id': d.id}))
        .toList(growable: false);
  }
}
