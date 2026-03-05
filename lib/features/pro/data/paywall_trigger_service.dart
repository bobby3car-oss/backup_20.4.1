import 'package:flutter/foundation.dart';

import '../domain/trigger_context.dart';
import 'entitlement_service.dart';
import 'paywall_config.dart';
import 'paywall_cooldown_storage.dart';
import 'paywall_trigger_analytics.dart';

/// Central decision engine for when and how to present the paywall.
///
/// This service does **not** replace any existing paywall logic. It sits
/// on top and answers: "Should we show a paywall right now?"
///
/// All timing / frequency rules live here.  Remote Config flags can
/// override behaviour at runtime.
class PaywallTriggerService {
  PaywallTriggerService({
    required EntitlementService entitlementService,
    required PaywallConfig paywallConfig,
    required PaywallCooldownStorage cooldownStorage,
    required PaywallTriggerAnalytics triggerAnalytics,
  })  : _entitlement = entitlementService,
        _config = paywallConfig,
        _storage = cooldownStorage,
        _analytics = triggerAnalytics;

  final EntitlementService _entitlement;
  final PaywallConfig _config;
  final PaywallCooldownStorage _storage;
  final PaywallTriggerAnalytics _analytics;

  /// A simple session identifier (changes on each cold start).
  late final String _sessionId =
      DateTime.now().millisecondsSinceEpoch.toString();

  // ── Public API ─────────────────────────────────────────────────────

  /// Returns `true` if a paywall should be presented for the given
  /// [triggerContext].
  ///
  /// If the answer is `false`, the appropriate `paywall_suppressed`
  /// analytics event is logged automatically.
  bool shouldShowPaywall(TriggerContext triggerContext) {
    // 1. Pro users never see a paywall.
    if (_entitlement.isPro) {
      return false;
    }

    // 2. Global kill switch via Remote Config.
    if (!_config.paywallEnabled) {
      _analytics.paywallSuppressed(
        context: triggerContext,
        reason: 'remote_config_disabled',
      );
      return false;
    }

    // 3. Surface-specific kill switches.
    if (triggerContext == TriggerContext.dashboardCard &&
        !_config.dashboardUpsellEnabled) {
      _analytics.paywallSuppressed(
        context: triggerContext,
        reason: 'dashboard_upsell_disabled',
      );
      return false;
    }
    if (triggerContext == TriggerContext.timelineBanner &&
        !_config.timelineBannerEnabled) {
      _analytics.paywallSuppressed(
        context: triggerContext,
        reason: 'timeline_banner_disabled',
      );
      return false;
    }

    // 4. Feature-gate triggers bypass frequency caps.
    if (triggerContext.bypassesFrequencyCap) {
      return true;
    }

    // 5. Frequency cap: max 1 fullscreen per 24 h.
    final now = DateTime.now();
    final frequencyHours = _config.paywallFrequencyHours;

    final lastShown = _storage.lastPaywallShownAt;
    if (lastShown != null) {
      final hoursSinceShown = now.difference(lastShown).inHours;
      if (hoursSinceShown < frequencyHours) {
        _analytics.paywallSuppressed(
          context: triggerContext,
          reason: 'frequency_cap_${frequencyHours}h',
        );
        return false;
      }
    }

    // 6. Cooldown after dismiss: 6 h.
    final lastDismissed = _storage.lastPaywallDismissedAt;
    if (lastDismissed != null) {
      final hoursSinceDismiss = now.difference(lastDismissed).inHours;
      if (hoursSinceDismiss < 6) {
        _analytics.paywallSuppressed(
          context: triggerContext,
          reason: 'dismiss_cooldown_6h',
        );
        return false;
      }
    }

    // 7. Cooldown after "Maybe later": 12 h.
    final lastMaybeLater = _storage.lastMaybeLaterAt;
    if (lastMaybeLater != null) {
      final hoursSinceMaybeLater = now.difference(lastMaybeLater).inHours;
      if (hoursSinceMaybeLater < 12) {
        _analytics.paywallSuppressed(
          context: triggerContext,
          reason: 'maybe_later_cooldown_12h',
        );
        return false;
      }
    }

    return true;
  }

  /// Call after a paywall was actually displayed.
  Future<void> registerPaywallShown(TriggerContext triggerContext) async {
    final now = DateTime.now();

    Duration? timeSinceLastShow;
    final lastShown = _storage.lastPaywallShownAt;
    if (lastShown != null) {
      timeSinceLastShow = now.difference(lastShown);
    }

    await _storage.setLastPaywallShownAt(now);

    _analytics.paywallTriggered(
      context: triggerContext,
      surfaceType: triggerContext.surfaceType,
      timeSinceLastShow: timeSinceLastShow,
    );
    _analytics.paywallSurface(
      context: triggerContext,
      surfaceType: triggerContext.surfaceType,
    );

    if (kDebugMode) {
      debugPrint(
        '[PaywallTrigger] shown – context=${triggerContext.sourceKey} '
        'surface=${triggerContext.surfaceType.name}',
      );
    }
  }

  /// Call when the user dismisses the paywall (X / back).
  Future<void> registerPaywallDismissed({
    TriggerContext triggerContext = TriggerContext.manualOpen,
    bool maybeLater = false,
  }) async {
    final now = DateTime.now();

    if (maybeLater) {
      await _storage.setLastMaybeLaterAt(now);
    } else {
      await _storage.setLastPaywallDismissedAt(now);
    }

    _analytics.paywallDismissed(
      context: triggerContext,
      surfaceType: triggerContext.surfaceType,
      maybeLater: maybeLater,
    );
  }

  /// Call when a purchase flow was started.
  Future<void> registerPurchaseAttempt() async {
    await _storage.setLastPurchaseAttemptAt(DateTime.now());
  }

  // ── Smart Trigger Moments ──────────────────────────────────────────

  /// Call each time the timeline tab is opened.
  ///
  /// Returns `true` if the timeline-banner upsell should be shown
  /// (user opened timeline ≥ 3× in this session & is not Pro).
  Future<bool> onTimelineOpened() async {
    if (_entitlement.isPro) return false;
    if (!_config.timelineBannerEnabled) return false;

    final count = await _storage.incrementTimelineOpen(_sessionId);
    if (kDebugMode) {
      debugPrint('[PaywallTrigger] timeline opens in session: $count');
    }
    if (count >= 3) {
      return shouldShowPaywall(TriggerContext.timelineBanner);
    }
    return false;
  }

  /// Call on each app session start.
  ///
  /// Returns `true` if the dashboard upsell card should be shown
  /// (user has been active on ≥ 3 distinct days & is not Pro).
  Future<bool> onSessionStarted() async {
    if (_entitlement.isPro) return false;
    if (!_config.dashboardUpsellEnabled) return false;

    final days = await _storage.recordActiveDay();
    if (kDebugMode) {
      debugPrint('[PaywallTrigger] total active days: $days');
    }
    return days >= 3;
  }

  /// Whether the inline dashboard upsell card should be visible.
  bool get shouldShowDashboardUpsell {
    if (_entitlement.isPro) return false;
    if (!_config.dashboardUpsellEnabled) return false;
    return _storage.activeDayCount >= 3;
  }
}
