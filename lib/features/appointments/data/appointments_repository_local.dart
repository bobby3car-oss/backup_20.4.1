import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/appointment.dart';
import '../domain/appointment_enums.dart';
import 'appointments_repository.dart';

class AppointmentsRepositoryLocal implements AppointmentsRepository {
  static final AppointmentsRepositoryLocal instance =
      AppointmentsRepositoryLocal._internal();

  factory AppointmentsRepositoryLocal() => instance;

  AppointmentsRepositoryLocal._internal({bool autoLoad = true}) {
    if (autoLoad) {
      unawaited(loadFromDisk());
    }
  }

  final List<Appointment> _items = <Appointment>[];
  final StreamController<List<Appointment>> _controller =
      StreamController<List<Appointment>>.broadcast();

  Timer? _saveDebounce;
  bool _disposed = false;

  @override
  Stream<List<Appointment>> watchAll() async* {
    yield _sorted(_items);
    yield* _controller.stream.map(_sorted);
  }

  @override
  Stream<List<Appointment>> watchRange(DateTime from, DateTime to) {
    final fromUtc = from.toUtc();
    final toUtc = to.toUtc();

    return watchAll().map((items) {
      return items
          .where((item) {
            final startUtc = item.startAt.toUtc();
            final endUtc = (item.endAt ?? item.startAt).toUtc();
            final overlaps =
                !endUtc.isBefore(fromUtc) && !startUtc.isAfter(toUtc);
            return overlaps;
          })
          .toList(growable: false);
    });
  }

  @override
  Future<void> upsert(Appointment appointment) async {
    final index = _items.indexWhere(
      (existing) => existing.id == appointment.id,
    );
    if (index == -1) {
      _items.add(appointment);
    } else {
      _items[index] = appointment;
    }
    _emit();
    _scheduleSave();
  }

  @override
  Future<void> delete(String id) async {
    _items.removeWhere((item) => item.id == id);
    _emit();
    _scheduleSave();
  }

  Future<void> deleteAll() async {
    _items.clear();
    _emit();
    await saveToDisk();
  }

  @override
  Future<Appointment?> getById(String id) async {
    if (!_isLoadedOnce) {
      await loadFromDisk();
    }
    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }

  bool _isLoadedOnce = false;

  @override
  Future<void> loadFromDisk() async {
    _isLoadedOnce = true;
    final file = await _storageFile();
    try {
      if (!await file.exists()) {
        _items.clear();
        _emit();
        return;
      }

      final raw = await file.readAsString();
      if (raw.trim().isEmpty) {
        _items.clear();
        _emit();
        return;
      }

      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        _items.clear();
        _emit();
        return;
      }

      final loaded = <Appointment>[];
      for (final entry in decoded) {
        if (entry is! Map) continue;
        try {
          loaded.add(Appointment.fromJson(Map<String, dynamic>.from(entry)));
        } catch (_) {
          // Skip malformed entries and keep repository usable.
        }
      }

      _items
        ..clear()
        ..addAll(loaded);
      _emit();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[AppointmentsRepositoryLocal] loadFromDisk failed: $error');
        debugPrint('$stackTrace');
      }
      _items.clear();
      _emit();
    }
  }

  @override
  Future<void> saveToDisk() async {
    final file = await _storageFile();
    try {
      final payload = jsonEncode(
        _items.map((item) => item.toJson()).toList(growable: false),
      );
      await file.writeAsString(payload, flush: true);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[AppointmentsRepositoryLocal] saveToDisk failed: $error');
        debugPrint('$stackTrace');
      }
    }
  }

  @override
  Future<void> seedDemoIfEmpty() async {
    if (!_isLoadedOnce) {
      await loadFromDisk();
    }
    if (_items.isNotEmpty) return;

    final now = DateTime.now();
    final ownerId = 'demo_patient';
    final baseCreatedAt = now.subtract(const Duration(days: 1));
    final demo = <Appointment>[
      _demoAppointment(
        id: 'demo_today_followup',
        ownerId: ownerId,
        title: 'Nachkontrolle Chirurgie',
        notes: 'Bringe Befunde und Medikamentenplan mit.',
        type: AppointmentType.followUp,
        startAt: DateTime(now.year, now.month, now.day, 10, 30),
        endAt: DateTime(now.year, now.month, now.day, 11, 0),
        reminderPreset: ReminderPreset.hour1,
        createdAt: baseCreatedAt,
      ),
      _demoAppointment(
        id: 'demo_today_physio',
        ownerId: ownerId,
        title: 'Physiotherapie',
        notes: 'Termin in Praxis am Park.',
        type: AppointmentType.physio,
        startAt: DateTime(now.year, now.month, now.day, 15, 0),
        endAt: DateTime(now.year, now.month, now.day, 15, 45),
        reminderPreset: ReminderPreset.min30,
        createdAt: baseCreatedAt,
      ),
      _demoAppointment(
        id: 'demo_tomorrow_imaging',
        ownerId: ownerId,
        title: 'MRT Knie',
        notes: '20 Minuten vorher da sein.',
        type: AppointmentType.imaging,
        startAt: DateTime(now.year, now.month, now.day + 1, 9, 0),
        endAt: DateTime(now.year, now.month, now.day + 1, 9, 45),
        reminderPreset: ReminderPreset.day1,
        createdAt: baseCreatedAt,
      ),
      _demoAppointment(
        id: 'demo_tomorrow_call',
        ownerId: ownerId,
        title: 'Telefonat mit Hausarzt',
        notes: 'Besprechung Laborwerte.',
        type: AppointmentType.call,
        startAt: DateTime(now.year, now.month, now.day + 1, 17, 30),
        endAt: DateTime(now.year, now.month, now.day + 1, 17, 50),
        reminderPreset: ReminderPreset.min15,
        createdAt: baseCreatedAt,
      ),
      _demoAppointment(
        id: 'demo_week_surgery_prep',
        ownerId: ownerId,
        title: 'OP-Aufklaerung',
        notes: 'Unterschrift Einverstaendnis.',
        type: AppointmentType.surgery,
        startAt: DateTime(now.year, now.month, now.day + 3, 13, 0),
        endAt: DateTime(now.year, now.month, now.day + 3, 14, 0),
        reminderPreset: ReminderPreset.hours2,
        createdAt: baseCreatedAt,
      ),
      _demoAppointment(
        id: 'demo_week_followup2',
        ownerId: ownerId,
        title: 'Wundkontrolle',
        notes: 'Foto-Doku einplanen.',
        type: AppointmentType.followUp,
        startAt: DateTime(now.year, now.month, now.day + 5, 10, 0),
        endAt: DateTime(now.year, now.month, now.day + 5, 10, 30),
        reminderPreset: ReminderPreset.hour1,
        createdAt: baseCreatedAt,
      ),
      _demoAppointment(
        id: 'demo_week_physio2',
        ownerId: ownerId,
        title: 'Physio Mobilisation',
        notes: 'Leichte Uebungen vorher.',
        type: AppointmentType.physio,
        startAt: DateTime(now.year, now.month, now.day + 6, 16, 0),
        endAt: DateTime(now.year, now.month, now.day + 6, 16, 45),
        reminderPreset: ReminderPreset.min30,
        createdAt: baseCreatedAt,
      ),
      _demoAppointment(
        id: 'demo_next_week_other',
        ownerId: ownerId,
        title: 'Sonstiger Termin',
        notes: 'Unterlagen fuers Versicherungsbuero.',
        type: AppointmentType.other,
        startAt: DateTime(now.year, now.month, now.day + 7, 11, 30),
        endAt: DateTime(now.year, now.month, now.day + 7, 12, 0),
        reminderPreset: ReminderPreset.day1,
        createdAt: baseCreatedAt,
      ),
    ];

    _items
      ..clear()
      ..addAll(demo);
    _emit();
    await saveToDisk();
  }

  Appointment _demoAppointment({
    required String id,
    required String ownerId,
    required String title,
    required String notes,
    required AppointmentType type,
    required DateTime startAt,
    required DateTime endAt,
    required ReminderPreset reminderPreset,
    required DateTime createdAt,
  }) {
    return Appointment(
      id: id,
      ownerId: ownerId,
      title: title,
      notes: notes,
      type: type,
      status: AppointmentStatus.planned,
      startAt: startAt,
      endAt: endAt,
      allDay: false,
      locationName: 'Klinikum Mitte',
      locationDetails: null,
      reminderPreset: reminderPreset,
      reminderMinutes: reminderPreset == ReminderPreset.custom ? 45 : null,
      repeatRule: RepeatRule.none,
      repeatUntil: null,
      createdAt: createdAt,
      updatedAt: createdAt,
      metadata: const <String, dynamic>{'seed': true},
    );
  }

  void dispose() {
    _saveDebounce?.cancel();
    _saveDebounce = null;
    _disposed = true;
    _controller.close();
  }

  void _scheduleSave() {
    if (_disposed) return;
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 300), () {
      if (_disposed) return;
      unawaited(saveToDisk());
    });
  }

  void _emit() {
    if (_disposed || _controller.isClosed) return;
    _controller.add(_sorted(_items));
  }

  List<Appointment> _sorted(List<Appointment> source) {
    final copy = List<Appointment>.from(source);
    copy.sort((a, b) => a.startAt.compareTo(b.startAt));
    return copy;
  }

  Future<File> _storageFile() async {
    final docs = await getApplicationDocumentsDirectory();
    return File('${docs.path}/appointments.json');
  }
}
