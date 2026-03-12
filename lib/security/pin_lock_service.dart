import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Manages a local 4-digit PIN for app-level locking.
///
/// The PIN is hashed with SHA-256 + salt before storage so the raw PIN
/// is never persisted.  All state lives on-device only.
class PinLockService {
  PinLockService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _pinHashKey = 'app_pin_hash';
  static const _pinSaltKey = 'app_pin_salt';
  static const _pinEnabledKey = 'app_pin_enabled';

  final FlutterSecureStorage _storage;

  // ── public API ──────────────────────────────────────────────────────────

  /// Whether a PIN is currently set and enabled.
  Future<bool> get isEnabled async {
    final flag = await _storage.read(key: _pinEnabledKey);
    return flag == 'true';
  }

  /// Set (or replace) the 4-digit PIN.
  Future<void> setPin(String pin) async {
    assert(pin.length == 4 && int.tryParse(pin) != null);
    final salt = _generateSalt();
    final hash = _hash(pin, salt);
    await _storage.write(key: _pinSaltKey, value: salt);
    await _storage.write(key: _pinHashKey, value: hash);
    await _storage.write(key: _pinEnabledKey, value: 'true');
  }

  /// Verify a candidate PIN against the stored hash.
  Future<bool> verify(String pin) async {
    final salt = await _storage.read(key: _pinSaltKey);
    final storedHash = await _storage.read(key: _pinHashKey);
    if (salt == null || storedHash == null) return false;
    return _hash(pin, salt) == storedHash;
  }

  /// Disable and remove the PIN.
  Future<void> removePin() async {
    await _storage.delete(key: _pinHashKey);
    await _storage.delete(key: _pinSaltKey);
    await _storage.write(key: _pinEnabledKey, value: 'false');
  }

  // ── internals ───────────────────────────────────────────────────────────

  String _generateSalt([int length = 16]) {
    final rng = Random.secure();
    final bytes = List<int>.generate(length, (_) => rng.nextInt(256));
    return base64Url.encode(bytes);
  }

  String _hash(String pin, String salt) {
    final bytes = utf8.encode('$salt:$pin');
    return sha256.convert(bytes).toString();
  }
}
