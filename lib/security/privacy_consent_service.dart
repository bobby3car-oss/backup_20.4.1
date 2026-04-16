import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages user consent for Firebase Analytics and Crashlytics (DSGVO).
///
/// Platform configuration keeps Analytics and Crashlytics disabled by
/// default. This service is the single runtime source of truth that can
/// enable collection after explicit user consent.
class PrivacyConsentService {
  PrivacyConsentService._();
  static final instance = PrivacyConsentService._();

  static const _keyAnalytics = 'privacy_analytics_enabled';
  static const _keyCrashlytics = 'privacy_crashlytics_enabled';

  bool _analyticsEnabled = false;
  bool _crashlyticsEnabled = false;
  FlutterExceptionHandler? _defaultFlutterErrorHandler;
  bool Function(Object, StackTrace)? _defaultPlatformErrorHandler;
  bool _crashlyticsHandlersInstalled = false;

  bool get analyticsEnabled => _analyticsEnabled;
  bool get crashlyticsEnabled => _crashlyticsEnabled;

  /// Loads saved preferences and applies them to Firebase services.
  /// Call once during app startup, after Firebase.initializeApp().
  Future<void> init() async {
    _captureDefaultErrorHandlers();
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
    _captureDefaultErrorHandlers();
    try {
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(_crashlyticsEnabled);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[PrivacyConsent] Crashlytics toggle failed: $e');
      }
    }
    _syncCrashlyticsHandlers();
  }

  void _captureDefaultErrorHandlers() {
    _defaultFlutterErrorHandler ??= FlutterError.onError;
    _defaultPlatformErrorHandler ??= PlatformDispatcher.instance.onError;
  }

  void _syncCrashlyticsHandlers() {
    if (kIsWeb || kDebugMode) return;

    if (_crashlyticsEnabled) {
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
      _crashlyticsHandlersInstalled = true;
      return;
    }

    if (_crashlyticsHandlersInstalled) {
      FlutterError.onError = _defaultFlutterErrorHandler;
      PlatformDispatcher.instance.onError = _defaultPlatformErrorHandler;
      _crashlyticsHandlersInstalled = false;
    }
  }
}
