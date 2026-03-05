import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';

import '../domain/trigger_context.dart';

/// Extended analytics events for the Smart Paywall Trigger System.
///
/// These events supplement [ProAnalytics] (which remains unchanged).
class PaywallTriggerAnalytics {
  PaywallTriggerAnalytics({FirebaseAnalytics? analytics})
      : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  String get _platform => Platform.isIOS ? 'ios' : 'android';

  // ── Events ────────────────────────────────────────────────────────

  /// A paywall was triggered and shown.
  Future<void> paywallTriggered({
    required TriggerContext context,
    required PaywallSurfaceType surfaceType,
    Duration? timeSinceLastShow,
  }) =>
      _analytics.logEvent(
        name: 'paywall_triggered',
        parameters: {
          'context': context.sourceKey,
          'surface_type': surfaceType.name,
          'platform': _platform,
          if (timeSinceLastShow != null)
            'time_since_last_show': timeSinceLastShow.inSeconds,
        },
      );

  /// A paywall was suppressed by frequency caps.
  Future<void> paywallSuppressed({
    required TriggerContext context,
    required String reason,
  }) =>
      _analytics.logEvent(
        name: 'paywall_suppressed',
        parameters: {
          'context': context.sourceKey,
          'reason': reason,
          'platform': _platform,
        },
      );

  /// User dismissed a paywall surface.
  Future<void> paywallDismissed({
    required TriggerContext context,
    required PaywallSurfaceType surfaceType,
    bool maybeLater = false,
  }) =>
      _analytics.logEvent(
        name: 'paywall_dismissed',
        parameters: {
          'context': context.sourceKey,
          'surface_type': surfaceType.name,
          'maybe_later': maybeLater ? 'true' : 'false',
          'platform': _platform,
        },
      );

  /// A paywall surface was shown (any type).
  Future<void> paywallSurface({
    required TriggerContext context,
    required PaywallSurfaceType surfaceType,
  }) =>
      _analytics.logEvent(
        name: 'paywall_surface',
        parameters: {
          'context': context.sourceKey,
          'surface_type': surfaceType.name,
          'platform': _platform,
        },
      );
}
