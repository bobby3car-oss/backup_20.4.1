import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages user consent for Firebase Analytics and Crashlytics (DSGVO).
///
/// Analytics and Crashlytics are disabled by default and only activated
/// after the user gives explicit consent.
class PrivacyConsentService {
  PrivacyConsentService._();
  static final instance = PrivacyConsentService._();

  static const _keyAnalytics = 'privacy_analytics_enabled';
  static const _keyCrashlytics = 'privacy_crashlytics_enabled';

  bool _analyticsEnabled = false;
  bool _crashlyticsEnabled = false;

  bool get analyticsEnabled => _analyticsEnabled;
  bool get crashlyticsEnabled => _crashlyticsEnabled;

  /// Loads saved preferences and applies them to Firebase services.
  /// Call once during app startup, after Firebase.initializeApp().
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _analyticsEnabled = prefs.getBool(_keyAnalytics) ?? false;
    _crashlyticsEnabled = prefs.getBool(_keyCrashlytics) ?? false;
    await _apply();
  }

  /// Updates analytics consent and persists the choice.
  Future<void> setAnalyticsEnabled(bool enabled) async {
    _analyticsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAnalytics, enabled);
    await _applyAnalytics();
  }

  /// Updates crashlytics consent and persists the choice.
  Future<void> setCrashlyticsEnabled(bool enabled) async {
    _crashlyticsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyCrashlytics, enabled);
    await _applyCrashlytics();
  }

  Future<void> _apply() async {
    await Future.wait([_applyAnalytics(), _applyCrashlytics()]);
  }

  Future<void> _applyAnalytics() async {
    try {
      await FirebaseAnalytics.instance
          .setAnalyticsCollectionEnabled(_analyticsEnabled);
    } catch (e) {
      if (kDebugMode) debugPrint('[PrivacyConsent] Analytics toggle failed: $e');
    }
  }

  Future<void> _applyCrashlytics() async {
    if (kIsWeb) return; // Crashlytics not available on web
    try {
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(_crashlyticsEnabled);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[PrivacyConsent] Crashlytics toggle failed: $e');
      }
    }
  }
}
