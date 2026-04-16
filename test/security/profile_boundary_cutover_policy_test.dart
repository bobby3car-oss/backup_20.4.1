import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('firebase paths expose patient care profile helper', () {
    final paths = File('lib/firebase/firebase_paths.dart').readAsStringSync();

    expect(paths, contains("static const String careProfile = 'care_profile'"));
    expect(paths, contains('static String patientCareProfileDoc(String patientId) =>'));
  });

  test('profile settings stop persisting owner-only pii in the shared user doc', () {
    final screen = File('lib/screens/profile_settings_screen.dart')
        .readAsStringSync();

    expect(
      screen,
      isNot(contains("'emergencyContactPhone': enc.encryptField(user.uid")),
    );
    expect(
      screen,
      isNot(contains("'hospitalName': enc.encryptField(user.uid")),
    );
    expect(screen, contains('FirestorePaths.userPrivateProfileDoc(user.uid)'));
    expect(screen, contains('FirestorePaths.patientCareProfileDoc(user.uid)'));
  });

  test('doctor and family repositories read shared patient data from care profile', () {
    final doctorRepo = File(
      'lib/features/doctor_patients/data/doctor_patient_repository.dart',
    ).readAsStringSync();
    final familyRepo = File(
      'lib/features/family/data/family_repository.dart',
    ).readAsStringSync();

    expect(doctorRepo, contains('FirestorePaths.patientCareProfileDoc(patientId)'));
    expect(familyRepo, contains('FirestorePaths.patientCareProfileDoc(patientId)'));
  });

  test('backend exposes eu-pinned profile boundary backfill tooling', () {
    final functionsSource = File('functions/index.js').readAsStringSync();

    expect(functionsSource, contains('exports.backfillProfileBoundaries'));
    expect(
      functionsSource,
      matches(
        RegExp(
          'exports\\.backfillProfileBoundaries\\s*=\\s*onCall\\(\\s*\\{[^)]*region\\s*:\\s*["\\\']europe-west1["\\\']',
          dotAll: true,
        ),
      ),
    );
  });
}