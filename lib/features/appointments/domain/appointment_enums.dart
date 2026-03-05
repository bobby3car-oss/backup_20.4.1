import 'package:flutter/material.dart';

// ── Appointment type ─────────────────────────────────────────────────────────

enum AppointmentType { followUp, physio, surgery, call, imaging, other }

extension AppointmentTypeX on AppointmentType {
  /// Human-readable German label.
  String get label => switch (this) {
    AppointmentType.followUp => 'Nachsorge',
    AppointmentType.physio => 'Physio',
    AppointmentType.surgery => 'OP',
    AppointmentType.call => 'Telefon',
    AppointmentType.imaging => 'Bildgebung',
    AppointmentType.other => 'Sonstiges',
  };

  /// Accent colour per appointment type.
  Color get color => switch (this) {
    AppointmentType.followUp => const Color(0xFF007AFF), // primary blue
    AppointmentType.physio => const Color(0xFF34C759), // success green
    AppointmentType.surgery => const Color(0xFFFF9500), // warning orange
    AppointmentType.call => const Color(0xFF30B0C7), // teal
    AppointmentType.imaging => const Color(0xFF5856D6), // accent purple
    AppointmentType.other => const Color(0xFF8E8E93), // grey
  };

  /// Lighter tint for backgrounds / chips.
  Color get tint => color.withValues(alpha: 0.12);

  /// Semantic icon for this appointment type.
  IconData get icon => switch (this) {
    AppointmentType.followUp => Icons.event_note_rounded,
    AppointmentType.physio => Icons.fitness_center_rounded,
    AppointmentType.surgery => Icons.local_hospital_rounded,
    AppointmentType.call => Icons.phone_rounded,
    AppointmentType.imaging => Icons.image_search_rounded,
    AppointmentType.other => Icons.category_rounded,
  };
}

// ── Appointment status ───────────────────────────────────────────────────────

enum AppointmentStatus { planned, done, canceled }

extension AppointmentStatusX on AppointmentStatus {
  String get label => switch (this) {
    AppointmentStatus.planned => 'Geplant',
    AppointmentStatus.done => 'Erledigt',
    AppointmentStatus.canceled => 'Abgesagt',
  };

  Color get color => switch (this) {
    AppointmentStatus.planned => const Color(0xFF007AFF),
    AppointmentStatus.done => const Color(0xFF34C759),
    AppointmentStatus.canceled => const Color(0xFFFF3B30),
  };

  IconData get icon => switch (this) {
    AppointmentStatus.planned => Icons.schedule_rounded,
    AppointmentStatus.done => Icons.check_circle_rounded,
    AppointmentStatus.canceled => Icons.cancel_rounded,
  };
}

// ── Reminder preset ──────────────────────────────────────────────────────────

enum ReminderPreset {
  none,
  atTime,
  min15,
  min30,
  hour1,
  hours2,
  day1,
  days2,
  custom,
}

extension ReminderPresetX on ReminderPreset {
  String get label => switch (this) {
    ReminderPreset.none => 'Keine',
    ReminderPreset.atTime => 'Zum Zeitpunkt',
    ReminderPreset.min15 => '15 Min. vorher',
    ReminderPreset.min30 => '30 Min. vorher',
    ReminderPreset.hour1 => '1 Stunde vorher',
    ReminderPreset.hours2 => '2 Stunden vorher',
    ReminderPreset.day1 => '1 Tag vorher',
    ReminderPreset.days2 => '2 Tage vorher',
    ReminderPreset.custom => 'Benutzerdefiniert',
  };
}

// ── Repeat rule ──────────────────────────────────────────────────────────────

enum RepeatRule { none, daily, weekly, monthly }

extension RepeatRuleX on RepeatRule {
  String get label => switch (this) {
    RepeatRule.none => 'Keine',
    RepeatRule.daily => 'Täglich',
    RepeatRule.weekly => 'Wöchentlich',
    RepeatRule.monthly => 'Monatlich',
  };
}

// ── Priority ─────────────────────────────────────────────────────────────────

enum AppointmentPriority { low, medium, high, urgent }

extension AppointmentPriorityX on AppointmentPriority {
  String get label => switch (this) {
    AppointmentPriority.low => 'Niedrig',
    AppointmentPriority.medium => 'Mittel',
    AppointmentPriority.high => 'Hoch',
    AppointmentPriority.urgent => 'Dringend',
  };

  Color get color => switch (this) {
    AppointmentPriority.low => const Color(0xFF8E8E93),
    AppointmentPriority.medium => const Color(0xFF007AFF),
    AppointmentPriority.high => const Color(0xFFFF9500),
    AppointmentPriority.urgent => const Color(0xFFFF3B30),
  };

  IconData get icon => switch (this) {
    AppointmentPriority.low => Icons.arrow_downward_rounded,
    AppointmentPriority.medium => Icons.remove_rounded,
    AppointmentPriority.high => Icons.arrow_upward_rounded,
    AppointmentPriority.urgent => Icons.priority_high_rounded,
  };
}
