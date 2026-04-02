import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../auth/auth_service.dart';
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
        _functions = functions ?? FirebaseFunctions.instance;

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
    required String approbationNumber,
    String? practiceName,
    String? kvNumber,
  }) async {
    final callable = _functions.httpsCallable('registerOrgDoctor');
    final result = await callable.call<dynamic>({
      'name': name.trim(),
      'email': email.trim(),
      'password': password,
      'specialty': specialty,
      'approbationNumber': approbationNumber.trim(),
      'practiceName': (practiceName ?? '').trim(),
      'kvNumber': (kvNumber ?? '').trim(),
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
  /// Iterates over each active doctor and counts their active doctor-links
  /// via the `links` collectionGroup.
  Future<int> getAggregatedPatientCount() async {
    final doctorUids = await getActiveDoctorUids();
    if (doctorUids.isEmpty) return 0;

    final seen = <String>{};
    for (final doctorUid in doctorUids) {
      final snap = await _firestore
          .collectionGroup('links')
          .where('linkedUid', isEqualTo: doctorUid)
          .where('status', isEqualTo: 'active')
          .where('linkType', isEqualTo: 'doctor')
          .get();
      for (final doc in snap.docs) {
        final patientId = doc.reference.parent.parent?.id;
        if (patientId != null) seen.add(patientId);
      }
    }
    return seen.length;
  }

  /// Returns the total number of active red flags across all patients of all
  /// active doctors in the organisation.
  Future<int> getAggregatedRedFlagCount() async {
    final doctorUids = await getActiveDoctorUids();
    if (doctorUids.isEmpty) return 0;

    // Collect unique patient IDs first.
    final patientIds = <String>{};
    for (final doctorUid in doctorUids) {
      final snap = await _firestore
          .collectionGroup('links')
          .where('linkedUid', isEqualTo: doctorUid)
          .where('status', isEqualTo: 'active')
          .where('linkType', isEqualTo: 'doctor')
          .get();
      for (final doc in snap.docs) {
        final patientId = doc.reference.parent.parent?.id;
        if (patientId != null) patientIds.add(patientId);
      }
    }

    var total = 0;
    for (final pid in patientIds) {
      final flagSnap = await _firestore
          .collection('patients/$pid/red_flags')
          .where('status', isEqualTo: 'active')
          .get();
      total += flagSnap.docs.length;
    }
    return total;
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

  // ── Aggregated Patient Stream ──────────────────────────────────

  /// Streams all patients linked to any active doctor of this organisation.
  ///
  /// Uses the `links` collectionGroup to find active doctor links, then
  /// reads each patient's user doc for display data. Deduplicates by
  /// patient ID (keeps first doctor found).
  Stream<List<OrgPatient>> watchAllOrgPatients() {
    return _watchWithOrgUid((uid) {
      return _firestore
          .collection('organisations/$uid/doctors')
          .where('status', isEqualTo: 'active')
          .snapshots()
          .asyncMap((doctorSnap) async {
        final doctors = doctorSnap.docs;
        if (doctors.isEmpty) return <OrgPatient>[];

        final doctorMap = <String, String>{};
        for (final d in doctors) {
          doctorMap[d.id] = (d.data()['name'] ?? '').toString();
        }

        final seen = <String, String>{};
        for (final doctorUid in doctorMap.keys) {
          final linkSnap = await _firestore
              .collectionGroup('links')
              .where('linkedUid', isEqualTo: doctorUid)
              .where('status', isEqualTo: 'active')
              .where('linkType', isEqualTo: 'doctor')
              .get();
          for (final doc in linkSnap.docs) {
            final patientId = doc.reference.parent.parent?.id;
            if (patientId != null && !seen.containsKey(patientId)) {
              seen[patientId] = doctorUid;
            }
          }
        }

        if (seen.isEmpty) return <OrgPatient>[];

        final futures = seen.entries.map((entry) async {
          try {
            final patientDoc = await _firestore.doc('users/${entry.key}').get();
            final data = patientDoc.data();
            if (data == null) return null;
            return OrgPatient.fromUserDoc(
              entry.key,
              data,
              doctorId: entry.value,
              doctorName: doctorMap[entry.value] ?? '',
            );
          } catch (_) {
            return null;
          }
        });

        final results = await Future.wait(futures);
        final patients = results.whereType<OrgPatient>().toList(growable: false);
        patients.sort((a, b) => a.patientName
            .toLowerCase()
            .compareTo(b.patientName.toLowerCase()));
        return patients;
      });
    });
  }

  // ── Organisation Stats ─────────────────────────────────────────

  /// Returns aggregated statistics across all active doctors and their patients.
  Future<OrgStatsData> getOrgStats() async {
    final doctorUids = await getActiveDoctorUids();
    if (doctorUids.isEmpty) return OrgStatsData.empty;

    // Collect unique patient IDs.
    final patientIds = <String>{};
    for (final doctorUid in doctorUids) {
      final snap = await _firestore
          .collectionGroup('links')
          .where('linkedUid', isEqualTo: doctorUid)
          .where('status', isEqualTo: 'active')
          .where('linkType', isEqualTo: 'doctor')
          .get();
      for (final doc in snap.docs) {
        final pid = doc.reference.parent.parent?.id;
        if (pid != null) patientIds.add(pid);
      }
    }

    if (patientIds.isEmpty) return OrgStatsData.empty;

    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    var totalRedFlags = 0;
    var activePatients = 0;
    var complianceSum = 0.0;
    final phaseMap = <PatientPhase, int>{};

    for (final pid in patientIds) {
      // ── Read user doc for opDate + lastEntryAt ─────────
      final userDoc = await _firestore.doc('users/$pid').get();
      final data = userDoc.data() ?? {};

      DateTime? opDate;
      final opRaw = data['opDate'];
      if (opRaw is Timestamp) {
        opDate = opRaw.toDate();
      } else if (opRaw is String) {
        opDate = DateTime.tryParse(opRaw);
      }

      // Phase
      final phase = _computePhase(opDate);
      phaseMap[phase] = (phaseMap[phase] ?? 0) + 1;

      // Compliance (progress)
      complianceSum += _computeProgress(opDate);

      // Active in last 7 days – check timeline entries.
      final recentSnap = await _firestore
          .collection('patients/$pid/timeline')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();
      if (recentSnap.docs.isNotEmpty) {
        final ts = recentSnap.docs.first.data()['createdAt'];
        DateTime? lastEntry;
        if (ts is Timestamp) lastEntry = ts.toDate();
        if (lastEntry != null && lastEntry.isAfter(sevenDaysAgo)) {
          activePatients++;
        }
      }

      // Red flags
      final flagSnap = await _firestore
          .collection('patients/$pid/red_flags')
          .where('status', isEqualTo: 'active')
          .get();
      totalRedFlags += flagSnap.docs.length;
    }

    return OrgStatsData(
      totalPatients: patientIds.length,
      activePatients: activePatients,
      totalRedFlags: totalRedFlags,
      averageCompliance:
          patientIds.isNotEmpty ? complianceSum / patientIds.length : 0,
      patientsByPhase: phaseMap,
    );
  }

  static PatientPhase _computePhase(DateTime? opDate) {
    if (opDate == null) return PatientPhase.preOp;
    final daysSinceOp = DateTime.now().difference(opDate).inDays;
    if (daysSinceOp < 0) return PatientPhase.preOp;
    if (daysSinceOp == 0) return PatientPhase.opDay;
    if (daysSinceOp <= 42) return PatientPhase.postOp;
    return PatientPhase.discharged;
  }

  static double _computeProgress(DateTime? opDate) {
    if (opDate == null) return 0;
    final daysSinceOp = DateTime.now().difference(opDate).inDays;
    if (daysSinceOp < 0) return 0;
    return (daysSinceOp / 42.0).clamp(0, 1);
  }
}
