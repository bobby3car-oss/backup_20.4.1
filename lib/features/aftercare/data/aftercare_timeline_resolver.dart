import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../firebase/firebase_paths.dart';
import '../domain/patient_aftercare_plan.dart';
import '../domain/plan_status.dart';

/// Determines whether a patient's post-OP timeline should be driven
/// by an active [PatientAftercarePlan] instead of the standard
/// system-generated care-plan templates.
///
/// Usage:
/// ```dart
/// final resolver = AftercareTimelineResolver();
/// final plan = await resolver.fetchActivePlan(patientId);
/// if (plan != null) {
///   // Use aftercare plan as post-OP source
/// }
/// ```
class AftercareTimelineResolver {
  AftercareTimelineResolver({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Fetches the currently active plan for [patientId] once.
  ///
  /// Returns `null` if no active plan exists. Catches Firestore errors
  /// gracefully to avoid blocking timeline initialization.
  Future<PatientAftercarePlan?> fetchActivePlan(String patientId) async {
    if (patientId.isEmpty) return null;
    try {
      final snap = await _firestore
          .collection(FirestorePaths.patientAftercarePlans)
          .where('patientId', isEqualTo: patientId)
          .where('status', whereIn: [
            PlanStatus.active.name,
            PlanStatus.paused.name,
          ])
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return null;
      final doc = snap.docs.first;
      return PatientAftercarePlan.fromJson({...doc.data(), 'id': doc.id});
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[AftercareTimelineResolver] fetchActivePlan error: $e',
        );
      }
      return null;
    }
  }

  /// Watches the active plan for [patientId] as a real-time stream.
  ///
  /// Emits `null` when no active plan exists.
  Stream<PatientAftercarePlan?> watchActivePlan(String patientId) {
    if (patientId.isEmpty) return Stream.value(null);
    return _firestore
        .collection(FirestorePaths.patientAftercarePlans)
        .where('patientId', isEqualTo: patientId)
        .where('status', whereIn: [
          PlanStatus.active.name,
          PlanStatus.paused.name,
        ])
        .limit(1)
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return null;
      final doc = snap.docs.first;
      return PatientAftercarePlan.fromJson({...doc.data(), 'id': doc.id});
    });
  }

  /// Checks whether [patientId] has an active aftercare plan.
  Future<bool> hasActivePlan(String patientId) async {
    final plan = await fetchActivePlan(patientId);
    return plan != null;
  }
}
