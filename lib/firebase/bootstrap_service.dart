import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_paths.dart';

class BootstrapService {
  BootstrapService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> ensurePatientRootExists(String uid) async {
    final ref = _firestore.doc(FirestorePaths.patientDoc(uid));
    final careProfileRef = _firestore.doc(
      FirestorePaths.patientCareProfileDoc(uid),
    );
    final doc = await ref.get();
    if (doc.exists) {
      await careProfileRef.set(<String, dynamic>{
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Doc already exists – no need to rewrite updatedAt on every startup.
      return;
    }

    await ref.set(<String, dynamic>{
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'profile': <String, dynamic>{},
      'settings': <String, dynamic>{},
    }, SetOptions(merge: true));

    await careProfileRef.set(<String, dynamic>{
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> ensureUserDocExists(
    String uid, {
    String? email,
    String? displayName,
    String roleDefault = 'patient',
  }) async {
    final ref = _firestore.doc(FirestorePaths.userDoc(uid));
    final privateRef = _firestore.doc(FirestorePaths.userPrivateProfileDoc(uid));

    final resolvedEmail = (email ?? '').trim();
    final resolvedDisplayName = (displayName ?? '').trim();

    final snapshots = await Future.wait([
      ref.get(),
      resolvedEmail.isNotEmpty ? privateRef.get() : Future.value(null),
    ]);
    final doc = snapshots[0] as DocumentSnapshot<Map<String, dynamic>>;
    final privateDoc = snapshots[1];

    if (!doc.exists) {
      await ref.set(<String, dynamic>{
        'displayName': resolvedDisplayName,
        'onboardingComplete': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    final existing = doc.data() ?? const <String, dynamic>{};
    final patch = <String, dynamic>{};
    final existingName = (existing['displayName'] ?? '').toString();
    if (existingName.isEmpty && resolvedDisplayName.isNotEmpty) {
      patch['displayName'] = resolvedDisplayName;
    }

    if (patch.isNotEmpty) {
      patch['updatedAt'] = FieldValue.serverTimestamp();
      await ref.set(patch, SetOptions(merge: true));
    }

    if (resolvedEmail.isEmpty) return;

    final privateData = privateDoc?.data() ?? const <String, dynamic>{};
    final existingEmail = (privateData['email'] ?? '').toString().trim();
    if (existingEmail.isNotEmpty) return;

    await privateRef.set(<String, dynamic>{
      'email': resolvedEmail,
      if (!(privateDoc?.exists ?? false)) 'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
