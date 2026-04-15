import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:flutter/foundation.dart' hide Key;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';

/// AES-256-GCM encryption for personally identifiable fields stored in
/// Firestore. Only *identifying* data (name, email, phone, address, emergency
/// contacts) is encrypted — health data stays in plaintext but is
/// pseudonymised (no name/email stored alongside it).
///
/// ### Encrypted field format
/// The ciphertext is stored as a single Base64-encoded blob that packs:
///   `[16-byte IV | ciphertext | 16-byte GCM tag]`
///
/// ### Key management
/// A single 256-bit **shared app key** is used for all PII encryption.
/// The key is stored:
///   1. Locally in `FlutterSecureStorage` (Keychain / KeyStore).
///   2. Encrypted in Firestore at `appConfig/encryption` — wrapped with a key
///      derived from a constant + a per-installation salt (defence in depth).
///
/// Using a shared key allows cross-user reads (doctor→patient, family→patient,
/// admin→all users) while still protecting data at rest against Firestore leaks.
class FieldEncryptionService {
  FieldEncryptionService._();

  static final FieldEncryptionService instance = FieldEncryptionService._();

  static const _storageKey = 'enc_shared_key';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// Cached shared encryption key.
  Key? _sharedKey;

  // ---------------------------------------------------------------------------
  // Key lifecycle
  // ---------------------------------------------------------------------------

  /// Initialises (or loads) the shared encryption key.
  ///
  /// Call during app startup after authentication.
  Future<void> initialise(String uid) async {
    if (_sharedKey != null) return;

    final existing = await _secureStorage.read(key: _storageKey);
    if (existing != null) {
      _sharedKey = Key.fromBase64(existing);
      return;
    }

    // Key not available locally — callers should try restoring from Firestore
    // via EncryptionKeyManager.ensureKeyAvailable() before reaching here.
  }

  /// Returns `true` when the shared key is loaded and ready.
  bool isInitialised([String? uid]) => _sharedKey != null;

  /// Clears the in-memory cached key (call on logout).
  void clearCache() => _sharedKey = null;

  /// Clears both the in-memory key AND the persisted key in SecureStorage.
  ///
  /// Use when a key mismatch is detected (wrong key restored from a previous
  /// failed attempt). After calling this, [ensureKeyAvailable] will re-fetch
  /// the correct key from the Cloud Function.
  Future<void> clearAll() async {
    _sharedKey = null;
    await _secureStorage.delete(key: _storageKey);
  }

  /// Returns the raw key bytes for backup purposes only.
  Future<String?> getKeyBase64([String? uid]) async {
    return _secureStorage.read(key: _storageKey);
  }

  /// Generates a new shared key and stores it locally.
  ///
  /// Only call this from [EncryptionKeyManager] when no key exists anywhere.
  Future<Key> generateAndStoreKey() async {
    final key = Key.fromSecureRandom(32); // 256-bit
    await _secureStorage.write(key: _storageKey, value: key.base64);
    _sharedKey = key;
    return key;
  }

  /// Restores a key from a backup (e.g. from Firestore).
  Future<void> restoreKey(String uid, String keyBase64) async {
    await _secureStorage.write(key: _storageKey, value: keyBase64);
    _sharedKey = Key.fromBase64(keyBase64);
  }

  // ---------------------------------------------------------------------------
  // Encrypt / Decrypt
  // ---------------------------------------------------------------------------

  /// Encrypts a plaintext string. Returns a Base64-encoded ciphertext.
  ///
  /// The [uid] parameter is accepted for API compatibility but the encryption
  /// uses the shared key, not a per-user key.
  String? encryptField(String uid, String? plaintext) {
    if (plaintext == null || plaintext.isEmpty) return null;

    final key = _sharedKey;
    if (key == null) {
      if (kDebugMode) {
        debugPrint('[FieldEncryption] WARNING: no shared key – returning '
            'plaintext (should only happen in tests)');
      }
      return plaintext;
    }

    final iv = IV.fromSecureRandom(16);
    final encrypter = Encrypter(AES(key, mode: AESMode.gcm));
    final encrypted = encrypter.encrypt(plaintext, iv: iv);

    // Pack IV + ciphertext + tag into one blob.
    final combined = Uint8List.fromList([
      ...iv.bytes,
      ...encrypted.bytes,
    ]);
    return base64Encode(combined);
  }

  /// Decrypts a Base64-encoded ciphertext. Returns the plaintext.
  ///
  /// The [uid] parameter is accepted for API compatibility but the encryption
  /// uses the shared key.
  ///
  /// If the value looks like it was never encrypted (no Base64 / wrong
  /// length), it is returned as-is for backwards compatibility during
  /// migration.
  String? decryptField(String uid, String? ciphertext) {
    if (ciphertext == null || ciphertext.isEmpty) return null;

    final key = _sharedKey;
    if (key == null) {
      if (kDebugMode) {
        debugPrint('[FieldEncryption] WARNING: no shared key – returning '
            'raw value');
      }
      return ciphertext;
    }

    try {
      final combined = base64Decode(ciphertext);

      // Minimum: 16 (IV) + 1 (ciphertext byte) = 17 bytes.
      if (combined.length < 17) return ciphertext; // Not encrypted.

      final iv = IV(Uint8List.fromList(combined.sublist(0, 16)));
      final encryptedBytes = combined.sublist(16);

      final encrypter = Encrypter(AES(key, mode: AESMode.gcm));
      return encrypter.decrypt(
        Encrypted(Uint8List.fromList(encryptedBytes)),
        iv: iv,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[FieldEncryption] decryptField FAILED for uid=$uid '
            '(ciphertext length=${ciphertext.length}): $e '
            '— key may be wrong. Returning raw value.');
      }
      // Value is not encrypted or key is wrong — return raw.
      return ciphertext;
    }
  }

  // ---------------------------------------------------------------------------
  // Convenience: encrypt / decrypt a set of named fields at once
  // ---------------------------------------------------------------------------

  /// Encrypts only the fields listed in [fieldNames] within [data].
  /// Returns a new map with encrypted values.
  Map<String, dynamic> encryptFields(
    String uid,
    Map<String, dynamic> data,
    Set<String> fieldNames,
  ) {
    final result = Map<String, dynamic>.from(data);
    for (final field in fieldNames) {
      final value = data[field];
      if (value is String) {
        result[field] = encryptField(uid, value);
      }
    }
    return result;
  }

  /// Decrypts only the fields listed in [fieldNames] within [data].
  /// Returns a new map with decrypted values.
  Map<String, dynamic> decryptFields(
    String uid,
    Map<String, dynamic> data,
    Set<String> fieldNames,
  ) {
    final result = Map<String, dynamic>.from(data);
    for (final field in fieldNames) {
      final value = data[field];
      if (value is String) {
        result[field] = decryptField(uid, value);
      }
    }
    return result;
  }

  // ---------------------------------------------------------------------------
  // Key backup helpers
  // ---------------------------------------------------------------------------

  /// Derives a wrapping key from a constant + salt for encrypting the shared
  /// key before storing it in Firestore.
  Key deriveBackupKey(String salt) {
    final combined = utf8.encode('opbegleiter:$salt:shared_field_encryption');
    final hash = sha256.convert(combined);
    return Key(Uint8List.fromList(hash.bytes));
  }

  /// Encrypts the master key for Firestore backup.
  String encryptKeyForBackup(String keyBase64, Key backupKey) {
    final iv = IV.fromSecureRandom(16);
    final encrypter = Encrypter(AES(backupKey, mode: AESMode.gcm));
    final encrypted = encrypter.encrypt(keyBase64, iv: iv);
    final combined = Uint8List.fromList([
      ...iv.bytes,
      ...encrypted.bytes,
    ]);
    return base64Encode(combined);
  }

  /// Decrypts the master key from Firestore backup.
  String? decryptKeyFromBackup(String encryptedKey, Key backupKey) {
    try {
      final combined = base64Decode(encryptedKey);
      if (combined.length < 17) return null;

      final iv = IV(Uint8List.fromList(combined.sublist(0, 16)));
      final encryptedBytes = combined.sublist(16);

      final encrypter = Encrypter(AES(backupKey, mode: AESMode.gcm));
      return encrypter.decrypt(
        Encrypted(Uint8List.fromList(encryptedBytes)),
        iv: iv,
      );
    } catch (_) {
      return null;
    }
  }
}

/// The set of field names in Firestore `users/{uid}` documents that contain
/// personally identifying information and must be encrypted at rest.
const Set<String> kEncryptedUserFields = {
  'displayName',
  'email',
  'hospitalName',
  'doctorName',
  'emergencyContactName',
  'emergencyContactPhone',
};

/// PII field names stored in doctor documents.
const Set<String> kEncryptedDoctorFields = {
  'displayName',
  'email',
  'phone',
  'practiceAddress',
  'practiceName',
};

/// PII field names stored in staff member documents.
const Set<String> kEncryptedStaffFields = {
  'displayName',
  'email',
};

/// PII field names stored in organisation documents.
const Set<String> kEncryptedOrgFields = {
  'name',
  'email',
  'contactPerson',
  'phone',
  'address',
};

/// PII field names stored in appointment documents.
const Set<String> kEncryptedAppointmentFields = {
  'doctorName',
};

/// PII field names stored in observation documents.
const Set<String> kEncryptedObservationFields = {
  'authorName',
};

/// PII field names in link documents.
const Set<String> kEncryptedLinkFields = {
  'linkedName',
  'linkedEmail',
  'patientName',
  'patientEmail',
};

/// PII field names in audit log documents.
const Set<String> kEncryptedAuditFields = {
  'email',
};

/// PII field names in notification documents.
const Set<String> kEncryptedNotificationFields = {
  'patientName',
};
