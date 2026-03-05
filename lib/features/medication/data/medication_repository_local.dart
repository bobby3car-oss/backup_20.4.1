import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/medication_intake.dart';
import 'medication_repository.dart';

class MedicationRepositoryLocal implements MedicationRepository {
  static final MedicationRepositoryLocal instance =
      MedicationRepositoryLocal._internal();

  factory MedicationRepositoryLocal() => instance;

  MedicationRepositoryLocal._internal({bool autoLoad = true}) {
    if (autoLoad) {
      unawaited(loadFromDisk());
    }
  }

  final List<MedicationIntake> _items = <MedicationIntake>[];
  final StreamController<List<MedicationIntake>> _controller =
      StreamController<List<MedicationIntake>>.broadcast();

  Timer? _saveDebounce;
  bool _disposed = false;
  bool _isLoadedOnce = false;

  @override
  Stream<List<MedicationIntake>> watchAll() async* {
    yield _sorted(_items);
    yield* _controller.stream.map(_sorted);
  }

  @override
  Future<void> upsert(MedicationIntake entry) async {
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
  Future<MedicationIntake?> getById(String id) async {
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
      final loaded = <MedicationIntake>[];
      for (final entry in decoded) {
        if (entry is! Map) continue;
        try {
          loaded.add(
            MedicationIntake.fromJson(Map<String, dynamic>.from(entry)),
          );
        } catch (e) {
          if (kDebugMode) debugPrint('[MedicationRepoLocal] Skipped entry: $e');
        }
      }
      _items
        ..clear()
        ..addAll(loaded);
      _emit();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[MedicationRepoLocal] loadFromDisk failed: $error');
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
        _items.map((e) => e.toJson()).toList(growable: false),
      );
      await file.writeAsString(payload, flush: true);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[MedicationRepoLocal] saveToDisk failed: $error');
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

  List<MedicationIntake> _sorted(List<MedicationIntake> source) {
    final copy = List<MedicationIntake>.from(source);
    copy.sort((a, b) => b.takenAt.compareTo(a.takenAt));
    return copy;
  }

  Future<File> _storageFile() async {
    final docs = await getApplicationDocumentsDirectory();
    return File('${docs.path}/medication_intakes.json');
  }
}
