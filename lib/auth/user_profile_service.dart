import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../firebase/bootstrap_service.dart';

/// Only this email is allowed to hold the admin role.
const allowedAdminEmail = 'jangoede2005@gmail.com';

enum AppUserRole { patient, doctor, family, admin, staff, organisation }

class UserProfileService {
  UserProfileService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance,
      _bootstrap = BootstrapService(
        firestore: firestore ?? FirebaseFirestore.instance,
      );

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final BootstrapService _bootstrap;

  Future<void> ensureUserDocExists(
    String uid, {
    String? email,
    String? displayName,
  }) async {
    await Future.wait([
      _bootstrap.ensureUserDocExists(
        uid,
        email: email,
        displayName: displayName,
        roleDefault: AppUserRole.patient.name,
      ),
      _bootstrap.ensurePatientRootExists(uid),
    ]);
  }

  Future<void> ensureCurrentUserDocExists() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await ensureUserDocExists(
      user.uid,
      email: user.email,
      displayName: user.displayName,
    );
  }

  Stream<Map<String, dynamic>?> getMyUserDoc() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream<Map<String, dynamic>?>.empty();
    }
    return _firestore
        .doc('users/${user.uid}')
        .snapshots()
        .map((snapshot) => snapshot.data());
  }

  Future<AppUserRole> getMyRole() async {
    final user = _auth.currentUser;
    if (user == null) return AppUserRole.patient;

    final userDoc = await _firestore.doc('users/${user.uid}').get();
    final role = _parseRole(userDoc.data()?['role']);
    return _enforceAdminRestriction(role);
  }

  Stream<AppUserRole> watchMyRole() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream<AppUserRole>.empty();
    }

    return _firestore.doc('users/${user.uid}').snapshots().map((snapshot) {
      final role = _parseRole(snapshot.data()?['role']);
      return _enforceAdminRestriction(role);
    });
  }

  /// Ensures only the allowed email can hold the admin role.
  /// Any other account with admin role gets actively demoted to patient
  /// both client-side and in Firestore.
  AppUserRole _enforceAdminRestriction(AppUserRole role) {
    if (role != AppUserRole.admin) return role;
    final user = _auth.currentUser;
    final email = user?.email?.toLowerCase().trim() ?? '';
    if (email == allowedAdminEmail) return role;

    // Unauthorized admin — actively revoke in Firestore.
    if (user != null) {
      _revokeUnauthorizedAdmin(user.uid);
    }
    return AppUserRole.patient;
  }

  /// Actively demotes an unauthorized admin in Firestore and revokes the
  /// custom claim via Cloud Function.  Fire-and-forget so it doesn't block
  /// the UI stream.
  bool _revokingAdmin = false;
  void _revokeUnauthorizedAdmin(String uid) {
    if (_revokingAdmin) return; // prevent duplicate calls
    _revokingAdmin = true;
    Future<void>(() async {
      try {
        // 1. Overwrite role in Firestore.
        await _firestore.doc('users/$uid').set(
          {'role': 'patient', 'updatedAt': FieldValue.serverTimestamp()},
          SetOptions(merge: true),
        );
        // 2. Ask backend to clear admin custom claim.
        await FirebaseFunctions.instanceFor(region: 'europe-west1')
            .httpsCallable('refreshAdminClaim')
            .call();
        // 3. Force token refresh so stale admin claim is gone.
        await _auth.currentUser?.getIdToken(true);
      } catch (_) {
        // Best-effort — server-side trigger will also catch this.
      } finally {
        _revokingAdmin = false;
      }
    });
  }

  Future<AppUserRole> roleForUid(String uid) async {
    final userDoc = await _firestore.doc('users/$uid').get();
    return _parseRole(userDoc.data()?['role']);
  }

  Future<int> getLinkedPatientsCount() async {
    final user = _auth.currentUser;
    if (user == null) return 0;

    final query = await _firestore
        .collectionGroup('links')
        .where('linkedUid', isEqualTo: user.uid)
        .where('status', isEqualTo: 'active')
        .get();
    return query.docs.length;
  }

  AppUserRole _parseRole(Object? raw) {
    final roleName = raw?.toString() ?? '';
    for (final role in AppUserRole.values) {
      if (role.name == roleName) return role;
    }
    return AppUserRole.patient;
  }

  Future<AppUserRole> get role => getMyRole();
}
