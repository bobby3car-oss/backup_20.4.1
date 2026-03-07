import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

/// Reads paywall-related Remote Config keys and exposes them as typed values.
///
/// Call [init] once at app start (after Firebase.initializeApp).
class PaywallConfig {
  PaywallConfig({FirebaseRemoteConfig? remoteConfig}) : _rc = remoteConfig;

  factory PaywallConfig.enabled() {
    return PaywallConfig(remoteConfig: FirebaseRemoteConfig.instance);
  }

  factory PaywallConfig.disabled() {
    return PaywallConfig();
  }

  final FirebaseRemoteConfig? _rc;

  // ── Keys ───────────────────────────────────────────────────────────

  static const _kDefaultPlan = 'paywall_default_plan';
  static const _kShowSavings = 'paywall_show_savings';
  static const _kPaywallEnabled = 'paywall_enabled';
  static const _kPaywallFrequencyHours = 'paywall_frequency_hours';
  static const _kDashboardUpsellEnabled = 'dashboard_upsell_enabled';
  static const _kTimelineBannerEnabled = 'timeline_banner_enabled';

  // ── Defaults ───────────────────────────────────────────────────────

  static const _defaults = <String, Object>{
    _kDefaultPlan: 'yearly',
    _kShowSavings: true,
    _kPaywallEnabled: true,
    _kPaywallFrequencyHours: 24,
    _kDashboardUpsellEnabled: true,
    _kTimelineBannerEnabled: true,
  };

  // ── Public getters ─────────────────────────────────────────────────

  /// `"yearly"` or `"monthly"` – which plan card is pre-selected.
  String get defaultPlan => _rc?.getString(_kDefaultPlan) ?? 'yearly';

  /// Whether the savings badge is visible on the yearly card.
  bool get showSavings => _rc?.getBool(_kShowSavings) ?? true;

  // ── Smart Trigger Config ───────────────────────────────────────────

  /// Master switch – if `false`, no paywall is ever shown.
  bool get paywallEnabled => _rc?.getBool(_kPaywallEnabled) ?? true;

  /// Minimum hours between two fullscreen paywalls.
  int get paywallFrequencyHours => _rc?.getInt(_kPaywallFrequencyHours) ?? 24;

  /// Whether the inline dashboard upsell card is enabled.
  bool get dashboardUpsellEnabled =>
      _rc?.getBool(_kDashboardUpsellEnabled) ?? true;

  /// Whether the timeline-banner upsell is enabled.
  bool get timelineBannerEnabled =>
      _rc?.getBool(_kTimelineBannerEnabled) ?? true;

  // ── Init ───────────────────────────────────────────────────────────

  /// Fetch & activate Remote Config values.
  ///
  /// In debug mode a 10 s minimum fetch interval is used for fast iteration.
  Future<void> init() async {
    final rc = _rc;
    if (rc == null) return;
    try {
      await rc.setDefaults(_defaults);
      await rc.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: kDebugMode
              ? const Duration(seconds: 10)
              : const Duration(hours: 1),
        ),
      );
      await rc.fetchAndActivate();

      if (kDebugMode) {
        debugPrint(
          '[PaywallConfig] '
          'defaultPlan=${rc.getString(_kDefaultPlan)} '
          'showSavings=${rc.getBool(_kShowSavings)} '
          'paywallEnabled=${rc.getBool(_kPaywallEnabled)} '
          'frequencyH=${rc.getInt(_kPaywallFrequencyHours)} '
          'dashboardUpsell=${rc.getBool(_kDashboardUpsellEnabled)} '
          'timelineBanner=${rc.getBool(_kTimelineBannerEnabled)}',
        );
      }
    } catch (e) {
      // Silently fall back to defaults – paywall still works.
      if (kDebugMode) {
        debugPrint('[PaywallConfig] init error (using defaults): $e');
      }
    }
  }
}
