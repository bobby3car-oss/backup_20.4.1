import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../sync/user_scoped_storage.dart';
import '../domain/wound_entry.dart';
import 'wound_repository.dart';

class WoundRepositoryLocal implements WoundRepository {
  static final WoundRepositoryLocal instance = WoundRepositoryLocal._internal();

  factory WoundRepositoryLocal() => instance;

  WoundRepositoryLocal._internal({bool autoLoad = true}) {
    if (autoLoad) {
      unawaited(loadFromDisk());
    }
    UserScopedStorage.instance.addListener(_onUserChanged);
  }

  void _onUserChanged() {
    _entries.clear();
    _emit();
    unawaited(loadFromDisk());
  }

  final List<WoundEntry> _entries = <WoundEntry>[];
  final StreamController<List<WoundEntry>> _controller =
      StreamController<List<WoundEntry>>.broadcast();
  Timer? _saveDebounce;
  bool _disposed = false;

  @override
  Stream<List<WoundEntry>> watchAll() async* {
    yield _sorted(_entries);
    yield* _controller.stream.map(_sorted);
  }

  @override
  Future<void> upsert(WoundEntry entry) async {
    final index = _entries.indexWhere((e) => e.id == entry.id);
    if (index == -1) {
      _entries.add(entry);
    } else {
      _entries[index] = entry;
    }
    _emit();
    _scheduleSave();
  }

  @override
  Future<void> delete(String id) async {
    _entries.removeWhere((e) => e.id == id);
    _emit();
    _scheduleSave();
  }

  Future<void> deleteAll() async {
    _entries.clear();
    _emit();
    await saveToDisk();
  }

  @override
  Future<void> loadFromDisk() async {
    try {
      final raw = await UserScopedStorage.instance.readSecure('wound_entries.json');
      if (raw == null) {
        _entries.clear();
        _emit();
        return;
      }

      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        _entries.clear();
        _emit();
        return;
      }

      final loaded = <WoundEntry>[];
      for (final item in decoded) {
        if (item is Map) {
          loaded.add(WoundEntry.fromJson(Map<String, dynamic>.from(item)));
        }
      }

      _entries
        ..clear()
        ..addAll(loaded);
      _emit();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[WoundRepositoryLocal] loadFromDisk failed: $error');
        debugPrint('$stackTrace');
      }
      _entries.clear();
      _emit();
    }
  }

  @override
  Future<void> saveToDisk() async {
    if (kIsWeb) return;
    final file = await _storageFile();
    try {
      final payload = jsonEncode(
        _entries.map((entry) => entry.toJson()).toList(growable: false),
      );
      await UserScopedStorage.instance.writeSecure('wound_entries.json', payload);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[WoundRepositoryLocal] saveToDisk failed: $error');
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
    _controller.add(_sorted(_entries));
  }

  List<WoundEntry> _sorted(List<WoundEntry> source) {
    final copy = source.where((e) => !e.isDeleted).toList();
    copy.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return copy;
  }

  Future<File> _storageFile() async {
    return UserScopedStorage.instance.file('wound_entries.json');
  }
}
