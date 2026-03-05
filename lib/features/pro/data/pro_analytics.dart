import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';

/// Centralised analytics tracking for Pro / IAP events.
class ProAnalytics {
  ProAnalytics({FirebaseAnalytics? analytics})
      : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  String get _platform => Platform.isIOS ? 'ios' : 'android';

  // ── Events ────────────────────────────────────────────────────────

  /// Paywall was displayed.
  Future<void> paywallOpened({
    String source = 'unknown',
    String variant = 'A',
  }) =>
      _analytics.logEvent(
        name: 'paywall_opened',
        parameters: {
          'source': source,
          'platform': _platform,
          'variant': variant,
        },
      );

  /// User selected / switched a plan on the paywall.
  Future<void> planSelected({
    required String plan,
    required String price,
  }) =>
      _analytics.logEvent(
        name: 'plan_selected',
        parameters: {
          'plan': plan,
          'price': price,
          'platform': _platform,
        },
      );

  /// Purchase flow started (buy button tapped).
  Future<void> purchaseStarted({
    required String plan,
    required String price,
  }) =>
      _analytics.logEvent(
        name: 'purchase_started',
        parameters: {
          'plan': plan,
          'price': price,
          'platform': _platform,
        },
      );

  /// Purchase verified & entitlement activated.
  Future<void> purchaseSuccess({
    required String plan,
    required String price,
  }) =>
      _analytics.logEvent(
        name: 'purchase_success',
        parameters: {
          'plan': plan,
          'price': price,
          'platform': _platform,
        },
      );

  /// Purchase attempt failed or was cancelled.
  Future<void> purchaseFailed({
    required String plan,
    String? error,
  }) =>
      _analytics.logEvent(
        name: 'purchase_failed',
        parameters: {
          'plan': plan,
          'platform': _platform,
          if (error != null) 'error': error,
        },
      );

  /// User tapped "Wiederherstellen".
  Future<void> restoreClicked() => _analytics.logEvent(
        name: 'restore_clicked',
        parameters: {'platform': _platform},
      );

  /// Restore completed and entitlement activated.
  Future<void> restoreSuccess() => _analytics.logEvent(
        name: 'restore_success',
        parameters: {'platform': _platform},
      );
}
