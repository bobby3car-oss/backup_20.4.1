import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:operationsbegleiter_v3/security/local_storage_encryption.dart';

void main() {
  final encryption = LocalStorageEncryption.instance;
  final deterministicKey = base64Encode(
    Uint8List.fromList(List<int>.generate(32, (index) => index)),
  );

  setUp(() {
    encryption.clearTestingKey();
  });

  tearDown(() {
    encryption.clearTestingKey();
  });

  test('encryptForStorage round-trips with a deterministic testing key', () {
    encryption.setTestingKeyBase64(deterministicKey);
    const plaintext = '{"kind":"timeline","value":42}';

    final ciphertext = encryption.encryptForStorage(
      plaintext,
      allowPlaintextFallback: false,
    );

    expect(ciphertext, isNot(plaintext));
    expect(encryption.decrypt(ciphertext), plaintext);
  });

  test('encryptForStorage throws when plaintext fallback is disallowed', () {
    expect(
      () => encryption.encryptForStorage(
        'sensitive-payload',
        allowPlaintextFallback: false,
      ),
      throwsStateError,
    );
  });

  test('decrypt returns legacy plaintext unchanged', () {
    encryption.setTestingKeyBase64(deterministicKey);

    expect(
      encryption.decrypt('{"legacy":true}'),
      '{"legacy":true}',
    );
  });
}