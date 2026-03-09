import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';

import '../domain/staff_invite.dart';
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
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  // ── Queries ───────────────────────────────────────────────────

  /// Streams all active staff members for the current doctor.
  Stream<List<StaffMember>> watchMyStaff() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _firestore
        .collection('doctors/$uid/staff')
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => StaffMember.fromJson(d.id, d.data()))
            .toList(growable: false));
  }

  /// Streams all pending staff invites for the current doctor.
  Stream<List<StaffInvite>> watchMyInvites() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _firestore
        .collection('staff_invites')
        .where('doctorUid', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => StaffInvite.fromJson(d.id, d.data()))
            .toList(growable: false));
  }

  // ── Mutations (Cloud Function backed) ─────────────────────────

  /// Creates a staff invite and returns the generated code.
  Future<String> createStaffInvite({
    StaffPermissions permissions = StaffPermissions.mfaDefault,
    int expiresInHours = 168,
  }) async {
    final callable = _functions.httpsCallable('createStaffInvite');
    final result = await callable.call<dynamic>({
      'permissions': permissions.toMap(),
      'expiresInHours': expiresInHours,
    });

    final data = result.data as Map<String, dynamic>? ?? {};
    return (data['code'] ?? '').toString();
  }

  /// Updates permissions of an existing staff member.
  Future<void> updatePermissions(
    String staffUid,
    StaffPermissions permissions,
  ) async {
    final callable = _functions.httpsCallable('updateStaffPermissions');
    await callable.call<dynamic>({
      'staffUid': staffUid,
      'permissions': permissions.toMap(),
    });
  }

  /// Removes a staff member (revokes access and demotes to patient).
  Future<void> removeStaff(String staffUid) async {
    final callable = _functions.httpsCallable('removeStaff');
    await callable.call<dynamic>({'staffUid': staffUid});
  }

  /// Accepts a staff invite (called from the staff-side).
  Future<void> acceptStaffInvite(String code) async {
    final callable = _functions.httpsCallable('acceptStaffInvite');
    await callable.call<dynamic>({
      'code': code.trim().toUpperCase(),
    });
  }

  /// Builds a deep-link URL for a staff invite code.
  String buildDeepLink(String code) {
    return 'https://operationsbegleiter-860e7.web.app/staff-invite/$code';
  }

  /// Shares a staff invite code via the system share sheet.
  Future<void> shareInvite(String code, String doctorName) async {
    final link = buildDeepLink(code);
    final text =
        'Sie wurden als Mitarbeiter/in von $doctorName in der '
        'Operationsbegleiter-App eingeladen.\n\n'
        'Code: $code\n'
        'Link: $link';
    await SharePlus.instance.share(ShareParams(text: text));
  }
}
