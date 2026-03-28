import 'package:flutter/material.dart';

import '../ui/theme/app_icons.dart';


enum QuickActionCategory { doku, planning, safety, doctor, info, settings }

class QuickActionItem {
  const QuickActionItem({
    required this.id,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.routeName,
    required this.category,
    this.isPrimaryDock = false,
    this.isProFeature = false,
  });

  final String id;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final String routeName;
  final QuickActionCategory category;
  final bool isPrimaryDock;
  final bool isProFeature;
}

final kQuickActions = <QuickActionItem>[
  // Doku
  QuickActionItem(
    id: 'wound',
    icon: AppIcons.wound,
    iconColor: AppIcons.woundColor,
    title: 'Wunddoku',
    subtitle: 'Wunden dokumentieren',
    routeName: '/wound',
    category: QuickActionCategory.doku,
    isPrimaryDock: true,
  ),
  QuickActionItem(
    id: 'pain',
    icon: AppIcons.pain,
    iconColor: AppIcons.painColor,
    title: 'Schmerztagebuch',
    subtitle: 'Schmerz erfassen',
    routeName: '/pain',
    category: QuickActionCategory.doku,
    isPrimaryDock: true,
  ),
  QuickActionItem(
    id: 'voice',
    icon: AppIcons.voice,
    iconColor: AppIcons.voiceColor,
    title: 'Sprachnotizen',
    subtitle: 'Memo aufnehmen',
    routeName: '/voice',
    category: QuickActionCategory.doku,
    isProFeature: true,
  ),
  QuickActionItem(
    id: 'photos',
    icon: AppIcons.photos,
    iconColor: AppIcons.photosColor,
    title: 'Fotos',
    subtitle: 'Doku-Hub für Kamera & Galerie',
    routeName: '/photos',
    category: QuickActionCategory.doku,
  ),
  QuickActionItem(
    id: 'documents',
    icon: AppIcons.documents,
    iconColor: AppIcons.documentsColor,
    title: 'Dokumente',
    subtitle: 'Befunde & Berichte',
    routeName: '/documents',
    category: QuickActionCategory.doku,
    isPrimaryDock: true,
  ),
  QuickActionItem(
    id: 'nutrition',
    icon: AppIcons.nutrition,
    iconColor: AppIcons.nutritionColor,
    title: 'Ernährungstagebuch',
    subtitle: 'Mahlzeiten & Empfehlungen',
    routeName: '/nutrition',
    category: QuickActionCategory.doku,
  ),

  // Planung
  QuickActionItem(
    id: 'appointments',
    icon: AppIcons.appointments,
    iconColor: AppIcons.appointmentsColor,
    title: 'Termine',
    subtitle: 'Alle Termine im Blick',
    routeName: '/appointments',
    category: QuickActionCategory.planning,
    isPrimaryDock: true,
  ),
  QuickActionItem(
    id: 'packing',
    icon: AppIcons.packing,
    iconColor: AppIcons.packingColor,
    title: 'Packliste',
    subtitle: 'Checkliste für die Klinik',
    routeName: '/packing',
    category: QuickActionCategory.planning,
  ),
  QuickActionItem(
    id: 'rehab',
    icon: AppIcons.rehab,
    iconColor: AppIcons.rehabColor,
    title: 'Reha',
    subtitle: 'Übungen, Timer & Fortschritt',
    routeName: '/rehab',
    category: QuickActionCategory.planning,
    isProFeature: true,
  ),

  // Sicherheit
  QuickActionItem(
    id: 'warnings',
    icon: AppIcons.warnings,
    iconColor: AppIcons.warningsColor,
    title: 'Warnzeichen',
    subtitle: 'Symptome prüfen',
    routeName: '/warnings',
    category: QuickActionCategory.safety,
    isPrimaryDock: true,
  ),
  QuickActionItem(
    id: 'red-flags',
    icon: AppIcons.redFlags,
    iconColor: AppIcons.redFlagsColor,
    title: 'Red Flags',
    subtitle: 'Warnungen & Notfall',
    routeName: '/alerts',
    category: QuickActionCategory.safety,
  ),

  // Arzt
  QuickActionItem(
    id: 'doctor-questions',
    icon: AppIcons.questions,
    iconColor: AppIcons.questionsColor,
    title: 'Fragen',
    subtitle: 'Operateur & Anästhesist',
    routeName: '/doctor-questions',
    category: QuickActionCategory.doctor,
  ),
  QuickActionItem(
    id: 'doctor-report',
    icon: AppIcons.doctor,
    iconColor: AppIcons.doctorColor,
    title: 'Arztbericht',
    subtitle: 'Zusammenfassung für den Arzt',
    routeName: '/doctor-report',
    category: QuickActionCategory.doctor,
    isProFeature: true,
  ),

  // Infos
  QuickActionItem(
    id: 'op-info',
    icon: AppIcons.info,
    iconColor: AppIcons.infoColor,
    title: 'OP-Infos',
    subtitle: 'Vor, während & nach der OP',
    routeName: '/op-info',
    category: QuickActionCategory.info,
  ),

  // Einstellungen
  QuickActionItem(
    id: 'settings',
    icon: AppIcons.settings,
    iconColor: AppIcons.settingsColor,
    title: 'Einstellungen',
    subtitle: 'Account & Rechtliches',
    routeName: '/settings',
    category: QuickActionCategory.settings,
  ),
  QuickActionItem(
    id: 'privacy',
    icon: AppIcons.privacy,
    iconColor: AppIcons.privacyColor,
    title: 'Datenschutz',
    routeName: '/privacy',
    category: QuickActionCategory.settings,
  ),
  QuickActionItem(
    id: 'imprint',
    icon: AppIcons.imprint,
    iconColor: AppIcons.imprintColor,
    title: 'Impressum',
    routeName: '/imprint',
    category: QuickActionCategory.settings,
  ),
];

List<QuickActionItem> get primaryDockActions =>
    kQuickActions.where((a) => a.isPrimaryDock).toList();

String categoryLabel(QuickActionCategory cat) {
  switch (cat) {
    case QuickActionCategory.doku:
      return 'Dokumentation';
    case QuickActionCategory.planning:
      return 'Planung';
    case QuickActionCategory.safety:
      return 'Sicherheit';
    case QuickActionCategory.doctor:
      return 'Arzt';
    case QuickActionCategory.info:
      return 'Infos';
    case QuickActionCategory.settings:
      return 'Einstellungen';
  }
}

/// Icon and colour for each category (used in section headers).
(IconData, Color) categoryIcon(QuickActionCategory cat) {
  return switch (cat) {
    QuickActionCategory.doku => (AppIcons.wound, AppIcons.woundColor),
    QuickActionCategory.planning => (AppIcons.appointments, AppIcons.appointmentsColor),
    QuickActionCategory.safety => (AppIcons.warnings, AppIcons.warningsColor),
    QuickActionCategory.doctor => (AppIcons.doctor, AppIcons.doctorColor),
    QuickActionCategory.info => (AppIcons.info, AppIcons.infoColor),
    QuickActionCategory.settings => (AppIcons.settings, AppIcons.settingsColor),
  };
}

Future<void> navigateToNamedRoute(
  BuildContext context,
  String routeName,
) async {
  final nav = Navigator.of(context);
  final messenger = ScaffoldMessenger.maybeOf(context);
  try {
    await nav.pushNamed(routeName);
  } catch (_) {
    messenger?.showSnackBar(
      SnackBar(
        content: Text('Kommt gleich'),
        duration: Duration(milliseconds: 1400),
      ),
    );
  }
}
