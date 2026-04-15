/// Access level for a single staff feature.
enum StaffAccessLevel { none, read, readWrite }

/// Per-feature permission set for a staff member.
///
/// Stored in `users/{staffUid}.staffPermissions` and mirrored in
/// `doctors/{doctorUid}/staff/{staffUid}.permissions`.
class StaffPermissions {
  const StaffPermissions({
    this.appointments = StaffAccessLevel.read,
    this.templates = StaffAccessLevel.none,
    this.invites = StaffAccessLevel.none,
    this.manageStaff = StaffAccessLevel.none,
    this.aftercare = StaffAccessLevel.none,
  });

  final StaffAccessLevel appointments;
  final StaffAccessLevel templates;
  final StaffAccessLevel invites;
  final StaffAccessLevel manageStaff;
  final StaffAccessLevel aftercare;

  /// Default permissions for new staff — read-only + appointment management.
  static const mfaDefault = StaffPermissions(
    appointments: StaffAccessLevel.readWrite,
    templates: StaffAccessLevel.none,
    invites: StaffAccessLevel.readWrite,
    manageStaff: StaffAccessLevel.none,
    aftercare: StaffAccessLevel.none,
  );

  factory StaffPermissions.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const StaffPermissions();
    return StaffPermissions(
      appointments: _parse(map['appointments']),
      templates: _parse(map['templates']),
      invites: _parse(map['invites']),
      manageStaff: _parse(map['manageStaff'], defaultLevel: StaffAccessLevel.none),
      aftercare: _parse(map['aftercare'], defaultLevel: StaffAccessLevel.none),
    );
  }

  Map<String, dynamic> toMap() => {
        'appointments': appointments.name,
        'templates': templates.name,
        'invites': invites.name,
        'manageStaff': manageStaff.name,
        'aftercare': aftercare.name,
      };

  StaffPermissions copyWith({
    StaffAccessLevel? appointments,
    StaffAccessLevel? templates,
    StaffAccessLevel? invites,
    StaffAccessLevel? manageStaff,
    StaffAccessLevel? aftercare,
  }) {
    return StaffPermissions(
      appointments: appointments ?? this.appointments,
      templates: templates ?? this.templates,
      invites: invites ?? this.invites,
      manageStaff: manageStaff ?? this.manageStaff,
      aftercare: aftercare ?? this.aftercare,
    );
  }

  /// Convenience accessor by feature name.
  StaffAccessLevel operator [](String feature) {
    return switch (feature) {
      'appointments' => appointments,
      'templates' => templates,
      'invites' => invites,
      'manageStaff' => manageStaff,
      'aftercare' => aftercare,
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
    'invites': 'Patienten einladen',
    'templates': 'Vorlagen',
    'aftercare': 'Nachbehandlung',
    'manageStaff': 'Teamverwaltung',
  };

  static const accessLevelLabels = <StaffAccessLevel, String>{
    StaffAccessLevel.none: 'Kein Zugriff',
    StaffAccessLevel.read: 'Lesen',
    StaffAccessLevel.readWrite: 'Lesen & Schreiben',
  };
}
