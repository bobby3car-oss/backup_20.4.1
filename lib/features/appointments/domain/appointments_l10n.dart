import '../../../l10n/app_localizations.dart';
import 'appointment_enums.dart';

/// Returns the localized label for an [AppointmentType].
String localizedAppointmentType(AppLocalizations l, AppointmentType type) {
  return switch (type) {
    AppointmentType.followUp => l.apptTypeFollowUp,
    AppointmentType.physio   => l.apptTypePhysio,
    AppointmentType.surgery  => l.apptTypeSurgery,
    AppointmentType.call     => l.apptTypeCall,
    AppointmentType.imaging  => l.apptTypeImaging,
    AppointmentType.other    => l.apptTypeOther,
  };
}

/// Returns the localized label for an [AppointmentStatus].
String localizedAppointmentStatus(
    AppLocalizations l, AppointmentStatus status) {
  return switch (status) {
    AppointmentStatus.planned   => l.apptStatusPlanned,
    AppointmentStatus.pending   => l.apptStatusPending,
    AppointmentStatus.confirmed => l.apptStatusConfirmed,
    AppointmentStatus.declined  => l.apptStatusDeclined,
    AppointmentStatus.done      => l.apptStatusDone,
    AppointmentStatus.canceled  => l.apptStatusCanceled,
    AppointmentStatus.completed => l.apptStatusCompleted,
  };
}

/// Returns the localized label for a [ReminderPreset].
String localizedReminderPreset(AppLocalizations l, ReminderPreset preset) {
  return switch (preset) {
    ReminderPreset.none    => l.apptReminderNone,
    ReminderPreset.atTime  => l.apptReminderAtTime,
    ReminderPreset.min15   => l.apptReminderMin15,
    ReminderPreset.min30   => l.apptReminderMin30,
    ReminderPreset.hour1   => l.apptReminderHour1,
    ReminderPreset.hours2  => l.apptReminderHours2,
    ReminderPreset.day1    => l.apptReminderDay1,
    ReminderPreset.days2   => l.apptReminderDays2,
    ReminderPreset.custom  => l.apptReminderCustom,
  };
}

/// Returns the localized label for a [RepeatRule].
String localizedRepeatRule(AppLocalizations l, RepeatRule rule) {
  return switch (rule) {
    RepeatRule.none    => l.apptRepeatNone,
    RepeatRule.daily   => l.apptRepeatDaily,
    RepeatRule.weekly  => l.apptRepeatWeekly,
    RepeatRule.monthly => l.apptRepeatMonthly,
  };
}

/// Returns the localized label for an [AppointmentPriority].
String localizedAppointmentPriority(
    AppLocalizations l, AppointmentPriority priority) {
  return switch (priority) {
    AppointmentPriority.low    => l.apptPriorityLow,
    AppointmentPriority.medium => l.apptPriorityMedium,
    AppointmentPriority.high   => l.apptPriorityHigh,
    AppointmentPriority.urgent => l.apptPriorityUrgent,
  };
}
