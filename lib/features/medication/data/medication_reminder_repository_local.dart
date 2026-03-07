import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../sync/user_scoped_storage.dart';
import '../domain/medication_reminder.dart';
import 'medication_reminder_repository.dart';

class MedicationReminderRepositoryLocal
    implements MedicationReminderRepository {
  static final MedicationReminderRepositoryLocal instance =
      MedicationReminderRepositoryLocal._internal();

  factory MedicationReminderRepositoryLocal() => instance;

  MedicationReminderRepositoryLocal._internal({bool autoLoad = true}) {
    if (autoLoad) {
      unawaited(loadFromDisk());
    }
    UserScopedStorage.instance.addListener(_onUserChanged);
  }

  void _onUserChanged() {
    _isLoadedOnce = false;
    _items.clear();
    _emit();
    unawaited(loadFromDisk());
  }

  final List<MedicationReminder> _items = <MedicationReminder>[];
  final StreamController<List<MedicationReminder>> _controller =
      StreamController<List<MedicationReminder>>.broadcast();

  Timer? _saveDebounce;
  bool _disposed = false;
  bool _isLoadedOnce = false;

  @override
  Stream<List<MedicationReminder>> watchAll() async* {
    yield _sorted(_items);
    yield* _controller.stream.map(_sorted);
  }

  @override
  Future<void> upsert(MedicationReminder reminder) async {
    final index = _items.indexWhere((item) => item.id == reminder.id);
    if (index == -1) {
      _items.add(reminder);
    } else {
      _items[index] = reminder;
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

  @override
  Future<MedicationReminder?> getById(String id) async {
    if (!_isLoadedOnce) await loadFromDisk();
    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }

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
      final loaded = <MedicationReminder>[];
      for (final entry in decoded) {
        if (entry is! Map) continue;
        try {
          loaded.add(
            MedicationReminder.fromJson(Map<String, dynamic>.from(entry)),
          );
        } catch (error) {
          if (kDebugMode) {
            debugPrint('[MedicationReminderRepoLocal] Skipped entry: $error');
          }
        }
      }
      _items
        ..clear()
        ..addAll(loaded);
      _emit();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[MedicationReminderRepoLocal] loadFromDisk failed: $error');
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
        debugPrint('[MedicationReminderRepoLocal] saveToDisk failed: $error');
        debugPrint('$stackTrace');
      }
    }
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

  List<MedicationReminder> _sorted(List<MedicationReminder> source) {
    final copy = List<MedicationReminder>.from(source);
    copy.sort((a, b) {
      final aMinutes = a.hour * 60 + a.minute;
      final bMinutes = b.hour * 60 + b.minute;
      return aMinutes.compareTo(bMinutes);
    });
    return copy;
  }

  Future<File> _storageFile() async {
    return UserScopedStorage.instance.file('medication_reminders.json');
  }
}
