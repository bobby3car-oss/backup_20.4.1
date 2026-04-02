import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../sync/user_scoped_storage.dart';
import '../domain/supplement.dart';
import 'supplement_repository.dart';

class SupplementRepositoryLocal implements SupplementRepository {
  static final SupplementRepositoryLocal instance =
      SupplementRepositoryLocal._internal();

  factory SupplementRepositoryLocal() => instance;

  SupplementRepositoryLocal._internal({bool autoLoad = true}) {
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

  final List<Supplement> _items = <Supplement>[];
  final StreamController<List<Supplement>> _controller =
      StreamController<List<Supplement>>.broadcast();

  Timer? _saveDebounce;
  bool _disposed = false;
  bool _isLoadedOnce = false;

  @override
  Stream<List<Supplement>> watchAll() async* {
    yield _sorted(_items);
    yield* _controller.stream.map(_sorted);
  }

  @override
  Future<void> upsert(Supplement supplement) async {
    final index = _items.indexWhere((item) => item.id == supplement.id);
    if (index == -1) {
      _items.add(supplement);
    } else {
      _items[index] = supplement;
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
  Future<Supplement?> getById(String id) async {
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
      final loaded = <Supplement>[];
      for (final entry in decoded) {
        if (entry is! Map) continue;
        try {
          loaded.add(
            Supplement.fromJson(Map<String, dynamic>.from(entry)),
          );
        } catch (error) {
          if (kDebugMode) {
            debugPrint('[SupplementRepoLocal] Skipped entry: $error');
          }
        }
      }
      _items
        ..clear()
        ..addAll(loaded);
      _emit();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[SupplementRepoLocal] loadFromDisk failed: $error');
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
        debugPrint('[SupplementRepoLocal] saveToDisk failed: $error');
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

  List<Supplement> _sorted(List<Supplement> source) {
    final copy = List<Supplement>.from(source);
    copy.sort((a, b) {
      final aSlot = a.enabledSlots.firstOrNull;
      final bSlot = b.enabledSlots.firstOrNull;
      final aMin =
          aSlot != null ? a.slots[aSlot]!.hour * 60 + a.slots[aSlot]!.minute : 0;
      final bMin =
          bSlot != null ? b.slots[bSlot]!.hour * 60 + b.slots[bSlot]!.minute : 0;
      return aMin.compareTo(bMin);
    });
    return copy;
  }

  Future<File> _storageFile() async {
    return UserScopedStorage.instance.file('supplement_reminders.json');
  }
}


