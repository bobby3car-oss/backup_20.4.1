import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('auth bootstrap no longer restores the legacy shared key remotely', () {
    final authGate = File('lib/auth/auth_gate.dart').readAsStringSync();

    expect(authGate, isNot(contains('EncryptionKeyManager')));
    expect(authGate, isNot(contains('ensureKeyAvailable(user.uid)')));
  });

  test('bootstrap user shell keeps private email out of users docs', () {
    final bootstrap = File('lib/firebase/bootstrap_service.dart')
        .readAsStringSync();

    expect(bootstrap, contains('FirestorePaths.userPrivateProfileDoc(uid)'));
    expect(bootstrap, isNot(contains("'email': _enc.encryptField")));
    expect(bootstrap, isNot(contains("'displayName': _enc.encryptField")));
    expect(
      bootstrap,
      isNot(
        matches(
          RegExp(
            "await ref\\.set\\(<String, dynamic>\\{[^}]*'email':",
            dotAll: true,
          ),
        ),
      ),
    );
  });

  test('backend disables legacy getEncryptionKey restore path', () {
    final functionsSource = File('functions/index.js').readAsStringSync();

    expect(functionsSource, contains('exports.getEncryptionKey'));
    expect(
      functionsSource,
      contains('Legacy encryption-key restore has been disabled.'),
    );
    expect(
      functionsSource,
      isNot(contains('encryptedKey: data.encryptedKey || null')),
    );
  });

  test('profile boundary backfill normalizes legacy shared-key ciphertext', () {
    final functionsSource = File('functions/index.js').readAsStringSync();

    expect(functionsSource, contains('normalizeLegacySharedField'));
    expect(
      functionsSource,
      contains(
        'email: normalizeLegacySharedField(userData.email, legacySharedKey) ?? null',
      ),
    );
    expect(
      functionsSource,
      contains(
        'displayName: normalizeLegacySharedField(userData.displayName, legacySharedKey) ?? patientProfile.displayName ?? ""',
      ),
    );
  });
}