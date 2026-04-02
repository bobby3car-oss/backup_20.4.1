import 'dart:async';

import '../../../notifications/local_notifications.dart';
import '../../../notifications/notification_preferences.dart';
import '../domain/supplement.dart';
import 'supplement_repository_sync.dart';

/// Schedules local notifications for supplement reminders.
///
/// Works analogously to [MedicationReminderScheduler].
class SupplementReminderScheduler {
  SupplementReminderScheduler._();

  static final SupplementReminderScheduler instance =
      SupplementReminderScheduler._();

  final SupplementRepositorySync _repository =
      SupplementRepositorySync.instance;

  Completer<void>? _rescheduleGuard;

  Future<void> bootstrap() async {
    await _repository.loadFromDisk();
    await _repository.pullLatest();
    await rescheduleAll();
  }

  Future<void> rescheduleAll() async {
    if (_rescheduleGuard != null) {
      await _rescheduleGuard!.future;
      return;
    }
    final completer = Completer<void>();
    _rescheduleGuard = completer;

    try {
      final supplements = await _repository.watchAll().first;
      final prefs = NotificationPreferences.instance;
      final enabled = prefs.globalEnabled && prefs.supplementReminders;

      for (final supplement in supplements) {
        if (!enabled ||
            supplement.isDeleted ||
            !supplement.isEnabled ||
            supplement.isExpired) {
          await LocalNotifications.cancelForSupplementReminder(supplement.id);
          continue;
        }
        await LocalNotifications.scheduleForSupplementReminder(supplement);
      }
    } finally {
      _rescheduleGuard = null;
      completer.complete();
    }
  }

  Future<void> syncReminder(Supplement supplement) async {
    final prefs = NotificationPreferences.instance;
    final enabled = prefs.globalEnabled && prefs.supplementReminders;
    if (!enabled ||
        supplement.isDeleted ||
        !supplement.isEnabled ||
        supplement.isExpired) {
      await LocalNotifications.cancelForSupplementReminder(supplement.id);
      return;
    }
    await LocalNotifications.scheduleForSupplementReminder(supplement);
  }
}


