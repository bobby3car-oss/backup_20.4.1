import '../../doctor_report/doctor_report_builder.dart';
import '../../red_flags/domain/red_flag.dart';

/// Represents the phase a patient is currently in.
enum PatientPhase { preOp, opDay, postOp, discharged }

/// Summary model for displaying a linked patient on the doctor dashboard.
class LinkedPatient {
  const LinkedPatient({
    required this.uid,
    required this.displayName,
    required this.email,
    this.opDate,
    this.diagnosis,
    this.warnStatus = ReportLight.unknown,
    this.lastEntryAt,
    this.lastEntryLabel,
    this.nextAppointmentAt,
    this.nextAppointmentTitle,
    this.phase = PatientPhase.preOp,
    this.progressPercent = 0,
    this.redFlagCount = 0,
    this.maxRedFlagSeverity = RedFlagSeverity.green,
    this.redFlags = const [],
  });

  final String uid;
  final String displayName;
  final String email;
  final DateTime? opDate;
  final String? diagnosis;
  final ReportLight warnStatus;
  final DateTime? lastEntryAt;
  final String? lastEntryLabel;
  final DateTime? nextAppointmentAt;
  final String? nextAppointmentTitle;
  final PatientPhase phase;
  final double progressPercent;
  final int redFlagCount;
  final RedFlagSeverity maxRedFlagSeverity;
  final List<RedFlag> redFlags;

  LinkedPatient copyWith({
    ReportLight? warnStatus,
    DateTime? lastEntryAt,
    String? lastEntryLabel,
    DateTime? nextAppointmentAt,
    String? nextAppointmentTitle,
    PatientPhase? phase,
    double? progressPercent,
    int? redFlagCount,
    RedFlagSeverity? maxRedFlagSeverity,
    List<RedFlag>? redFlags,
  }) {
    return LinkedPatient(
      uid: uid,
      displayName: displayName,
      email: email,
      opDate: opDate,
      diagnosis: diagnosis,
      warnStatus: warnStatus ?? this.warnStatus,
      lastEntryAt: lastEntryAt ?? this.lastEntryAt,
      lastEntryLabel: lastEntryLabel ?? this.lastEntryLabel,
      nextAppointmentAt: nextAppointmentAt ?? this.nextAppointmentAt,
      nextAppointmentTitle: nextAppointmentTitle ?? this.nextAppointmentTitle,
      phase: phase ?? this.phase,
      progressPercent: progressPercent ?? this.progressPercent,
      redFlagCount: redFlagCount ?? this.redFlagCount,
      maxRedFlagSeverity: maxRedFlagSeverity ?? this.maxRedFlagSeverity,
      redFlags: redFlags ?? this.redFlags,
    );
  }
}
