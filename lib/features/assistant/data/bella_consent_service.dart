import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../firebase/firebase_paths.dart';

/// Manages user consent for Bella AI data processing (DSGVO Art. 6/9).
///
/// Firestore is the server-readable source of truth. Local preferences are
/// kept only as a UX cache so already-granted consent can be reflected
/// immediately on the device.
///
/// Stores consent version and timestamp to satisfy DSGVO Art. 7(1)
/// proof-of-consent requirements. When the consent text changes, bump
/// [_currentVersion] to force a re-consent prompt.
class BellaConsentService {
  BellaConsentService._();
  static final instance = BellaConsentService._();

  static const _key = 'bella_ai_consent_given';
  static const _versionKey = 'bella_ai_consent_version';
  static const _timestampKey = 'bella_ai_consent_timestamp';

  /// Bump this when the consent text changes to trigger re-consent.
  static const int _currentVersion = 2;

  bool _cached = false;
  bool _consentGiven = false;

  /// Whether the user has already consented to the current version.
  Future<bool> get hasConsented async {
    if (_cached) return _consentGiven;

    final prefs = await SharedPreferences.getInstance();
    final localConsentGiven = _hasCurrentLocalConsent(prefs);
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      _consentGiven = localConsentGiven;
      _cached = true;
      return _consentGiven;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .doc(FirestorePaths.userPrivateProfileDoc(uid))
          .get();
      final data = snapshot.data();
      if (_hasCurrentServerConsent(data)) {
        await _writeLocalConsent(
          prefs,
          grantedAt: _serverGrantedAt(data) ?? DateTime.now().toUtc(),
        );
        _consentGiven = true;
        _cached = true;
        return true;
      }

      if (localConsentGiven) {
        final synced = await _writeServerConsent(
          uid,
          granted: true,
          grantedAt: _localGrantedAt(prefs) ?? DateTime.now().toUtc(),
        );
        if (synced) {
          _consentGiven = true;
          _cached = true;
          return true;
        }
      }

      await _clearLocalConsent(prefs);
      _consentGiven = false;
      _cached = true;
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[BellaConsent] hasConsented sync failed: $e');
      }
      _consentGiven = localConsentGiven;
      _cached = true;
      return _consentGiven;
    }
  }

  /// Records that the user has given consent to the current version.
  Future<void> grantConsent() async {
    final prefs = await SharedPreferences.getInstance();
    final grantedAt = DateTime.now().toUtc();
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      await _writeServerConsent(uid, granted: true, grantedAt: grantedAt);
    }

    await _writeLocalConsent(prefs, grantedAt: grantedAt);
    _consentGiven = true;
    _cached = true;
  }

  /// Revokes consent (e.g. from settings).
  Future<void> revokeConsent() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      await _writeServerConsent(uid, granted: false);
    }

    await _clearLocalConsent(prefs);
    _consentGiven = false;
    _cached = true;
  }

  /// Resets the in-memory cache so the next [hasConsented] call re-reads
  /// from SharedPreferences. Call after SharedPreferences are cleared
  /// (e.g. on sign-out) to prevent stale cached values.
  void resetCache() {
    _cached = false;
    _consentGiven = false;
  }

  bool _hasCurrentLocalConsent(SharedPreferences prefs) {
    final given = prefs.getBool(_key) ?? false;
    final version = prefs.getInt(_versionKey) ?? 0;
    return given && version == _currentVersion;
  }

  DateTime? _localGrantedAt(SharedPreferences prefs) {
    final raw = prefs.getString(_timestampKey);
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw)?.toUtc();
  }

  bool _hasCurrentServerConsent(Map<String, dynamic>? data) {
    final bellaConsent = data?['bellaConsent'];
    if (bellaConsent is! Map) return false;

    final granted = bellaConsent['granted'] == true;
    final version = (bellaConsent['version'] as num?)?.toInt() ?? 0;
    return granted && version == _currentVersion;
  }

  DateTime? _serverGrantedAt(Map<String, dynamic>? data) {
    final bellaConsent = data?['bellaConsent'];
    if (bellaConsent is! Map) return null;

    final raw = bellaConsent['grantedAt'];
    if (raw is Timestamp) return raw.toDate().toUtc();
    if (raw is String) return DateTime.tryParse(raw)?.toUtc();
    return null;
  }

  Future<bool> _writeServerConsent(
    String uid, {
    required bool granted,
    DateTime? grantedAt,
  }) async {
    final now = DateTime.now().toUtc();
    await FirebaseFirestore.instance
        .doc(FirestorePaths.userPrivateProfileDoc(uid))
        .set({
          'bellaConsent': <String, dynamic>{
            'granted': granted,
            'version': _currentVersion,
            'updatedAt': now.toIso8601String(),
            if (granted)
              'grantedAt': (grantedAt ?? now).toIso8601String()
            else
              'revokedAt': now.toIso8601String(),
          },
        }, SetOptions(merge: true));
    return true;
  }

  Future<void> _writeLocalConsent(
    SharedPreferences prefs, {
    required DateTime grantedAt,
  }) async {
    await prefs.setBool(_key, true);
    await prefs.setInt(_versionKey, _currentVersion);
    await prefs.setString(_timestampKey, grantedAt.toIso8601String());
  }

  Future<void> _clearLocalConsent(SharedPreferences prefs) async {
    await prefs.remove(_key);
    await prefs.remove(_versionKey);
    await prefs.remove(_timestampKey);
  }
}
