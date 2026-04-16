import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../auth/auth_service.dart';
import '../../../firebase/app_functions.dart';
import '../../../security/field_encryption_service.dart';
import '../../doctor_patients/domain/linked_patient.dart';
import '../domain/org_doctor.dart';
import '../domain/org_join_request.dart';
import '../domain/org_patient.dart';
import '../domain/org_stats.dart';
import '../domain/organisation.dart';

/// Service for organisation-side management of doctors and org profile.
///
/// All mutating operations go through Cloud Functions for consistent
/// server-side validation and dual-write (user doc + org doc).
class OrganisationService {
  OrganisationService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _functions = functions ?? appFunctions();

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  String? get _orgUid => _auth.currentUser?.uid;

  Future<String?> _waitForOrgUid() async {
    final currentUid = _orgUid;
    if (currentUid != null) return currentUid;

    try {
      await AuthService.waitForWebSessionReady();
    } catch (_) {
      // Best effort only.
    }

    final readyUid = _orgUid;
    if (readyUid != null) return readyUid;

    try {
      final user = await _auth
          .idTokenChanges()
          .firstWhere((candidate) => candidate != null)
          .timeout(const Duration(seconds: 5));
      return user?.uid;
    } catch (_) {
      return _auth.currentUser?.uid;
    }
  }

  Stream<T> _watchWithOrgUid<T>(Stream<T> Function(String uid) build) async* {
    final uid = await _waitForOrgUid();
    if (uid == null) return;
    yield* build(uid);
  }

  // ── Organisation Profile ──────────────────────────────────────

  /// Streams the organisation profile document.
  Stream<Organisation?> watchOrganisation() {
    return _watchWithOrgUid((uid) {
      return _firestore.doc('organisations/$uid').snapshots().map((snap) {
        final data = snap.data();
        if (data == null) return null;
        return Organisation.fromJson(snap.id, data);
      });
    });
  }

  // ── Doctors Management ────────────────────────────────────────

  /// Streams all doctors belonging to this organisation.
  Stream<List<OrgDoctor>> watchDoctors() {
    return _watchWithOrgUid((uid) {
      return _firestore
          .collection('organisations/$uid/doctors')
          .orderBy('addedAt', descending: true)
          .snapshots()
          .map((snap) => snap.docs
              .map((d) => OrgDoctor.fromJson(d.id, d.data()))
              .toList(growable: false));
    });
  }

  /// Registers a new doctor under this organisation.
  Future<String> registerDoctor({
    required String name,
    required String email,
    required String password,
    required String specialty,
    String? practiceName,
  }) async {
    final callable = _functions.httpsCallable('registerOrgDoctor');
    final result = await callable.call<dynamic>({
      'name': name.trim(),
      'email': email.trim(),
      'password': password,
      'specialty': specialty,
      'practiceName': (practiceName ?? '').trim(),
    });
    final data = result.data as Map<String, dynamic>? ?? {};
    return (data['uid'] ?? '').toString();
  }

  /// Removes a doctor from this organisation (doctor becomes independent).
  Future<void> removeDoctor(String doctorUid) async {
    final callable = _functions.httpsCallable('removeOrgDoctor');
    await callable.call<dynamic>({'doctorUid': doctorUid});
  }

  // ── Aggregate Patient Data ────────────────────────────────────

  /// Returns UIDs of all active doctors in this organisation.
  Future<List<String>> getActiveDoctorUids() async {
    final uid = await _waitForOrgUid();
    if (uid == null) return [];

    final snap = await _firestore
        .collection('organisations/$uid/doctors')
        .where('status', isEqualTo: 'active')
        .get();
    return snap.docs.map((d) => d.id).toList();
  }

  /// Returns the total number of patients linked across all active doctors.
  ///
  /// Uses a Cloud Function for secure server-side aggregation (the org
  /// account does not have direct Firestore access to patient data).
  Future<int> getAggregatedPatientCount() async {
    final stats = await getOrgStats();
    return stats.totalPatients;
  }

  // ── Invite Code ───────────────────────────────────────────────

  /// Returns the organisation's permanent invite code (creates one if needed).
  Future<String> getInviteCode() async {
    await _waitForOrgUid();
    try {
      await _auth.currentUser?.getIdToken(true).timeout(const Duration(seconds: 3));
    } catch (_) {
      // Best effort only.
    }
    final callable = _functions.httpsCallable('getOrgInviteCode');
    final result = await callable.call<dynamic>(<String, dynamic>{});
    final data = Map<String, dynamic>.from(result.data as Map);
    final code = (data['code'] ?? '').toString();
    if (code.isEmpty) throw StateError('Kein Code erhalten');
    return code;
  }

  // ── Join Requests ─────────────────────────────────────────────

  /// Streams all join requests for this organisation (pending first).
  Stream<List<OrgJoinRequest>> watchJoinRequests() {
    return _watchWithOrgUid((uid) {
      return _firestore
          .collection('org_join_requests')
          .where('orgUid', isEqualTo: uid)
          .orderBy('requestedAt', descending: true)
          .snapshots()
          .map((snap) => snap.docs
              .map((d) => OrgJoinRequest.fromJson(d.id, d.data()))
              .toList(growable: false));
    });
  }

  /// Approves or rejects a join request.
  Future<void> resolveJoinRequest(
    String requestId, {
    required bool approved,
    String? rejectionReason,
  }) async {
    final callable = _functions.httpsCallable('resolveOrgJoinRequest');
    await callable.call<dynamic>({
      'requestId': requestId,
      'approved': approved,
      'rejectionReason': ?rejectionReason,
    });
  }

  // ── Aggregated Patient List ─────────────────────────────────────

  /// Returns all patients linked to any active doctor of this organisation.
  ///
  /// Uses a Cloud Function for secure server-side aggregation — the org
  /// account does not have direct Firestore access to patient data or links.
  Future<List<OrgPatient>> fetchAllOrgPatients() async {
    final callable = _functions.httpsCallable('getOrgPatients');
    final result = await callable.call<dynamic>(<String, dynamic>{});
    final data = Map<String, dynamic>.from(result.data as Map);
    final rawList = (data['patients'] as List?)?.cast<Map<dynamic, dynamic>>() ?? [];

    final enc = FieldEncryptionService.instance;
    final uid = _orgUid ?? '';
    return rawList.map((raw) {
      final m = Map<String, dynamic>.from(raw);
      DateTime? opDate;
      final opRaw = m['opDate'];
      if (opRaw is String && opRaw.isNotEmpty) {
        opDate = DateTime.tryParse(opRaw);
      }

      return OrgPatient(
        patientId: (m['patientId'] ?? '').toString(),
        patientName: enc.decryptField(uid, (m['patientName'] ?? '').toString()) ?? '',
        patientEmail: enc.decryptField(uid, (m['patientEmail'] ?? '').toString()) ?? '',
        doctorId: (m['doctorId'] ?? '').toString(),
        doctorName: enc.decryptField(uid, (m['doctorName'] ?? '').toString()) ?? '',
        opDate: opDate,
        diagnosis: (m['diagnosis'] ?? '').toString(),
      );
    }).toList(growable: false);
  }

  /// Fetches detailed patient data for a single patient via Cloud Function.
  ///
  /// Returns a map with keys: patient, timeline, appointments.
  Future<Map<String, dynamic>> fetchOrgPatientDetail(String patientId) async {
    final callable = _functions.httpsCallable('getOrgPatientDetail');
    final result = await callable.call<dynamic>(<String, dynamic>{
      'patientId': patientId,
    });
    return Map<String, dynamic>.from(result.data as Map);
  }

  // ── Organisation Stats ─────────────────────────────────────────

  /// Returns aggregated statistics across all active doctors and their
  /// patients via Cloud Function.
  Future<OrgStatsData> getOrgStats() async {
    final callable = _functions.httpsCallable('getOrgStats');
    final result = await callable.call<dynamic>(<String, dynamic>{});
    final data = Map<String, dynamic>.from(result.data as Map);

    final rawPhases = data['patientsByPhase'];
    final phaseMap = <PatientPhase, int>{};
    if (rawPhases is Map) {
      for (final entry in rawPhases.entries) {
        final phase = _parsePhase(entry.key.toString());
        phaseMap[phase] = (entry.value as int?) ?? 0;
      }
    }

    return OrgStatsData(
      totalPatients: (data['totalPatients'] as int?) ?? 0,
      activePatients: (data['activePatients'] as int?) ?? 0,
      patientsByPhase: phaseMap,
    );
  }

  static PatientPhase _parsePhase(String value) {
    return switch (value) {
      'preOp' => PatientPhase.preOp,
      'opDay' => PatientPhase.opDay,
      'postOp' => PatientPhase.postOp,
      'discharged' => PatientPhase.discharged,
      _ => PatientPhase.preOp,
    };
  }

  // ── Profile Update ─────────────────────────────────────────────

  /// Updates the organisation profile via Cloud Function.
  Future<void> updateProfile(Map<String, dynamic> fields) async {
    final callable = _functions.httpsCallable('updateOrgProfile');
    await callable.call<dynamic>(fields);
  }
}
