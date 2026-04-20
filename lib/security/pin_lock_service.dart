import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Manages a local 4-digit PIN for app-level locking.
///
/// The PIN is stretched with PBKDF2-HMAC-SHA256 (100 000 iterations) and a
/// 16-byte random salt before storage so the raw PIN is never persisted and
/// brute-forcing the 10 000-value PIN space is deliberately slow even if the
/// hash + salt leak. All state lives on-device only in the platform secure
/// storage (Keychain / KeyStore).
class PinLockService {
  PinLockService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _pinHashKey = 'app_pin_hash';
  static const _pinSaltKey = 'app_pin_salt';
  static const _pinEnabledKey = 'app_pin_enabled';
  static const _pinVersionKey = 'app_pin_version';
  static const _failedAttemptsKey = 'app_pin_failed_attempts';
  static const _lockoutUntilKey = 'app_pin_lockout_until';
  static const _lockoutCountKey = 'app_pin_lockout_count';

  static const int maxAttempts = 5;
  // Base lockout: 5 min. Doubles each lockout cycle (5 → 10 → 20 ... capped at 8 h).
  static const Duration _baseLockoutDuration = Duration(minutes: 5);

  // PBKDF2 parameters. OWASP 2023 recommends ≥ 600k for SHA-256, but a
  // 4-digit PIN has only 10 000 possibilities so 100k iterations already push
  // an offline attack past several minutes per PIN on mobile hardware while
  // staying responsive (< 200 ms) for legitimate verify calls.
  static const int _pbkdf2Iterations = 100000;
  static const int _pbkdf2OutputBytes = 32; // 256 bits
  static const int _currentVersion = 2;

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
    await _storage.write(key: _pinVersionKey, value: '$_currentVersion');
    await _resetAttempts();
  }

  /// Verify a candidate PIN against the stored hash.
  ///
  /// Returns `false` and locks out after [maxAttempts] consecutive failures.
  /// Throws [StateError] if currently locked out.
  Future<bool> verify(String pin) async {
    // Check lockout first so invalid input during lockout still surfaces the
    // lockout to the caller (prevents enumeration + keeps UX consistent).
    final lockout = await remainingLockout;
    if (lockout > Duration.zero) {
      throw StateError(
        'PIN locked for ${lockout.inSeconds} seconds',
      );
    }

    // Validate input.
    if (pin.length != 4 || int.tryParse(pin) == null) {
      // Count malformed input as a failed attempt to throttle probing.
      await _recordFailedAttempt();
      return false;
    }

    final salt = await _storage.read(key: _pinSaltKey);
    final storedHash = await _storage.read(key: _pinHashKey);
    if (salt == null || storedHash == null) return false;

    final versionRaw = await _storage.read(key: _pinVersionKey);
    final version = int.tryParse(versionRaw ?? '') ?? 1;

    final candidate = version >= _currentVersion
        ? _hash(pin, salt)
        : _legacyHash(pin, salt);
    final ok = _constantTimeEquals(candidate, storedHash);

    if (ok) {
      // Transparent upgrade: if the stored hash is the legacy SHA-256 format,
      // re-hash with PBKDF2 so the next verify runs against the hardened form.
      if (version < _currentVersion) {
        final newSalt = _generateSalt();
        await _storage.write(key: _pinSaltKey, value: newSalt);
        await _storage.write(key: _pinHashKey, value: _hash(pin, newSalt));
        await _storage.write(key: _pinVersionKey, value: '$_currentVersion');
      }
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
    await _storage.delete(key: _pinVersionKey);
    await _storage.write(key: _pinEnabledKey, value: 'false');
  }

  // ── internals ───────────────────────────────────────────────────────────

  Future<void> _recordFailedAttempt() async {
    final raw = await _storage.read(key: _failedAttemptsKey);
    final attempts = (int.tryParse(raw ?? '') ?? 0) + 1;
    await _storage.write(key: _failedAttemptsKey, value: '$attempts');
    if (attempts >= maxAttempts) {
      // Exponential backoff: 5 min → 10 min → 20 min … capped at 8 hours.
      final countRaw = await _storage.read(key: _lockoutCountKey);
      final lockoutCount = (int.tryParse(countRaw ?? '') ?? 0) + 1;
      final multiplier = (1 << (lockoutCount - 1)).clamp(1, 96); // max 96×5min = 8h
      final lockoutMs = _baseLockoutDuration.inMilliseconds * multiplier;
      final until = DateTime.now().millisecondsSinceEpoch + lockoutMs;
      await _storage.write(key: _lockoutCountKey, value: '$lockoutCount');
      await _storage.write(key: _lockoutUntilKey, value: '$until');
      await _storage.write(key: _failedAttemptsKey, value: '0');
    }
  }

  Future<void> _resetAttempts() async {
    await _storage.delete(key: _failedAttemptsKey);
    await _storage.delete(key: _lockoutUntilKey);
    await _storage.delete(key: _lockoutCountKey);
  }

  String _generateSalt([int length = 16]) {
    final rng = Random.secure();
    final bytes = List<int>.generate(length, (_) => rng.nextInt(256));
    return base64Url.encode(bytes);
  }

  /// Current PBKDF2-HMAC-SHA256 stretching.
  String _hash(String pin, String salt) {
    final saltBytes = base64Url.decode(salt);
    final derived = _pbkdf2HmacSha256(
      password: utf8.encode(pin),
      salt: saltBytes,
      iterations: _pbkdf2Iterations,
      dkLen: _pbkdf2OutputBytes,
    );
    return base64Url.encode(derived);
  }

  /// Legacy v1 format (plain SHA-256) retained for one-time migration.
  String _legacyHash(String pin, String salt) {
    final bytes = utf8.encode('$salt:$pin');
    return sha256.convert(bytes).toString();
  }

  /// Constant-time string comparison to avoid timing side channels.
  bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }
}

/// PBKDF2-HMAC-SHA256 built on top of `package:crypto`'s [Hmac]. SHA-256
/// output is 32 bytes, so we derive the key as a sequence of
/// `ceil(dkLen / 32)` HMAC blocks per RFC 2898 §5.2.
List<int> _pbkdf2HmacSha256({
  required List<int> password,
  required List<int> salt,
  required int iterations,
  required int dkLen,
}) {
  const hashLen = 32; // SHA-256 output size
  final hmac = Hmac(sha256, password);
  final blocks = (dkLen + hashLen - 1) ~/ hashLen;
  final output = <int>[];
  for (var blockIndex = 1; blockIndex <= blocks; blockIndex++) {
    final indexBytes = [
      (blockIndex >> 24) & 0xff,
      (blockIndex >> 16) & 0xff,
      (blockIndex >> 8) & 0xff,
      blockIndex & 0xff,
    ];
    final first = hmac.convert([...salt, ...indexBytes]).bytes;
    final block = List<int>.from(first);
    var previous = first;
    for (var i = 1; i < iterations; i++) {
      final next = hmac.convert(previous).bytes;
      for (var j = 0; j < block.length; j++) {
        block[j] ^= next[j];
      }
      previous = next;
    }
    output.addAll(block);
  }
  return output.sublist(0, dkLen);
}
