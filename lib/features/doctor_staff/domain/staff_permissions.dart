/// Access level for a single staff feature.
enum StaffAccessLevel { none, read, readWrite }

/// Per-feature permission set for a staff member.
///
/// Stored in `users/{staffUid}.staffPermissions` and mirrored in
/// `doctors/{doctorUid}/staff/{staffUid}.permissions`.
class StaffPermissions {
  const StaffPermissions({
    this.appointments = StaffAccessLevel.read,
    this.timeline = StaffAccessLevel.read,
    this.vitals = StaffAccessLevel.read,
    this.pain = StaffAccessLevel.read,
    this.wounds = StaffAccessLevel.read,
    this.documents = StaffAccessLevel.read,
    this.redFlags = StaffAccessLevel.read,
    this.templates = StaffAccessLevel.none,
    this.invites = StaffAccessLevel.none,
  });

  final StaffAccessLevel appointments;
  final StaffAccessLevel timeline;
  final StaffAccessLevel vitals;
  final StaffAccessLevel pain;
  final StaffAccessLevel wounds;
  final StaffAccessLevel documents;
  final StaffAccessLevel redFlags;
  final StaffAccessLevel templates;
  final StaffAccessLevel invites;

  /// Default permissions for new staff — read-only + appointment management.
  static const mfaDefault = StaffPermissions(
    appointments: StaffAccessLevel.readWrite,
    timeline: StaffAccessLevel.read,
    vitals: StaffAccessLevel.read,
    pain: StaffAccessLevel.read,
    wounds: StaffAccessLevel.read,
    documents: StaffAccessLevel.read,
    redFlags: StaffAccessLevel.read,
    templates: StaffAccessLevel.none,
    invites: StaffAccessLevel.readWrite,
  );

  factory StaffPermissions.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const StaffPermissions();
    return StaffPermissions(
      appointments: _parse(map['appointments']),
      timeline: _parse(map['timeline']),
      vitals: _parse(map['vitals']),
      pain: _parse(map['pain']),
      wounds: _parse(map['wounds']),
      documents: _parse(map['documents']),
      redFlags: _parse(map['redFlags']),
      templates: _parse(map['templates']),
      invites: _parse(map['invites']),
    );
  }

  Map<String, dynamic> toMap() => {
        'appointments': appointments.name,
        'timeline': timeline.name,
        'vitals': vitals.name,
        'pain': pain.name,
        'wounds': wounds.name,
        'documents': documents.name,
        'redFlags': redFlags.name,
        'templates': templates.name,
        'invites': invites.name,
      };

  StaffPermissions copyWith({
    StaffAccessLevel? appointments,
    StaffAccessLevel? timeline,
    StaffAccessLevel? vitals,
    StaffAccessLevel? pain,
    StaffAccessLevel? wounds,
    StaffAccessLevel? documents,
    StaffAccessLevel? redFlags,
    StaffAccessLevel? templates,
    StaffAccessLevel? invites,
  }) {
    return StaffPermissions(
      appointments: appointments ?? this.appointments,
      timeline: timeline ?? this.timeline,
      vitals: vitals ?? this.vitals,
      pain: pain ?? this.pain,
      wounds: wounds ?? this.wounds,
      documents: documents ?? this.documents,
      redFlags: redFlags ?? this.redFlags,
      templates: templates ?? this.templates,
      invites: invites ?? this.invites,
    );
  }

  /// Convenience accessor by feature name.
  StaffAccessLevel operator [](String feature) {
    return switch (feature) {
      'appointments' => appointments,
      'timeline' => timeline,
      'vitals' => vitals,
      'pain' => pain,
      'wounds' => wounds,
      'documents' => documents,
      'redFlags' => redFlags,
      'templates' => templates,
      'invites' => invites,
      _ => StaffAccessLevel.none,
    };
  }

  bool canRead(String feature) => this[feature] != StaffAccessLevel.none;
  bool canWrite(String feature) => this[feature] == StaffAccessLevel.readWrite;

  static StaffAccessLevel _parse(Object? raw) {
    final name = raw?.toString() ?? '';
    for (final level in StaffAccessLevel.values) {
      if (level.name == name) return level;
    }
    return StaffAccessLevel.read;
  }

  /// Labels for the settings UI.
  static const featureLabels = <String, String>{
    'appointments': 'Termine',
    'timeline': 'Aufgaben & Plan',
    'vitals': 'Vitalwerte',
    'pain': 'Schmerztagebuch',
    'wounds': 'Wunddokumentation',
    'documents': 'Dokumente',
    'redFlags': 'Warnhinweise',
    'templates': 'Vorlagen',
    'invites': 'Patienten einladen',
  };

  static const accessLevelLabels = <StaffAccessLevel, String>{
    StaffAccessLevel.none: 'Kein Zugriff',
    StaffAccessLevel.read: 'Lesen',
    StaffAccessLevel.readWrite: 'Lesen & Schreiben',
  };
}
