/// Context from which a paywall trigger originated.
enum TriggerContext {
  /// User tried to access the relatives / caregiver feature.
  relativesFeature,

  /// Pro upsell card on the dashboard (timeline feed).
  dashboardCard,

  /// Timeline banner upsell after repeated timeline opens.
  timelineBanner,

  /// User explicitly opened the paywall (e.g. "Upgrade" button).
  manualOpen,

  /// Pro button in the settings screen.
  settingsProButton,
}

/// Extension to map [TriggerContext] to the existing `source` strings
/// used by [PaywallScreen] and [ProAnalytics].
extension TriggerContextX on TriggerContext {
  /// Analytics / route-argument source key.
  String get sourceKey => switch (this) {
        TriggerContext.relativesFeature => 'relatives',
        TriggerContext.dashboardCard => 'dashboard',
        TriggerContext.timelineBanner => 'timeline_banner',
        TriggerContext.manualOpen => 'manual',
        TriggerContext.settingsProButton => 'settings',
      };

  /// Which surface type should be used for this trigger.
  PaywallSurfaceType get surfaceType => switch (this) {
        TriggerContext.relativesFeature => PaywallSurfaceType.fullscreen,
        TriggerContext.manualOpen => PaywallSurfaceType.fullscreen,
        TriggerContext.timelineBanner => PaywallSurfaceType.bottomSheet,
        TriggerContext.dashboardCard => PaywallSurfaceType.bottomSheet,
        TriggerContext.settingsProButton => PaywallSurfaceType.fullscreen,
      };

  /// Whether this trigger should bypass frequency caps.
  ///
  /// Feature-gate triggers (e.g. relatives) always show the paywall
  /// so the user understands why the feature is locked.
  bool get bypassesFrequencyCap => switch (this) {
        TriggerContext.relativesFeature => true,
        TriggerContext.manualOpen => true,
        _ => false,
      };
}

/// The visual surface used to present the paywall.
enum PaywallSurfaceType {
  /// Full-screen paywall (existing [PaywallScreen]).
  fullscreen,

  /// Modal bottom sheet upsell.
  bottomSheet,

  /// Inline card embedded in a list / dashboard.
  inlineCard,
}
