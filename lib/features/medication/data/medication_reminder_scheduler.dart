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

  Future<void> bootstrap() async {
    await _repository.loadFromDisk();
    await _repository.pullLatest();
    await rescheduleAll();
  }

  Future<void> rescheduleAll() async {
    final reminders = await _repository.watchAll().first;
    final prefs = NotificationPreferences.instance;
    final enabled = prefs.globalEnabled && prefs.medicationReminders;

    for (final reminder in reminders) {
      if (!enabled || reminder.isDeleted || !reminder.isEnabled) {
        await LocalNotifications.cancelForMedicationReminder(reminder.id);
        continue;
      }
      await LocalNotifications.scheduleForMedicationReminder(reminder);
    }
  }

  Future<void> syncReminder(MedicationReminder reminder) async {
    final prefs = NotificationPreferences.instance;
    final enabled = prefs.globalEnabled && prefs.medicationReminders;
    if (!enabled || reminder.isDeleted || !reminder.isEnabled) {
      await LocalNotifications.cancelForMedicationReminder(reminder.id);
      return;
    }
    await LocalNotifications.scheduleForMedicationReminder(reminder);
  }

  Future<void> cancel(String reminderId) {
    return LocalNotifications.cancelForMedicationReminder(reminderId);
  }
}
