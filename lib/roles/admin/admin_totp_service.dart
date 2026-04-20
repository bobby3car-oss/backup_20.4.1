import 'dart:io' show Platform;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../firebase/app_functions.dart';

enum AdminTotpStatus { none, pending, active }

class AdminTotpEnrollment {
  const AdminTotpEnrollment({
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

class AdminTotpVerifyResult {
  const AdminTotpVerifyResult({this.deviceToken, this.deviceId});

  final String? deviceToken;
  final String? deviceId;

  bool get hasTrustedDevice =>
      (deviceToken?.isNotEmpty ?? false) && (deviceId?.isNotEmpty ?? false);
}

class AdminTrustedDevice {
  const AdminTrustedDevice({
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

/// Client-side facade for the admin TOTP callables. Stores the per-account
/// trusted-device token in FlutterSecureStorage (Keychain on iOS, Keystore
/// on Android, libsecret/DPAPI on desktop).
class AdminTotpService {
  AdminTotpService({FirebaseAuth? auth, FlutterSecureStorage? storage})
    : _auth = auth ?? FirebaseAuth.instance,
      _storage = storage ?? const FlutterSecureStorage();

  final FirebaseAuth _auth;
  final FlutterSecureStorage _storage;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('AdminTotpService requires a signed-in user.');
    }
    return user.uid;
  }

  String _tokenKey(String uid) => 'admin_totp_device_token_$uid';
  String _idKey(String uid) => 'admin_totp_device_id_$uid';

  Future<AdminTotpStatus> getStatus() async {
    final result = await appFunctions()
        .httpsCallable('getAdminTotpStatus')
        .call();
    final raw = (result.data as Map?)?['status']?.toString() ?? 'none';
    return switch (raw) {
      'active' => AdminTotpStatus.active,
      'pending' => AdminTotpStatus.pending,
      _ => AdminTotpStatus.none,
    };
  }

  Future<AdminTotpEnrollment> beginEnrollment() async {
    final result = await appFunctions()
        .httpsCallable('beginAdminTotpEnrollment')
        .call();
    final data = Map<String, dynamic>.from(result.data as Map);
    return AdminTotpEnrollment(
      secret: data['secret']?.toString() ?? '',
      otpauthUrl: data['otpauthUrl']?.toString() ?? '',
      issuer: data['issuer']?.toString() ?? 'Operationsbegleiter',
      email: data['email']?.toString() ?? '',
    );
  }

  Future<AdminTotpVerifyResult> confirmEnrollment({
    required String code,
    bool rememberDevice = false,
  }) async {
    final result = await appFunctions()
        .httpsCallable('confirmAdminTotpEnrollment')
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

  Future<AdminTotpVerifyResult> verifyCode({
    required String code,
    bool rememberDevice = false,
  }) async {
    final result = await appFunctions().httpsCallable('verifyAdminTotp').call({
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
  /// Returns false if there is no stored token or the server rejected it
  /// (in which case the stored token is cleared).
  Future<bool> verifyTrustedDevice() async {
    final uid = _uid;
    final token = await _storage.read(key: _tokenKey(uid));
    final deviceId = await _storage.read(key: _idKey(uid));
    if (token == null || deviceId == null || token.isEmpty || deviceId.isEmpty) {
      return false;
    }
    try {
      await appFunctions().httpsCallable('verifyAdminTrustedDevice').call({
        'deviceToken': token,
        'deviceId': deviceId,
      });
      return true;
    } on Exception catch (e) {
      if (kDebugMode) {
        debugPrint('[AdminTotpService] trusted device rejected: $e');
      }
      // Clear invalid/expired token so we don't retry it every launch.
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

  Future<List<AdminTrustedDevice>> listTrustedDevices() async {
    final result = await appFunctions()
        .httpsCallable('listAdminTrustedDevices')
        .call();
    final raw = (result.data as Map?)?['devices'] as List? ?? const [];
    return raw.map((item) {
      final map = Map<String, dynamic>.from(item as Map);
      return AdminTrustedDevice(
        id: map['id']?.toString() ?? '',
        deviceName: map['deviceName']?.toString() ?? 'Unbenannt',
        createdAt: _parseMs(map['createdAt']),
        lastUsedAt: _parseMs(map['lastUsedAt']),
        expiresAt: _parseMs(map['expiresAt']),
      );
    }).toList();
  }

  Future<void> revokeDevice(String deviceId) async {
    await appFunctions().httpsCallable('revokeAdminTrustedDevice').call({
      'deviceId': deviceId,
    });
    // If the revoked device is the current one, clear local storage too.
    final uid = _uid;
    final currentId = await _storage.read(key: _idKey(uid));
    if (currentId == deviceId) {
      await forgetCurrentDevice();
    }
  }

  Future<void> resetTotp({required String currentCode}) async {
    await appFunctions().httpsCallable('resetAdminTotp').call({
      'code': currentCode,
    });
    await forgetCurrentDevice();
  }

  Future<void> _persistDeviceToken(AdminTotpVerifyResult verify) async {
    final uid = _uid;
    await _storage.write(key: _tokenKey(uid), value: verify.deviceToken);
    await _storage.write(key: _idKey(uid), value: verify.deviceId);
  }

  AdminTotpVerifyResult _parseVerifyResult(Object? raw) {
    if (raw is! Map) return const AdminTotpVerifyResult();
    final map = Map<String, dynamic>.from(raw);
    return AdminTotpVerifyResult(
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
