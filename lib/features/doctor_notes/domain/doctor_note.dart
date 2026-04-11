import 'package:cloud_firestore/cloud_firestore.dart';

/// The type of doctor note.
enum NoteType {
  freeform,
  soap,
  discharge;

  static NoteType fromString(String? value) => switch (value) {
        'soap' => NoteType.soap,
        'discharge' => NoteType.discharge,
        _ => NoteType.freeform,
      };
}

/// Structured SOAP data (Subjective, Objective, Assessment, Plan).
class SoapData {
  const SoapData({
    this.subjective = '',
    this.objective = '',
    this.assessment = '',
    this.plan = '',
  });

  final String subjective;
  final String objective;
  final String assessment;
  final String plan;

  factory SoapData.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const SoapData();
    return SoapData(
      subjective: map['subjective'] as String? ?? '',
      objective: map['objective'] as String? ?? '',
      assessment: map['assessment'] as String? ?? '',
      plan: map['plan'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'subjective': subjective,
        'objective': objective,
        'assessment': assessment,
        'plan': plan,
      };

  bool get isEmpty =>
      subjective.isEmpty &&
      objective.isEmpty &&
      assessment.isEmpty &&
      plan.isEmpty;

  SoapData copyWith({
    String? subjective,
    String? objective,
    String? assessment,
    String? plan,
  }) =>
      SoapData(
        subjective: subjective ?? this.subjective,
        objective: objective ?? this.objective,
        assessment: assessment ?? this.assessment,
        plan: plan ?? this.plan,
      );
}

/// Structured discharge data.
class DischargeData {
  const DischargeData({
    this.diagnosis = '',
    this.procedure = '',
    this.findings = '',
    this.medication = '',
    this.followUp = '',
    this.restrictions = '',
    this.notes = '',
  });

  final String diagnosis;
  final String procedure;
  final String findings;
  final String medication;
  final String followUp;
  final String restrictions;
  final String notes;

  factory DischargeData.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const DischargeData();
    return DischargeData(
      diagnosis: map['diagnosis'] as String? ?? '',
      procedure: map['procedure'] as String? ?? '',
      findings: map['findings'] as String? ?? '',
      medication: map['medication'] as String? ?? '',
      followUp: map['followUp'] as String? ?? '',
      restrictions: map['restrictions'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'diagnosis': diagnosis,
        'procedure': procedure,
        'findings': findings,
        'medication': medication,
        'followUp': followUp,
        'restrictions': restrictions,
        'notes': notes,
      };

  bool get isEmpty =>
      diagnosis.isEmpty &&
      procedure.isEmpty &&
      findings.isEmpty &&
      medication.isEmpty &&
      followUp.isEmpty &&
      restrictions.isEmpty &&
      notes.isEmpty;
}

/// A private doctor note about a patient.
class DoctorNote {
  DoctorNote({
    required this.id,
    required this.patientId,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
    this.pinned = false,
    this.noteType = NoteType.freeform,
    this.soapData,
    this.dischargeData,
  });

  final String id;
  final String patientId;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;
  final bool pinned;
  final NoteType noteType;
  final SoapData? soapData;
  final DischargeData? dischargeData;

  factory DoctorNote.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return DoctorNote(
      id: doc.id,
      patientId: data['patientId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      content: data['content'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      tags: List<String>.from(data['tags'] as List? ?? []),
      pinned: data['pinned'] as bool? ?? false,
      noteType: NoteType.fromString(data['noteType'] as String?),
      soapData: data['soapData'] != null
          ? SoapData.fromMap(data['soapData'] as Map<String, dynamic>)
          : null,
      dischargeData: data['dischargeData'] != null
          ? DischargeData.fromMap(
              data['dischargeData'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'patientId': patientId,
        'title': title,
        'content': content,
        'tags': tags,
        'pinned': pinned,
        'noteType': noteType.name,
        if (soapData != null) 'soapData': soapData!.toMap(),
        if (dischargeData != null) 'dischargeData': dischargeData!.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  DoctorNote copyWith({
    String? title,
    String? content,
    List<String>? tags,
    bool? pinned,
    NoteType? noteType,
    SoapData? soapData,
    DischargeData? dischargeData,
  }) =>
      DoctorNote(
        id: id,
        patientId: patientId,
        title: title ?? this.title,
        content: content ?? this.content,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
        tags: tags ?? this.tags,
        pinned: pinned ?? this.pinned,
        noteType: noteType ?? this.noteType,
        soapData: soapData ?? this.soapData,
        dischargeData: dischargeData ?? this.dischargeData,
      );
}
