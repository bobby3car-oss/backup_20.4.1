/// Per-feature permission level for a doctor link.
enum FeatureAccess {
  none,
  read,
  readWrite;

  bool get canRead => this == read || this == readWrite;
  bool get canWrite => this == readWrite;

  String toJson() => name;

  static FeatureAccess fromJson(dynamic value) {
    if (value == 'readWrite') return FeatureAccess.readWrite;
    if (value == 'read') return FeatureAccess.read;
    return FeatureAccess.none;
  }
}

/// Per-feature permissions that a patient configures for their linked doctor.
///
/// Stored in the link document at `patients/{patientId}/links/{doctorUid}_doctor`.
/// Default: all features set to [FeatureAccess.readWrite].
class DoctorPermissions {
  const DoctorPermissions({
    this.timeline = FeatureAccess.readWrite,
    this.vitals = FeatureAccess.readWrite,
    this.pain = FeatureAccess.readWrite,
    this.wounds = FeatureAccess.readWrite,
    this.appointments = FeatureAccess.readWrite,
    this.medications = FeatureAccess.readWrite,
    this.documents = FeatureAccess.readWrite,
    this.redFlags = FeatureAccess.readWrite,
    this.observations = FeatureAccess.readWrite,
  });

  final FeatureAccess timeline;
  final FeatureAccess vitals;
  final FeatureAccess pain;
  final FeatureAccess wounds;
  final FeatureAccess appointments;
  final FeatureAccess medications;
  final FeatureAccess documents;
  final FeatureAccess redFlags;
  final FeatureAccess observations;

  /// All features set to readWrite.
  static const allAccess = DoctorPermissions();

  /// All features set to read only.
  static const readOnly = DoctorPermissions(
    timeline: FeatureAccess.read,
    vitals: FeatureAccess.read,
    pain: FeatureAccess.read,
    wounds: FeatureAccess.read,
    appointments: FeatureAccess.read,
    medications: FeatureAccess.read,
    documents: FeatureAccess.read,
    redFlags: FeatureAccess.read,
    observations: FeatureAccess.read,
  );

  /// Minimal access — only timeline and red flags readable.
  static const minimal = DoctorPermissions(
    timeline: FeatureAccess.read,
    vitals: FeatureAccess.none,
    pain: FeatureAccess.none,
    wounds: FeatureAccess.none,
    appointments: FeatureAccess.read,
    medications: FeatureAccess.none,
    documents: FeatureAccess.none,
    redFlags: FeatureAccess.read,
    observations: FeatureAccess.none,
  );

  factory DoctorPermissions.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const DoctorPermissions();
    return DoctorPermissions(
      timeline: FeatureAccess.fromJson(map['timeline']),
      vitals: FeatureAccess.fromJson(map['vitals']),
      pain: FeatureAccess.fromJson(map['pain']),
      wounds: FeatureAccess.fromJson(map['wounds']),
      appointments: FeatureAccess.fromJson(map['appointments']),
      medications: FeatureAccess.fromJson(map['medications']),
      documents: FeatureAccess.fromJson(map['documents']),
      redFlags: FeatureAccess.fromJson(map['redFlags']),
      observations: FeatureAccess.fromJson(map['observations']),
    );
  }

  Map<String, dynamic> toMap() => {
        'timeline': timeline.toJson(),
        'vitals': vitals.toJson(),
        'pain': pain.toJson(),
        'wounds': wounds.toJson(),
        'appointments': appointments.toJson(),
        'medications': medications.toJson(),
        'documents': documents.toJson(),
        'redFlags': redFlags.toJson(),
        'observations': observations.toJson(),
      };

  FeatureAccess operator [](String key) => switch (key) {
        'timeline' => timeline,
        'vitals' => vitals,
        'pain' => pain,
        'wounds' => wounds,
        'appointments' => appointments,
        'medications' => medications,
        'documents' => documents,
        'redFlags' => redFlags,
        'observations' => observations,
        _ => FeatureAccess.none,
      };

  DoctorPermissions copyWithFeature(String key, FeatureAccess value) {
    return DoctorPermissions(
      timeline: key == 'timeline' ? value : timeline,
      vitals: key == 'vitals' ? value : vitals,
      pain: key == 'pain' ? value : pain,
      wounds: key == 'wounds' ? value : wounds,
      appointments: key == 'appointments' ? value : appointments,
      medications: key == 'medications' ? value : medications,
      documents: key == 'documents' ? value : documents,
      redFlags: key == 'redFlags' ? value : redFlags,
      observations: key == 'observations' ? value : observations,
    );
  }

  /// Feature labels for display.
  static const featureLabels = <String, String>{
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

  static const featureIcons = <String, int>{
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
}
