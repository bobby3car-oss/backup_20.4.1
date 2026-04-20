import 'dart:io' show Platform;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../firebase/app_functions.dart';

enum UserTotpStatus { none, pending, active }

class UserTotpEnrollment {
  const UserTotpEnrollment({
    required this.secret,
    required this.otpauthUrl,
    required this.issuer,
    required this.email,
  });

  final String secret;
  final String otpauthUrl;
  final String issuer;
  final String email;
}

class UserTotpVerifyResult {
  const UserTotpVerifyResult({this.deviceToken, this.deviceId});

  final String? deviceToken;
  final String? deviceId;

  bool get hasTrustedDevice =>
      (deviceToken?.isNotEmpty ?? false) && (deviceId?.isNotEmpty ?? false);
}

class UserTrustedDevice {
  const UserTrustedDevice({
    required this.id,
    required this.deviceName,
    this.createdAt,
    this.lastUsedAt,
    this.expiresAt,
  });

  final String id;
  final String deviceName;
  final DateTime? createdAt;
  final DateTime? lastUsedAt;
  final DateTime? expiresAt;
}

/// Client facade for opt-in user TOTP callables (doctors, orgs, staff).
/// The per-account trusted-device token is persisted in FlutterSecureStorage
/// (Keychain on iOS, Keystore on Android, libsecret/DPAPI on desktop).
class UserTotpService {
  UserTotpService({FirebaseAuth? auth, FlutterSecureStorage? storage})
    : _auth = auth ?? FirebaseAuth.instance,
      _storage = storage ?? const FlutterSecureStorage();

  final FirebaseAuth _auth;
  final FlutterSecureStorage _storage;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('UserTotpService requires a signed-in user.');
    }
    return user.uid;
  }

  String _tokenKey(String uid) => 'user_totp_device_token_$uid';
  String _idKey(String uid) => 'user_totp_device_id_$uid';

  Future<UserTotpStatus> getStatus() async {
    final result = await appFunctions()
        .httpsCallable('getUserTotpStatus')
        .call();
    final raw = (result.data as Map?)?['status']?.toString() ?? 'none';
    return switch (raw) {
      'active' => UserTotpStatus.active,
      'pending' => UserTotpStatus.pending,
      _ => UserTotpStatus.none,
    };
  }

  Future<UserTotpEnrollment> beginEnrollment() async {
    final result = await appFunctions()
        .httpsCallable('beginUserTotpEnrollment')
        .call();
    final data = Map<String, dynamic>.from(result.data as Map);
    return UserTotpEnrollment(
      secret: data['secret']?.toString() ?? '',
      otpauthUrl: data['otpauthUrl']?.toString() ?? '',
      issuer: data['issuer']?.toString() ?? 'Operationsbegleiter',
      email: data['email']?.toString() ?? '',
    );
  }

  Future<UserTotpVerifyResult> confirmEnrollment({
    required String code,
    bool rememberDevice = false,
  }) async {
    final result = await appFunctions()
        .httpsCallable('confirmUserTotpEnrollment')
        .call({
          'code': code,
          'rememberDevice': rememberDevice,
          'deviceName': _currentDeviceLabel(),
        });
    final verify = _parseVerifyResult(result.data);
    if (rememberDevice && verify.hasTrustedDevice) {
      await _persistDeviceToken(verify);
    }
    return verify;
  }

  Future<UserTotpVerifyResult> verifyCode({
    required String code,
    bool rememberDevice = false,
  }) async {
    final result = await appFunctions().httpsCallable('verifyUserTotp').call({
      'code': code,
      'rememberDevice': rememberDevice,
      'deviceName': _currentDeviceLabel(),
    });
    final verify = _parseVerifyResult(result.data);
    if (rememberDevice && verify.hasTrustedDevice) {
      await _persistDeviceToken(verify);
    }
    return verify;
  }

  /// Returns true if the stored device token was accepted by the server.
  /// Clears and returns false if missing or rejected.
  Future<bool> verifyTrustedDevice() async {
    final uid = _uid;
    final token = await _storage.read(key: _tokenKey(uid));
    final deviceId = await _storage.read(key: _idKey(uid));
    if (token == null || deviceId == null || token.isEmpty || deviceId.isEmpty) {
      return false;
    }
    try {
      await appFunctions().httpsCallable('verifyUserTrustedDevice').call({
        'deviceToken': token,
        'deviceId': deviceId,
      });
      return true;
    } on Exception catch (e) {
      if (kDebugMode) {
        debugPrint('[UserTotpService] trusted device rejected: $e');
      }
      await forgetCurrentDevice();
      return false;
    }
  }

  Future<bool> hasStoredDeviceToken() async {
    final uid = _uid;
    final token = await _storage.read(key: _tokenKey(uid));
    final id = await _storage.read(key: _idKey(uid));
    return (token?.isNotEmpty ?? false) && (id?.isNotEmpty ?? false);
  }

  Future<void> forgetCurrentDevice() async {
    final uid = _uid;
    await _storage.delete(key: _tokenKey(uid));
    await _storage.delete(key: _idKey(uid));
  }

  Future<List<UserTrustedDevice>> listTrustedDevices() async {
    final result = await appFunctions()
        .httpsCallable('listUserTrustedDevices')
        .call();
    final raw = (result.data as Map?)?['devices'] as List? ?? const [];
    return raw.map((item) {
      final map = Map<String, dynamic>.from(item as Map);
      return UserTrustedDevice(
        id: map['id']?.toString() ?? '',
        deviceName: map['deviceName']?.toString() ?? 'Unbenannt',
        createdAt: _parseMs(map['createdAt']),
        lastUsedAt: _parseMs(map['lastUsedAt']),
        expiresAt: _parseMs(map['expiresAt']),
      );
    }).toList();
  }

  Future<void> revokeDevice(String deviceId) async {
    await appFunctions().httpsCallable('revokeUserTrustedDevice').call({
      'deviceId': deviceId,
    });
    final uid = _uid;
    final currentId = await _storage.read(key: _idKey(uid));
    if (currentId == deviceId) {
      await forgetCurrentDevice();
    }
  }

  Future<void> disableTotp({required String currentCode}) async {
    await appFunctions().httpsCallable('disableUserTotp').call({
      'code': currentCode,
    });
    await forgetCurrentDevice();
  }

  /// Returns the active secret + otpauth URL so the user can re-add the
  /// account to another authenticator app. Requires a valid current code.
  Future<UserTotpEnrollment> revealSecret({required String currentCode}) async {
    final result = await appFunctions()
        .httpsCallable('revealUserTotpSecret')
        .call({'code': currentCode});
    final data = Map<String, dynamic>.from(result.data as Map);
    return UserTotpEnrollment(
      secret: data['secret']?.toString() ?? '',
      otpauthUrl: data['otpauthUrl']?.toString() ?? '',
      issuer: data['issuer']?.toString() ?? 'Operationsbegleiter',
      email: data['email']?.toString() ?? '',
    );
  }

  Future<void> _persistDeviceToken(UserTotpVerifyResult verify) async {
    final uid = _uid;
    await _storage.write(key: _tokenKey(uid), value: verify.deviceToken);
    await _storage.write(key: _idKey(uid), value: verify.deviceId);
  }

  UserTotpVerifyResult _parseVerifyResult(Object? raw) {
    if (raw is! Map) return const UserTotpVerifyResult();
    final map = Map<String, dynamic>.from(raw);
    return UserTotpVerifyResult(
      deviceToken: map['deviceToken']?.toString(),
      deviceId: map['deviceId']?.toString(),
    );
  }

  DateTime? _parseMs(Object? raw) {
    if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw);
    if (raw is double) return DateTime.fromMillisecondsSinceEpoch(raw.toInt());
    return null;
  }

  String _currentDeviceLabel() {
    try {
      if (kIsWeb) return 'Web-Browser';
      if (Platform.isIOS) return 'iOS Gerät';
      if (Platform.isAndroid) return 'Android Gerät';
      if (Platform.isMacOS) return 'macOS';
      if (Platform.isWindows) return 'Windows';
      if (Platform.isLinux) return 'Linux';
    } catch (_) {
      // Platform not available on web — caught above via kIsWeb.
    }
    return 'Unbekanntes Gerät';
  }
}
