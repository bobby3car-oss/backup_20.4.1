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

  // ── Feature Gate Analytics ─────────────────────────────────────────

  /// A free user hit a feature gate and saw a paywall.
  Future<void> featureGateHit({
    required String feature,
  }) =>
      _analytics.logEvent(
        name: 'feature_gate_hit',
        parameters: {
          'feature': feature,
          'platform': _platform,
        },
      );

  /// A free user reached a soft limit (e.g. 3/3 photos).
  Future<void> softLimitReached({
    required String feature,
    required int count,
    required int limit,
  }) =>
      _analytics.logEvent(
        name: 'free_limit_reached',
        parameters: {
          'feature': feature,
          'count': count,
          'limit': limit,
          'platform': _platform,
        },
      );

  /// User scrolled to the pricing section on the paywall.
  Future<void> paywallScrolledToPrices({required String source}) =>
      _analytics.logEvent(
        name: 'paywall_scrolled_to_prices',
        parameters: {
          'source': source,
          'platform': _platform,
        },
      );
}
