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

  // ── Feature Gates ────────────────────────────────────────────────

  /// Voice / Speech Memos (hard block).
  voiceFeature,

  /// Photo upload limit reached (soft limit: max 3 free).
  photoLimit,

  /// Document upload limit reached (soft limit: max 5 free).
  documentLimit,

  /// Doctor report export / share (mix: preview free, export Pro).
  arztberichtExport,

  /// Red-Flag / Alert system (hard block).
  redFlagFeature,

  /// Progress / Fortschritt screen (hard block).
  progressFeature,
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
        TriggerContext.voiceFeature => 'voice',
        TriggerContext.photoLimit => 'photo_limit',
        TriggerContext.documentLimit => 'document_limit',
        TriggerContext.arztberichtExport => 'arztbericht_export',
        TriggerContext.redFlagFeature => 'red_flag',
        TriggerContext.progressFeature => 'progress',
      };

  /// Which surface type should be used for this trigger.
  PaywallSurfaceType get surfaceType => switch (this) {
        TriggerContext.relativesFeature => PaywallSurfaceType.fullscreen,
        TriggerContext.manualOpen => PaywallSurfaceType.fullscreen,
        TriggerContext.settingsProButton => PaywallSurfaceType.fullscreen,
        TriggerContext.voiceFeature => PaywallSurfaceType.fullscreen,
        TriggerContext.progressFeature => PaywallSurfaceType.fullscreen,
        TriggerContext.redFlagFeature => PaywallSurfaceType.fullscreen,
        TriggerContext.arztberichtExport => PaywallSurfaceType.fullscreen,
        TriggerContext.timelineBanner => PaywallSurfaceType.bottomSheet,
        TriggerContext.dashboardCard => PaywallSurfaceType.bottomSheet,
        TriggerContext.photoLimit => PaywallSurfaceType.bottomSheet,
        TriggerContext.documentLimit => PaywallSurfaceType.bottomSheet,
      };

  /// Whether this trigger should bypass frequency caps.
  ///
  /// Feature-gate triggers always show the paywall so the user
  /// understands why the feature is locked.
  bool get bypassesFrequencyCap => switch (this) {
        TriggerContext.relativesFeature => true,
        TriggerContext.manualOpen => true,
        TriggerContext.voiceFeature => true,
        TriggerContext.photoLimit => true,
        TriggerContext.documentLimit => true,
        TriggerContext.arztberichtExport => true,
        TriggerContext.redFlagFeature => true,
        TriggerContext.progressFeature => true,
        _ => false,
      };

  /// Emoji for the trigger context (used in paywall copy).
  String get emoji => switch (this) {
        TriggerContext.relativesFeature => '👪',
        TriggerContext.dashboardCard => '🚀',
        TriggerContext.timelineBanner => '📋',
        TriggerContext.manualOpen => '✨',
        TriggerContext.settingsProButton => '✨',
        TriggerContext.voiceFeature => '🎤',
        TriggerContext.photoLimit => '📸',
        TriggerContext.documentLimit => '📄',
        TriggerContext.arztberichtExport => '🧑‍⚕️',
        TriggerContext.redFlagFeature => '🚨',
        TriggerContext.progressFeature => '💪',
      };

  /// Context-aware headline for the paywall.
  String get paywallHeadline => switch (this) {
        TriggerContext.relativesFeature =>
          'Sei nicht allein bei deiner OP',
        TriggerContext.voiceFeature =>
          'Deine Stimme, dein Tagebuch',
        TriggerContext.photoLimit =>
          'Jede Heilung verdient ein Bild',
        TriggerContext.documentLimit =>
          'Alle Dokumente an einem Ort',
        TriggerContext.arztberichtExport =>
          'Dein Bericht. Dein Überblick.',
        TriggerContext.redFlagFeature =>
          'Warnungen, die auf dich achten',
        TriggerContext.progressFeature =>
          'Sieh wie weit du gekommen bist',
        _ => 'Deine OP verdient das Beste',
      };

  /// Context-aware subline for the paywall.
  String get paywallSubline => switch (this) {
        TriggerContext.relativesFeature =>
          'Lade Angehörige ein, damit sie deine Genesung '
              'mitverfolgen und dir helfen können.',
        TriggerContext.voiceFeature =>
          'Nimm Sprachnotizen auf, statt alles zu tippen. '
              'Besonders praktisch, wenn Tippen weh tut.',
        TriggerContext.photoLimit =>
          'Halte deinen Heilungsverlauf mit unbegrenzten Fotos '
              'fest — für dich und deinen Arzt.',
        TriggerContext.documentLimit =>
          'Arztbriefe, Befunde, Rezepte — alles sicher '
              'gespeichert und immer dabei.',
        TriggerContext.arztberichtExport =>
          'Exportiere deinen Gesundheitsbericht und teile '
              'ihn direkt mit deinem Arzt.',
        TriggerContext.redFlagFeature =>
          'Das Red-Flag System erkennt kritische Werte und '
              'warnt dich automatisch — damit du sicher bist.',
        TriggerContext.progressFeature =>
          'Streaks, Badges und dein Recovery-Score — '
              'sieh deine Fortschritte auf einen Blick.',
        _ =>
          'Mit Pro bekommst du volle Kontrolle über deine '
              'OP-Vorbereitung, Dokumentation und Genesung.',
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
