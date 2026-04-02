import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/staff_member.dart';
import '../domain/staff_permissions.dart';

/// Service for doctor-side staff management.
///
/// All mutating operations go through Cloud Functions to ensure
/// consistent server-side validation and dual-write (user doc + staff doc).
class StaffManagementService {
  StaffManagementService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
    this.overrideDoctorUid,
    this.collectionPrefix = 'doctors',
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  /// When set, queries use this doctor UID instead of the current user's UID.
  /// Used by staff managers who view the doctor's team.
  final String? overrideDoctorUid;

  /// The Firestore collection prefix for staff queries.
  /// Defaults to 'doctors'; use 'organisations' for org staff.
  final String collectionPrefix;

  String? get _effectiveDoctorUid => overrideDoctorUid ?? _auth.currentUser?.uid;

  Future<String?> _waitForEffectiveDoctorUid() async {
    final currentUid = _effectiveDoctorUid;
    if (currentUid != null) return currentUid;
    try {
      final user = await _auth
          .authStateChanges()
          .firstWhere((candidate) => candidate != null)
          .timeout(const Duration(seconds: 5));
      return overrideDoctorUid ?? user?.uid;
    } catch (_) {
      return _effectiveDoctorUid;
    }
  }

  // ── Queries ───────────────────────────────────────────────────

  /// Streams all staff members (active + disabled) for the doctor's team.
  Stream<List<StaffMember>> watchMyStaff() async* {
    final uid = await _waitForEffectiveDoctorUid();
    if (uid == null) return;

    yield* _firestore
        .collection('$collectionPrefix/$uid/staff')
        .where('status', whereIn: ['active', 'disabled'])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => StaffMember.fromJson(d.id, d.data()))
            .toList(growable: false));
  }

  // ── Mutations (Cloud Function backed) ─────────────────────────

  /// Creates a new staff member account (Firebase Auth + Firestore).
  Future<String> createStaffMember({
    required String name,
    required String email,
    required String password,
    StaffPermissions permissions = StaffPermissions.mfaDefault,
  }) async {
    try {
      final callable = _functions.httpsCallable('createStaffMember');
      final result = await callable.call<dynamic>({
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
        'permissions': permissions.toMap(),
      });

      final data = result.data as Map<String, dynamic>? ?? {};
      return (data['uid'] ?? '').toString();
    } on FirebaseFunctionsException {
      rethrow;
    }
  }

  /// Updates name and/or email of an existing staff member.
  Future<void> updateStaffMember({
    required String staffUid,
    String? name,
    String? email,
  }) async {
    try {
      final callable = _functions.httpsCallable('updateStaffMember');
      await callable.call<dynamic>({
        'staffUid': staffUid,
        if (name != null) 'name': name.trim(),
        if (email != null) 'email': email.trim(),
      });
    } on FirebaseFunctionsException {
      rethrow;
    }
  }

  /// Resets the password for a staff member.
  Future<void> resetStaffPassword({
    required String staffUid,
    required String newPassword,
  }) async {
    try {
      final callable = _functions.httpsCallable('resetStaffPassword');
      await callable.call<dynamic>({
        'staffUid': staffUid,
        'newPassword': newPassword,
      });
    } on FirebaseFunctionsException {
      rethrow;
    }
  }

  /// Enables or disables a staff member's Firebase Auth account.
  Future<void> toggleStaffDisabled({
    required String staffUid,
    required bool disabled,
  }) async {
    try {
      final callable = _functions.httpsCallable('toggleStaffDisabled');
      await callable.call<dynamic>({
        'staffUid': staffUid,
        'disabled': disabled,
      });
    } on FirebaseFunctionsException {
      rethrow;
    }
  }

  /// Updates permissions of an existing staff member.
  Future<void> updatePermissions(
    String staffUid,
    StaffPermissions permissions,
  ) async {
    final permMap = permissions.toMap();
    assert(() {
      // ignore: avoid_print
      print('[StaffService] updatePermissions staffUid=$staffUid perms=$permMap');
      return true;
    }());
    try {
      final callable = _functions.httpsCallable('updateStaffPermissions');
      final result = await callable.call<dynamic>({
        'staffUid': staffUid,
        'permissions': permMap,
      });
      // Verify the server echoed back the expected manageStaff value.
      final saved = (result.data as Map?)?['permissions'];
      if (saved is Map && permMap['manageStaff'] != null) {
        final echoedManage = saved['manageStaff']?.toString();
        if (echoedManage != permMap['manageStaff']) {
          throw Exception(
            'Server did not save manageStaff correctly '
            '(sent=${permMap['manageStaff']}, got=$echoedManage)',
          );
        }
      }
    } on FirebaseFunctionsException {
      rethrow;
    }
  }

  /// Removes a staff member (revokes access, disables auth, demotes to patient).
  Future<void> removeStaff(String staffUid) async {
    try {
      final callable = _functions.httpsCallable('removeStaff');
      await callable.call<dynamic>({'staffUid': staffUid});
    } on FirebaseFunctionsException {
      rethrow;
    }
  }
}
