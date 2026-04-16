import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_paths.dart';
import '../security/field_encryption_service.dart';

class BootstrapService {
  BootstrapService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final FieldEncryptionService _enc = FieldEncryptionService.instance;

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
    final doc = await ref.get();

    final resolvedEmail = (email ?? '').trim();
    final resolvedDisplayName = (displayName ?? '').trim();

    if (!doc.exists) {
      await ref.set(<String, dynamic>{
        'displayName': _enc.encryptField(uid, resolvedDisplayName) ??
            resolvedDisplayName,
        'email': _enc.encryptField(uid, resolvedEmail) ?? resolvedEmail,
        'onboardingComplete': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return;
    }

    // Doc already exists — only update fields that are currently empty/null
    // in Firestore. Never overwrite existing encrypted values because the
    // local key might differ from the one that originally encrypted them,
    // which would corrupt the data.
    final existing = doc.data() ?? const <String, dynamic>{};
    final patch = <String, dynamic>{};

    final existingName = (existing['displayName'] ?? '').toString();
    if (existingName.isEmpty && resolvedDisplayName.isNotEmpty) {
      patch['displayName'] =
          _enc.encryptField(uid, resolvedDisplayName) ?? resolvedDisplayName;
    }

    final existingEmail = (existing['email'] ?? '').toString();
    if (existingEmail.isEmpty && resolvedEmail.isNotEmpty) {
      patch['email'] =
          _enc.encryptField(uid, resolvedEmail) ?? resolvedEmail;
    }

    if (patch.isNotEmpty) {
      patch['updatedAt'] = FieldValue.serverTimestamp();
      await ref.set(patch, SetOptions(merge: true));
    }
  }
}
