import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'care_plan_templates.dart';
import '../notifications/local_notifications.dart';
import 'timeline_engine.dart';

String phaseTitle(String phase) {
  switch (phase) {
    case 'preop':
      return 'Vorbereitung';
    case 'opday':
      return 'OP-Tag';
    case 'week1':
      return 'Woche 1 · Heilung & Kontrolle';
    case 'week2':
      return 'Woche 2 · Aktivierung';
    case 'followup':
      return 'Nachkontrolle';
    default:
      return 'Phase';
  }
}

int phaseOrder(String phase) {
  switch (phase) {
    case 'preop':
      return 0;
    case 'opday':
      return 1;
    case 'week1':
      return 2;
    case 'week2':
      return 3;
    case 'followup':
      return 4;
    default:
      return 999;
  }
}

class TaskOrchestrator {
  static const int _defaultPlanDays = 30;
  static const int _defaultDaysSinceOperation = 18;

  TaskOrchestrator() {
    _initialLoad = loadFromDisk();
  }

  final List<TimelineItem> _items = <TimelineItem>[];
  final StreamController<List<TimelineItem>> _controller =
      StreamController<List<TimelineItem>>.broadcast();
  late final Future<void> _initialLoad;
  Timer? _saveDebounce;
  bool _disposed = false;

  bool _seeded = false;
  DateTime? _operationDate;

  Stream<List<TimelineItem>> watch({
    required DateTime from,
    required DateTime to,
  }) async* {
    await _initialLoad;

    List<TimelineItem> project(List<TimelineItem> source) {
      final now = DateTime.now();
      final filtered = source
          .where((item) {
            final scheduled = item.scheduledAt;
            return !scheduled.isBefore(from) && !scheduled.isAfter(to);
          })
          .map((item) {
            final nextState = computeState(item, now);
            if (nextState == item.state) return item;
            return item.copyWith(state: nextState, updatedAt: now);
          })
          .toList();
      return sortItems(filtered);
    }

    yield project(_items);
    yield* _controller.stream.map(project);
  }

  Future<void> upsert(TimelineItem item) async {
    await _initialLoad;
    final now = DateTime.now();
    final index = _items.indexWhere((existing) => existing.id == item.id);
    final normalized = item.copyWith(updatedAt: now);

    if (index == -1) {
      _items.add(normalized);
    } else {
      _items[index] = normalized;
    }
    _emit();
    _scheduleSaveToDisk();
    final current = _items[index == -1 ? _items.length - 1 : index];
    final isFinalized =
        current.state == TaskState.done || current.state == TaskState.skipped;
    if (isFinalized) {
      await LocalNotifications.cancelForItem(current.id);
    } else {
      await LocalNotifications.scheduleForItem(current);
    }
  }

  Future<void> setState(String id, TaskState state) async {
    await _initialLoad;
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) return;

    final now = DateTime.now();
    final current = _items[index];

    DateTime? doneAt = current.doneAt;
    DateTime? skippedAt = current.skippedAt;
    bool clearDoneAt = false;
    bool clearSkippedAt = false;

    if (state == TaskState.done) {
      doneAt = now;
      clearSkippedAt = true;
    } else if (state == TaskState.skipped) {
      skippedAt = now;
      clearDoneAt = true;
    } else {
      clearDoneAt = true;
      clearSkippedAt = true;
    }

    _items[index] = current.copyWith(
      state: state,
      updatedAt: now,
      doneAt: doneAt,
      skippedAt: skippedAt,
      clearDoneAt: clearDoneAt,
      clearSkippedAt: clearSkippedAt,
    );
    _emit();
    _scheduleSaveToDisk();
    final updated = _items[index];
    final isFinalized =
        updated.state == TaskState.done || updated.state == TaskState.skipped;
    if (isFinalized) {
      await LocalNotifications.cancelForItem(updated.id);
    } else {
      await LocalNotifications.scheduleForItem(updated);
    }
  }

  Future<void> snoozeItem30Minutes(String id) async {
    await _initialLoad;
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) return;

    final now = DateTime.now();
    final snoozedUntil = now.add(const Duration(minutes: 30));
    final current = _items[index];
    final nextMetadata = Map<String, dynamic>.from(current.metadata)
      ..['snoozedUntil'] = snoozedUntil.toIso8601String();

    _items[index] = current.copyWith(
      dueAt: snoozedUntil,
      state: TaskState.planned,
      metadata: nextMetadata,
      updatedAt: now,
    );
    _emit();
    _scheduleSaveToDisk();
    await LocalNotifications.scheduleForItem(_items[index]);
  }

  Future<void> seedDemoDataIfEmpty() async {
    await _initialLoad;
    await _seedIfEmptyInternal(emit: true, scheduleSave: true);
    await _syncNotificationsForAll();
  }

  Future<void> generateForOperation({
    required DateTime operationDate,
    required int days,
  }) async {
    await _initialLoad;
    await _generateForOperationInternal(
      operationDate: operationDate,
      days: days,
      emit: true,
      scheduleSave: true,
    );
    await _syncNotificationsForAll();
  }

  Future<void> loadFromDisk() async {
    final file = await _storageFile();

    try {
      if (!await file.exists()) {
        _items.clear();
        _seeded = false;
        _operationDate = null;
        await _seedIfEmptyInternal(emit: false, scheduleSave: true);
        _emit();
        await _syncNotificationsForAll();
        return;
      }

      final raw = await file.readAsString();
      if (raw.trim().isEmpty) {
        _items.clear();
        _seeded = false;
        _operationDate = null;
        await _seedIfEmptyInternal(emit: false, scheduleSave: true);
        _emit();
        await _syncNotificationsForAll();
        return;
      }

      final decoded = jsonDecode(raw);
      Object? itemsPayload = decoded;
      if (decoded is Map<String, dynamic>) {
        itemsPayload = decoded['items'];
        _operationDate = _parseDateTime(decoded['operationDate']);
      } else {
        _operationDate = null;
      }

      if (itemsPayload is! List) {
        _items.clear();
        _seeded = false;
        await _seedIfEmptyInternal(emit: false, scheduleSave: true);
        _emit();
        await _syncNotificationsForAll();
        return;
      }

      final loaded = <TimelineItem>[];
      for (final entry in itemsPayload) {
        if (entry is Map) {
          loaded.add(TimelineItem.fromJson(Map<String, dynamic>.from(entry)));
        }
      }

      _items
        ..clear()
        ..addAll(sortItems(loaded));

      _seeded = _items.isNotEmpty;
      if (_items.isEmpty) {
        await _seedIfEmptyInternal(emit: false, scheduleSave: true);
      }
      _emit();
      await _syncNotificationsForAll();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[TaskOrchestrator] loadFromDisk failed: $error');
        debugPrint('$stackTrace');
      }
      _items.clear();
      _seeded = false;
      _operationDate = null;
      await _seedIfEmptyInternal(emit: false, scheduleSave: true);
      _emit();
      await _syncNotificationsForAll();
    }
  }

  Future<void> saveToDisk() async {
    final file = await _storageFile();

    try {
      final payload = jsonEncode(<String, dynamic>{
        'operationDate': _operationDate?.toIso8601String(),
        'items': _items.map((item) => item.toJson()).toList(growable: false),
      });
      await file.writeAsString(payload, flush: true);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[TaskOrchestrator] saveToDisk failed: $error');
        debugPrint('$stackTrace');
      }
    }
  }

  Future<void> resetDemoData() async {
    await _initialLoad;
    _saveDebounce?.cancel();
    _saveDebounce = null;

    final file = await _storageFile();
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[TaskOrchestrator] resetDemoData delete failed: $error');
        debugPrint('$stackTrace');
      }
    }

    _items.clear();
    _seeded = false;
    _operationDate = DateTime.now().subtract(
      const Duration(days: _defaultDaysSinceOperation),
    );
    await _seedIfEmptyInternal(emit: true, scheduleSave: true);
    await _syncNotificationsForAll();
  }

  Future<String> exportJson() async {
    await _initialLoad;
    final encoder = const JsonEncoder.withIndent('  ');
    return encoder.convert(
      _items.map((item) => item.toJson()).toList(growable: false),
    );
  }

  Future<void> _seedIfEmptyInternal({
    bool emit = true,
    bool scheduleSave = false,
  }) async {
    if (_seeded || _items.isNotEmpty) {
      _seeded = true;
      return;
    }

    final fallbackOperationDate =
        _operationDate ??
        DateTime.now().subtract(
          const Duration(days: _defaultDaysSinceOperation),
        );
    await _generateForOperationInternal(
      operationDate: fallbackOperationDate,
      days: _defaultPlanDays,
      emit: emit,
      scheduleSave: scheduleSave,
    );
  }

  Future<void> _generateForOperationInternal({
    required DateTime operationDate,
    required int days,
    bool emit = true,
    bool scheduleSave = false,
  }) async {
    final normalizedOperationDate = _dateOnly(operationDate.toLocal());
    _operationDate = normalizedOperationDate;

    _items.removeWhere(
      (item) => (item.metadata['templateId'] as String?) != null,
    );

    final now = DateTime.now();
    for (final template in carePlanTemplates) {
      final repeats = template.repeatCount ?? 1;
      final repeatEveryDays = template.repeatEveryDays ?? 0;

      for (var repeatIndex = 0; repeatIndex < repeats; repeatIndex++) {
        final dayOffset =
            template.relativeDay + (repeatEveryDays * repeatIndex);
        if (dayOffset < -14 || dayOffset > days) continue;

        final scheduledDay = normalizedOperationDate.add(
          Duration(days: dayOffset),
        );
        final scheduledAt = _dateTimeFromDayAndTime(
          day: scheduledDay,
          hhmm: template.timeOfDay,
        );
        final dueAt = template.dueHoursAfterScheduled == null
            ? null
            : scheduledAt.add(
                Duration(hours: template.dueHoursAfterScheduled!),
              );

        final metadata = <String, dynamic>{
          ...template.metadataDefaults,
          'source': 'care_plan',
          'phase': template.phase,
          'templateId': template.templateId,
        };
        if (repeats > 1) {
          metadata['repeatIndex'] = repeatIndex;
        }

        final id = _templateItemId(
          templateId: template.templateId,
          day: scheduledDay,
          hhmm: template.timeOfDay,
          repeatIndex: repeats > 1 ? repeatIndex : null,
        );

        _upsertInMemory(
          TimelineItem(
            id: id,
            type: template.type,
            title: template.title,
            subtitle: template.subtitle,
            scheduledAt: scheduledAt,
            dueAt: dueAt,
            priority: template.priority,
            state: computeState(
              TimelineItem(
                id: id,
                type: template.type,
                title: template.title,
                subtitle: template.subtitle,
                scheduledAt: scheduledAt,
                dueAt: dueAt,
                priority: template.priority,
                state: TaskState.planned,
                deeplinkRoute: template.deeplinkRoute,
                metadata: metadata,
                createdAt: now,
                updatedAt: now,
              ),
              now,
            ),
            deeplinkRoute: template.deeplinkRoute,
            metadata: metadata,
            createdAt: now,
            updatedAt: now,
          ),
        );
      }
    }

    _seeded = _items.isNotEmpty;
    if (emit) _emit();
    if (scheduleSave) _scheduleSaveToDisk();
  }

  void _upsertInMemory(TimelineItem item) {
    final index = _items.indexWhere((existing) => existing.id == item.id);
    if (index == -1) {
      _items.add(item);
    } else {
      _items[index] = item;
    }
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  DateTime _dateTimeFromDayAndTime({
    required DateTime day,
    required String hhmm,
  }) {
    final parts = hhmm.split(':');
    final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return DateTime(day.year, day.month, day.day, hour, minute);
  }

  String _templateItemId({
    required String templateId,
    required DateTime day,
    required String hhmm,
    int? repeatIndex,
  }) {
    final mm = day.month.toString().padLeft(2, '0');
    final dd = day.day.toString().padLeft(2, '0');
    final datePart = '${day.year}$mm$dd';
    final timePart = hhmm.replaceAll(':', '');
    if (repeatIndex == null) {
      return '${templateId}_${datePart}_$timePart';
    }
    return '${templateId}_${datePart}_${timePart}_$repeatIndex';
  }

  DateTime? _parseDateTime(Object? value) {
    if (value == null) return null;
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  void dispose() {
    _saveDebounce?.cancel();
    _saveDebounce = null;
    _disposed = true;
    _controller.close();
  }

  void _emit() {
    if (_disposed || _controller.isClosed) return;
    _controller.add(sortItems(_items));
  }

  Future<File> _storageFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/timeline_items.json');
  }

  void _scheduleSaveToDisk() {
    if (_disposed) return;
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 300), () {
      if (_disposed) return;
      unawaited(saveToDisk());
    });
  }

  Future<void> _syncNotificationsForAll() async {
    for (final item in _items) {
      final isFinalized =
          item.state == TaskState.done || item.state == TaskState.skipped;
      if (isFinalized || item.dueAt == null) {
        await LocalNotifications.cancelForItem(item.id);
      } else {
        await LocalNotifications.scheduleForItem(item);
      }
    }
  }
}
