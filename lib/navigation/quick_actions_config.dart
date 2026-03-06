import 'package:flutter/material.dart';

enum QuickActionCategory { doku, planning, safety, doctor, info, settings }

class QuickActionItem {
  const QuickActionItem({
    required this.id,
    required this.emoji,
    required this.title,
    this.subtitle,
    required this.routeName,
    required this.category,
    this.isPrimaryDock = false,
  });

  final String id;
  final String emoji;
  final String title;
  final String? subtitle;
  final String routeName;
  final QuickActionCategory category;
  final bool isPrimaryDock;
}

const kQuickActions = <QuickActionItem>[
  // 🩹 Doku
  QuickActionItem(
    id: 'wound',
    emoji: '🩹',
    title: 'Wunddoku',
    subtitle: 'Wunden dokumentieren',
    routeName: '/wound',
    category: QuickActionCategory.doku,
    isPrimaryDock: true,
  ),
  QuickActionItem(
    id: 'pain',
    emoji: '😣',
    title: 'Schmerztagebuch',
    subtitle: 'Schmerz erfassen',
    routeName: '/pain',
    category: QuickActionCategory.doku,
    isPrimaryDock: true,
  ),
  QuickActionItem(
    id: 'voice',
    emoji: '🎙️',
    title: 'Sprachnotizen',
    subtitle: 'Memo aufnehmen',
    routeName: '/voice',
    category: QuickActionCategory.doku,
  ),
  QuickActionItem(
    id: 'photos',
    emoji: '📷',
    title: 'Fotos',
    subtitle: 'Doku-Hub für Kamera & Galerie',
    routeName: '/photos',
    category: QuickActionCategory.doku,
  ),
  QuickActionItem(
    id: 'documents',
    emoji: '📄',
    title: 'Dokumente',
    subtitle: 'Befunde & Berichte',
    routeName: '/documents',
    category: QuickActionCategory.doku,
    isPrimaryDock: true,
  ),

  // 📅 Planung
  QuickActionItem(
    id: 'appointments',
    emoji: '📅',
    title: 'Termine',
    subtitle: 'Alle Termine im Blick',
    routeName: '/appointments',
    category: QuickActionCategory.planning,
    isPrimaryDock: true,
  ),
  QuickActionItem(
    id: 'packing',
    emoji: '🧳',
    title: 'Packliste',
    subtitle: 'Checkliste für die Klinik',
    routeName: '/packing',
    category: QuickActionCategory.planning,
  ),

  // 🚦 Sicherheit
  QuickActionItem(
    id: 'warnings',
    emoji: '🚦',
    title: 'Warnzeichen',
    subtitle: 'Symptome prüfen',
    routeName: '/warnings',
    category: QuickActionCategory.safety,
    isPrimaryDock: true,
  ),
  QuickActionItem(
    id: 'red-flags',
    emoji: '🚨',
    title: 'Red Flags',
    subtitle: 'Warnungen & Notfall',
    routeName: '/alerts',
    category: QuickActionCategory.safety,
  ),

  // ❓ Arzt
  QuickActionItem(
    id: 'doctor-questions',
    emoji: '❓',
    title: 'Fragen',
    subtitle: 'Operateur & Anästhesist',
    routeName: '/doctor-questions',
    category: QuickActionCategory.doctor,
  ),
  QuickActionItem(
    id: 'doctor-report',
    emoji: '🧑‍⚕️',
    title: 'Arztbericht',
    subtitle: 'Zusammenfassung für den Arzt',
    routeName: '/doctor-report',
    category: QuickActionCategory.doctor,
  ),

  // ℹ️ Infos
  QuickActionItem(
    id: 'op-info',
    emoji: 'ℹ️',
    title: 'OP-Infos',
    subtitle: 'Vor, während & nach der OP',
    routeName: '/op-info',
    category: QuickActionCategory.info,
  ),

  // ⚙️ Einstellungen
  QuickActionItem(
    id: 'settings',
    emoji: '⚙️',
    title: 'Einstellungen',
    subtitle: 'Account & Rechtliches',
    routeName: '/settings',
    category: QuickActionCategory.settings,
  ),
  QuickActionItem(
    id: 'privacy',
    emoji: '🔒',
    title: 'Datenschutz',
    routeName: '/privacy',
    category: QuickActionCategory.settings,
  ),
  QuickActionItem(
    id: 'imprint',
    emoji: '📜',
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
      return '🩹 Dokumentation';
    case QuickActionCategory.planning:
      return '📅 Planung';
    case QuickActionCategory.safety:
      return '🚦 Sicherheit';
    case QuickActionCategory.doctor:
      return '❓ Arzt';
    case QuickActionCategory.info:
      return 'ℹ️ Infos';
    case QuickActionCategory.settings:
      return '⚙️ Einstellungen';
  }
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
      const SnackBar(
        content: Text('Kommt gleich ✨'),
        duration: Duration(milliseconds: 1400),
      ),
    );
  }
}
