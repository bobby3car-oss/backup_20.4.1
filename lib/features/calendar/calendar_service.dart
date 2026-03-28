import 'dart:io' show File, Platform;

import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../appointments/domain/appointment.dart' as app_model;
import '../appointments/domain/appointment_enums.dart';
import '../../l10n/app_localizations.dart';

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

  // ── Export any appointment to device calendar ──────────────────────────────

  /// Exports an [app_model.Appointment] to the device calendar.
  /// Returns `true` on success.
  Future<bool> exportToDeviceCalendar(app_model.Appointment appointment) async {
    if (!_supported) return false;

    try {
      var permResult = await _plugin.hasPermissions();
      if (permResult.data != true) {
        permResult = await _plugin.requestPermissions();
        if (permResult.data != true) return false;
      }

      final calendarsResult = await _plugin.retrieveCalendars();
      final calendars = calendarsResult.data;
      if (calendars == null || calendars.isEmpty) return false;

      final prefs = await SharedPreferences.getInstance();
      String? calendarId = prefs.getString(_prefCalendarId);

      if (calendarId != null &&
          !calendars.any((c) => c.id == calendarId)) {
        calendarId = null;
      }

      calendarId ??= calendars
              .where((c) => c.isDefault == true && c.isReadOnly != true)
              .map((c) => c.id)
              .firstOrNull ??
          calendars
              .where((c) => c.isReadOnly != true)
              .map((c) => c.id)
              .firstOrNull;

      if (calendarId == null) return false;
      await prefs.setString(_prefCalendarId, calendarId);

      final event = Event(calendarId)
        ..title = appointment.title
        ..description = [
          if (appointment.notes.isNotEmpty) appointment.notes,
          if (appointment.preparation != null &&
              appointment.preparation!.isNotEmpty)
            'Vorbereitung: ${appointment.preparation}',
        ].join('\n')
        ..start = appointment.startAt
        ..end = appointment.endAt ?? appointment.startAt.add(const Duration(hours: 1))
        ..allDay = appointment.allDay
        ..location = appointment.locationName;

      final result = await _plugin.createOrUpdateEvent(event);
      if (result?.data != null && result!.data!.isNotEmpty) {
        debugPrint(
          '[CalendarService] Appointment exported (eventId=${result.data})',
        );
        return true;
      }
      return false;
    } catch (e, st) {
      debugPrint('[CalendarService] exportToDeviceCalendar failed: $e\n$st');
      return false;
    }
  }

  // ── iCal (.ics) export ─────────────────────────────────────────────────────

  /// Generates an iCal string for the given appointment.
  String generateIcs(app_model.Appointment appointment) {
    final buf = StringBuffer()
      ..writeln('BEGIN:VCALENDAR')
      ..writeln('VERSION:2.0')
      ..writeln('PRODID:-//Operationsbegleiter//DE')
      ..writeln('CALSCALE:GREGORIAN')
      ..writeln('BEGIN:VEVENT')
      ..writeln('UID:${appointment.id}@operationsbegleiter')
      ..writeln('DTSTART:${_icsDate(appointment.startAt, appointment.allDay)}')
      ..writeln(
        'DTEND:${_icsDate(appointment.endAt ?? appointment.startAt.add(const Duration(hours: 1)), appointment.allDay)}',
      )
      ..writeln('SUMMARY:${_icsEscape(appointment.title)}');

    if (appointment.locationName != null &&
        appointment.locationName!.isNotEmpty) {
      buf.writeln('LOCATION:${_icsEscape(appointment.locationName!)}');
    }

    final descParts = <String>[
      if (appointment.notes.isNotEmpty) appointment.notes,
      if (appointment.preparation != null &&
          appointment.preparation!.isNotEmpty)
        'Vorbereitung: ${appointment.preparation}',
      if (appointment.doctorName != null &&
          appointment.doctorName!.isNotEmpty)
        'Arzt: ${appointment.doctorName}',
    ];
    if (descParts.isNotEmpty) {
      buf.writeln('DESCRIPTION:${_icsEscape(descParts.join('\\n'))}');
    }

    // Add alarm for primary reminder.
    final alarmMinutes = _reminderMinutesFor(appointment.reminderPreset,
        appointment.reminderMinutes);
    if (alarmMinutes != null) {
      buf
        ..writeln('BEGIN:VALARM')
        ..writeln('TRIGGER:-PT${alarmMinutes}M')
        ..writeln('ACTION:DISPLAY')
        ..writeln('DESCRIPTION:${_icsEscape(appointment.title)}')
        ..writeln('END:VALARM');
    }

    // Add alarms for additional reminders.
    for (final preset in appointment.reminderPresets) {
      final mins = _reminderMinutesFor(preset, null);
      if (mins != null && mins != alarmMinutes) {
        buf
          ..writeln('BEGIN:VALARM')
          ..writeln('TRIGGER:-PT${mins}M')
          ..writeln('ACTION:DISPLAY')
          ..writeln('DESCRIPTION:${_icsEscape(appointment.title)}')
          ..writeln('END:VALARM');
      }
    }

    buf
      ..writeln('END:VEVENT')
      ..writeln('END:VCALENDAR');
    return buf.toString();
  }

  /// Shares the appointment as an .ics file.
  Future<void> shareIcs(app_model.Appointment appointment) async {
    try {
      final icsContent = generateIcs(appointment);
      final dir = await getTemporaryDirectory();
      final sanitized = appointment.title
          .replaceAll(RegExp(r'[^\w\s-]'), '')
          .replaceAll(RegExp(r'\s+'), '_');
      final filePath = '${dir.path}/$sanitized.ics';
      final file = File(filePath);
      await file.writeAsString(icsContent);
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)]),
      );
    } catch (e) {
      debugPrint('[CalendarService] shareIcs failed: $e');
    }
  }

  // ── "Add to calendar?" dialog ──────────────────────────────────────────────

  /// Shows a dialog asking whether to add the appointment to device calendar
  /// and/or share as .ics file.
  static Future<void> showAddToCalendarDialog(
    BuildContext context,
    app_model.Appointment appointment,
  ) async {
    final l = AppLocalizations.of(context)!;
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.calendarAddTitle),
        content: Text(l.calendarAddToCalendarBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.calendarNoThanks),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'ics'),
            child: Text(l.calendarShareIcs),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, 'device'),
            child: Text(l.calendarAdd),
          ),
        ],
      ),
    );

    if (result == null) return;

    if (result == 'device') {
      final success =
          await CalendarService.instance.exportToDeviceCalendar(appointment);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? l.calendarAddedSuccess
                  : l.calendarExportFailed,
            ),
          ),
        );
      }
    } else if (result == 'ics') {
      await CalendarService.instance.shareIcs(appointment);
    }
  }

  // ── private helpers ────────────────────────────────────────────────────────

  String _icsDate(DateTime dt, bool allDay) {
    if (allDay) {
      return '${dt.year}${_pad2(dt.month)}${_pad2(dt.day)}';
    }
    final utc = dt.toUtc();
    return '${utc.year}${_pad2(utc.month)}${_pad2(utc.day)}T'
        '${_pad2(utc.hour)}${_pad2(utc.minute)}${_pad2(utc.second)}Z';
  }

  String _pad2(int v) => v.toString().padLeft(2, '0');

  String _icsEscape(String s) =>
      s.replaceAll(r'\', r'\\').replaceAll(',', r'\,').replaceAll(';', r'\;');

  int? _reminderMinutesFor(ReminderPreset preset, int? customMinutes) {
    return switch (preset) {
      ReminderPreset.none => null,
      ReminderPreset.atTime => 0,
      ReminderPreset.min15 => 15,
      ReminderPreset.min30 => 30,
      ReminderPreset.hour1 => 60,
      ReminderPreset.hours2 => 120,
      ReminderPreset.day1 => 24 * 60,
      ReminderPreset.days2 => 2 * 24 * 60,
      ReminderPreset.custom => customMinutes,
    };
  }
}
