import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../sync/user_scoped_storage.dart';
import '../domain/rehab_session.dart';
import 'rehab_session_repository.dart';

class RehabSessionRepositoryLocal implements RehabSessionRepository {
  static final RehabSessionRepositoryLocal instance =
      RehabSessionRepositoryLocal._internal();

  factory RehabSessionRepositoryLocal() => instance;

  RehabSessionRepositoryLocal._internal({bool autoLoad = true}) {
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

  final List<RehabSession> _items = <RehabSession>[];
  final StreamController<List<RehabSession>> _controller =
      StreamController<List<RehabSession>>.broadcast();

  Timer? _saveDebounce;
  bool _disposed = false;
  bool _isLoadedOnce = false;

  @override
  Stream<List<RehabSession>> watchAll() async* {
    yield _sorted(_items);
    yield* _controller.stream.map(_sorted);
  }

  @override
  Future<void> upsert(RehabSession session) async {
    final index = _items.indexWhere((existing) => existing.id == session.id);
    if (index == -1) {
      _items.add(session);
    } else {
      _items[index] = session;
    }
    _emit();
    _scheduleSave();
  }

  @override
  Future<void> delete(String id) async {
    _items.removeWhere((session) => session.id == id);
    _emit();
    _scheduleSave();
  }

  Future<void> deleteAll() async {
    _items.clear();
    _emit();
    await saveToDisk();
  }

  @override
  Future<RehabSession?> getById(String id) async {
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
      final raw = await UserScopedStorage.instance.readSecure('rehab_sessions.json');
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

      final loaded = <RehabSession>[];
      for (final entry in decoded) {
        if (entry is! Map) continue;
        try {
          loaded.add(
            RehabSession.fromJson(Map<String, dynamic>.from(entry)),
          );
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
        debugPrint('[RehabSessionRepositoryLocal] loadFromDisk failed: $error');
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
      await UserScopedStorage.instance.writeSecure('rehab_sessions.json', payload);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[RehabSessionRepositoryLocal] saveToDisk failed: $error');
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

  List<RehabSession> _sorted(List<RehabSession> source) {
    final copy = source.where((e) => !e.isDeleted).toList();
    copy.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return copy;
  }

  Future<File> _storageFile() async {
    return UserScopedStorage.instance.file('rehab_sessions.json');
  }
}
