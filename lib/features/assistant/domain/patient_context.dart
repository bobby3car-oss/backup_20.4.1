import 'dart:async';

import '../../../domain/task_orchestrator.dart';
import '../../../domain/timeline_engine.dart';
import '../../medication/data/medication_repository_local.dart';
import '../../pain/data/pain_repository_local.dart';
import '../../red_flags/data/red_flag_repository_local.dart';
import '../../vitals/data/vital_repository_local.dart';
import '../../nutrition/data/nutrition_repository_local.dart';

/// Collects current patient data to provide as context to the AI assistant.
class PatientContext {
  const PatientContext({
    this.painEntries = const [],
    this.latestVitals,
    this.medications = const [],
    this.openTasks = const [],
    this.redFlags = const [],
    this.nutritionEntries = const [],
    this.opPhase,
  });

  final List<_PainSummary> painEntries;
  final _VitalSummary? latestVitals;
  final List<_MedSummary> medications;
  final List<_TaskSummary> openTasks;
  final List<_RedFlagSummary> redFlags;
  final List<_NutritionSummary> nutritionEntries;
  final String? opPhase;

  /// Gather context from local repositories.
  static Future<PatientContext> gather(TaskOrchestrator orchestrator) async {
    // Pain – last 5 entries.
    final painList =
        await PainRepositoryLocal.instance.watchAll().first;
    final recentPain = painList.take(5).map((e) => _PainSummary(
          date: e.occurredAt.toIso8601String().substring(0, 10),
          level: e.painLevel,
          region: e.bodyRegion?.name,
          type: e.painType?.name,
        )).toList();

    // Vitals – latest entry.
    final vitalList =
        await VitalRepositoryLocal.instance.watchAll().first;
    _VitalSummary? vitals;
    if (vitalList.isNotEmpty) {
      final v = vitalList.first;
      vitals = _VitalSummary(
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
    final meds = <_MedSummary>[];
    for (final m in medList) {
      if (m.isDeleted) continue;
      if (seen.add(m.name)) {
        meds.add(_MedSummary(name: m.name, dose: m.dose));
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
        .map((t) => _TaskSummary(
              title: t.title,
              priority: t.priority.name,
            ))
        .toList();

    // Red flags – active.
    final flags = RedFlagRepositoryLocal.instance.activeFlags
        .take(5)
        .map((r) => _RedFlagSummary(
              severity: r.severity.name,
              title: r.title,
              summary: r.summary,
            ))
        .toList();

    // Nutrition – last 5 entries.
    final nutritionList =
        await NutritionRepositoryLocal.instance.watchAll().first;
    final recentNutrition = nutritionList.take(5).map((e) => _NutritionSummary(
          date: e.occurredAt.toIso8601String().substring(0, 10),
          mealType: e.mealType.name,
          description: e.description,
          calories: e.calories,
          protein: e.protein,
          waterMl: e.waterMl,
          tolerability: e.tolerability,
          symptoms: e.symptoms.map((s) => s.name).toList(),
        )).toList();

    return PatientContext(
      painEntries: recentPain,
      latestVitals: vitals,
      medications: meds,
      openTasks: tasks,
      redFlags: flags,
      nutritionEntries: recentNutrition,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (painEntries.isNotEmpty)
        'painEntries': painEntries.map((e) => e.toJson()).toList(),
      if (latestVitals != null) 'latestVitals': latestVitals!.toJson(),
      if (medications.isNotEmpty)
        'medications': medications.map((e) => e.toJson()).toList(),
      if (openTasks.isNotEmpty)
        'openTasks': openTasks.map((e) => e.toJson()).toList(),
      if (redFlags.isNotEmpty)
        'redFlags': redFlags.map((e) => e.toJson()).toList(),
      if (nutritionEntries.isNotEmpty)
        'nutritionEntries':
            nutritionEntries.map((e) => e.toJson()).toList(),
      if (opPhase != null) 'opPhase': opPhase,
    };
  }
}

class _PainSummary {
  const _PainSummary({
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

class _VitalSummary {
  const _VitalSummary({
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

class _MedSummary {
  const _MedSummary({required this.name, this.dose});
  final String name;
  final String? dose;

  Map<String, dynamic> toJson() => {
        'name': name,
        if (dose != null) 'dose': dose,
      };
}

class _TaskSummary {
  const _TaskSummary({required this.title, required this.priority});
  final String title;
  final String priority;

  Map<String, dynamic> toJson() => {'title': title, 'priority': priority};
}

class _RedFlagSummary {
  const _RedFlagSummary({
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

class _NutritionSummary {
  const _NutritionSummary({
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
