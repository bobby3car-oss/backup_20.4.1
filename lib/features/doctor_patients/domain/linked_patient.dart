import '../../red_flags/domain/red_flag.dart';

enum PatientPhase { preOp, opDay, postOp, discharged }

class LinkedPatient {
  const LinkedPatient({
    required this.uid,
    required this.displayName,
    this.age,
    this.opDate,
    this.diagnosis,
    this.linkedDoctorUid,
    this.nextAppointmentAt,
    this.nextAppointmentTitle,
    this.phase = PatientPhase.preOp,
    this.activeAftercarePlanTitle,
    this.redFlags = const [],
  });

  final String uid;
  final String displayName;

  /// Patient age in whole years (computed from birthDate). Null if unknown.
  final int? age;
  final DateTime? opDate;
  final String? diagnosis;
  final String? linkedDoctorUid;
  final DateTime? nextAppointmentAt;
  final String? nextAppointmentTitle;
  final PatientPhase phase;
  final String? activeAftercarePlanTitle;
  final List<RedFlag> redFlags;

  LinkedPatient copyWith({
    DateTime? nextAppointmentAt,
    String? nextAppointmentTitle,
    PatientPhase? phase,
    String? activeAftercarePlanTitle,
    List<RedFlag>? redFlags,
  }) {
    return LinkedPatient(
      uid: uid,
      displayName: displayName,
      age: age,
      opDate: opDate,
      diagnosis: diagnosis,
      linkedDoctorUid: linkedDoctorUid,
      nextAppointmentAt: nextAppointmentAt ?? this.nextAppointmentAt,
      nextAppointmentTitle: nextAppointmentTitle ?? this.nextAppointmentTitle,
      phase: phase ?? this.phase,
      activeAftercarePlanTitle:
          activeAftercarePlanTitle ?? this.activeAftercarePlanTitle,
      redFlags: redFlags ?? this.redFlags,
    );
  }

  /// Computes age in whole years from a [birthDate]. Returns null if null.
  static int? ageFromBirthDate(DateTime? birthDate) {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int years = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      years--;
    }
    return years;
  }
}
