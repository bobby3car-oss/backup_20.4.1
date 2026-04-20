import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'local_storage_encryption.dart';

class GuestProfileStore {
  GuestProfileStore({
    FlutterSecureStorage? storage,
    LocalStorageEncryption? encryption,
  })  : _storage = storage ?? const FlutterSecureStorage(),
        _encryption = encryption ?? LocalStorageEncryption.instance;

  static const String secureProfileKey = 'guest_profile_data_secure';
  static const String legacyProfileKey = 'guest_profile_data';

  final FlutterSecureStorage _storage;
  final LocalStorageEncryption _encryption;

  Future<Map<String, dynamic>?> load() async {
    final raw = await _storage.read(key: secureProfileKey);
    if (raw != null && raw.isNotEmpty) {
      // Transparent migration: try decryption first, fall back to raw JSON
      // for payloads written by older versions before layered encryption.
      final plaintext = _encryption.isReady ? _encryption.decrypt(raw) : raw;
      return _decode(plaintext);
    }

    final prefs = await SharedPreferences.getInstance();
    final legacyRaw = prefs.getString(legacyProfileKey);
    if (legacyRaw == null || legacyRaw.isEmpty) {
      return null;
    }

    final decoded = _decode(legacyRaw);
    if (decoded == null) {
      await prefs.remove(legacyProfileKey);
      return null;
    }

    await save(decoded);
    await prefs.remove(legacyProfileKey);
    return decoded;
  }

  Future<void> save(Map<String, dynamic> data) async {
    final payload = jsonEncode(data);
    // Layered encryption: flutter_secure_storage already encrypts at rest,
    // but we add an app-level AES-256-GCM wrapper so a device backup, a
    // debugger attach, or a misconfigured backup policy cannot read guest
    // PII (Name, Geburtsdatum, OP-Art, ...).
    final stored = _encryption.isReady
        ? _encryption.encryptForStorage(payload, allowPlaintextFallback: false)
        : payload;
    await _storage.write(key: secureProfileKey, value: stored);
  }

  Future<void> clear() async {
    await _storage.delete(key: secureProfileKey);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(legacyProfileKey);
  }

  Map<String, dynamic>? _decode(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint(
          '[GuestProfileStore] invalid stored profile payload: $error',
        );
      }
    }
    return null;
  }
}
