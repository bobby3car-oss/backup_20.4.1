import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../sync/user_scoped_storage.dart';
import '../domain/symptom_check_result.dart';

/// Local persistence for symptom check results.
///
/// Stores all results in `symptom_checks.json` inside the user-scoped directory.
class SymptomCheckRepositoryLocal {
  static final SymptomCheckRepositoryLocal instance =
      SymptomCheckRepositoryLocal._internal();

  factory SymptomCheckRepositoryLocal() => instance;

  SymptomCheckRepositoryLocal._internal() {
    UserScopedStorage.instance.addListener(_onUserChanged);
  }

  void _onUserChanged() {
    _loaded = false;
    _items.clear();
    _emit();
  }

  final List<SymptomCheckResult> _items = <SymptomCheckResult>[];
  final StreamController<List<SymptomCheckResult>> _controller =
      StreamController<List<SymptomCheckResult>>.broadcast();
  bool _loaded = false;

  Stream<List<SymptomCheckResult>> watchAll() async* {
    if (!_loaded) await loadFromDisk();
    yield _sorted(List<SymptomCheckResult>.from(_items));
    yield* _controller.stream;
  }

  List<SymptomCheckResult> get cached => _sorted(List.from(_items));

  SymptomCheckResult? get latest =>
      _items.isEmpty ? null : _sorted(_items).first;

  Future<void> add(SymptomCheckResult result) async {
    _items.add(result);
    _emit();
    await _saveToDisk();
  }

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
          _items.add(
            SymptomCheckResult.fromJson(Map<String, dynamic>.from(entry)),
          );
        }
      }
      _emit();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '[SymptomCheckRepositoryLocal] loadFromDisk failed: $error',
        );
        debugPrint('$stackTrace');
      }
    }
  }

  Future<void> _saveToDisk() async {
    if (kIsWeb) return;
    final file = await _storageFile();
    try {
      final json = _items.map((r) => r.toJson()).toList();
      await UserScopedStorage.instance.writeSecure('symptom_checks.json', jsonEncode(json));
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '[SymptomCheckRepositoryLocal] saveToDisk failed: $error',
        );
        debugPrint('$stackTrace');
      }
    }
  }

  void _emit() {
    _controller.add(_sorted(List<SymptomCheckResult>.from(_items)));
  }

  static List<SymptomCheckResult> _sorted(List<SymptomCheckResult> list) {
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<File> _storageFile() async {
    return UserScopedStorage.instance.file('symptom_checks.json');
  }
}
