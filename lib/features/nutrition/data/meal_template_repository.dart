import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../sync/user_scoped_storage.dart';
import '../domain/meal_template.dart';

/// Local-JSON-backed meal template repository.
class MealTemplateRepository {
  static final MealTemplateRepository instance =
      MealTemplateRepository._internal();

  factory MealTemplateRepository() => instance;

  MealTemplateRepository._internal() {
    UserScopedStorage.instance.addListener(_onUserChanged);
  }

  void _onUserChanged() {
    _loaded = false;
    _items.clear();
    _emit();
    unawaited(load());
  }

  final List<MealTemplate> _items = <MealTemplate>[];
  final StreamController<List<MealTemplate>> _controller =
      StreamController<List<MealTemplate>>.broadcast();

  Timer? _saveDebounce;
  bool _loaded = false;

  Stream<List<MealTemplate>> watchAll() async* {
    if (!_loaded) await load();
    yield List<MealTemplate>.unmodifiable(_items);
    yield* _controller.stream;
  }

  List<MealTemplate> get items => List<MealTemplate>.unmodifiable(_items);

  Future<void> add(MealTemplate template) async {
    _items.add(template);
    _emit();
    _scheduleSave();
  }

  Future<void> remove(String id) async {
    _items.removeWhere((t) => t.id == id);
    _emit();
    _scheduleSave();
  }

  Future<void> load() async {
    _loaded = true;
    if (kIsWeb) return;
    try {
      final raw = await UserScopedStorage.instance.readSecure('meal_templates.json');
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

      final loaded = <MealTemplate>[];
      for (final entry in decoded) {
        if (entry is! Map) continue;
        try {
          loaded.add(
            MealTemplate.fromJson(Map<String, dynamic>.from(entry)),
          );
        } catch (_) {}
      }

      _items
        ..clear()
        ..addAll(loaded);
      _emit();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[MealTemplateRepository] load failed: $error');
        debugPrint('$stackTrace');
      }
    }
  }

  Future<void> _save() async {
    if (kIsWeb) return;
    final file = await _storageFile();
    try {
      final payload = jsonEncode(
        _items.map((t) => t.toJson()).toList(growable: false),
      );
      await UserScopedStorage.instance.writeSecure('meal_templates.json', payload);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[MealTemplateRepository] save failed: $error');
        debugPrint('$stackTrace');
      }
    }
  }

  void _scheduleSave() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 300), () {
      unawaited(_save());
    });
  }

  void _emit() {
    if (!_controller.isClosed) {
      _controller.add(List<MealTemplate>.unmodifiable(_items));
    }
  }

  Future<File> _storageFile() async {
    return UserScopedStorage.instance.file('meal_templates.json');
  }

  void dispose() {
    _saveDebounce?.cancel();
    _controller.close();
  }
}
