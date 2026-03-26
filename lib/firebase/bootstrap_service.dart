import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_paths.dart';

class BootstrapService {
  BootstrapService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> ensurePatientRootExists(String uid) async {
    final ref = _firestore.doc(FirestorePaths.patientDoc(uid));
    final doc = await ref.get();
    if (doc.exists) {
      // Doc already exists – no need to rewrite updatedAt on every startup.
      return;
    }

    await ref.set(<String, dynamic>{
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'profile': <String, dynamic>{},
      'settings': <String, dynamic>{},
    }, SetOptions(merge: true));
  }

  Future<void> ensureUserDocExists(
    String uid, {
    String? email,
    String? displayName,
    String roleDefault = 'patient',
  }) async {
    final ref = _firestore.doc(FirestorePaths.userDoc(uid));
    final doc = await ref.get();

    final resolvedEmail = (email ?? '').trim();
    final resolvedDisplayName = (displayName ?? '').trim();

    if (!doc.exists) {
      // Note: 'role' is a server-only field in Firestore rules.
      // The app defaults to 'patient' when no role is set.
      await ref.set(<String, dynamic>{
        'displayName': resolvedDisplayName,
        'email': resolvedEmail,
        'onboardingComplete': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return;
    }

    final patch = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (resolvedDisplayName.isNotEmpty) {
      patch['displayName'] = resolvedDisplayName;
    }
    if (resolvedEmail.isNotEmpty) {
      patch['email'] = resolvedEmail;
    }

    await ref.set(patch, SetOptions(merge: true));
  }
}
