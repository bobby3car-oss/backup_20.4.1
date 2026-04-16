import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../firebase/firebase_paths.dart';
import '../../../security/field_encryption_service.dart';

class ProfileBoundaryRepository {
  ProfileBoundaryRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const Set<String> _legacyEncryptedPrivateFields = {
    'email',
    'hospitalName',
    'doctorName',
    'emergencyContactName',
    'emergencyContactPhone',
  };

  Future<Map<String, dynamic>> getSelfProfile(String uid) async {
    final results = await Future.wait([
      _firestore.doc(FirestorePaths.userDoc(uid)).get(),
      _firestore.doc(FirestorePaths.userPrivateProfileDoc(uid)).get(),
      _firestore.doc(FirestorePaths.patientCareProfileDoc(uid)).get(),
    ]);

    final shellData = results[0].data() ?? const <String, dynamic>{};
    final privateData = _decryptPrivateProfile(uid, results[1].data());
    final careData = results[2].data() ?? const <String, dynamic>{};

    return <String, dynamic>{
      ...shellData,
      ...privateData,
      ...careData,
    };
  }

  Stream<Map<String, dynamic>?> watchSelfProfile(String uid) {
    late final StreamController<Map<String, dynamic>?> controller;
    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? shellSub;
    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? privateSub;
    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? careSub;

    Future<void> emitProfile() async {
      try {
        final profile = await getSelfProfile(uid);
        controller.add(profile.isEmpty ? null : profile);
      } catch (error, stackTrace) {
        controller.addError(error, stackTrace);
      }
    }

    controller = StreamController<Map<String, dynamic>?>(
      onListen: () {
        shellSub = _firestore
            .doc(FirestorePaths.userDoc(uid))
            .snapshots()
            .listen((_) => emitProfile(), onError: controller.addError);
        privateSub = _firestore
            .doc(FirestorePaths.userPrivateProfileDoc(uid))
            .snapshots()
            .listen((_) => emitProfile(), onError: controller.addError);
        careSub = _firestore
            .doc(FirestorePaths.patientCareProfileDoc(uid))
            .snapshots()
            .listen((_) => emitProfile(), onError: controller.addError);
        emitProfile();
      },
      onCancel: () async {
        await shellSub?.cancel();
        await privateSub?.cancel();
        await careSub?.cancel();
      },
    );

    return controller.stream;
  }

  Map<String, dynamic> _decryptPrivateProfile(
    String uid,
    Map<String, dynamic>? privateData,
  ) {
    if (privateData == null) return const <String, dynamic>{};
    return FieldEncryptionService.instance.decryptFields(
      uid,
      privateData,
      _legacyEncryptedPrivateFields,
    );
  }
}