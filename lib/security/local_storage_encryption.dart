import 'dart:convert';

import 'package:encrypt/encrypt.dart' as aes;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// AES-256-GCM encryption for local JSON files stored in
/// [UserScopedStorage] directories.
///
/// Uses a device-local key stored in FlutterSecureStorage (Keychain / KeyStore)
/// that never leaves the device. This is separate from the shared PII
/// encryption key used for Firestore fields.
///
/// ### Ciphertext format
/// Base64-encoded blob: `[16-byte IV | ciphertext | GCM tag]`
///
/// ### Backward compatibility
/// [decrypt] gracefully handles plaintext input: if decryption fails, the
/// raw string is returned as-is. This allows transparent migration from
/// unencrypted to encrypted local storage.
class LocalStorageEncryption {
  LocalStorageEncryption._();

  static final LocalStorageEncryption instance = LocalStorageEncryption._();

  static const _storageKey = 'local_storage_aes_key';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  aes.Key? _key;

  /// Whether the encryption key is loaded and ready.
  bool get isReady => _key != null;

  /// Initialises the local encryption key. Generates a new one on first use.
  ///
  /// Call once during app startup, after Firebase init.
  Future<void> init() async {
    if (_key != null) return;

    try {
      final existing = await _secureStorage.read(key: _storageKey);
      if (existing != null) {
        _key = aes.Key.fromBase64(existing);
        return;
      }

      // First launch — generate and persist a new key.
      final key = aes.Key.fromSecureRandom(32); // 256-bit
      await _secureStorage.write(key: _storageKey, value: key.base64);
      _key = key;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LocalStorageEncryption] init failed: $e');
      }
    }
  }

  /// Encrypts [plaintext] and returns a Base64-encoded ciphertext.
  ///
  /// Returns the plaintext unchanged if the key is not initialised
  /// (graceful degradation during tests or early startup).
  String encrypt(String plaintext) {
    return encryptForStorage(plaintext, allowPlaintextFallback: true);
  }

  /// Encrypts [plaintext] for local persistence.
  ///
  /// When [allowPlaintextFallback] is false, missing encryption state fails
  /// closed so callers cannot silently persist sensitive data unencrypted.
  String encryptForStorage(
    String plaintext, {
    required bool allowPlaintextFallback,
  }) {
    final key = _key;
    if (key == null) {
      if (allowPlaintextFallback) return plaintext;
      throw StateError('Local storage encryption key is not initialized.');
    }

    return _encryptWithKey(key, plaintext);
  }

  String _encryptWithKey(aes.Key key, String plaintext) {
    final iv = aes.IV.fromSecureRandom(16);
    final encrypter = aes.Encrypter(aes.AES(key, mode: aes.AESMode.gcm));
    final encrypted = encrypter.encrypt(plaintext, iv: iv);

    final combined = Uint8List.fromList([
      ...iv.bytes,
      ...encrypted.bytes,
    ]);
    return base64Encode(combined);
  }

  @visibleForTesting
  void setTestingKeyBase64(String keyBase64) {
    _key = aes.Key.fromBase64(keyBase64);
  }

  @visibleForTesting
  void clearTestingKey() {
    _key = null;
  }

  /// Decrypts a Base64-encoded ciphertext. Returns plaintext.
  ///
  /// If the input is not valid ciphertext (e.g. legacy unencrypted JSON),
  /// the raw input is returned as-is for backward compatibility.
  String decrypt(String ciphertext) {
    final key = _key;
    if (key == null) return ciphertext;

    try {
      final combined = base64Decode(ciphertext);

      // Minimum: 16 (IV) + 1 (ciphertext byte) = 17 bytes.
      if (combined.length < 17) return ciphertext;

      final iv = aes.IV(Uint8List.fromList(combined.sublist(0, 16)));
      final encryptedBytes = combined.sublist(16);

      final encrypter = aes.Encrypter(aes.AES(key, mode: aes.AESMode.gcm));
      return encrypter.decrypt(
        aes.Encrypted(Uint8List.fromList(encryptedBytes)),
        iv: iv,
      );
    } catch (_) {
      // Not encrypted (legacy data) — return raw for backward compatibility.
      return ciphertext;
    }
  }
}
