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
  static const _failedAttemptsKey = 'app_pin_failed_attempts';
  static const _lockoutUntilKey = 'app_pin_lockout_until';

  static const int maxAttempts = 5;
  static const Duration lockoutDuration = Duration(seconds: 30);

  final FlutterSecureStorage _storage;

  // ── public API ──────────────────────────────────────────────────────────

  /// Whether a PIN is currently set and enabled.
  Future<bool> get isEnabled async {
    final flag = await _storage.read(key: _pinEnabledKey);
    return flag == 'true';
  }

  /// Returns the remaining lockout duration, or [Duration.zero] if not locked.
  Future<Duration> get remainingLockout async {
    final raw = await _storage.read(key: _lockoutUntilKey);
    if (raw == null) return Duration.zero;
    final until = int.tryParse(raw) ?? 0;
    final remaining = until - DateTime.now().millisecondsSinceEpoch;
    return remaining > 0 ? Duration(milliseconds: remaining) : Duration.zero;
  }

  /// Set (or replace) the 4-digit PIN.
  Future<void> setPin(String pin) async {
    if (pin.length != 4 || int.tryParse(pin) == null) {
      throw ArgumentError('PIN must be exactly 4 digits');
    }
    final salt = _generateSalt();
    final hash = _hash(pin, salt);
    await _storage.write(key: _pinSaltKey, value: salt);
    await _storage.write(key: _pinHashKey, value: hash);
    await _storage.write(key: _pinEnabledKey, value: 'true');
    await _resetAttempts();
  }

  /// Verify a candidate PIN against the stored hash.
  ///
  /// Returns `false` and locks out after [maxAttempts] consecutive failures.
  /// Throws [StateError] if currently locked out.
  Future<bool> verify(String pin) async {
    // Validate input.
    if (pin.length != 4 || int.tryParse(pin) == null) return false;

    // Check lockout.
    final lockout = await remainingLockout;
    if (lockout > Duration.zero) {
      throw StateError(
        'PIN locked for ${lockout.inSeconds} seconds',
      );
    }

    final salt = await _storage.read(key: _pinSaltKey);
    final storedHash = await _storage.read(key: _pinHashKey);
    if (salt == null || storedHash == null) return false;

    if (_hash(pin, salt) == storedHash) {
      await _resetAttempts();
      return true;
    }

    // Wrong PIN – increment failure counter.
    await _recordFailedAttempt();
    return false;
  }

  /// Disable and remove the PIN.
  Future<void> removePin() async {
    await _storage.delete(key: _pinHashKey);
    await _storage.delete(key: _pinSaltKey);
    await _storage.write(key: _pinEnabledKey, value: 'false');
  }

  // ── internals ───────────────────────────────────────────────────────────

  Future<void> _recordFailedAttempt() async {
    final raw = await _storage.read(key: _failedAttemptsKey);
    final attempts = (int.tryParse(raw ?? '') ?? 0) + 1;
    await _storage.write(key: _failedAttemptsKey, value: '$attempts');
    if (attempts >= maxAttempts) {
      final until = DateTime.now().millisecondsSinceEpoch +
          lockoutDuration.inMilliseconds;
      await _storage.write(key: _lockoutUntilKey, value: '$until');
      await _storage.write(key: _failedAttemptsKey, value: '0');
    }
  }

  Future<void> _resetAttempts() async {
    await _storage.delete(key: _failedAttemptsKey);
    await _storage.delete(key: _lockoutUntilKey);
  }

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
