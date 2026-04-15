import 'package:cloud_firestore/cloud_firestore.dart';

/// Aggregated patient model for the organisation view.
///
/// Combines patient data with the linked doctor's name so the org
/// can see which doctor is responsible for each patient.
class OrgPatient {
  const OrgPatient({
    required this.patientId,
    required this.patientName,
    required this.patientEmail,
    required this.doctorId,
    required this.doctorName,
    this.opDate,
    this.diagnosis,
  });

  final String patientId;
  final String patientName;
  final String patientEmail;
  final String doctorId;
  final String doctorName;
  final DateTime? opDate;
  final String? diagnosis;

  /// Creates an [OrgPatient] from a patient user document and a doctor name.
  factory OrgPatient.fromUserDoc(
    String patientId,
    Map<String, dynamic> data, {
    required String doctorId,
    required String doctorName,
  }) {
    DateTime? opDate;
    final opRaw = data['opDate'];
    if (opRaw is String) {
      opDate = DateTime.tryParse(opRaw);
    } else if (opRaw is Timestamp) {
      opDate = opRaw.toDate();
    }

    return OrgPatient(
      patientId: patientId,
      patientName: (data['displayName'] ?? '').toString(),
      patientEmail: (data['email'] ?? '').toString(),
      doctorId: doctorId,
      doctorName: doctorName,
      opDate: opDate,
      diagnosis: (data['diagnosis'] ?? data['opType'] ?? '').toString(),
    );
  }
}
