import '../../medication/domain/medication_reminder.dart';
import '../../nutrition/domain/nutrition_entry.dart';
import '../../pain/domain/pain_entry.dart';
import '../../red_flags/domain/red_flag.dart';
import '../../vitals/domain/vital_entry.dart';
import '../../wound/domain/wound_entry.dart';

/// All toggleable sections in the health report.
enum ReportSection {
  pain,
  vitals,
  wounds,
  medication,
  nutrition,
  redFlags,
}

/// Predefined time-range options for the report.
enum ReportRange {
  days7,
  days14,
  days30,
  custom,
}

/// Aggregated health data for a chosen time period.
class HealthReportData {
  const HealthReportData({
    required this.patientName,
    required this.from,
    required this.to,
    required this.sections,
    this.painEntries = const [],
    this.vitalEntries = const [],
    this.woundEntries = const [],
    this.medications = const [],
    this.nutritionEntries = const [],
    this.redFlags = const [],
  });

  final String patientName;
  final DateTime from;
  final DateTime to;
  final Set<ReportSection> sections;

  final List<PainEntry> painEntries;
  final List<VitalEntry> vitalEntries;
  final List<WoundEntry> woundEntries;
  final List<MedicationReminder> medications;
  final List<NutritionEntry> nutritionEntries;
  final List<RedFlag> redFlags;
}
