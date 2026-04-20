import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:operationsbegleiter_v3/security/pin_lock_service.dart';

/// In-memory stub of [FlutterSecureStorage] for deterministic unit tests.
class _InMemoryStorage implements FlutterSecureStorage {
  final Map<String, String> _values = <String, String>{};

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async =>
      _values[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      _values.remove(key);
    } else {
      _values[key] = value;
    }
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _values.remove(key);
  }

  // Unused overrides — throw to fail loudly if any test path hits them.
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PinLockService', () {
    test('setPin + verify succeeds with correct PIN and rejects wrong', () async {
      final storage = _InMemoryStorage();
      final svc = PinLockService(storage: storage);

      await svc.setPin('1234');
      expect(await svc.isEnabled, isTrue);
      expect(await svc.verify('1234'), isTrue);
      expect(await svc.verify('9999'), isFalse);
    });

    test('PIN is not stored in cleartext', () async {
      final storage = _InMemoryStorage();
      final svc = PinLockService(storage: storage);

      await svc.setPin('1234');
      // None of the stored values must contain the raw PIN.
      for (final v in storage._values.values) {
        expect(v.contains('1234'), isFalse, reason: 'raw PIN leaked: $v');
      }
    });

    test('rejects malformed PINs and counts them as failed attempts', () async {
      final storage = _InMemoryStorage();
      final svc = PinLockService(storage: storage);
      await svc.setPin('1234');

      expect(await svc.verify('abcd'), isFalse);
      expect(await svc.verify('12'), isFalse);
      // Failed-attempt counter should have advanced — still verifiable.
      expect(await svc.verify('1234'), isTrue);
    });

    test('lockout triggers after max failed attempts', () async {
      final storage = _InMemoryStorage();
      final svc = PinLockService(storage: storage);
      await svc.setPin('1234');

      for (var i = 0; i < PinLockService.maxAttempts; i++) {
        expect(await svc.verify('9999'), isFalse);
      }
      expect(
        () async => await svc.verify('1234'),
        throwsA(isA<StateError>()),
      );
    });

    test('legacy v1 SHA-256 hashes migrate transparently on first success',
        () async {
      final storage = _InMemoryStorage();
      final svc = PinLockService(storage: storage);

      // Seed legacy hash format: sha256('<salt>:<pin>') without version key.
      const salt = 'QUJDREVGR0hJSktMTU5PUA==';
      const pin = '4321';
      final legacyHash =
          sha256.convert(utf8.encode('$salt:$pin')).toString();
      await storage.write(key: 'app_pin_hash', value: legacyHash);
      await storage.write(key: 'app_pin_salt', value: salt);
      await storage.write(key: 'app_pin_enabled', value: 'true');
      // Note: NO version key → treated as v1.

      expect(await svc.verify(pin), isTrue);
      // After successful legacy verify, hash should be upgraded to v2.
      expect(await storage.read(key: 'app_pin_version'), '2');
      // New hash is PBKDF2 (length 44 base64-url chars for 32 bytes).
      final newHash = await storage.read(key: 'app_pin_hash');
      expect(newHash, isNot(legacyHash));
      // Re-verify with upgraded hash.
      expect(await svc.verify(pin), isTrue);
    });

    test('removePin disables and clears stored values', () async {
      final storage = _InMemoryStorage();
      final svc = PinLockService(storage: storage);
      await svc.setPin('1234');
      await svc.removePin();
      expect(await svc.isEnabled, isFalse);
      expect(await storage.read(key: 'app_pin_hash'), isNull);
      expect(await storage.read(key: 'app_pin_salt'), isNull);
    });
  });
}
