import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../firebase/firebase_paths.dart';
import '../domain/aftercare_phase.dart';
import '../domain/aftercare_template.dart';
import '../domain/patient_aftercare_plan.dart';
import '../domain/plan_change_log.dart';
import '../domain/plan_status.dart';
import 'plan_change_log_service.dart';

/// Firestore-backed service for patient aftercare plans.
///
/// Collection: `patient_aftercare_plans/{planId}`
///
/// Plans are always created as snapshots of a template — the template's
/// phases are deep-copied so that later template edits do not affect
/// existing patient plans.
class PatientAftercarePlanService {
  PatientAftercarePlanService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    this.overrideDoctorUid,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  /// When set (staff mode), use this UID instead of the current user's UID.
  final String? overrideDoctorUid;

  static const _collection = FirestorePaths.patientAftercarePlans;

  String? get _effectiveUid => overrideDoctorUid ?? _auth.currentUser?.uid;

  // ══════════════════════════════════════════════════════════════════════
  // Create
  // ══════════════════════════════════════════════════════════════════════

  /// Creates a draft plan from a template (not yet active).
  ///
  /// The template's phases are deep-copied via JSON round-trip.
  Future<String> createDraftFromTemplate({
    required AftercareTemplate template,
    required String patientId,
    required DateTime surgeryDate,
    DateTime? effectiveFrom,
    ActivationMode activationMode = ActivationMode.opDate,
    DateTime? scheduledActivationDate,
    String? doctorId,
    String? organizationId,
  }) async {
    final uid = doctorId ?? _effectiveUid;
    if (uid == null || uid.isEmpty) return '';

    final docRef = _firestore.collection(_collection).doc();
    final now = DateTime.now();

    // Deep copy phases by round-tripping through JSON.
    final phasesCopy = template.phases
        .map((p) => p.toJson())
        .map((json) =>
            AftercarePhase.fromJson(Map<String, dynamic>.from(json as Map)))
        .toList(growable: false);

    final plan = PatientAftercarePlan(
      id: docRef.id,
      patientId: patientId,
      doctorId: uid,
      organizationId: organizationId ?? template.organizationId,
      sourceTemplateId: template.id,
      sourceTemplateType: template.templateType,
      sourceTemplateVersion: template.version,
      title: template.title,
      surgeryDate: surgeryDate,
      effectiveFrom: effectiveFrom ?? surgeryDate,
      version: 1,
      phases: phasesCopy,
      status: PlanStatus.draft,
      activationMode: activationMode,
      scheduledActivationDate: scheduledActivationDate,
      preparedBy: _auth.currentUser?.uid,
      createdAt: now,
      updatedAt: now,
    );

    final data = plan.toJson();
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();
    await docRef.set(data);
    return docRef.id;
  }

  /// Creates and immediately activates a plan from a template.
  ///
  /// Automatically archives any existing active plan for the patient
  /// using a Firestore transaction to prevent race conditions.
  Future<String> assignTemplateToPatient({
    required AftercareTemplate template,
    required String patientId,
    required DateTime surgeryDate,
    DateTime? effectiveFrom,
    ActivationMode activationMode = ActivationMode.opDate,
    String? doctorId,
    String? organizationId,
  }) async {
    final uid = doctorId ?? _effectiveUid;
    if (uid == null || uid.isEmpty) return '';

    final currentUserUid = _auth.currentUser?.uid;
    if (kDebugMode) {
      debugPrint('[PlanService] assignTemplateToPatient: '
          'patientId=$patientId, organizationId=$organizationId');
    }

    // Deep copy phases.
    final phasesCopy = template.phases
        .map((p) => p.toJson())
        .map((json) =>
            AftercarePhase.fromJson(Map<String, dynamic>.from(json as Map)))
        .toList(growable: false);

    final newDocRef = _firestore.collection(_collection).doc();
    final now = DateTime.now();

    final plan = PatientAftercarePlan(
      id: newDocRef.id,
      patientId: patientId,
      doctorId: uid,
      organizationId: organizationId ?? template.organizationId,
      sourceTemplateId: template.id,
      sourceTemplateType: template.templateType,
      sourceTemplateVersion: template.version,
      title: template.title,
      surgeryDate: surgeryDate,
      effectiveFrom: effectiveFrom ?? surgeryDate,
      version: 1,
      phases: phasesCopy,
      status: PlanStatus.active,
      activationMode: activationMode,
      preparedBy: currentUserUid,
      activatedBy: currentUserUid,
      createdAt: now,
      updatedAt: now,
    );

    // Query for existing active or paused plans *for this doctor* only.
    // Filtering by doctorId prevents permission errors when other doctors
    // also have plans for the same patient.
    QuerySnapshot<Map<String, dynamic>>? activeQuery;
    try {
      activeQuery = await _firestore
          .collection(_collection)
          .where('patientId', isEqualTo: patientId)
          .where('doctorId', isEqualTo: uid)
          .where('status', whereIn: [
            PlanStatus.active.name,
            PlanStatus.paused.name,
          ])
          .limit(2)
          .get();
      if (kDebugMode) debugPrint('[PlanService] query returned ${activeQuery.docs.length} docs');
    } catch (e) {
      if (kDebugMode) debugPrint('[PlanService] QUERY failed (proceeding without archive): $e');
      // Query might fail due to missing composite index or permissions.
      // Proceed without archiving existing plans.
    }

    final data = plan.toJson();
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();

    // If we have existing plans to archive, use a transaction.
    // Otherwise, do a simple set.
    if (activeQuery != null && activeQuery.docs.isNotEmpty) {
      try {
      await _firestore.runTransaction((tx) async {
        for (final existingDoc in activeQuery!.docs) {
          final existingRef = existingDoc.reference;
          final freshSnap = await tx.get(existingRef);
          final st = freshSnap.data()?['status'];
          if (freshSnap.exists &&
              (st == PlanStatus.active.name || st == PlanStatus.paused.name)) {
            tx.update(existingRef, {
              'status': PlanStatus.archived.name,
              'isActive': false,
              'archivedBy': currentUserUid,
              'archivedAt': FieldValue.serverTimestamp(),
              'archivedReason': 'Neuer Plan zugewiesen',
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }
        }
        tx.set(newDocRef, data);
      });
      } catch (e) {
        if (kDebugMode) debugPrint('[PlanService] TRANSACTION failed: $e');
        rethrow;
      }
    } else {
      if (kDebugMode) {
        debugPrint('[PlanService] direct set: docId=${newDocRef.id}, '
            'doctorId=${data['doctorId']}, patientId=${data['patientId']}');
      }
      await newDocRef.set(data);
    }

    if (kDebugMode) debugPrint('[PlanService] plan created: ${newDocRef.id}');
    return newDocRef.id;
  }

  // ══════════════════════════════════════════════════════════════════════
  // Lifecycle transitions
  // ══════════════════════════════════════════════════════════════════════

  /// Activates a draft or scheduled plan.
  ///
  /// Atomically archives any currently active or paused plan for the
  /// same patient.
  Future<void> activatePlan(String planId) async {
    final uid = _auth.currentUser?.uid;
    final planRef = _firestore.collection(_collection).doc(planId);

    // Read the plan to get patientId for the active-plan query.
    final planPreRead = await planRef.get();
    if (!planPreRead.exists) return;
    final patientId = planPreRead.data()?['patientId'] as String?;
    if (patientId == null) return;

    // Query for existing active OR paused plans *for this doctor* only.
    final doctorId = planPreRead.data()?['doctorId'] as String?;
    final activeQuery = await _firestore
        .collection(_collection)
        .where('patientId', isEqualTo: patientId)
        .where('doctorId', isEqualTo: doctorId ?? uid)
        .where('status', whereIn: [
          PlanStatus.active.name,
          PlanStatus.paused.name,
        ])
        .limit(2)
        .get();

    await _firestore.runTransaction((tx) async {
      // Re-read the target plan inside the transaction.
      final planSnap = await tx.get(planRef);
      if (!planSnap.exists) return;

      // Archive any currently active or paused plans.
      for (final doc in activeQuery.docs) {
        if (doc.id == planId) continue; // skip the plan being activated
        final freshSnap = await tx.get(doc.reference);
        if (freshSnap.exists) {
          final st = freshSnap.data()?['status'];
          if (st == PlanStatus.active.name ||
              st == PlanStatus.paused.name) {
            tx.update(doc.reference, {
              'status': PlanStatus.archived.name,
              'isActive': false,
              'archivedBy': uid,
              'archivedAt': FieldValue.serverTimestamp(),
              'archivedReason': 'Neuer Plan aktiviert',
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }
        }
      }

      // Activate the target plan.
      tx.update(planRef, {
        'status': PlanStatus.active.name,
        'isActive': true,
        'activatedBy': uid,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Schedules a draft plan for future activation.
  Future<void> schedulePlanActivation({
    required String planId,
    required DateTime activationDate,
  }) async {
    await _firestore.collection(_collection).doc(planId).update({
      'status': PlanStatus.scheduled.name,
      'scheduledActivationDate': activationDate.toIso8601String(),
      'activationMode': ActivationMode.customDate.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Doctor approves a staff-prepared plan (updates audit trail).
  Future<void> approvePreparedPlan(String planId) async {
    final uid = _auth.currentUser?.uid;
    await _firestore.collection(_collection).doc(planId).update({
      'approvedBy': uid,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Archives a plan with an optional reason.
  Future<void> archivePlan(String planId, {String? reason}) async {
    final uid = _auth.currentUser?.uid;
    await _firestore.collection(_collection).doc(planId).update({
      'status': PlanStatus.archived.name,
      'isActive': false,
      'archivedBy': uid,
      'archivedAt': FieldValue.serverTimestamp(),
      'archivedReason': reason,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ══════════════════════════════════════════════════════════════════════
  // Read
  // ══════════════════════════════════════════════════════════════════════

  /// Streams the currently active plan for a patient (if any).
  Stream<PatientAftercarePlan?> getActivePlan(String patientId) {
    return _firestore
        .collection(_collection)
        .where('patientId', isEqualTo: patientId)
        .where('status', isEqualTo: PlanStatus.active.name)
        .limit(1)
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return null;
      final doc = snap.docs.first;
      return PatientAftercarePlan.fromJson({...doc.data(), 'id': doc.id});
    });
  }

  /// Streams the current plan for a patient, including paused/completed/cancelled.
  ///
  /// Unlike [getActivePlan], this returns the plan regardless of lifecycle
  /// status, excluding only drafts, scheduled, and archived plans.
  Stream<PatientAftercarePlan?> getCurrentPatientPlan(String patientId) {
    return _firestore
        .collection(_collection)
        .where('patientId', isEqualTo: patientId)
        .where('status', whereIn: [
          PlanStatus.active.name,
          PlanStatus.paused.name,
          PlanStatus.completed.name,
          PlanStatus.cancelled.name,
        ])
        .orderBy('updatedAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return null;
      final doc = snap.docs.first;
      return PatientAftercarePlan.fromJson({...doc.data(), 'id': doc.id});
    });
  }

  /// Streams all plans for a patient (all statuses).
  Stream<List<PatientAftercarePlan>> getAllPlans(String patientId) {
    Query<Map<String, dynamic>> query = _firestore
        .collection(_collection)
        .where('patientId', isEqualTo: patientId);
    // In staff/org-staff mode, scope to the assigned doctor/org so
    // the Firestore read rule (staffOf() == doctorId) can be satisfied.
    if (overrideDoctorUid != null) {
      query = query.where('doctorId', isEqualTo: overrideDoctorUid);
    }
    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) =>
                PatientAftercarePlan.fromJson({...d.data(), 'id': d.id}))
            .toList(growable: false));
  }

  /// Streams archived plans for a patient.
  Stream<List<PatientAftercarePlan>> getArchivedPlans(String patientId) {
    Query<Map<String, dynamic>> query = _firestore
        .collection(_collection)
        .where('patientId', isEqualTo: patientId)
        .where('status', isEqualTo: PlanStatus.archived.name);
    if (overrideDoctorUid != null) {
      query = query.where('doctorId', isEqualTo: overrideDoctorUid);
    }
    return query
        .orderBy('archivedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) =>
                PatientAftercarePlan.fromJson({...d.data(), 'id': d.id}))
            .toList(growable: false));
  }

  /// Streams draft plans for a patient.
  Stream<List<PatientAftercarePlan>> getDraftPlans(String patientId) {
    Query<Map<String, dynamic>> query = _firestore
        .collection(_collection)
        .where('patientId', isEqualTo: patientId)
        .where('status', isEqualTo: PlanStatus.draft.name);
    if (overrideDoctorUid != null) {
      query = query.where('doctorId', isEqualTo: overrideDoctorUid);
    }
    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) =>
                PatientAftercarePlan.fromJson({...d.data(), 'id': d.id}))
            .toList(growable: false));
  }

  /// Streams all plans created by a specific doctor (for overview).
  Stream<List<PatientAftercarePlan>> getPlansForDoctor(String doctorId) {
    return _firestore
        .collection(_collection)
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) =>
                PatientAftercarePlan.fromJson({...d.data(), 'id': d.id}))
            .toList(growable: false));
  }

  // ══════════════════════════════════════════════════════════════════════
  // Update
  // ══════════════════════════════════════════════════════════════════════

  /// Updates a plan (e.g. modified phases, title, surgery date).
  /// Increments [version] automatically. Only non-terminal plans.
  Future<void> updatePlan(PatientAftercarePlan plan) async {
    if (plan.id.isEmpty) return;
    if (plan.status == PlanStatus.archived ||
        plan.status == PlanStatus.completed ||
        plan.status == PlanStatus.cancelled) {
      return; // terminal states are read-only
    }

    final data = plan
        .copyWith(
          version: plan.version + 1,
          updatedAt: DateTime.now(),
        )
        .toJson();

    data['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.collection(_collection).doc(plan.id).update(data);
  }

  /// Deletes a draft plan (only drafts can be deleted).
  Future<void> deleteDraft(String planId) async {
    final doc = await _firestore.collection(_collection).doc(planId).get();
    if (!doc.exists) return;
    final status = doc.data()?['status'];
    if (status != PlanStatus.draft.name) return;
    await doc.reference.delete();
  }

  // ══════════════════════════════════════════════════════════════════════
  // Extended lifecycle
  // ══════════════════════════════════════════════════════════════════════

  final PlanChangeLogService _changeLog = PlanChangeLogService();

  /// Pauses an active plan temporarily.
  Future<void> pausePlan(String planId, {String? reason}) async {
    final uid = _auth.currentUser?.uid;
    final planRef = _firestore.collection(_collection).doc(planId);
    await _firestore.runTransaction((tx) async {
      final doc = await tx.get(planRef);
      if (!doc.exists) return;
      final status = doc.data()?['status'];
      if (status != PlanStatus.active.name) return;

      tx.update(planRef, {
        'status': PlanStatus.paused.name,
        'isActive': false,
        'pausedAt': FieldValue.serverTimestamp(),
        'pausedBy': uid,
        'pauseReason': ?reason,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });

    await _changeLog.log(
      planId: planId,
      changeType: PlanChangeType.statusChange,
      description: reason != null
          ? 'Plan pausiert: $reason'
          : 'Plan pausiert',
      details: {'from': 'active', 'to': 'paused'},
    );
  }

  /// Resumes a paused plan back to active.
  ///
  /// Atomically archives any other active plan for the same patient.
  Future<void> resumePlan(String planId) async {
    final uid = _auth.currentUser?.uid;
    final planRef = _firestore.collection(_collection).doc(planId);
    final planPreRead = await planRef.get();
    if (!planPreRead.exists) return;

    final planData = planPreRead.data()!;
    if (planData['status'] != PlanStatus.paused.name) return;

    final patientId = planData['patientId'] as String?;
    if (patientId == null) return;

    // Query for any currently active plan (could exist if another was
    // activated while this one was paused).
    final activeQuery = await _firestore
        .collection(_collection)
        .where('patientId', isEqualTo: patientId)
        .where('status', isEqualTo: PlanStatus.active.name)
        .limit(1)
        .get();

    await _firestore.runTransaction((tx) async {
      // Archive any currently active plan.
      if (activeQuery.docs.isNotEmpty) {
        final activeRef = activeQuery.docs.first.reference;
        final freshSnap = await tx.get(activeRef);
        if (freshSnap.exists &&
            freshSnap.data()?['status'] == PlanStatus.active.name) {
          tx.update(activeRef, {
            'status': PlanStatus.archived.name,
            'isActive': false,
            'archivedBy': uid,
            'archivedAt': FieldValue.serverTimestamp(),
            'archivedReason': 'Pausierter Plan fortgesetzt',
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      tx.update(planRef, {
        'status': PlanStatus.active.name,
        'isActive': true,
        'resumedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });

    await _changeLog.log(
      planId: planId,
      changeType: PlanChangeType.statusChange,
      description: 'Plan fortgesetzt',
      details: {'from': 'paused', 'to': 'active'},
    );
  }

  /// Completes a plan (manual doctor action).
  ///
  /// Valid from `active` or `paused` status.
  Future<void> completePlan(String planId, {String? summary}) async {
    final uid = _auth.currentUser?.uid;
    String? priorStatus;
    final planRef = _firestore.collection(_collection).doc(planId);
    await _firestore.runTransaction((tx) async {
      final doc = await tx.get(planRef);
      if (!doc.exists) return;

      final status = doc.data()?['status'];
      if (status != PlanStatus.active.name &&
          status != PlanStatus.paused.name) {
        return;
      }
      priorStatus = status?.toString();

      tx.update(planRef, {
        'status': PlanStatus.completed.name,
        'isActive': false,
        'completedAt': FieldValue.serverTimestamp(),
        'completedBy': uid,
        'completionSummary': ?summary,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });

    if (priorStatus == null) return;

    await _changeLog.log(
      planId: planId,
      changeType: PlanChangeType.statusChange,
      description: summary != null
          ? 'Plan abgeschlossen: $summary'
          : 'Plan abgeschlossen',
      details: {'from': priorStatus, 'to': 'completed'},
    );
  }

  /// Cancels a plan with an optional reason.
  ///
  /// Valid from `active` or `paused` status.
  Future<void> cancelPlan(String planId, {String? reason}) async {
    final uid = _auth.currentUser?.uid;
    String? priorStatus;
    final planRef = _firestore.collection(_collection).doc(planId);
    await _firestore.runTransaction((tx) async {
      final doc = await tx.get(planRef);
      if (!doc.exists) return;

      final status = doc.data()?['status'];
      if (status != PlanStatus.active.name &&
          status != PlanStatus.paused.name) {
        return;
      }
      priorStatus = status?.toString();

      tx.update(planRef, {
        'status': PlanStatus.cancelled.name,
        'isActive': false,
        'cancelledAt': FieldValue.serverTimestamp(),
        'cancelledBy': uid,
        'cancelReason': ?reason,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });

    if (priorStatus == null) return;

    await _changeLog.log(
      planId: planId,
      changeType: PlanChangeType.statusChange,
      description: reason != null
          ? 'Plan abgebrochen: $reason'
          : 'Plan abgebrochen',
      details: {'from': priorStatus, 'to': 'cancelled'},
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // Queries for new statuses
  // ══════════════════════════════════════════════════════════════════════

  /// Streams paused plans for a patient.
  Stream<List<PatientAftercarePlan>> getPausedPlans(String patientId) {
    return _firestore
        .collection(_collection)
        .where('patientId', isEqualTo: patientId)
        .where('status', isEqualTo: PlanStatus.paused.name)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) =>
                PatientAftercarePlan.fromJson({...d.data(), 'id': d.id}))
            .toList(growable: false));
  }

  /// Streams completed plans for a patient.
  Stream<List<PatientAftercarePlan>> getCompletedPlans(String patientId) {
    return _firestore
        .collection(_collection)
        .where('patientId', isEqualTo: patientId)
        .where('status', isEqualTo: PlanStatus.completed.name)
        .orderBy('completedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) =>
                PatientAftercarePlan.fromJson({...d.data(), 'id': d.id}))
            .toList(growable: false));
  }
}
