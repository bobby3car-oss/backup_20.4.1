import 'dart:async';

import '../../../notifications/local_notifications.dart';
import '../../../notifications/notification_preferences.dart';
import '../domain/medication_reminder.dart';
import 'medication_reminder_repository_sync.dart';

class MedicationReminderScheduler {
  MedicationReminderScheduler._();

  static final MedicationReminderScheduler instance =
      MedicationReminderScheduler._();

  final MedicationReminderRepositorySync _repository =
      MedicationReminderRepositorySync.instance;

  Completer<void>? _rescheduleGuard;

  Future<void> bootstrap() async {
    await _repository.loadFromDisk();
    await _repository.pullLatest();
    await rescheduleAll();
  }

  Future<void> rescheduleAll() async {
    // Prevent concurrent rescheduleAll() calls from race-conditioning
    // notification scheduling. Wait for the in-progress run to finish.
    if (_rescheduleGuard != null) {
      await _rescheduleGuard!.future;
      return;
    }
    final completer = Completer<void>();
    _rescheduleGuard = completer;

    try {
      final reminders = await _repository.watchAll().first;
      final prefs = NotificationPreferences.instance;
      final enabled = prefs.globalEnabled && prefs.medicationReminders;

      for (final reminder in reminders) {
        if (!enabled || reminder.isDeleted || !reminder.isEnabled || reminder.isExpired) {
          await LocalNotifications.cancelForMedicationReminder(reminder.id);
          continue;
        }
        await LocalNotifications.scheduleForMedicationReminder(reminder);
      }
    } finally {
      _rescheduleGuard = null;
      completer.complete();
    }
  }

  Future<void> syncReminder(MedicationReminder reminder) async {
    final prefs = NotificationPreferences.instance;
    final enabled = prefs.globalEnabled && prefs.medicationReminders;
    if (!enabled || reminder.isDeleted || !reminder.isEnabled || reminder.isExpired) {
      await LocalNotifications.cancelForMedicationReminder(reminder.id);
      return;
    }
    await LocalNotifications.scheduleForMedicationReminder(reminder);
  }

  Future<void> cancel(String reminderId) {
    return LocalNotifications.cancelForMedicationReminder(reminderId);
  }
}
