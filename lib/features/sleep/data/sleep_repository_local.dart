import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../sync/user_scoped_storage.dart';
import '../domain/sleep_entry.dart';
import 'sleep_repository.dart';

class SleepRepositoryLocal implements SleepRepository {
  static final SleepRepositoryLocal instance = SleepRepositoryLocal._internal();

  factory SleepRepositoryLocal() => instance;

  SleepRepositoryLocal._internal({bool autoLoad = true}) {
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

  final List<SleepEntry> _items = <SleepEntry>[];
  final StreamController<List<SleepEntry>> _controller =
      StreamController<List<SleepEntry>>.broadcast();

  Timer? _saveDebounce;
  bool _disposed = false;
  bool _isLoadedOnce = false;

  @override
  Stream<List<SleepEntry>> watchAll() async* {
    yield _sorted(_items);
    yield* _controller.stream.map(_sorted);
  }

  @override
  Future<void> upsert(SleepEntry entry) async {
    final index = _items.indexWhere((existing) => existing.id == entry.id);
    if (index == -1) {
      _items.add(entry);
    } else {
      _items[index] = entry;
    }
    _emit();
    _scheduleSave();
  }

  @override
  Future<void> delete(String id) async {
    _items.removeWhere((entry) => entry.id == id);
    _emit();
    _scheduleSave();
  }

  Future<void> deleteAll() async {
    _items.clear();
    _emit();
    await saveToDisk();
  }

  @override
  Future<SleepEntry?> getById(String id) async {
    if (!_isLoadedOnce) {
      await loadFromDisk();
    }
    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }

  @override
  Future<void> loadFromDisk() async {
    _isLoadedOnce = true;
    if (kIsWeb) return;
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

      final loaded = <SleepEntry>[];
      for (final entry in decoded) {
        if (entry is! Map) continue;
        try {
          loaded.add(SleepEntry.fromJson(Map<String, dynamic>.from(entry)));
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
        debugPrint('[SleepRepositoryLocal] loadFromDisk failed: $error');
        debugPrint('$stackTrace');
      }
      _items.clear();
      _emit();
    }
  }

  @override
  Future<void> saveToDisk() async {
    if (kIsWeb) return;
    final file = await _storageFile();
    try {
      final payload = jsonEncode(
        _items.map((item) => item.toJson()).toList(growable: false),
      );
      await file.writeAsString(payload, flush: true);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[SleepRepositoryLocal] saveToDisk failed: $error');
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

  List<SleepEntry> _sorted(List<SleepEntry> source) {
    final copy = List<SleepEntry>.from(source);
    copy.sort((a, b) => b.bedTime.compareTo(a.bedTime));
    return copy;
  }

  Future<File> _storageFile() async {
    return UserScopedStorage.instance.file('sleep_entries.json');
  }
}
