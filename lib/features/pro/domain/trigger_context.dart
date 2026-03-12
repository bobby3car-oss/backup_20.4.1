import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

import '../../../ui/theme/app_icons.dart';

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

  /// Rehab plans, timer and rehab progress.
  rehabFeature,

  /// Red-Flag / Alert system (hard block).
  redFlagFeature,

  /// Progress / Fortschritt screen (hard block).
  progressFeature,

  /// Analytics Dashboard (hard block).
  analyticsFeature,

  /// Apple Health / Google Health Connect sync (hard block).
  healthSyncFeature,

  /// AI assistant chat (hard block).
  assistantFeature,

  // ── Packing List Feature Gates ───────────────────────────────

  /// Sharing / collaboration on packing lists (hard block).
  packingCollaboration,

  /// User exceeded the free packing list limit (soft limit: max 1 free).
  packingListLimit,

  /// User tried to use a premium packing template (hard block).
  packingTemplateLimit,

  /// Extended vitals charts (7/30 day view, soft gate).
  vitalsChartsFeature,

  /// Pain diary insights: statistics, trends, calendar heatmap (soft gate).
  painDiaryInsights,

  /// Bella AI Actions mode — creating entries via chat (hard block).
  bellaActionsMode,
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
        TriggerContext.rehabFeature => 'rehab_feature',
        TriggerContext.redFlagFeature => 'red_flag',
        TriggerContext.progressFeature => 'progress',
        TriggerContext.analyticsFeature => 'analytics',
        TriggerContext.healthSyncFeature => 'health_sync',
        TriggerContext.assistantFeature => 'assistant',
        TriggerContext.packingCollaboration => 'packing_collaboration',
        TriggerContext.packingListLimit => 'packing_list_limit',
        TriggerContext.packingTemplateLimit => 'packing_template_limit',
        TriggerContext.vitalsChartsFeature => 'vitals_charts',
        TriggerContext.painDiaryInsights => 'pain_diary_insights',
        TriggerContext.bellaActionsMode => 'bella_actions',
      };

  /// Which surface type should be used for this trigger.
  PaywallSurfaceType get surfaceType => switch (this) {
        TriggerContext.relativesFeature => PaywallSurfaceType.fullscreen,
        TriggerContext.manualOpen => PaywallSurfaceType.fullscreen,
        TriggerContext.settingsProButton => PaywallSurfaceType.fullscreen,
        TriggerContext.voiceFeature => PaywallSurfaceType.fullscreen,
        TriggerContext.progressFeature => PaywallSurfaceType.fullscreen,
        TriggerContext.analyticsFeature => PaywallSurfaceType.fullscreen,
        TriggerContext.healthSyncFeature => PaywallSurfaceType.fullscreen,
        TriggerContext.redFlagFeature => PaywallSurfaceType.fullscreen,
        TriggerContext.arztberichtExport => PaywallSurfaceType.fullscreen,
        TriggerContext.rehabFeature => PaywallSurfaceType.fullscreen,
        TriggerContext.assistantFeature => PaywallSurfaceType.fullscreen,
        TriggerContext.packingCollaboration => PaywallSurfaceType.fullscreen,
        TriggerContext.packingListLimit => PaywallSurfaceType.bottomSheet,
        TriggerContext.packingTemplateLimit => PaywallSurfaceType.bottomSheet,
        TriggerContext.timelineBanner => PaywallSurfaceType.bottomSheet,
        TriggerContext.dashboardCard => PaywallSurfaceType.bottomSheet,
        TriggerContext.photoLimit => PaywallSurfaceType.bottomSheet,
        TriggerContext.documentLimit => PaywallSurfaceType.bottomSheet,
        TriggerContext.vitalsChartsFeature => PaywallSurfaceType.bottomSheet,
        TriggerContext.painDiaryInsights => PaywallSurfaceType.bottomSheet,
        TriggerContext.bellaActionsMode => PaywallSurfaceType.fullscreen,
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
        TriggerContext.rehabFeature => true,
        TriggerContext.redFlagFeature => true,
        TriggerContext.progressFeature => true,
        TriggerContext.analyticsFeature => true,
        TriggerContext.healthSyncFeature => true,
        TriggerContext.assistantFeature => true,
        TriggerContext.packingCollaboration => true,
        TriggerContext.packingListLimit => true,
        TriggerContext.packingTemplateLimit => true,
        TriggerContext.bellaActionsMode => true,
        _ => false,
      };

  /// Icon for the trigger context (used in paywall UI).
  IconData get icon => switch (this) {
        TriggerContext.relativesFeature => AppIcons.family,
        TriggerContext.dashboardCard => AppIcons.rocket,
        TriggerContext.timelineBanner => AppIcons.clipboard,
        TriggerContext.manualOpen => AppIcons.pro,
        TriggerContext.settingsProButton => AppIcons.pro,
        TriggerContext.voiceFeature => AppIcons.voice,
        TriggerContext.photoLimit => AppIcons.photos,
        TriggerContext.documentLimit => AppIcons.documents,
        TriggerContext.arztberichtExport => AppIcons.doctor,
        TriggerContext.rehabFeature => AppIcons.rehab,
        TriggerContext.redFlagFeature => AppIcons.redFlags,
        TriggerContext.progressFeature => AppIcons.progress,
        TriggerContext.analyticsFeature => AppIcons.analytics,
        TriggerContext.healthSyncFeature => AppIcons.vitals,
        TriggerContext.assistantFeature => AppIcons.help,
        TriggerContext.packingCollaboration => AppIcons.family,
        TriggerContext.packingListLimit => AppIcons.packing,
        TriggerContext.packingTemplateLimit => AppIcons.notes,
        TriggerContext.vitalsChartsFeature => AppIcons.vitals,
        TriggerContext.painDiaryInsights => AppIcons.wound,
        TriggerContext.bellaActionsMode => AppIcons.help,
      };

  Color get iconColor => switch (this) {
        TriggerContext.relativesFeature => AppIcons.familyColor,
        TriggerContext.dashboardCard => AppIcons.rocketColor,
        TriggerContext.timelineBanner => AppIcons.clipboardColor,
        TriggerContext.manualOpen => AppIcons.proColor,
        TriggerContext.settingsProButton => AppIcons.proColor,
        TriggerContext.voiceFeature => AppIcons.voiceColor,
        TriggerContext.photoLimit => AppIcons.photosColor,
        TriggerContext.documentLimit => AppIcons.documentsColor,
        TriggerContext.arztberichtExport => AppIcons.doctorColor,
        TriggerContext.rehabFeature => AppIcons.rehabColor,
        TriggerContext.redFlagFeature => AppIcons.redFlagsColor,
        TriggerContext.progressFeature => AppIcons.progressColor,
        TriggerContext.analyticsFeature => AppIcons.analyticsColor,
        TriggerContext.healthSyncFeature => AppIcons.vitalsColor,
        TriggerContext.assistantFeature => AppIcons.helpColor,
        TriggerContext.packingCollaboration => AppIcons.familyColor,
        TriggerContext.packingListLimit => AppIcons.packingColor,
        TriggerContext.packingTemplateLimit => AppIcons.notesColor,
        TriggerContext.vitalsChartsFeature => AppIcons.vitalsColor,
        TriggerContext.painDiaryInsights => AppIcons.woundColor,
        TriggerContext.bellaActionsMode => AppIcons.helpColor,
      };

  /// Emoji for the trigger context (kept for notification text).
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
        TriggerContext.rehabFeature => '🏋️',
        TriggerContext.redFlagFeature => '🚨',
        TriggerContext.progressFeature => '💪',
        TriggerContext.analyticsFeature => '📊',
        TriggerContext.healthSyncFeature => '❤️',
        TriggerContext.assistantFeature => '🤖',
        TriggerContext.packingCollaboration => '👥',
        TriggerContext.packingListLimit => '🧳',
        TriggerContext.packingTemplateLimit => '📝',
        TriggerContext.vitalsChartsFeature => '🩺',
        TriggerContext.painDiaryInsights => '🩹',
        TriggerContext.bellaActionsMode => '🐰⚡',
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
        TriggerContext.rehabFeature =>
          'Reha mit Plan statt Zufall',
        TriggerContext.redFlagFeature =>
          'Automatische Überwachung freischalten',
        TriggerContext.progressFeature =>
          'Sieh wie weit du gekommen bist',
        TriggerContext.analyticsFeature =>
          'Deine Daten. Dein Überblick.',
        TriggerContext.healthSyncFeature =>
          'Deine Gesundheitsdaten. Automatisch.',
        TriggerContext.assistantFeature =>
          'Dein persönlicher OP-Assistent',
        TriggerContext.packingCollaboration =>
          'Gemeinsam packen, nichts vergessen',
        TriggerContext.packingListLimit =>
          'Mehr Listen für jede Situation',
        TriggerContext.packingTemplateLimit =>
          'Professionelle Vorlagen nutzen',
        TriggerContext.vitalsChartsFeature =>
          'Deine Vitalwerte im Blick',
        TriggerContext.painDiaryInsights =>
          'Dein Schmerztagebuch. Volle Insights.',
        TriggerContext.bellaActionsMode =>
          'Bella erstellt Einträge für dich',
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
        TriggerContext.rehabFeature =>
          'Strukturierte Übungen, Timer und Reha-Fortschritt '
              'helfen dir, konsequent dranzubleiben.',
        TriggerContext.redFlagFeature =>
          'Mit Pro erkennt das Red-Flag System kritische Werte '
              'automatisch und warnt dich sofort — noch bevor du es merkst.',
        TriggerContext.progressFeature =>
          'Streaks, Badges und dein Recovery-Score — '
              'sieh deine Fortschritte auf einen Blick.',
        TriggerContext.analyticsFeature =>
          'Interaktive Diagramme zeigen dir Schmerz, Vitals '
              'und Wundheilung im Zeitverlauf.',
        TriggerContext.healthSyncFeature =>
          'Verbinde Apple Health oder Google Health Connect '
              'und synchronisiere Herzfrequenz, Blutdruck und Schritte automatisch.',
        TriggerContext.assistantFeature =>
          'Dein KI-Assistent beantwortet Fragen zu OPs, '
              'Nachsorge und App-Bedienung — komplett offline.',
        TriggerContext.packingCollaboration =>
          'Teile deine Packliste mit Angehörigen und '
              'bearbeitet sie gemeinsam — so wird garantiert nichts vergessen.',
        TriggerContext.packingListLimit =>
          'Erstelle unbegrenzt Packlisten für verschiedene '
              'OPs, Reha-Aufenthalte oder Familienmitglieder.',
        TriggerContext.packingTemplateLimit =>
          'Nutze professionelle Vorlagen für Kinder-OPs, '
              'Reha und mehr — sofort einsatzbereit.',
        TriggerContext.vitalsChartsFeature =>
          'Verfolge Blutdruck, Puls und mehr '
              'über 7 oder 30 Tage — mit interaktiven Charts.',
        TriggerContext.painDiaryInsights =>
          'Erkenne Trends, Auslöser und Muster — '
              'mit Kalender-Heatmap, Statistiken und Verlaufsdiagrammen.',
        TriggerContext.bellaActionsMode =>
          'Sag Bella einfach was du brauchst — Termine, Aufgaben, '
              'Vitalwerte, Schmerz oder Medikamente. '
              'Sie erstellt den Eintrag für dich.',
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
