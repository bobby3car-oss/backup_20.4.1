import 'dart:io' show Platform;

import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages adding / updating the surgery date (Op-Termin) in the device
/// calendar automatically.
class CalendarService {
  CalendarService._();
  static final CalendarService instance = CalendarService._();

  final DeviceCalendarPlugin _plugin = DeviceCalendarPlugin();

  static const _prefCalendarId = 'op_calendar_id';
  static const _prefEventId = 'op_calendar_event_id';

  /// Whether the device calendar plugin is available on this platform.
  bool get _supported =>
      !kIsWeb && (Platform.isIOS || Platform.isAndroid);

  /// Adds or updates the Op-Termin as an all-day event in the device calendar.
  ///
  /// [opDate] – the surgery date.
  /// [opType] – optional surgery type (e.g. "Knie-TEP") used in the title.
  Future<void> saveOpDateToCalendar(DateTime opDate, {String? opType}) async {
    if (!_supported) return;

    try {
      // 1. Check / request permissions.
      var permResult = await _plugin.hasPermissions();
      debugPrint('[CalendarService] hasPermissions=${permResult.data}');
      if (permResult.data != true) {
        permResult = await _plugin.requestPermissions();
        debugPrint(
          '[CalendarService] requestPermissions=${permResult.data}',
        );
        if (permResult.data != true) {
          debugPrint('[CalendarService] Calendar permission denied');
          return;
        }
      }

      // 2. Find a writable calendar (prefer the default one).
      final calendarsResult = await _plugin.retrieveCalendars();
      final calendars = calendarsResult.data;
      if (calendars == null || calendars.isEmpty) {
        debugPrint('[CalendarService] No calendars found on device');
        return;
      }

      debugPrint(
        '[CalendarService] Found ${calendars.length} calendars: '
        '${calendars.map((c) => '${c.name}(id=${c.id}, ro=${c.isReadOnly}, def=${c.isDefault})').join(', ')}',
      );

      final prefs = await SharedPreferences.getInstance();
      String? calendarId = prefs.getString(_prefCalendarId);

      // Check if previously used calendar still exists.
      if (calendarId != null &&
          !calendars.any((c) => c.id == calendarId)) {
        calendarId = null;
      }

      // Pick the default / first writable calendar.
      calendarId ??= calendars
              .where((c) => c.isDefault == true && c.isReadOnly != true)
              .map((c) => c.id)
              .firstOrNull ??
          calendars
              .where((c) => c.isReadOnly != true)
              .map((c) => c.id)
              .firstOrNull;

      if (calendarId == null) {
        debugPrint('[CalendarService] No writable calendar found');
        return;
      }

      await prefs.setString(_prefCalendarId, calendarId);

      // 3. Delete existing event if we previously created one.
      final existingEventId = prefs.getString(_prefEventId);
      if (existingEventId != null) {
        try {
          await _plugin.deleteEvent(calendarId, existingEventId);
        } catch (_) {
          // Best-effort: the event may already have been removed manually.
        }
        await prefs.remove(_prefEventId);
      }

      // 4. Create a new all-day event.
      final title = opType != null && opType.isNotEmpty
          ? 'Operation: $opType'
          : 'Operation (Op-Termin)';

      final startDate =
          DateTime(opDate.year, opDate.month, opDate.day);

      final event = Event(calendarId)
        ..title = title
        ..description = 'Automatisch erstellt von Operationsbegleiter'
        ..start = startDate
        ..end = startDate
        ..allDay = true;

      debugPrint(
        '[CalendarService] Creating event: "$title" on $startDate '
        'in calendar $calendarId',
      );

      final createResult = await _plugin.createOrUpdateEvent(event);
      final errors = createResult?.errors;
      if (errors != null && errors.isNotEmpty) {
        debugPrint(
          '[CalendarService] createOrUpdateEvent errors: '
          '${errors.map((e) => '${e.errorCode}: ${e.errorMessage}').join(', ')}',
        );
      }
      if (createResult?.data != null && createResult!.data!.isNotEmpty) {
        await prefs.setString(_prefEventId, createResult.data!);
        debugPrint(
          '[CalendarService] Op-Termin saved to calendar '
          '(eventId=${createResult.data})',
        );
      } else {
        debugPrint('[CalendarService] createOrUpdateEvent returned no id');
      }
    } catch (e, st) {
      debugPrint('[CalendarService] saveOpDateToCalendar failed: $e\n$st');
    }
  }
}
