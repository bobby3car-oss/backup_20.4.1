import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../ui/ui.dart';

/// Status of a milestone.
enum MilestoneStatus {
  /// Not yet started / requirements not met.
  locked,

  /// Partially completed — progress is visible.
  inProgress,

  /// Fully completed.
  completed,
}

/// Category of milestone (drives grouping and visuals).
enum MilestoneCategory {
  /// Tied to an OP phase (preop, opday, week1, week2, followup).
  phase,

  /// Weekly behaviour goal (e.g. "7 Tage in Folge dokumentiert").
  weekly,

  /// Cumulative behaviour goal (e.g. "30 Vitalwerte").
  behaviour,
}

/// A single milestone definition.
class MilestoneDefinition {
  const MilestoneDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    required this.color,
    required this.xpReward,
    required this.targetValue,
    this.phase,
  });

  final String id;
  final String title;
  final String description;
  final MilestoneCategory category;
  final IconData icon;
  final Color color;
  final int xpReward;

  /// The numeric target that [MilestoneProgress.currentValue] is compared to.
  final int targetValue;

  /// For [MilestoneCategory.phase] milestones — the OP phase key.
  final String? phase;
}

/// Runtime progress toward a milestone.
class MilestoneProgress {
  const MilestoneProgress({
    required this.milestoneId,
    this.currentValue = 0,
    this.status = MilestoneStatus.locked,
    this.completedAt,
  });

  final String milestoneId;
  final int currentValue;
  final MilestoneStatus status;
  final DateTime? completedAt;

  /// 0.0 – 1.0 progress ratio.
  double progressFor(MilestoneDefinition def) {
    if (def.targetValue <= 0) return status == MilestoneStatus.completed ? 1.0 : 0.0;
    return (currentValue / def.targetValue).clamp(0.0, 1.0);
  }

  MilestoneProgress copyWith({
    String? milestoneId,
    int? currentValue,
    MilestoneStatus? status,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    return MilestoneProgress(
      milestoneId: milestoneId ?? this.milestoneId,
      currentValue: currentValue ?? this.currentValue,
      status: status ?? this.status,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
    );
  }

  Map<String, dynamic> toJson() => {
        'milestoneId': milestoneId,
        'currentValue': currentValue,
        'status': status.name,
        'completedAt': completedAt?.toIso8601String(),
      };

  factory MilestoneProgress.fromJson(Map<String, dynamic> json) {
    return MilestoneProgress(
      milestoneId: json['milestoneId'] as String? ?? '',
      currentValue: (json['currentValue'] as num?)?.toInt() ?? 0,
      status: MilestoneStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => MilestoneStatus.locked,
      ),
      completedAt: _parseDateTime(json['completedAt']),
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
    return null;
  }
}

/// All milestone definitions in the app.
abstract final class MilestoneCatalog {
  // ── Phase milestones ──

  static const preopComplete = MilestoneDefinition(
    id: 'ms_preop',
    title: 'Vorbereitung abgeschlossen',
    description: 'Alle Vorbereitungs-Aufgaben erledigt',
    category: MilestoneCategory.phase,
    icon: Icons.checklist_rounded,
    color: AppColors.primary,
    xpReward: 75,
    targetValue: 1,
    phase: 'preop',
  );

  static const opdayComplete = MilestoneDefinition(
    id: 'ms_opday',
    title: 'OP-Tag geschafft',
    description: 'Alle OP-Tag Aufgaben abgehakt',
    category: MilestoneCategory.phase,
    icon: Icons.local_hospital_rounded,
    color: AppColors.accent,
    xpReward: 100,
    targetValue: 1,
    phase: 'opday',
  );

  static const week1Complete = MilestoneDefinition(
    id: 'ms_week1',
    title: 'Woche 1 gemeistert',
    description: 'Erste Woche nach OP erfolgreich abgeschlossen',
    category: MilestoneCategory.phase,
    icon: Icons.emoji_events_rounded,
    color: Color(0xFFFFD700),
    xpReward: 150,
    targetValue: 1,
    phase: 'week1',
  );

  static const week2Complete = MilestoneDefinition(
    id: 'ms_week2',
    title: 'Woche 2 abgeschlossen',
    description: 'Aktivierungsphase erfolgreich beendet',
    category: MilestoneCategory.phase,
    icon: Icons.fitness_center_rounded,
    color: AppColors.success,
    xpReward: 150,
    targetValue: 1,
    phase: 'week2',
  );

  static const followupDone = MilestoneDefinition(
    id: 'ms_followup',
    title: 'Nachkontrolle erledigt',
    description: 'Follow-up Termine wahrgenommen',
    category: MilestoneCategory.phase,
    icon: Icons.verified_rounded,
    color: AppColors.primary,
    xpReward: 100,
    targetValue: 1,
    phase: 'followup',
  );

  // ── Weekly milestones ──

  static const perfectWeek = MilestoneDefinition(
    id: 'ms_perfect_week',
    title: 'Perfekte Woche',
    description: '7 Tage in Folge alle Aufgaben erledigt',
    category: MilestoneCategory.weekly,
    icon: Icons.star_rounded,
    color: AppColors.warning,
    xpReward: 80,
    targetValue: 7,
  );

  static const docuWeek = MilestoneDefinition(
    id: 'ms_docu_week',
    title: 'Dokumentations-Woche',
    description: '7 Tage in Folge Wundfoto + Schmerz dokumentiert',
    category: MilestoneCategory.weekly,
    icon: Icons.auto_awesome_rounded,
    color: AppColors.accent,
    xpReward: 60,
    targetValue: 7,
  );

  // ── Behaviour milestones ──

  static const tasks25 = MilestoneDefinition(
    id: 'ms_tasks_25',
    title: '25 Aufgaben',
    description: '25 Aufgaben erledigt – du machst Fortschritte!',
    category: MilestoneCategory.behaviour,
    icon: Icons.task_alt_rounded,
    color: AppColors.success,
    xpReward: 50,
    targetValue: 25,
  );

  static const tasks100 = MilestoneDefinition(
    id: 'ms_tasks_100',
    title: '100 Aufgaben',
    description: '100 Aufgaben geschafft – beeindruckend!',
    category: MilestoneCategory.behaviour,
    icon: Icons.military_tech_rounded,
    color: Color(0xFFFFD700),
    xpReward: 120,
    targetValue: 100,
  );

  static const photos10 = MilestoneDefinition(
    id: 'ms_photos_10',
    title: '10 Wundfotos',
    description: '10 Wundfotos dokumentiert',
    category: MilestoneCategory.behaviour,
    icon: Icons.camera_alt_rounded,
    color: AppColors.primary,
    xpReward: 40,
    targetValue: 10,
  );

  static const vitals20 = MilestoneDefinition(
    id: 'ms_vitals_20',
    title: '20 Vital-Checks',
    description: '20× Vitalwerte eingetragen',
    category: MilestoneCategory.behaviour,
    icon: Icons.monitor_heart_rounded,
    color: AppColors.error,
    xpReward: 40,
    targetValue: 20,
  );

  static const painDiary15 = MilestoneDefinition(
    id: 'ms_pain_15',
    title: '15 Schmerzeinträge',
    description: '15× Schmerzen dokumentiert',
    category: MilestoneCategory.behaviour,
    icon: Icons.edit_note_rounded,
    color: Color(0xFFE91E63),
    xpReward: 35,
    targetValue: 15,
  );

  /// All milestones in display order.
  static const List<MilestoneDefinition> all = [
    // Phase
    preopComplete,
    opdayComplete,
    week1Complete,
    week2Complete,
    followupDone,
    // Weekly
    perfectWeek,
    docuWeek,
    // Behaviour
    tasks25,
    tasks100,
    photos10,
    vitals20,
    painDiary15,
  ];

  /// Lookup by id.
  static MilestoneDefinition? byId(String id) {
    for (final ms in all) {
      if (ms.id == id) return ms;
    }
    return null;
  }
}
