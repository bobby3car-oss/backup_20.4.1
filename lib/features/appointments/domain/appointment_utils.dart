import 'appointment.dart';
import 'appointment_enums.dart';

({DateTime startAt, DateTime? endAt}) normalizeAllDay({
  required DateTime startAt,
  DateTime? endAt,
  required bool allDay,
}) {
  if (!allDay) {
    return (startAt: startAt, endAt: endAt);
  }

  final normalizedStart = DateTime(startAt.year, startAt.month, startAt.day);
  final normalizedEnd = endAt == null
      ? null
      : DateTime(endAt.year, endAt.month, endAt.day, 23, 59, 59, 999, 999);

  return (startAt: normalizedStart, endAt: normalizedEnd);
}

String formatDayKey(DateTime value) {
  final yyyy = value.year.toString().padLeft(4, '0');
  final mm = value.month.toString().padLeft(2, '0');
  final dd = value.day.toString().padLeft(2, '0');
  return '$yyyy-$mm-$dd';
}

List<String> validate(Appointment appointment) {
  final errors = <String>[];

  if (appointment.id.trim().isEmpty) {
    errors.add('id is required');
  }
  if (appointment.ownerId.trim().isEmpty) {
    errors.add('ownerId is required');
  }
  if (appointment.title.trim().isEmpty) {
    errors.add('title is required');
  }

  final endAt = appointment.endAt;
  if (endAt != null && endAt.isBefore(appointment.startAt)) {
    errors.add('endAt must be >= startAt');
  }

  if (appointment.reminderPreset == ReminderPreset.custom) {
    final minutes = appointment.reminderMinutes;
    if (minutes == null || minutes <= 0) {
      errors.add('reminderMinutes must be > 0 for custom preset');
    }
  }

  if (appointment.repeatRule != RepeatRule.none &&
      appointment.repeatUntil != null &&
      appointment.repeatUntil!.isBefore(appointment.startAt)) {
    errors.add('repeatUntil must be >= startAt');
  }

  if (appointment.updatedAt.isBefore(appointment.createdAt)) {
    errors.add('updatedAt must be >= createdAt');
  }

  return errors;
}
