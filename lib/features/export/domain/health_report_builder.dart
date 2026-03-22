import 'package:firebase_auth/firebase_auth.dart';

import '../../medication/data/medication_reminder_repository_local.dart';
import '../../medication/domain/medication_reminder.dart';
import '../../nutrition/data/nutrition_repository_local.dart';
import '../../nutrition/domain/nutrition_entry.dart';
import '../../pain/data/pain_repository_local.dart';
import '../../pain/domain/pain_entry.dart';
import '../../red_flags/data/red_flag_repository_local.dart';
import '../../red_flags/domain/red_flag.dart';
import '../../vitals/data/vital_repository_local.dart';
import '../../vitals/domain/vital_entry.dart';
import '../../wound/data/wound_repository_local.dart';
import '../../wound/domain/wound_entry.dart';
import 'health_report_data.dart';

/// Collects data from all local repositories for a given time range and
/// selected sections, producing a [HealthReportData] ready for PDF export.
class HealthReportBuilder {
  HealthReportBuilder._();

  static Future<HealthReportData> build({
    required DateTime from,
    required DateTime to,
    required Set<ReportSection> sections,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final patientName = user?.displayName ?? 'Patient';

    final data = HealthReportData(
      patientName: patientName,
      from: from,
      to: to,
      sections: sections,
      painEntries: sections.contains(ReportSection.pain)
          ? await _loadPain(from, to)
          : const [],
      vitalEntries: sections.contains(ReportSection.vitals)
          ? await _loadVitals(from, to)
          : const [],
      woundEntries: sections.contains(ReportSection.wounds)
          ? await _loadWounds(from, to)
          : const [],
      medications: sections.contains(ReportSection.medication)
          ? await _loadMedications()
          : const [],
      nutritionEntries: sections.contains(ReportSection.nutrition)
          ? await _loadNutrition(from, to)
          : const [],
      redFlags: sections.contains(ReportSection.redFlags)
          ? await _loadRedFlags(from, to)
          : const [],
    );

    return data;
  }

  // ── Loaders ──────────────────────────────────────────────────────────

  static Future<List<PainEntry>> _loadPain(DateTime from, DateTime to) async {
    final repo = PainRepositoryLocal.instance;
    await repo.loadFromDisk();
    final all = await repo.watchAll().first;
    return all
        .where((e) =>
            !e.occurredAt.isBefore(from) && !e.occurredAt.isAfter(to))
        .toList()
      ..sort((a, b) => a.occurredAt.compareTo(b.occurredAt));
  }

  static Future<List<VitalEntry>> _loadVitals(
      DateTime from, DateTime to) async {
    final repo = VitalRepositoryLocal.instance;
    await repo.loadFromDisk();
    final all = await repo.watchAll().first;
    return all
        .where((e) =>
            !e.createdAt.isBefore(from) && !e.createdAt.isAfter(to))
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  static Future<List<WoundEntry>> _loadWounds(
      DateTime from, DateTime to) async {
    final repo = WoundRepositoryLocal.instance;
    await repo.loadFromDisk();
    final all = await repo.watchAll().first;
    return all
        .where((e) =>
            !e.createdAt.isBefore(from) && !e.createdAt.isAfter(to))
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  static Future<List<MedicationReminder>> _loadMedications() async {
    final repo = MedicationReminderRepositoryLocal.instance;
    await repo.loadFromDisk();
    final all = await repo.watchAll().first;
    // Return all active (non-deleted) medications - no date filter needed
    return all.where((e) => e.deletedAt == null).toList()
      ..sort((a, b) => a.medicationName.compareTo(b.medicationName));
  }

  static Future<List<NutritionEntry>> _loadNutrition(
      DateTime from, DateTime to) async {
    final repo = NutritionRepositoryLocal.instance;
    await repo.loadFromDisk();
    final all = await repo.watchAll().first;
    return all
        .where((e) =>
            !e.occurredAt.isBefore(from) && !e.occurredAt.isAfter(to))
        .toList()
      ..sort((a, b) => a.occurredAt.compareTo(b.occurredAt));
  }

  static Future<List<RedFlag>> _loadRedFlags(
      DateTime from, DateTime to) async {
    final repo = RedFlagRepositoryLocal.instance;
    await repo.loadFromDisk();
    final all = await repo.watchAll().first;
    return all
        .where((e) =>
            !e.createdAt.isBefore(from) && !e.createdAt.isAfter(to))
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }
}
