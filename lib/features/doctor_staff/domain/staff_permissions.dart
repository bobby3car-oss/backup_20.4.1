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
    this.manageStaff = StaffAccessLevel.none,
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
  final StaffAccessLevel manageStaff;

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
    manageStaff: StaffAccessLevel.none,
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
      manageStaff: _parse(map['manageStaff'], defaultLevel: StaffAccessLevel.none),
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
        'manageStaff': manageStaff.name,
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
    StaffAccessLevel? manageStaff,
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
      manageStaff: manageStaff ?? this.manageStaff,
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
      'manageStaff' => manageStaff,
      _ => StaffAccessLevel.none,
    };
  }

  bool canRead(String feature) => this[feature] != StaffAccessLevel.none;
  bool canWrite(String feature) => this[feature] == StaffAccessLevel.readWrite;

  static StaffAccessLevel _parse(
    Object? raw, {
    StaffAccessLevel defaultLevel = StaffAccessLevel.read,
  }) {
    final name = raw?.toString() ?? '';
    for (final level in StaffAccessLevel.values) {
      if (level.name == name) return level;
    }
    return defaultLevel;
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
    'manageStaff': 'Teamverwaltung',
  };

  static const accessLevelLabels = <StaffAccessLevel, String>{
    StaffAccessLevel.none: 'Kein Zugriff',
    StaffAccessLevel.read: 'Lesen',
    StaffAccessLevel.readWrite: 'Lesen & Schreiben',
  };
}
