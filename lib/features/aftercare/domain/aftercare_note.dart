import 'package:cloud_firestore/cloud_firestore.dart';

/// A private patient note attached to an aftercare plan.
///
/// Stored at: `patient_aftercare_plans/{planId}/patient_notes/{noteId}`
///
/// Visible ONLY to the patient — not to doctors, staff, or admins.
class AftercareNote {
  const AftercareNote({
    required this.id,
    required this.patientId,
    required this.planId,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String patientId;
  final String planId;
  final String text;
  final DateTime createdAt;
  final DateTime updatedAt;

  AftercareNote copyWith({
    String? id,
    String? patientId,
    String? planId,
    String? text,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AftercareNote(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      planId: planId ?? this.planId,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'patientId': patientId,
      'planId': planId,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory AftercareNote.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return AftercareNote(
      id: (json['id'] ?? '').toString(),
      patientId: (json['patientId'] ?? '').toString(),
      planId: (json['planId'] ?? '').toString(),
      text: (json['text'] ?? '').toString(),
      createdAt: _parseDateTime(json['createdAt']) ?? now,
      updatedAt: _parseDateTime(json['updatedAt']) ?? now,
    );
  }

  static DateTime? _parseDateTime(Object? raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is String && raw.trim().isNotEmpty) return DateTime.tryParse(raw);
    return null;
  }
}
