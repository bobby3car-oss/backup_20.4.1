import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../sync/user_scoped_storage.dart';
import '../domain/doctor_question.dart';

class QuestionsRepositoryLocal {
  static final QuestionsRepositoryLocal instance =
      QuestionsRepositoryLocal._internal();

  factory QuestionsRepositoryLocal() => instance;

  QuestionsRepositoryLocal._internal({bool autoLoad = true}) {
    if (autoLoad) {
      unawaited(loadFromDisk());
    }
    UserScopedStorage.instance.addListener(_onUserChanged);
  }

  void _onUserChanged() {
    _loadedOnce = false;
    _items.clear();
    _emit();
    unawaited(loadFromDisk());
  }

  final List<DoctorQuestion> _items = <DoctorQuestion>[];
  final StreamController<List<DoctorQuestion>> _controller =
      StreamController<List<DoctorQuestion>>.broadcast();

  Timer? _saveDebounce;
  bool _loadedOnce = false;

  Stream<List<DoctorQuestion>> watchAll() async* {
    yield _sorted(_items);
    yield* _controller.stream.map(_sorted);
  }

  Future<void> upsert(DoctorQuestion item) async {
    final idx = _items.indexWhere((e) => e.id == item.id);
    if (idx == -1) {
      _items.add(item);
    } else {
      _items[idx] = item;
    }
    _emit();
    _scheduleSave();
  }

  Future<void> delete(String id) async {
    _items.removeWhere((item) => item.id == id);
    _emit();
    _scheduleSave();
  }

  Future<void> deleteAll() async {
    _items.clear();
    _emit();
    await saveToDisk();
  }

  Future<void> loadFromDisk() async {
    _loadedOnce = true;
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
      final loaded = <DoctorQuestion>[];
      for (final row in decoded) {
        if (row is! Map) continue;
        try {
          loaded.add(DoctorQuestion.fromJson(Map<String, dynamic>.from(row)));
        } catch (_) {
          // Skip invalid entry.
        }
      }
      _items
        ..clear()
        ..addAll(loaded);
      _emit();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[QuestionsRepositoryLocal] loadFromDisk failed: $error');
        debugPrint('$stackTrace');
      }
      _items.clear();
      _emit();
    }
  }

  Future<void> saveToDisk() async {
    final file = await _storageFile();
    try {
      final payload = jsonEncode(
        _items.map((item) => item.toJson()).toList(growable: false),
      );
      await file.writeAsString(payload, flush: true);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[QuestionsRepositoryLocal] saveToDisk failed: $error');
        debugPrint('$stackTrace');
      }
    }
  }

  Future<void> seedDefaultsIfEmpty(String ownerId) async {
    if (!_loadedOnce) {
      await loadFromDisk();
    }
    if (_items.isNotEmpty) return;
    final now = DateTime.now();
    final defaults = <DoctorQuestion>[
      _default(
        id: 'q_surgeon_1',
        ownerId: ownerId,
        text: 'Welche Risiken sind bei diesem Eingriff am wichtigsten?',
        category: QuestionCategory.surgeon,
        now: now,
      ),
      _default(
        id: 'q_surgeon_2',
        ownerId: ownerId,
        text: 'Wann darf ich wieder Sport treiben?',
        category: QuestionCategory.surgeon,
        now: now,
      ),
      _default(
        id: 'q_surgeon_3',
        ownerId: ownerId,
        text: 'Welche Warnzeichen erfordern sofortige Rückmeldung?',
        category: QuestionCategory.surgeon,
        now: now,
      ),
      _default(
        id: 'q_anes_1',
        ownerId: ownerId,
        text: 'Welche Narkoseform ist geplant und warum?',
        category: QuestionCategory.anesthetist,
        now: now,
      ),
      _default(
        id: 'q_anes_2',
        ownerId: ownerId,
        text: 'Wie gehe ich mit Übelkeit nach der Narkose um?',
        category: QuestionCategory.anesthetist,
        now: now,
      ),
      _default(
        id: 'q_anes_3',
        ownerId: ownerId,
        text: 'Welche Medikamente sollte ich vor der OP pausieren?',
        category: QuestionCategory.anesthetist,
        now: now,
      ),
    ];
    _items
      ..clear()
      ..addAll(defaults);
    _emit();
    await saveToDisk();
  }

  DoctorQuestion _default({
    required String id,
    required String ownerId,
    required String text,
    required QuestionCategory category,
    required DateTime now,
  }) {
    return DoctorQuestion(
      id: id,
      ownerId: ownerId,
      text: text,
      category: category,
      status: QuestionStatus.open,
      favorite: false,
      createdAt: now,
      updatedAt: now,
      isDefault: true,
      metadata: const <String, dynamic>{'seed': true},
    );
  }

  void _scheduleSave() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 250), () {
      unawaited(saveToDisk());
    });
  }

  void _emit() {
    if (_controller.isClosed) return;
    _controller.add(_sorted(_items));
  }

  List<DoctorQuestion> _sorted(List<DoctorQuestion> source) {
    final copy = List<DoctorQuestion>.from(source);
    copy.sort((a, b) {
      final byCat = a.category.index.compareTo(b.category.index);
      if (byCat != 0) return byCat;
      final byFav = a.favorite == b.favorite ? 0 : (a.favorite ? -1 : 1);
      if (byFav != 0) return byFav;
      return a.createdAt.compareTo(b.createdAt);
    });
    return copy;
  }

  Future<File> _storageFile() async {
    return UserScopedStorage.instance.file('doctor_questions.json');
  }
}
