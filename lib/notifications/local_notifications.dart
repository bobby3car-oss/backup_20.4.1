import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../domain/timeline_engine.dart';

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
    return _permissionGranted;
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
    } catch (_) {}
  }

  static Future<void> cancelForItem(String id) async {
    await init();
    if (!_initialized) return;
    try {
      await _plugin.cancel(id: _notificationIdFor(id));
    } catch (_) {}
  }

  static Future<void> cancelAll() async {
    await init();
    if (!_initialized) return;
    try {
      await _plugin.cancelAll();
    } catch (_) {}
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
}
