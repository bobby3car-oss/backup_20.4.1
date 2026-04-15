import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../sync/user_scoped_storage.dart';
import '../domain/supplement_intake.dart';
import 'supplement_intake_repository.dart';

class SupplementIntakeRepositoryLocal implements SupplementIntakeRepository {
  static final SupplementIntakeRepositoryLocal instance =
      SupplementIntakeRepositoryLocal._internal();

  factory SupplementIntakeRepositoryLocal() => instance;

  SupplementIntakeRepositoryLocal._internal({bool autoLoad = true}) {
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

  final List<SupplementIntake> _items = <SupplementIntake>[];
  final StreamController<List<SupplementIntake>> _controller =
      StreamController<List<SupplementIntake>>.broadcast();

  Timer? _saveDebounce;
  bool _disposed = false;
  bool _isLoadedOnce = false;

  @override
  Stream<List<SupplementIntake>> watchAll() async* {
    yield _sorted(_items);
    yield* _controller.stream.map(_sorted);
  }

  @override
  Future<void> upsert(SupplementIntake entry) async {
    final index = _items.indexWhere((e) => e.id == entry.id);
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
    _items.removeWhere((e) => e.id == id);
    _emit();
    _scheduleSave();
  }

  Future<void> deleteAll() async {
    _items.clear();
    _emit();
    await saveToDisk();
  }

  @override
  Future<SupplementIntake?> getById(String id) async {
    if (!_isLoadedOnce) await loadFromDisk();
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
      final raw = await UserScopedStorage.instance.readSecure('supplement_intakes.json');
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
      final loaded = <SupplementIntake>[];
      for (final entry in decoded) {
        if (entry is! Map) continue;
        try {
          loaded.add(
            SupplementIntake.fromJson(Map<String, dynamic>.from(entry)),
          );
        } catch (e) {
          if (kDebugMode) {
            debugPrint('[SupplementIntakeRepoLocal] Skipped entry: $e');
          }
        }
      }
      _items
        ..clear()
        ..addAll(loaded);
      _emit();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint(
            '[SupplementIntakeRepoLocal] loadFromDisk failed: $error');
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
        _items.map((e) => e.toJson()).toList(growable: false),
      );
      await UserScopedStorage.instance.writeSecure('supplement_intakes.json', payload);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint(
            '[SupplementIntakeRepoLocal] saveToDisk failed: $error');
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

  List<SupplementIntake> _sorted(List<SupplementIntake> source) {
    final copy = List<SupplementIntake>.from(source);
    copy.sort((a, b) => b.takenAt.compareTo(a.takenAt));
    return copy;
  }

  Future<File> _storageFile() async {
    return UserScopedStorage.instance.file('supplement_intakes.json');
  }
}

