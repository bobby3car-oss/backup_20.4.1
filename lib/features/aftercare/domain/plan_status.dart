/// Lifecycle status of a patient aftercare plan.
///
/// Transitions:
/// ```
///   draft ──→ scheduled ──→ active ──→ archived
///          └─────────────→ active ──→ archived
/// ```
enum PlanStatus {
  /// Plan prepared but not yet approved or activated.
  draft,

  /// Plan approved and scheduled for future activation.
  scheduled,

  /// Currently active plan for the patient (at most one per patient).
  active,

  /// Temporarily paused — can be resumed, completed, or cancelled.
  paused,

  /// All items done or doctor manually completed. Terminal state.
  completed,

  /// Aborted without completion. Terminal state.
  cancelled,

  /// Superseded or manually archived plan (replaced by new plan).
  archived;

  /// Parse from Firestore string value, defaulting to [draft].
  factory PlanStatus.fromString(String? value) {
    for (final s in PlanStatus.values) {
      if (s.name == value) return s;
    }
    return PlanStatus.draft;
  }

  /// German display label.
  String get displayName => switch (this) {
        PlanStatus.draft => 'Entwurf',
        PlanStatus.scheduled => 'Geplant',
        PlanStatus.active => 'Aktiv',
        PlanStatus.paused => 'Pausiert',
        PlanStatus.completed => 'Abgeschlossen',
        PlanStatus.cancelled => 'Abgebrochen',
        PlanStatus.archived => 'Archiviert',
      };
}

/// How the plan activation date is determined.
enum ActivationMode {
  /// Activation starts at the patient's surgery date.
  opDate,

  /// Activation starts at a custom date chosen by the doctor.
  customDate;

  factory ActivationMode.fromString(String? value) {
    if (value == 'customDate') return ActivationMode.customDate;
    return ActivationMode.opDate;
  }
}
