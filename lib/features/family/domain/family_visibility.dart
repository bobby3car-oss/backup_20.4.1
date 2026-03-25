/// Per-category visibility settings that a patient configures for their
/// linked family members.
///
/// Stored in the link document at `patients/{patientId}/links/{familyUid}_family`.
/// The patient can toggle each category independently.
/// Default: only [timeline] is enabled.
class FamilyVisibility {
  const FamilyVisibility({
    this.timeline = true,
    this.vitals = false,
    this.pain = false,
    this.wounds = false,
    this.appointments = false,
    this.medications = false,
    this.documents = false,
    this.redFlags = false,
    this.observations = true,
  });

  final bool timeline;
  final bool vitals;
  final bool pain;
  final bool wounds;
  final bool appointments;
  final bool medications;
  final bool documents;
  final bool redFlags;
  final bool observations;

  factory FamilyVisibility.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const FamilyVisibility();
    return FamilyVisibility(
      timeline: map['timeline'] as bool? ?? true,
      vitals: map['vitals'] as bool? ?? false,
      pain: map['pain'] as bool? ?? false,
      wounds: map['wounds'] as bool? ?? false,
      appointments: map['appointments'] as bool? ?? false,
      medications: map['medications'] as bool? ?? false,
      documents: map['documents'] as bool? ?? false,
      redFlags: map['redFlags'] as bool? ?? false,
      observations: map['observations'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
        'timeline': timeline,
        'vitals': vitals,
        'pain': pain,
        'wounds': wounds,
        'appointments': appointments,
        'medications': medications,
        'documents': documents,
        'redFlags': redFlags,
        'observations': observations,
      };

  FamilyVisibility copyWith({
    bool? timeline,
    bool? vitals,
    bool? pain,
    bool? wounds,
    bool? appointments,
    bool? medications,
    bool? documents,
    bool? redFlags,
    bool? observations,
  }) {
    return FamilyVisibility(
      timeline: timeline ?? this.timeline,
      vitals: vitals ?? this.vitals,
      pain: pain ?? this.pain,
      wounds: wounds ?? this.wounds,
      appointments: appointments ?? this.appointments,
      medications: medications ?? this.medications,
      documents: documents ?? this.documents,
      redFlags: redFlags ?? this.redFlags,
      observations: observations ?? this.observations,
    );
  }

  /// All category labels for display in settings UI.
  static const categoryLabels = <String, String>{
    'timeline': 'Aufgaben & Plan',
    'vitals': 'Vitalwerte',
    'pain': 'Schmerztagebuch',
    'wounds': 'Wunddokumentation',
    'appointments': 'Termine',
    'medications': 'Medikamente',
    'documents': 'Dokumente',
    'redFlags': 'Warnhinweise',
    'observations': 'Beobachtungen',
  };

  static const categoryIcons = <String, int>{
    'timeline': 0xe873, // Icons.checklist_rounded
    'vitals': 0xf013f, // Icons.monitor_heart_outlined
    'pain': 0xe2e3, // Icons.healing_rounded
    'wounds': 0xf06cb, // Icons.photo_camera_outlined
    'appointments': 0xe935, // Icons.calendar_today_rounded
    'medications': 0xf0609, // Icons.medication_outlined
    'documents': 0xe873, // Icons.description_outlined
    'redFlags': 0xe645, // Icons.flag_rounded
    'observations': 0xf05da, // Icons.note_alt_outlined
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FamilyVisibility &&
          timeline == other.timeline &&
          vitals == other.vitals &&
          pain == other.pain &&
          wounds == other.wounds &&
          appointments == other.appointments &&
          medications == other.medications &&
          documents == other.documents &&
          redFlags == other.redFlags &&
          observations == other.observations;

  @override
  int get hashCode => Object.hash(
        timeline, vitals, pain, wounds,
        appointments, medications, documents, redFlags, observations,
      );
}
