import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

/// Paywall A/B/C variant.
///
/// - **A** – Feature list above plan cards (default / current layout).
/// - **B** – Outcome text first (social-proof hero, features hidden by default).
/// - **C** – Yearly plan rendered larger / more prominent.
enum PaywallVariant { a, b, c }

/// Reads paywall-related Remote Config keys and exposes them as typed values.
///
/// Call [init] once at app start (after Firebase.initializeApp).
class PaywallConfig {
  PaywallConfig({FirebaseRemoteConfig? remoteConfig})
      : _rc = remoteConfig ?? FirebaseRemoteConfig.instance;

  final FirebaseRemoteConfig _rc;

  // ── Keys ───────────────────────────────────────────────────────────

  static const _kVariant = 'paywall_variant';
  static const _kDefaultPlan = 'paywall_default_plan';
  static const _kShowSavings = 'paywall_show_savings';
  static const _kShowFeatures = 'paywall_show_features';

  // ── Defaults ───────────────────────────────────────────────────────

  static const _defaults = <String, Object>{
    _kVariant: 'A',
    _kDefaultPlan: 'yearly',
    _kShowSavings: true,
    _kShowFeatures: true,
  };

  // ── Public getters ─────────────────────────────────────────────────

  PaywallVariant get variant {
    final v = _rc.getString(_kVariant).toUpperCase();
    return switch (v) {
      'B' => PaywallVariant.b,
      'C' => PaywallVariant.c,
      _ => PaywallVariant.a,
    };
  }

  /// `"yearly"` or `"monthly"` – which plan card is pre-selected.
  String get defaultPlan => _rc.getString(_kDefaultPlan);

  /// Whether the savings badge is visible on the yearly card.
  bool get showSavings => _rc.getBool(_kShowSavings);

  /// Whether the feature list section is shown.
  bool get showFeatures => _rc.getBool(_kShowFeatures);

  // ── Init ───────────────────────────────────────────────────────────

  /// Fetch & activate Remote Config values.
  ///
  /// In debug mode a 10 s minimum fetch interval is used for fast iteration.
  Future<void> init() async {
    try {
      await _rc.setDefaults(_defaults);
      await _rc.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval:
            kDebugMode ? const Duration(seconds: 10) : const Duration(hours: 1),
      ));
      await _rc.fetchAndActivate();

      if (kDebugMode) {
        debugPrint(
          '[PaywallConfig] variant=${_rc.getString(_kVariant)} '
          'defaultPlan=${_rc.getString(_kDefaultPlan)} '
          'showSavings=${_rc.getBool(_kShowSavings)} '
          'showFeatures=${_rc.getBool(_kShowFeatures)}',
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
