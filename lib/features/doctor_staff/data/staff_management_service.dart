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
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  /// When set, queries use this doctor UID instead of the current user's UID.
  /// Used by staff managers who view the doctor's team.
  final String? overrideDoctorUid;

  String? get _effectiveDoctorUid => overrideDoctorUid ?? _auth.currentUser?.uid;

  // ── Queries ───────────────────────────────────────────────────

  /// Streams all staff members (active + disabled) for the doctor's team.
  Stream<List<StaffMember>> watchMyStaff() {
    final uid = _effectiveDoctorUid;
    if (uid == null) return const Stream.empty();

    return _firestore
        .collection('doctors/$uid/staff')
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
    try {
      final callable = _functions.httpsCallable('updateStaffPermissions');
      await callable.call<dynamic>({
        'staffUid': staffUid,
        'permissions': permissions.toMap(),
      });
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
