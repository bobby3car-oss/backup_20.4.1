import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../sync/user_scoped_storage.dart';
import '../domain/pain_entry.dart';
import 'pain_repository.dart';

class PainRepositoryLocal implements PainRepository {
  static final PainRepositoryLocal instance = PainRepositoryLocal._internal();

  factory PainRepositoryLocal() => instance;

  PainRepositoryLocal._internal({bool autoLoad = true}) {
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

  final List<PainEntry> _items = <PainEntry>[];
  final StreamController<List<PainEntry>> _controller =
      StreamController<List<PainEntry>>.broadcast();

  Timer? _saveDebounce;
  bool _disposed = false;
  bool _isLoadedOnce = false;

  @override
  Stream<List<PainEntry>> watchAll() async* {
    yield _sorted(_items);
    yield* _controller.stream.map(_sorted);
  }

  @override
  Future<void> upsert(PainEntry entry) async {
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
  Future<PainEntry?> getById(String id) async {
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
    try {
      final raw = await UserScopedStorage.instance.readSecure('pain_entries.json');
      if (raw == null) {
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

      final loaded = <PainEntry>[];
      for (final entry in decoded) {
        if (entry is! Map) continue;
        try {
          loaded.add(PainEntry.fromJson(Map<String, dynamic>.from(entry)));
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
        debugPrint('[PainRepositoryLocal] loadFromDisk failed: $error');
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
      await UserScopedStorage.instance.writeSecure('pain_entries.json', payload);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[PainRepositoryLocal] saveToDisk failed: $error');
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

  List<PainEntry> _sorted(List<PainEntry> source) {
    final copy = List<PainEntry>.from(source)
      ..removeWhere((e) => e.isDeleted);
    copy.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return copy;
  }

  Future<File> _storageFile() async {
    return UserScopedStorage.instance.file('pain_entries.json');
  }
}
