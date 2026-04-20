import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../firebase/firebase_paths.dart';

/// Persists AGB + Datenschutzerklärung acceptance for DSGVO audit compliance
/// (Art. 7 Abs. 1 — Nachweis der Einwilligung).
///
/// Stores version, timestamp, and granted flag both locally (SharedPreferences)
/// and in Firestore (`users/{uid}/private/profile → termsConsent`).
class TermsConsentService {
  TermsConsentService._();
  static final instance = TermsConsentService._();

  static const _key = 'terms_consent_given';
  static const _versionKey = 'terms_consent_version';
  static const _timestampKey = 'terms_consent_timestamp';

  /// Bump when AGB / Datenschutzerklärung text changes materially.
  static const int currentVersion = 1;

  /// Records that the user has accepted the current AGB + Datenschutz.
  ///
  /// Call immediately after successful registration or when a user
  /// re-accepts after a version bump.
  Future<void> recordAcceptance({String? uid}) async {
    final grantedAt = DateTime.now().toUtc();

    // 1. Local persistence (fast).
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
    await prefs.setInt(_versionKey, currentVersion);
    await prefs.setString(_timestampKey, grantedAt.toIso8601String());

    // 2. Firestore for audit trail — best-effort, don't block.
    final effectiveUid = uid ?? FirebaseAuth.instance.currentUser?.uid;
    if (effectiveUid != null) {
      unawaited(
        FirebaseFirestore.instance
            .doc(FirestorePaths.userPrivateProfileDoc(effectiveUid))
            .set({
              'termsConsent': <String, dynamic>{
                'granted': true,
                'version': currentVersion,
                'grantedAt': grantedAt.toIso8601String(),
              },
            }, SetOptions(merge: true))
            .catchError((Object e) {
              if (kDebugMode) {
                debugPrint('[TermsConsent] Firestore write failed: $e');
              }
            }),
      );
    }
  }

  /// Whether the current terms version has been accepted locally.
  Future<bool> hasAcceptedCurrentVersion() async {
    final prefs = await SharedPreferences.getInstance();
    final given = prefs.getBool(_key) ?? false;
    final version = prefs.getInt(_versionKey) ?? 0;
    return given && version == currentVersion;
  }
}
