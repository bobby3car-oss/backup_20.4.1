import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../sync/user_scoped_storage.dart';
import '../domain/red_flag.dart';

class RedFlagRepositoryLocal {
  static final RedFlagRepositoryLocal instance =
      RedFlagRepositoryLocal._internal();

  factory RedFlagRepositoryLocal() => instance;

  RedFlagRepositoryLocal._internal() {
    UserScopedStorage.instance.addListener(_onUserChanged);
  }

  void _onUserChanged() {
    _loaded = false;
    _items.clear();
    _emit();
  }

  final List<RedFlag> _items = <RedFlag>[];
  final StreamController<List<RedFlag>> _controller =
      StreamController<List<RedFlag>>.broadcast();
  bool _loaded = false;

  Stream<List<RedFlag>> watchAll() async* {
    if (!_loaded) await loadFromDisk();
    yield _sorted(List<RedFlag>.from(_items));
    yield* _controller.stream;
  }

  Future<void> upsert(RedFlag flag) async {
    final idx = _items.indexWhere((f) => f.id == flag.id);
    if (idx >= 0) {
      _items[idx] = flag;
    } else {
      _items.add(flag);
    }
    _emit();
    await saveToDisk();
  }

  Future<void> upsertAll(List<RedFlag> flags) async {
    for (final flag in flags) {
      final idx = _items.indexWhere((f) => f.id == flag.id);
      if (idx >= 0) {
        _items[idx] = flag;
      } else {
        _items.add(flag);
      }
    }
    _emit();
    await saveToDisk();
  }

  Future<void> delete(String id) async {
    _items.removeWhere((f) => f.id == id);
    _emit();
    await saveToDisk();
  }

  RedFlag? getByIdSync(String id) {
    for (final f in _items) {
      if (f.id == id) return f;
    }
    return null;
  }

  List<RedFlag> get activeFlags =>
      _items.where((f) => f.status.isActive).toList()
        ..sort((a, b) => b.severity.index.compareTo(a.severity.index));

  Future<void> loadFromDisk() async {
    if (_loaded) return;
    _loaded = true;
    if (kIsWeb) return;
    final file = await _storageFile();
    try {
      if (!await file.exists()) return;
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) return;
      final decoded = jsonDecode(raw);
      if (decoded is! List) return;
      _items.clear();
      for (final entry in decoded) {
        if (entry is Map) {
          _items.add(RedFlag.fromJson(Map<String, dynamic>.from(entry)));
        }
      }
      _emit();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[RedFlagRepositoryLocal] loadFromDisk failed: $error');
        debugPrint('$stackTrace');
      }
    }
  }

  Future<void> saveToDisk() async {
    if (kIsWeb) return;
    final file = await _storageFile();
    try {
      final json = _items.map((f) => f.toJson()).toList();
      await UserScopedStorage.instance.writeSecure('red_flags.json', jsonEncode(json));
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[RedFlagRepositoryLocal] saveToDisk failed: $error');
        debugPrint('$stackTrace');
      }
    }
  }

  void _emit() {
    _controller.add(_sorted(List<RedFlag>.from(_items)));
  }

  List<RedFlag> _sorted(List<RedFlag> source) {
    source.sort((a, b) {
      // Active before resolved
      final aActive = a.status.isActive ? 0 : 1;
      final bActive = b.status.isActive ? 0 : 1;
      if (aActive != bActive) return aActive.compareTo(bActive);
      // Higher severity first
      if (a.severity != b.severity) {
        return b.severity.index.compareTo(a.severity.index);
      }
      // Newest first
      return b.createdAt.compareTo(a.createdAt);
    });
    return source;
  }

  Future<File> _storageFile() async {
    return UserScopedStorage.instance.file('red_flags.json');
  }

  void dispose() {
    _controller.close();
  }
}
