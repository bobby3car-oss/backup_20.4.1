import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GuestProfileStore {
  GuestProfileStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const String secureProfileKey = 'guest_profile_data_secure';
  static const String legacyProfileKey = 'guest_profile_data';

  final FlutterSecureStorage _storage;

  Future<Map<String, dynamic>?> load() async {
    final raw = await _storage.read(key: secureProfileKey);
    if (raw != null && raw.isNotEmpty) {
      return _decode(raw);
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
    await _storage.write(key: secureProfileKey, value: jsonEncode(data));
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
