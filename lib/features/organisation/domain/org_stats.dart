import '../../doctor_patients/domain/linked_patient.dart';

/// Aggregated statistics for an organisation dashboard.
class OrgStatsData {
  const OrgStatsData({
    required this.totalPatients,
    required this.activePatients,
    required this.patientsByPhase,
  });

  /// Total number of unique patients across all doctors.
  final int totalPatients;

  /// Patients with activity in the last 7 days.
  final int activePatients;

  /// Distribution of patients by phase.
  final Map<PatientPhase, int> patientsByPhase;

  static const empty = OrgStatsData(
    totalPatients: 0,
    activePatients: 0,
    patientsByPhase: {},
  );
}
