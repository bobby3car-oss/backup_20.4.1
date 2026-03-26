import 'package:cloud_firestore/cloud_firestore.dart';

/// All data collected during the patient onboarding questionnaire.
class QuestionnaireData {
  QuestionnaireData({
    this.opDate,
    required this.opType,
    required this.opModus,
    this.hospitalName,
    this.doctorName,
    this.preExistingConditions = const [],
    this.allergies = const [],
    this.currentMedications = const [],
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.weight,
    this.height,
    this.smokerStatus,
  });

  // ── Page 1: OP info (mandatory) ──
  final DateTime? opDate;
  final String opType;
  final String opModus; // "ambulant" | "stationär"

  // ── Page 2: Clinic & doctor ──
  final String? hospitalName;
  final String? doctorName;

  // ── Page 3: Health profile ──
  final List<String> preExistingConditions;
  final List<String> allergies;
  final List<String> currentMedications;
  final double? weight; // kg
  final double? height; // cm
  final String? smokerStatus; // "Nichtraucher" | "Raucher" | "Ex-Raucher"

  // ── Page 4: Emergency contact ──
  final String? emergencyContactName;
  final String? emergencyContactPhone;

  /// Converts to a Firestore-compatible map for `users/{uid}`.
  Map<String, dynamic> toFirestore() {
    return <String, dynamic>{
      if (opDate != null) 'opDate': opDate!.toIso8601String(),
      'opType': opType,
      'opModus': opModus,
      if (hospitalName != null && hospitalName!.isNotEmpty)
        'hospitalName': hospitalName,
      if (doctorName != null && doctorName!.isNotEmpty)
        'doctorName': doctorName,
      if (preExistingConditions.isNotEmpty)
        'preExistingConditions': preExistingConditions,
      if (allergies.isNotEmpty) 'allergies': allergies,
      if (currentMedications.isNotEmpty)
        'currentMedications': currentMedications,
      if (weight != null) 'weight': weight,
      if (height != null) 'height': height,
      if (smokerStatus != null && smokerStatus!.isNotEmpty)
        'smokerStatus': smokerStatus,
      if (emergencyContactName != null && emergencyContactName!.isNotEmpty)
        'emergencyContactName': emergencyContactName,
      if (emergencyContactPhone != null && emergencyContactPhone!.isNotEmpty)
        'emergencyContactPhone': emergencyContactPhone,
      'onboardingComplete': true,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

/// Known surgery types for chip selection.
const List<String> kSurgeryTypes = [
  'Knie-TEP',
  'Hüft-TEP',
  'Schulter-OP',
  'Kreuzband-OP',
  'Meniskus-OP',
  'Wirbelsäulen-OP',
  'Herz-OP',
  'Bauch-OP',
];
