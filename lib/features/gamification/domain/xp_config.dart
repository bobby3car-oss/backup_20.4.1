import 'package:flutter/material.dart';
import '../../../ui/ui.dart';

/// All XP reward values and level thresholds.
abstract final class XpConfig {
  // ── XP rewards per action ──
  static const int taskDone = 10;
  static const int woundPhoto = 15;
  static const int painLog = 5;
  static const int vitalsLog = 5;
  static const int medicationLog = 8;
  static const int rehabSession = 12;
  static const int dailyCompleteBonus = 20;
  static const int challengeComplete = 25;
  static const int milestonePhase = 50;

  // ── Combo & Streak multipliers (Pro) ──

  /// Seconds within which consecutive actions count as a combo.
  static const int comboWindowSeconds = 300; // 5 minutes

  /// Maximum combo multiplier (1.0 + comboMax * 0.1 = 1.5x).
  static const int comboMax = 5;

  /// Extra XP per combo step.
  static const int comboBonus = 3;

  /// Streak threshold → multiplier factor (applied to base XP).
  static double streakMultiplier(int streak) {
    if (streak >= 30) return 1.5;
    if (streak >= 14) return 1.3;
    if (streak >= 7) return 1.15;
    return 1.0;
  }

  /// XP needed to go from [level] to level+1.
  static int xpForLevel(int level) => 100 * level;

  /// Compute level from total XP.
  static int levelFromXp(int totalXp) {
    var level = 1;
    var accumulated = 0;
    while (accumulated + xpForLevel(level) <= totalXp) {
      accumulated += xpForLevel(level);
      level++;
    }
    return level;
  }
}

/// Metadata for a single badge definition (template, not earned instance).
class BadgeDefinition {
  const BadgeDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.xpReward = 0,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final int xpReward;
}

/// All available badges in the app.
abstract final class BadgeCatalog {
  static const streak7 = BadgeDefinition(
    id: 'streak_7',
    title: '7-Tage Streak',
    description: '7 Tage in Folge dokumentiert',
    icon: Icons.local_fire_department_rounded,
    color: AppColors.warning,
    xpReward: 30,
  );

  static const streak14 = BadgeDefinition(
    id: 'streak_14',
    title: '14-Tage Streak',
    description: '14 Tage in Folge dokumentiert',
    icon: Icons.local_fire_department_rounded,
    color: Color(0xFFFF6B00),
    xpReward: 50,
  );

  static const streak30 = BadgeDefinition(
    id: 'streak_30',
    title: '30-Tage Streak',
    description: '30 Tage in Folge aktiv',
    icon: Icons.star_rounded,
    color: AppColors.accent,
    xpReward: 100,
  );

  static const firstWeek = BadgeDefinition(
    id: 'first_week',
    title: 'Erste Woche',
    description: 'Erste Woche nach OP gemeistert',
    icon: Icons.emoji_events_rounded,
    color: Color(0xFFFFD700),
    xpReward: 40,
  );

  static const vitalsPro = BadgeDefinition(
    id: 'vitals_pro',
    title: 'Vital-Profi',
    description: '30× Vitalwerte eingetragen',
    icon: Icons.favorite_rounded,
    color: AppColors.error,
    xpReward: 40,
  );

  static const photoDocumentor = BadgeDefinition(
    id: 'photo_doc',
    title: 'Foto-Dokumentar',
    description: '14 Wundfotos hochgeladen',
    icon: Icons.camera_alt_rounded,
    color: AppColors.primary,
    xpReward: 30,
  );

  static const medicationHero = BadgeDefinition(
    id: 'medication_hero',
    title: 'Medikamenten-Held',
    description: '7 Tage keine Einnahme verpasst',
    icon: Icons.medication_rounded,
    color: AppColors.success,
    xpReward: 30,
  );

  static const painDiaryPro = BadgeDefinition(
    id: 'pain_diary_pro',
    title: 'Schmerz-Tracker',
    description: '20× Schmerzen dokumentiert',
    icon: Icons.edit_note_rounded,
    color: Color(0xFFE91E63),
    xpReward: 30,
  );

  static const earlyBird = BadgeDefinition(
    id: 'early_bird',
    title: 'Frühstarter',
    description: 'Ersten Task am ersten Tag erledigt',
    icon: Icons.wb_sunny_rounded,
    color: Color(0xFFFFC107),
    xpReward: 15,
  );

  static const taskMaster = BadgeDefinition(
    id: 'task_master',
    title: 'Aufgaben-Meister',
    description: '50 Tasks erledigt',
    icon: Icons.task_alt_rounded,
    color: AppColors.success,
    xpReward: 60,
  );

  static const level5 = BadgeDefinition(
    id: 'level_5',
    title: 'Genesungs-Profi',
    description: 'Level 5 erreicht',
    icon: Icons.workspace_premium_rounded,
    color: AppColors.primary,
    xpReward: 0, // XP already earned from leveling
  );

  static const level10 = BadgeDefinition(
    id: 'level_10',
    title: 'Comeback-König',
    description: 'Level 10 erreicht',
    icon: Icons.military_tech_rounded,
    color: Color(0xFFFFD700),
    xpReward: 0,
  );

  /// All badges in display order.
  static const List<BadgeDefinition> all = [
    earlyBird,
    streak7,
    firstWeek,
    streak14,
    vitalsPro,
    photoDocumentor,
    medicationHero,
    painDiaryPro,
    taskMaster,
    streak30,
    level5,
    level10,
  ];

  /// Lookup by id.
  static BadgeDefinition? byId(String id) {
    for (final badge in all) {
      if (badge.id == id) return badge;
    }
    return null;
  }
}

/// Level titles for display.
abstract final class LevelNames {
  static String forLevel(int level) => switch (level) {
        1 => 'Neuling',
        2 => 'Anfänger',
        3 => 'Lernender',
        4 => 'Fortgeschritten',
        5 => 'Genesungs-Profi',
        6 => 'Experte',
        7 => 'Meister',
        8 => 'Veteran',
        9 => 'Champion',
        10 => 'Comeback-König',
        _ => 'Legende (Lv. $level)',
      };
}
