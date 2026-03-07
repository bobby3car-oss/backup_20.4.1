import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../sync/user_scoped_storage.dart';
import '../domain/appointment.dart';
import 'appointments_repository.dart';

class AppointmentsRepositoryLocal implements AppointmentsRepository {
  static final AppointmentsRepositoryLocal instance =
      AppointmentsRepositoryLocal._internal();

  factory AppointmentsRepositoryLocal() => instance;

  AppointmentsRepositoryLocal._internal();

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

  @override
  Future<void> switchUser(String? userId) async {
    _items.clear();
    _isLoadedOnce = false;
    _emit();
    if (userId != null) {
      await loadFromDisk();
    }
  }

  Future<File> _storageFile() async {
    return UserScopedStorage.instance.file('appointments.json');
  }
}
