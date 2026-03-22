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
  String toShareText() {
    final buf = StringBuffer('🆘 NOTFALL-INFORMATIONEN\n');
    buf.writeln('========================');
    if (bloodType != null && bloodType!.isNotEmpty) {
      buf.writeln('Blutgruppe: $bloodType');
    }
    if (allergies.isNotEmpty) {
      buf.writeln('Allergien: ${allergies.join(', ')}');
    }
    if (emergencyContactName != null && emergencyContactName!.isNotEmpty) {
      buf.writeln('Notfallkontakt: $emergencyContactName');
    }
    if (emergencyContactPhone != null && emergencyContactPhone!.isNotEmpty) {
      buf.writeln('Tel: $emergencyContactPhone');
    }
    if (hospitalName != null && hospitalName!.isNotEmpty) {
      buf.writeln('Krankenhaus: $hospitalName');
    }
    if (hospitalPhone != null && hospitalPhone!.isNotEmpty) {
      buf.writeln('KH-Tel: $hospitalPhone');
    }
    if (doctorName != null && doctorName!.isNotEmpty) {
      buf.writeln('Arzt: $doctorName');
    }
    if (doctorPhone != null && doctorPhone!.isNotEmpty) {
      buf.writeln('Arzt-Tel: $doctorPhone');
    }
    if (insuranceInfo != null && insuranceInfo!.isNotEmpty) {
      buf.writeln('Versicherung: $insuranceInfo');
    }
    buf.writeln('========================');
    buf.writeln('Notruf: 112');
    return buf.toString();
  }
}
