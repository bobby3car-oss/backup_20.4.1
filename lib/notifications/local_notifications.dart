import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'package:flutter/material.dart';

import '../domain/timeline_engine.dart';
import '../features/appointments/domain/appointment.dart';
import '../features/appointments/domain/appointment_enums.dart';
import '../features/medication/domain/medication_reminder.dart';

class LocalNotifications {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static bool _timezoneInitialized = false;
  static bool _permissionRequested = false;
  static bool _permissionGranted = false;

  static const AndroidNotificationDetails _androidDetails =
      AndroidNotificationDetails(
        'timeline_due_channel',
        'Timeline Erinnerungen',
        channelDescription: 'Erinnerungen fuer faellige Timeline-Aufgaben',
        importance: Importance.max,
        priority: Priority.high,
      );

  static const DarwinNotificationDetails _darwinDetails =
      DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

  static const NotificationDetails _details = NotificationDetails(
    android: _androidDetails,
    iOS: _darwinDetails,
    macOS: _darwinDetails,
  );

  static const AndroidNotificationDetails _medicationAndroidDetails =
      AndroidNotificationDetails(
        'medication_channel',
        'Medikamentenwecker',
        channelDescription: 'Taegliche Erinnerungen fuer Medikamente',
        importance: Importance.max,
        priority: Priority.high,
      );

  static const NotificationDetails _medicationDetails = NotificationDetails(
    android: _medicationAndroidDetails,
    iOS: _darwinDetails,
    macOS: _darwinDetails,
  );

  static const AndroidNotificationDetails _vitalsAndroidDetails =
      AndroidNotificationDetails(
        'vitals_reminder_channel',
        'Vitalwerte Erinnerung',
        channelDescription: 'Taegliche Erinnerung zur Vitalwerte-Messung',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      );

  static const NotificationDetails _vitalsDetails = NotificationDetails(
    android: _vitalsAndroidDetails,
    iOS: _darwinDetails,
    macOS: _darwinDetails,
  );

  static Future<void> init() async {
    if (_initialized) return;
    try {
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const settings = InitializationSettings(
        android: android,
        iOS: ios,
        macOS: ios,
      );

      if (!_timezoneInitialized) {
        tz_data.initializeTimeZones();
        _timezoneInitialized = true;
      }

      await _plugin.initialize(settings: settings);
      _initialized = true;
    } catch (_) {
      _initialized = false;
    }
  }

  static Future<bool> requestPermissionsIfNeeded() async {
    await init();
    if (!_initialized) return false;
    if (_permissionRequested) return _permissionGranted;
    _permissionRequested = true;

    try {
      bool granted = true;
      final androidImpl = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final androidGranted = await androidImpl?.requestNotificationsPermission();
      if (androidGranted != null) {
        granted = granted && androidGranted;
      }

      final iosImpl = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final iosGranted = await iosImpl?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      if (iosGranted != null) {
        granted = granted && iosGranted;
      }

      final macImpl = _plugin
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >();
      final macGranted = await macImpl?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      if (macGranted != null) {
        granted = granted && macGranted;
      }

      _permissionGranted = granted;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LocalNotifications] requestPermissionsIfNeeded: $e');
      }
      _permissionGranted = false;
    }

    return _permissionGranted;
  }

  /// Show a notification triggered by an FCM foreground message.
  static Future<void> showFcmNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await init();
    if (!_initialized) return;

    const androidDetails = AndroidNotificationDetails(
      'fcm_channel',
      'Push-Benachrichtigungen',
      channelDescription: 'Benachrichtigungen vom Server',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: _darwinDetails,
      macOS: _darwinDetails,
    );

    await _plugin.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }

  static Future<void> scheduleForItem(TimelineItem item) async {
    await init();
    if (!_initialized) return;

    final dueAt = item.dueAt;
    final isFinalized =
        item.state == TaskState.done || item.state == TaskState.skipped;
    if (dueAt == null || isFinalized) {
      await cancelForItem(item.id);
      return;
    }

    final hasPermission = await requestPermissionsIfNeeded();
    if (!hasPermission) return;

    final id = _notificationIdFor(item.id);
    final dueLocal = dueAt.toLocal();
    final dueTimeLabel = _hhmm(dueLocal);

    try {
      await _plugin.cancel(id: id);
      if (dueLocal.isBefore(DateTime.now())) {
        await _plugin.show(
          id: id,
          title: item.title,
          body: 'Überfällig seit $dueTimeLabel',
          notificationDetails: _details,
        );
        return;
      }

      final subtitle = item.subtitle.trim();
      final body = subtitle.isEmpty
          ? 'fällig $dueTimeLabel'
          : '$subtitle · fällig $dueTimeLabel';
      await _plugin.zonedSchedule(
        id: id,
        title: item.title,
        body: body,
        scheduledDate: tz.TZDateTime.from(dueLocal, tz.local),
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('[LocalNotifications] scheduleForItem: $e');
    }
  }

  static Future<void> cancelForItem(String id) async {
    await init();
    if (!_initialized) return;
    try {
      await _plugin.cancel(id: _notificationIdFor(id));
    } catch (e) {
      if (kDebugMode) debugPrint('[LocalNotifications] cancelForItem: $e');
    }
  }

  static Future<void> cancelAll() async {
    await init();
    if (!_initialized) return;
    try {
      await _plugin.cancelAll();
    } catch (e) {
      if (kDebugMode) debugPrint('[LocalNotifications] cancelAll: $e');
    }
  }

  static Future<void> scheduleForAppointment(Appointment appointment) async {
    await init();
    if (!_initialized) return;

    final isFinalized =
        appointment.status == AppointmentStatus.done ||
        appointment.status == AppointmentStatus.canceled;
    if (appointment.reminderPreset == ReminderPreset.none || isFinalized) {
      await cancelForAppointment(appointment.id);
      return;
    }

    final reminderAt = _appointmentReminderAt(appointment);
    if (reminderAt == null || reminderAt.isBefore(DateTime.now())) {
      await cancelForAppointment(appointment.id);
      return;
    }

    final hasPermission = await requestPermissionsIfNeeded();
    if (!hasPermission) return;

    final id = _notificationIdFor('appointment_${appointment.id}');
    final reminderLocal = reminderAt.toLocal();
    final startLocal = appointment.startAt.toLocal();
    final body = appointment.locationName?.trim().isNotEmpty == true
        ? '${appointment.locationName} · ${_hhmm(startLocal)}'
        : 'Start: ${_hhmm(startLocal)}';

    try {
      await _plugin.cancel(id: id);
      await _plugin.zonedSchedule(
        id: id,
        title: appointment.title,
        body: body,
        scheduledDate: tz.TZDateTime.from(reminderLocal, tz.local),
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LocalNotifications] scheduleForAppointment: $e');
      }
    }
  }

  static Future<void> cancelForAppointment(String appointmentId) async {
    await init();
    if (!_initialized) return;
    try {
      await _plugin.cancel(
        id: _notificationIdFor('appointment_$appointmentId'),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LocalNotifications] cancelForAppointment: $e');
      }
    }
  }

  static Future<void> scheduleForMedicationReminder(
    MedicationReminder reminder,
  ) async {
    await init();
    if (!_initialized) return;

    if (!reminder.isEnabled || reminder.isDeleted) {
      await cancelForMedicationReminder(reminder.id);
      return;
    }

    final hasPermission = await requestPermissionsIfNeeded();
    if (!hasPermission) return;

    final id = _notificationIdFor('medication_${reminder.id}');
    final scheduledAt = reminder.nextOccurrence();
    final bodyParts = <String>[
      if (reminder.dose != null && reminder.dose!.trim().isNotEmpty)
        reminder.dose!.trim(),
      if (reminder.note != null && reminder.note!.trim().isNotEmpty)
        reminder.note!.trim(),
    ];
    final body = bodyParts.isEmpty
        ? 'Geplante Einnahme um ${reminder.timeLabel}'
        : '${bodyParts.join(' · ')} · ${reminder.timeLabel}';

    try {
      await _plugin.cancel(id: id);
      await _plugin.zonedSchedule(
        id: id,
        title: '${reminder.medicationName} einnehmen',
        body: body,
        scheduledDate: tz.TZDateTime.from(scheduledAt, tz.local),
        notificationDetails: _medicationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: '/meds',
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LocalNotifications] scheduleForMedicationReminder: $e');
      }
    }
  }

  static Future<void> cancelForMedicationReminder(String reminderId) async {
    await init();
    if (!_initialized) return;
    try {
      await _plugin.cancel(id: _notificationIdFor('medication_$reminderId'));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LocalNotifications] cancelForMedicationReminder: $e');
      }
    }
  }

  static Future<void> scheduleMedicationSnooze({
    required MedicationReminder reminder,
    required Duration duration,
  }) async {
    await init();
    if (!_initialized) return;

    final hasPermission = await requestPermissionsIfNeeded();
    if (!hasPermission) return;

    final id = _notificationIdFor('medication_snooze_${reminder.id}');
    final scheduledAt = DateTime.now().add(duration);
    final bodyParts = <String>[
      if (reminder.dose != null && reminder.dose!.trim().isNotEmpty)
        reminder.dose!.trim(),
      if (reminder.note != null && reminder.note!.trim().isNotEmpty)
        reminder.note!.trim(),
    ];
    final body = bodyParts.isEmpty
        ? 'Erneute Erinnerung um ${_hhmm(scheduledAt)}'
        : '${bodyParts.join(' · ')} · ${_hhmm(scheduledAt)}';

    try {
      await _plugin.cancel(id: id);
      await _plugin.zonedSchedule(
        id: id,
        title: '${reminder.medicationName} später einnehmen',
        body: body,
        scheduledDate: tz.TZDateTime.from(scheduledAt, tz.local),
        notificationDetails: _medicationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: '/meds',
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LocalNotifications] scheduleMedicationSnooze: $e');
      }
    }
  }

  static Future<void> cancelMedicationSnooze(String reminderId) async {
    await init();
    if (!_initialized) return;
    try {
      await _plugin.cancel(
        id: _notificationIdFor('medication_snooze_$reminderId'),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LocalNotifications] cancelMedicationSnooze: $e');
      }
    }
  }

  static Future<void> scheduleVitalReminder(TimeOfDay time) async {
    await init();
    if (!_initialized) return;

    final hasPermission = await requestPermissionsIfNeeded();
    if (!hasPermission) return;

    final id = _notificationIdFor('vitals_daily_reminder');
    final now = DateTime.now();
    var scheduledAt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    if (scheduledAt.isBefore(now)) {
      scheduledAt = scheduledAt.add(const Duration(days: 1));
    }

    try {
      await _plugin.cancel(id: id);
      await _plugin.zonedSchedule(
        id: id,
        title: 'Vitalwerte messen',
        body: 'Zeit fuer deine taegliche Messung \u{1F3E5}',
        scheduledDate: tz.TZDateTime.from(scheduledAt, tz.local),
        notificationDetails: _vitalsDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: '/vitals',
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LocalNotifications] scheduleVitalReminder: $e');
      }
    }
  }

  static Future<void> cancelVitalReminder() async {
    await init();
    if (!_initialized) return;
    try {
      await _plugin.cancel(
        id: _notificationIdFor('vitals_daily_reminder'),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LocalNotifications] cancelVitalReminder: $e');
      }
    }
  }

  static int _notificationIdFor(String id) {
    var hash = 0x811C9DC5;
    for (final unit in id.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0x7FFFFFFF;
    }
    return hash;
  }

  static String _hhmm(DateTime value) {
    final hh = value.hour.toString().padLeft(2, '0');
    final mm = value.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  static DateTime? _appointmentReminderAt(Appointment appointment) {
    final minutes = switch (appointment.reminderPreset) {
      ReminderPreset.none => null,
      ReminderPreset.atTime => 0,
      ReminderPreset.min15 => 15,
      ReminderPreset.min30 => 30,
      ReminderPreset.hour1 => 60,
      ReminderPreset.hours2 => 120,
      ReminderPreset.day1 => 24 * 60,
      ReminderPreset.days2 => 2 * 24 * 60,
      ReminderPreset.custom => appointment.reminderMinutes,
    };
    if (minutes == null) return null;
    return appointment.startAt.subtract(Duration(minutes: minutes));
  }
}
