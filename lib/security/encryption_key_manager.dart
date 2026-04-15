import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

import 'field_encryption_service.dart';

/// Manages the shared encryption key lifecycle.
///
/// The app uses a single shared AES-256 key for all PII encryption. This key
/// is stored locally in SecureStorage. The Firestore backup at
/// `appConfig/encryption` is accessible **only** via the `getEncryptionKey`
/// Cloud Function — Firestore rules restrict direct client access to admin.
///
/// Flow:
///   1. On app start → try to load the key from local SecureStorage.
///   2. If not present → call the `getEncryptionKey` Cloud Function to
///      retrieve the encrypted backup, decrypt it with a derived wrapping
///      key, and store locally.
///   3. If no backup exists either (very first user ever) → generate a new
///      key, store locally, and push the encrypted backup to Firestore
///      via a Cloud Function that has admin SDK access.
class EncryptionKeyManager {
  EncryptionKeyManager({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _functions = functions ??
            FirebaseFunctions.instanceFor(region: 'europe-west1');

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;
  final FieldEncryptionService _encryption = FieldEncryptionService.instance;

  /// Firestore path for the shared key backup (admin-only access).
  static const _backupPath = 'appConfig/encryption';

  /// Generates a random salt for wrapping the backup key.
  String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Backs up the shared encryption key to Firestore.
  ///
  /// Uses admin SDK path — only works if the user is admin or if
  /// the document doesn't exist yet (first-time setup via Cloud Function).
  Future<void> backupKeyToFirestore(String uid) async {
    final keyBase64 = await _encryption.getKeyBase64();
    if (keyBase64 == null) return;

    final salt = _generateSalt();
    final backupKey = _encryption.deriveBackupKey(salt);
    final encryptedKey = _encryption.encryptKeyForBackup(keyBase64, backupKey);

    await _firestore.doc(_backupPath).set({
      'encryptedKey': encryptedKey,
      'salt': salt,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': uid,
      'version': 2,
    });

    if (kDebugMode) {
      debugPrint('[EncryptionKeyManager] Shared key backed up to Firestore');
    }
  }

  /// Attempts to restore the shared encryption key via Cloud Function.
  ///
  /// The Cloud Function reads the admin-only Firestore document and returns
  /// the encrypted key + salt. The client decrypts locally.
  ///
  /// Returns `true` if successful.
  Future<bool> restoreKeyFromFirestore(String uid) async {
    try {
      final callable = _functions.httpsCallable('getEncryptionKey');
      final result = await callable.call<Map<String, dynamic>>();
      final data = result.data;

      if (kDebugMode) {
        debugPrint(
          '[EncryptionKeyManager] CF response: exists=${data['exists']}, '
          'version=${data['version']}, '
          'hasSalt=${data['salt'] != null}, '
          'hasKey=${data['encryptedKey'] != null}',
        );
      }

      if (data['exists'] != true) return false;

      final encryptedKey = data['encryptedKey'] as String?;
      if (encryptedKey == null) return false;

      // Version 2 uses a random salt stored alongside the key.
      // Version 1 (legacy) used the hardcoded salt.
      final version = data['version'] as int? ?? 1;
      final String salt;
      if (version >= 2) {
        salt = data['salt'] as String? ?? '';
        if (salt.isEmpty) {
          if (kDebugMode) {
            debugPrint('[EncryptionKeyManager] ERROR: v2 key but salt is empty/null');
          }
          return false;
        }
      } else {
        // Legacy fallback for v1 keys.
        salt = 'OpBegleiter2025SharedFieldKey';
      }

      final backupKey = _encryption.deriveBackupKey(salt);
      final keyBase64 =
          _encryption.decryptKeyFromBackup(encryptedKey, backupKey);
      if (keyBase64 == null) {
        if (kDebugMode) {
          debugPrint('[EncryptionKeyManager] ERROR: decryptKeyFromBackup returned null');
        }
        return false;
      }

      await _encryption.restoreKey(uid, keyBase64);

      if (kDebugMode) {
        debugPrint(
            '[EncryptionKeyManager] Shared key restored via Cloud Function');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[EncryptionKeyManager] Restore failed: $e');
      }
      return false;
    }
  }

  /// Clears the locally cached key and re-fetches from the Cloud Function.
  ///
  /// Call when a key mismatch is detected (e.g. patient names still look
  /// encrypted after decryption).
  Future<bool> refreshKey(String uid) async {
    await _encryption.clearAll();
    final restored = await restoreKeyFromFirestore(uid);
    if (kDebugMode) {
      debugPrint(
        '[EncryptionKeyManager] Key refresh ${restored ? 'succeeded' : 'failed'}',
      );
    }
    return restored;
  }

  /// Ensures the shared encryption key is available — either locally or from
  /// the Cloud Function backup. If neither exists, generates a new key.
  ///
  /// On every call the server key is fetched and compared to the local one.
  /// If they differ the server key wins. This self-heals devices that
  /// previously cached a wrong key (e.g. when the CF was missing the salt).
  ///
  /// Call this after login / auth state change.
  Future<void> ensureKeyAvailable(String uid) async {
    // 1. Try loading the local key first (fast, offline-safe).
    await _encryption.initialise(uid);

    // 2. Always verify against the Cloud Function to catch key mismatches.
    //    restoreKeyFromFirestore overwrites the local key if successful.
    final restored = await restoreKeyFromFirestore(uid);
    if (restored) return;

    // 3. CF call failed (offline?) — if we already have a local key, use it.
    if (_encryption.isInitialised()) return;

    // 4. No key anywhere — generate a new one (first-ever user).
    await _encryption.generateAndStoreKey();
    await backupKeyToFirestore(uid);

    if (kDebugMode) {
      debugPrint('[EncryptionKeyManager] Generated new shared key (first user)');
    }
  }
}
