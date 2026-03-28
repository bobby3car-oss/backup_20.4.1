import '../../../l10n/app_localizations.dart';

/// Offline-ready emergency information model.
///
/// All fields are nullable because the user progressively completes them
/// in the profile settings.
class EmergencyInfo {
  const EmergencyInfo({
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.hospitalName,
    this.hospitalPhone,
    this.bloodType,
    this.allergies = const [],
    this.insuranceInfo,
    this.doctorName,
    this.doctorPhone,
  });

  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? hospitalName;
  final String? hospitalPhone;
  final String? bloodType;
  final List<String> allergies;
  final String? insuranceInfo;
  final String? doctorName;
  final String? doctorPhone;

  factory EmergencyInfo.fromMap(Map<String, dynamic> data) {
    return EmergencyInfo(
      emergencyContactName: data['emergencyContactName'] as String?,
      emergencyContactPhone: data['emergencyContactPhone'] as String?,
      hospitalName: data['hospitalName'] as String?,
      hospitalPhone: data['hospitalPhone'] as String?,
      bloodType: data['bloodType'] as String?,
      allergies: data['allergies'] is List
          ? List<String>.from(data['allergies'] as List)
          : const [],
      insuranceInfo: data['insuranceInfo'] as String?,
      doctorName: data['doctorName'] as String?,
      doctorPhone: data['doctorPhone'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'emergencyContactName': emergencyContactName,
        'emergencyContactPhone': emergencyContactPhone,
        'hospitalName': hospitalName,
        'hospitalPhone': hospitalPhone,
        'bloodType': bloodType,
        'allergies': allergies,
        'insuranceInfo': insuranceInfo,
        'doctorName': doctorName,
        'doctorPhone': doctorPhone,
      };

  bool get isEmpty =>
      emergencyContactName == null &&
      emergencyContactPhone == null &&
      hospitalName == null &&
      hospitalPhone == null &&
      bloodType == null &&
      allergies.isEmpty &&
      insuranceInfo == null &&
      doctorName == null &&
      doctorPhone == null;

  /// Formats all emergency info as a shareable text block.
  String toShareText(AppLocalizations l) {
    const sep = '========================';
    final buf = StringBuffer('${l.eiShareHeader}\n');
    buf.writeln(sep);
    if (bloodType != null && bloodType!.isNotEmpty) {
      buf.writeln(l.eiShareBloodType(bloodType!));
    }
    if (allergies.isNotEmpty) {
      buf.writeln(l.eiShareAllergies(allergies.join(', ')));
    }
    if (emergencyContactName != null && emergencyContactName!.isNotEmpty) {
      buf.writeln(l.eiShareContact(emergencyContactName!));
    }
    if (emergencyContactPhone != null && emergencyContactPhone!.isNotEmpty) {
      buf.writeln(l.eiSharePhone(emergencyContactPhone!));
    }
    if (hospitalName != null && hospitalName!.isNotEmpty) {
      buf.writeln(l.eiShareHospital(hospitalName!));
    }
    if (hospitalPhone != null && hospitalPhone!.isNotEmpty) {
      buf.writeln(l.eiShareHospitalPhone(hospitalPhone!));
    }
    if (doctorName != null && doctorName!.isNotEmpty) {
      buf.writeln(l.eiShareDoctor(doctorName!));
    }
    if (doctorPhone != null && doctorPhone!.isNotEmpty) {
      buf.writeln(l.eiShareDoctorPhone(doctorPhone!));
    }
    if (insuranceInfo != null && insuranceInfo!.isNotEmpty) {
      buf.writeln(l.eiShareInsurance(insuranceInfo!));
    }
    buf.writeln('========================');
    buf.writeln(l.eiShareEmergency);
    return buf.toString();
  }
}
