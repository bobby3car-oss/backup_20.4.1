import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../sync/user_scoped_storage.dart';
import '../domain/daily_challenge.dart';
import '../domain/daily_log.dart';
import '../domain/gamification_state.dart';
import '../domain/recovery_event.dart';

/// Local JSON-file–backed repository for gamification data.
///
/// Mirrors the four Firestore collections:
///   • gamification state  → `gamification_state.json`  (single object)
///   • daily logs           → `gamification_logs.json`   (map: dateKey → log)
///   • daily challenges     → `gamification_challenges.json` (map: dateKey → set)
///   • recovery feed events → `gamification_events.json` (list)
class GamificationRepositoryLocal {
  static final GamificationRepositoryLocal instance =
      GamificationRepositoryLocal._internal();

  factory GamificationRepositoryLocal() => instance;

  GamificationRepositoryLocal._internal() {
    UserScopedStorage.instance.addListener(_onUserChanged);
  }

  // ── In-memory caches ───────────────────────────────────────────

  GamificationState _state = const GamificationState();
  final Map<String, DailyLog> _logs = {};
  final Map<String, DailyChallengeSet> _challenges = {};
  final List<RecoveryEvent> _events = [];
  bool _loaded = false;

  // ── Stream controllers ─────────────────────────────────────────

  final _stateCtrl =
      StreamController<GamificationState>.broadcast();
  final _logsCtrl =
      StreamController<Map<String, DailyLog>>.broadcast();
  final _challengesCtrl =
      StreamController<Map<String, DailyChallengeSet>>.broadcast();
  final _eventsCtrl =
      StreamController<List<RecoveryEvent>>.broadcast();

  Timer? _stateSaveDebounce;
  Timer? _logsSaveDebounce;
  Timer? _challengesSaveDebounce;
  Timer? _eventsSaveDebounce;

  // ── State ──────────────────────────────────────────────────────

  Stream<GamificationState> watchState() async* {
    yield _state;
    yield* _stateCtrl.stream;
  }

  GamificationState getStateSync() => _state;

  Future<GamificationState> getState() async {
    if (!_loaded) await loadFromDisk();
    return _state;
  }

  Future<void> saveState(GamificationState state) async {
    _state = state;
    _stateCtrl.add(state);
    _scheduleSave(_stateSaveDebounce, _saveState, (t) => _stateSaveDebounce = t);
  }

  /// Apply an [updater] to the current state atomically (single-threaded,
  /// no Firestore transaction needed).
  Future<GamificationState> updateState(
    GamificationState Function(GamificationState current) updater,
  ) async {
    final updated = updater(_state);
    await saveState(updated);
    return updated;
  }

  // ── Daily logs ─────────────────────────────────────────────────

  Future<DailyLog?> getDailyLog(String dateKey) async {
    if (!_loaded) await loadFromDisk();
    return _logs[dateKey];
  }

  Future<void> saveDailyLog(DailyLog log) async {
    _logs[log.date] = log;
    _logsCtrl.add(Map.unmodifiable(_logs));
    _scheduleSave(_logsSaveDebounce, _saveLogs, (t) => _logsSaveDebounce = t);
  }

  Stream<List<DailyLog>> watchRecentLogs({int days = 35}) async* {
    List<DailyLog> filter() {
      final cutoff = DateTime.now().subtract(Duration(days: days));
      final cutoffKey = _dateKey(cutoff);
      return _logs.entries
          .where((e) => e.key.compareTo(cutoffKey) >= 0)
          .map((e) => e.value)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    }
    yield filter();
    yield* _logsCtrl.stream.map((_) => filter());
  }

  // ── Daily challenges ───────────────────────────────────────────

  Future<DailyChallengeSet?> getDailyChallenges(String dateKey) async {
    if (!_loaded) await loadFromDisk();
    return _challenges[dateKey];
  }

  Future<void> saveDailyChallenges(DailyChallengeSet cs) async {
    _challenges[cs.date] = cs;
    _challengesCtrl.add(Map.unmodifiable(_challenges));
    _scheduleSave(
      _challengesSaveDebounce,
      _saveChallenges,
      (t) => _challengesSaveDebounce = t,
    );
  }

  Stream<DailyChallengeSet?> watchDailyChallenges(String dateKey) async* {
    yield _challenges[dateKey];
    yield* _challengesCtrl.stream.map((_) => _challenges[dateKey]);
  }

  // ── Recovery feed events ───────────────────────────────────────

  Future<void> saveRecoveryEvent(RecoveryEvent event) async {
    _events.insert(0, event);
    // Keep max 200 events locally
    if (_events.length > 200) _events.removeRange(200, _events.length);
    _eventsCtrl.add(List.unmodifiable(_events));
    _scheduleSave(
      _eventsSaveDebounce,
      _saveEvents,
      (t) => _eventsSaveDebounce = t,
    );
  }

  Stream<List<RecoveryEvent>> watchTodayEvents() async* {
    List<RecoveryEvent> filter() {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      return _events
          .where((e) => !e.createdAt.isBefore(todayStart))
          .toList();
    }
    yield filter();
    yield* _eventsCtrl.stream.map((_) => filter());
  }

  Stream<List<RecoveryEvent>> watchRecentEvents({int days = 7}) async* {
    List<RecoveryEvent> filter() {
      final cutoff = DateTime.now().subtract(Duration(days: days));
      return _events.where((e) => e.createdAt.isAfter(cutoff)).toList();
    }
    yield filter();
    yield* _eventsCtrl.stream.map((_) => filter());
  }

  // ── Disk I/O ───────────────────────────────────────────────────

  Future<void> loadFromDisk() async {
    _loaded = true;
    if (kIsWeb) return;
    await Future.wait([
      _loadState(),
      _loadLogs(),
      _loadChallenges(),
      _loadEvents(),
    ]);
  }

  // -- state --
  Future<void> _loadState() async {
    try {
      final raw = await UserScopedStorage.instance.readSecure('gamification_state.json');
      if (raw == null) return;
      if (raw.trim().isEmpty) return;
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        _state = GamificationState.fromJson(decoded);
        _stateCtrl.add(_state);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[GamificationLocal] _loadState: $e');
    }
  }

  Future<void> _saveState() async {
    try {
      await UserScopedStorage.instance.writeSecure('gamification_state.json', jsonEncode(_state.toJson()));
    } catch (e) {
      if (kDebugMode) debugPrint('[GamificationLocal] _saveState: $e');
    }
  }

  // -- logs --
  Future<void> _loadLogs() async {
    try {
      final raw = await UserScopedStorage.instance.readSecure('gamification_logs.json');
      if (raw == null) return;
      if (raw.trim().isEmpty) return;
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        _logs.clear();
        for (final entry in decoded.entries) {
          if (entry.value is Map) {
            _logs[entry.key] = DailyLog.fromJson(
              Map<String, dynamic>.from(entry.value as Map),
            );
          }
        }
        _logsCtrl.add(Map.unmodifiable(_logs));
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[GamificationLocal] _loadLogs: $e');
    }
  }

  Future<void> _saveLogs() async {
    try {
      final map = <String, dynamic>{};
      for (final entry in _logs.entries) {
        map[entry.key] = entry.value.toJson();
      }
      await UserScopedStorage.instance.writeSecure('gamification_logs.json', jsonEncode(map));
    } catch (e) {
      if (kDebugMode) debugPrint('[GamificationLocal] _saveLogs: $e');
    }
  }

  // -- challenges --
  Future<void> _loadChallenges() async {
    try {
      final raw = await UserScopedStorage.instance.readSecure('gamification_challenges.json');
      if (raw == null) return;
      if (raw.trim().isEmpty) return;
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        _challenges.clear();
        for (final entry in decoded.entries) {
          if (entry.value is Map) {
            _challenges[entry.key] = DailyChallengeSet.fromJson(
              Map<String, dynamic>.from(entry.value as Map),
            );
          }
        }
        _challengesCtrl.add(Map.unmodifiable(_challenges));
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[GamificationLocal] _loadChallenges: $e');
    }
  }

  Future<void> _saveChallenges() async {
    try {
      final map = <String, dynamic>{};
      for (final entry in _challenges.entries) {
        map[entry.key] = entry.value.toJson();
      }
      await UserScopedStorage.instance.writeSecure('gamification_challenges.json', jsonEncode(map));
    } catch (e) {
      if (kDebugMode) debugPrint('[GamificationLocal] _saveChallenges: $e');
    }
  }

  // -- events --
  Future<void> _loadEvents() async {
    try {
      final raw = await UserScopedStorage.instance.readSecure('gamification_events.json');
      if (raw == null) return;
      if (raw.trim().isEmpty) return;
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        _events.clear();
        for (final item in decoded) {
          if (item is Map) {
            _events.add(
              RecoveryEvent.fromJson(Map<String, dynamic>.from(item)),
            );
          }
        }
        _eventsCtrl.add(List.unmodifiable(_events));
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[GamificationLocal] _loadEvents: $e');
    }
  }

  Future<void> _saveEvents() async {
    try {
      final list = _events.map((e) => e.toJson()).toList();
      await UserScopedStorage.instance.writeSecure('gamification_events.json', jsonEncode(list));
    } catch (e) {
      if (kDebugMode) debugPrint('[GamificationLocal] _saveEvents: $e');
    }
  }

  // ── Helpers ────────────────────────────────────────────────────

  void _onUserChanged() {
    _loaded = false;
    _state = const GamificationState();
    _logs.clear();
    _challenges.clear();
    _events.clear();
    _stateCtrl.add(_state);
    _logsCtrl.add({});
    _challengesCtrl.add({});
    _eventsCtrl.add([]);
    unawaited(loadFromDisk());
  }

  Future<File> _file(String name) => UserScopedStorage.instance.file(name);

  void _scheduleSave(
    Timer? current,
    Future<void> Function() saver,
    void Function(Timer?) assign,
  ) {
    current?.cancel();
    assign(Timer(const Duration(milliseconds: 300), () => unawaited(saver())));
  }

  static String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void dispose() {
    _stateSaveDebounce?.cancel();
    _logsSaveDebounce?.cancel();
    _challengesSaveDebounce?.cancel();
    _eventsSaveDebounce?.cancel();
    _stateCtrl.close();
    _logsCtrl.close();
    _challengesCtrl.close();
    _eventsCtrl.close();
  }
}
