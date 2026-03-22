import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/org_doctor.dart';
import '../domain/org_join_request.dart';
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

  // ── Organisation Profile ──────────────────────────────────────

  /// Streams the organisation profile document.
  Stream<Organisation?> watchOrganisation() {
    final uid = _orgUid;
    if (uid == null) return const Stream.empty();

    return _firestore.doc('organisations/$uid').snapshots().map((snap) {
      final data = snap.data();
      if (data == null) return null;
      return Organisation.fromJson(snap.id, data);
    });
  }

  // ── Doctors Management ────────────────────────────────────────

  /// Streams all doctors belonging to this organisation.
  Stream<List<OrgDoctor>> watchDoctors() {
    final uid = _orgUid;
    if (uid == null) return const Stream.empty();

    return _firestore
        .collection('organisations/$uid/doctors')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => OrgDoctor.fromJson(d.id, d.data()))
            .toList(growable: false));
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
    final uid = _orgUid;
    if (uid == null) return [];

    final snap = await _firestore
        .collection('organisations/$uid/doctors')
        .where('status', isEqualTo: 'active')
        .get();
    return snap.docs.map((d) => d.id).toList();
  }

  // ── Invite Code ───────────────────────────────────────────────

  /// Returns the organisation's permanent invite code (creates one if needed).
  Future<String> getInviteCode() async {
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
    final uid = _orgUid;
    if (uid == null) return const Stream.empty();

    return _firestore
        .collection('org_join_requests')
        .where('orgUid', isEqualTo: uid)
        .orderBy('requestedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => OrgJoinRequest.fromJson(d.id, d.data()))
            .toList(growable: false));
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
}
