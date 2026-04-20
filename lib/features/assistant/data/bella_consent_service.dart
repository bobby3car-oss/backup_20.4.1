import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../firebase/firebase_paths.dart';

/// Manages user consent for Bella AI data processing (DSGVO Art. 6/9).
///
/// **Local-first**: SharedPreferences are the primary source of truth for
/// the client. Firestore is written for DSGVO audit compliance but never
/// blocks or overrides the local decision. This avoids race conditions
/// between slow Firestore reads and fast in-memory consent grants.
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
  ///
  /// Fast path: returns cached in-memory value or reads SharedPreferences.
  /// Only falls back to Firestore when local prefs have NO consent (e.g.
  /// after app reinstall) to recover server-side consent.
  Future<bool> get hasConsented async {
    // 1. In-memory cache (instant).
    if (_cached) return _consentGiven;

    // 2. Local SharedPreferences (fast, <1 ms).
    final prefs = await SharedPreferences.getInstance();
    if (_hasCurrentLocalConsent(prefs)) {
      _consentGiven = true;
      _cached = true;
      // Best-effort sync to Firestore in background.
      _syncToFirestore(prefs);
      return true;
    }

    // 3. Firestore fallback (slow — only for app-reinstall recovery).
    //    If grantConsent() runs while this await is in flight, the cache
    //    guard below ensures we don't overwrite a freshly-granted consent.
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      try {
        final snap = await FirebaseFirestore.instance
            .doc(FirestorePaths.userPrivateProfileDoc(uid))
            .get();

        // Guard: grantConsent() may have run during the Firestore read.
        if (_cached && _consentGiven) return true;

        if (_hasCurrentServerConsent(snap.data())) {
          final ts = _serverGrantedAt(snap.data()) ?? DateTime.now().toUtc();
          await _writeLocalConsent(prefs, grantedAt: ts);
          _consentGiven = true;
          _cached = true;
          return true;
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[BellaConsent] Firestore fallback failed: $e');
        }
        // Guard: grantConsent() may have run during the failed await.
        if (_cached && _consentGiven) return true;
      }
    }

    _consentGiven = false;
    _cached = true;
    return false;
  }

  /// Records that the user has given consent to the current version.
  ///
  /// Sets the in-memory cache and local prefs FIRST (instant), then
  /// writes to Firestore for audit compliance (best-effort).
  Future<void> grantConsent() async {
    final grantedAt = DateTime.now().toUtc();

    // Immediately set in-memory cache so any concurrent hasConsented
    // calls see the granted consent without waiting.
    _consentGiven = true;
    _cached = true;

    // Write local prefs (fast, synchronous in-memory + async disk).
    final prefs = await SharedPreferences.getInstance();
    await _writeLocalConsent(prefs, grantedAt: grantedAt);

    // Firestore write for DSGVO audit — best-effort, don't block.
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      unawaited(_writeServerConsent(uid, granted: true, grantedAt: grantedAt)
          .catchError((Object e) {
        if (kDebugMode) {
          debugPrint('[BellaConsent] Firestore write failed: $e');
        }
      }));
    }
  }

  /// Revokes consent (e.g. from settings).
  Future<void> revokeConsent() async {
    _consentGiven = false;
    _cached = true;

    final prefs = await SharedPreferences.getInstance();
    await _clearLocalConsent(prefs);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      try {
        await _writeServerConsent(uid, granted: false);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[BellaConsent] Firestore revoke failed: $e');
        }
      }
    }
  }

  /// Resets the in-memory cache so the next [hasConsented] call re-reads
  /// from SharedPreferences. Call on sign-out only.
  void resetCache() {
    _cached = false;
    _consentGiven = false;
  }

  // ── Private helpers ──────────────────────────────────────────────

  /// Fire-and-forget: sync local consent to Firestore if not already there.
  void _syncToFirestore(SharedPreferences prefs) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final ts = _localGrantedAt(prefs) ?? DateTime.now().toUtc();
    unawaited(_writeServerConsent(uid, granted: true, grantedAt: ts)
        .catchError((Object e) {
      if (kDebugMode) {
        debugPrint('[BellaConsent] background sync failed: $e');
      }
    }));
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

  Future<void> _writeServerConsent(
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
