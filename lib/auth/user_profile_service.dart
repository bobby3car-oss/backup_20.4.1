import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../firebase/bootstrap_service.dart';

enum AppUserRole { patient, doctor, family, admin, staff }

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
    await _bootstrap.ensureUserDocExists(
      uid,
      email: email,
      displayName: displayName,
      roleDefault: AppUserRole.patient.name,
    );
    await _bootstrap.ensurePatientRootExists(uid);
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
    return _parseRole(userDoc.data()?['role']);
  }

  Stream<AppUserRole> watchMyRole() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream<AppUserRole>.empty();
    }

    return _firestore.doc('users/${user.uid}').snapshots().map((snapshot) {
      final role = _parseRole(snapshot.data()?['role']);
      return role;
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
