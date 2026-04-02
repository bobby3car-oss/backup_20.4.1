import 'dart:async';

import '../../../domain/task_orchestrator.dart';
import '../../../domain/timeline_engine.dart';
import '../../medication/data/medication_repository_local.dart';
import '../../mood/data/mood_repository_local.dart';
import '../../pain/data/pain_repository_local.dart';
import '../../red_flags/data/red_flag_repository_local.dart';
import '../../sleep/data/sleep_repository_local.dart';
import '../../supplements/data/supplement_intake_repository_local.dart';
import '../../vitals/data/vital_repository_local.dart';
import '../../nutrition/data/nutrition_repository_local.dart';
import '../../warnings/data/symptom_check_repository_local.dart';

/// Collects current patient data to provide as context to the AI assistant.
class PatientContext {
  const PatientContext({
    this.painEntries = const [],
    this.latestVitals,
    this.medications = const [],
    this.supplements = const [],
    this.openTasks = const [],
    this.redFlags = const [],
    this.nutritionEntries = const [],
    this.moodEntries = const [],
    this.sleepEntries = const [],
    this.lastSymptomCheck,
    this.opPhase,
  });

  final List<PatientPainSummary> painEntries;
  final PatientVitalSummary? latestVitals;
  final List<PatientMedSummary> medications;
  final List<PatientSupplementSummary> supplements;
  final List<PatientTaskSummary> openTasks;
  final List<PatientRedFlagSummary> redFlags;
  final List<PatientNutritionSummary> nutritionEntries;
  final List<PatientMoodSummary> moodEntries;
  final List<PatientSleepSummary> sleepEntries;
  final PatientSymptomCheckSummary? lastSymptomCheck;
  final String? opPhase;

  /// Gather context from local repositories.
  static Future<PatientContext> gather(TaskOrchestrator orchestrator) async {
    // Pain – last 5 entries.
    final painList =
        await PainRepositoryLocal.instance.watchAll().first;
    final recentPain = painList.take(5).map((e) => PatientPainSummary(
          date: e.occurredAt.toIso8601String().substring(0, 10),
          level: e.painLevel,
          region: e.bodyRegion?.name,
          type: e.painType?.name,
        )).toList();

    // Vitals – latest entry.
    final vitalList =
        await VitalRepositoryLocal.instance.watchAll().first;
    PatientVitalSummary? vitals;
    if (vitalList.isNotEmpty) {
      final v = vitalList.first;
      vitals = PatientVitalSummary(
        systolic: v.systolic,
        diastolic: v.diastolic,
        pulse: v.pulse,
        temperature: v.temperature,
        oxygenSaturation: v.oxygenSaturation,
      );
    }

    // Medications – unique names, most recent dose.
    final medList =
        await MedicationRepositoryLocal.instance.watchAll().first;
    final seen = <String>{};
    final meds = <PatientMedSummary>[];
    for (final m in medList) {
      if (m.isDeleted) continue;
      if (seen.add(m.name)) {
        meds.add(PatientMedSummary(name: m.name, dose: m.dose));
      }
      if (meds.length >= 10) break;
    }

    // Timeline tasks – open/overdue.

    final tasks = orchestrator.items
        .where((t) =>
            t.state == TaskState.planned ||
            t.state == TaskState.due ||
            t.state == TaskState.inProgress)
        .take(10)
        .map((t) => PatientTaskSummary(
              title: t.title,
              priority: t.priority.name,
            ))
        .toList();

    // Red flags – active.
    final flags = RedFlagRepositoryLocal.instance.activeFlags
        .take(5)
        .map((r) => PatientRedFlagSummary(
              severity: r.severity.name,
              title: r.title,
              summary: r.summary,
            ))
        .toList();

    // Nutrition – last 5 entries.
    final nutritionList =
        await NutritionRepositoryLocal.instance.watchAll().first;
    final recentNutrition = nutritionList.take(5).map((e) => PatientNutritionSummary(
          date: e.occurredAt.toIso8601String().substring(0, 10),
          mealType: e.mealType.name,
          description: e.description,
          calories: e.calories,
          protein: e.protein,
          waterMl: e.waterMl,
          tolerability: e.tolerability,
          symptoms: e.symptoms.map((s) => s.name).toList(),
        )).toList();

    // Mood – last 5 entries.
    final moodList =
        await MoodRepositoryLocal.instance.watchAll().first;
    final recentMood = moodList.take(5).map((e) => PatientMoodSummary(
          date: e.createdAt.toIso8601String().substring(0, 10),
          level: e.moodLevel.name,
          note: e.note,
        )).toList();

    // Sleep – last 5 entries.
    final sleepList =
        await SleepRepositoryLocal.instance.watchAll().first;
    final recentSleep = sleepList.take(5).map((e) => PatientSleepSummary(
          date: e.createdAt.toIso8601String().substring(0, 10),
          quality: e.quality.name,
          durationMinutes: e.durationMinutes,
          disturbances: e.disturbances,
        )).toList();

    // Symptom Check – most recent.
    final symptomChecks =
        SymptomCheckRepositoryLocal.instance.cached;
    PatientSymptomCheckSummary? symptomCheck;
    if (symptomChecks.isNotEmpty) {
      final sc = symptomChecks.first;
      symptomCheck = PatientSymptomCheckSummary(
        date: sc.createdAt.toIso8601String().substring(0, 10),
        level: sc.overallLevel.name,
        criticalSymptoms: sc.criticalSymptoms,
        totalScore: sc.totalScore,
      );
    }

    return PatientContext(
      painEntries: recentPain,
      latestVitals: vitals,
      medications: meds,
      supplements: await _gatherSupplements(),
      openTasks: tasks,
      redFlags: flags,
      nutritionEntries: recentNutrition,
      moodEntries: recentMood,
      sleepEntries: recentSleep,
      lastSymptomCheck: symptomCheck,
    );
  }

  /// Gather supplement data from local repository.
  static Future<List<PatientSupplementSummary>> _gatherSupplements() async {
    try {
      final supplementList =
          await SupplementIntakeRepositoryLocal.instance.watchAll().first;
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      final recent = supplementList
          .where((e) => !e.isDeleted && e.takenAt.isAfter(sevenDaysAgo))
          .take(10)
          .map((e) => PatientSupplementSummary(
                name: e.name,
                dose: e.dose,
                category: e.category.name,
                lastTakenAt: e.takenAt.toIso8601String().substring(0, 10),
              ))
          .toList();
      return recent;
    } catch (_) {
      return const [];
    }
  }

  Map<String, dynamic> toJson() {
    return {
      if (painEntries.isNotEmpty)
        'painEntries': painEntries.map((e) => e.toJson()).toList(),
      if (latestVitals != null) 'latestVitals': latestVitals!.toJson(),
      if (medications.isNotEmpty)
        'medications': medications.map((e) => e.toJson()).toList(),
      if (supplements.isNotEmpty)
        'supplements': supplements.map((e) => e.toJson()).toList(),
      if (openTasks.isNotEmpty)
        'openTasks': openTasks.map((e) => e.toJson()).toList(),
      if (redFlags.isNotEmpty)
        'redFlags': redFlags.map((e) => e.toJson()).toList(),
      if (nutritionEntries.isNotEmpty)
        'nutritionEntries':
            nutritionEntries.map((e) => e.toJson()).toList(),
      if (moodEntries.isNotEmpty)
        'moodEntries': moodEntries.map((e) => e.toJson()).toList(),
      if (sleepEntries.isNotEmpty)
        'sleepEntries': sleepEntries.map((e) => e.toJson()).toList(),
      if (lastSymptomCheck != null)
        'lastSymptomCheck': lastSymptomCheck!.toJson(),
      if (opPhase != null) 'opPhase': opPhase,
    };
  }

  /// Generates a context-aware greeting based on the latest patient data.
  ///
  /// Example: "Gestern hattest du Schmerz 7/10. Wie geht es dir heute?"
  /// Returns null if there is nothing relevant to mention.
  String? proactiveGreeting() {
    // Check yesterday's pain.
    if (painEntries.isNotEmpty) {
      final latest = painEntries.first;
      final now = DateTime.now();
      final yesterday = DateTime(now.year, now.month, now.day)
          .subtract(const Duration(days: 1));
      final entryDate = DateTime.tryParse(latest.date);
      if (entryDate != null) {
        final entryDay =
            DateTime(entryDate.year, entryDate.month, entryDate.day);
        if (entryDay == yesterday) {
          return 'Gestern hattest du Schmerz ${latest.level}/10. '
              'Wie geht es dir heute?';
        }
        // Today's entry exists – reference it.
        final today = DateTime(now.year, now.month, now.day);
        if (entryDay == today && latest.level >= 5) {
          return 'Du hast heute Schmerz ${latest.level}/10 eingetragen. '
              'Kann ich dir weiterhelfen?';
        }
      }
    }

    // Check vitals.
    if (latestVitals != null) {
      final v = latestVitals!;
      if (v.systolic >= 140 || v.diastolic >= 90) {
        return 'Dein letzter Blutdruck war ${v.systolic}/${v.diastolic}. '
            'Wie fühlst du dich?';
      }
    }

    // Open tasks.
    if (openTasks.length >= 3) {
      return 'Du hast ${openTasks.length} offene Aufgaben. '
          'Soll ich dir helfen zu priorisieren?';
    }

    return null;
  }
}

class PatientPainSummary {
  const PatientPainSummary({
    required this.date,
    required this.level,
    this.region,
    this.type,
  });
  final String date;
  final int level;
  final String? region;
  final String? type;

  Map<String, dynamic> toJson() => {
        'date': date,
        'level': level,
        if (region != null) 'region': region,
        if (type != null) 'type': type,
      };
}

class PatientVitalSummary {
  const PatientVitalSummary({
    required this.systolic,
    required this.diastolic,
    required this.pulse,
    this.temperature,
    this.oxygenSaturation,
  });
  final int systolic;
  final int diastolic;
  final int pulse;
  final double? temperature;
  final int? oxygenSaturation;

  Map<String, dynamic> toJson() => {
        'systolic': systolic,
        'diastolic': diastolic,
        'pulse': pulse,
        if (temperature != null) 'temperature': temperature,
        if (oxygenSaturation != null) 'oxygenSaturation': oxygenSaturation,
      };
}

class PatientMedSummary {
  const PatientMedSummary({required this.name, this.dose});
  final String name;
  final String? dose;

  Map<String, dynamic> toJson() => {
        'name': name,
        if (dose != null) 'dose': dose,
      };
}

class PatientSupplementSummary {
  const PatientSupplementSummary({
    required this.name,
    this.dose,
    required this.category,
    required this.lastTakenAt,
  });
  final String name;
  final String? dose;
  final String category;
  final String lastTakenAt;

  Map<String, dynamic> toJson() => {
        'name': name,
        if (dose != null) 'dose': dose,
        'category': category,
        'lastTakenAt': lastTakenAt,
      };
}

class PatientTaskSummary {
  const PatientTaskSummary({required this.title, required this.priority});
  final String title;
  final String priority;

  Map<String, dynamic> toJson() => {'title': title, 'priority': priority};
}

class PatientRedFlagSummary {
  const PatientRedFlagSummary({
    required this.severity,
    required this.title,
    this.summary,
  });
  final String severity;
  final String title;
  final String? summary;

  Map<String, dynamic> toJson() => {
        'severity': severity,
        'title': title,
        if (summary != null) 'summary': summary,
      };
}

class PatientNutritionSummary {
  const PatientNutritionSummary({
    required this.date,
    required this.mealType,
    required this.description,
    this.calories,
    this.protein,
    this.waterMl,
    this.tolerability,
    this.symptoms = const [],
  });
  final String date;
  final String mealType;
  final String description;
  final int? calories;
  final int? protein;
  final int? waterMl;
  final int? tolerability;
  final List<String> symptoms;

  Map<String, dynamic> toJson() => {
        'date': date,
        'mealType': mealType,
        'description': description,
        if (calories != null) 'calories': calories,
        if (protein != null) 'protein': protein,
        if (waterMl != null) 'waterMl': waterMl,
        if (tolerability != null) 'tolerability': tolerability,
        if (symptoms.isNotEmpty) 'symptoms': symptoms,
      };
}

class PatientMoodSummary {
  const PatientMoodSummary({
    required this.date,
    required this.level,
    this.note,
  });
  final String date;
  final String level;
  final String? note;

  Map<String, dynamic> toJson() => {
        'date': date,
        'level': level,
        if (note != null) 'note': note,
      };
}

class PatientSleepSummary {
  const PatientSleepSummary({
    required this.date,
    required this.quality,
    required this.durationMinutes,
    this.disturbances = 0,
  });
  final String date;
  final String quality;
  final int durationMinutes;
  final int disturbances;

  Map<String, dynamic> toJson() => {
        'date': date,
        'quality': quality,
        'durationMinutes': durationMinutes,
        if (disturbances > 0) 'disturbances': disturbances,
      };
}

class PatientSymptomCheckSummary {
  const PatientSymptomCheckSummary({
    required this.date,
    required this.level,
    this.criticalSymptoms = const [],
    this.totalScore = 0,
  });
  final String date;
  final String level;
  final List<String> criticalSymptoms;
  final int totalScore;

  Map<String, dynamic> toJson() => {
        'date': date,
        'level': level,
        if (criticalSymptoms.isNotEmpty)
          'criticalSymptoms': criticalSymptoms,
        'totalScore': totalScore,
      };
}
