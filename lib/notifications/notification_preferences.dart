import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Persisted notification preferences controlling which auto-notification
/// categories the user wants to receive.
class NotificationPreferences with ChangeNotifier {
  // ── Singleton ────────────────────────────────────────────────────────────

  static final NotificationPreferences instance =
      NotificationPreferences._internal();

  factory NotificationPreferences() => instance;

  NotificationPreferences._internal() {
    unawaited(load());
  }

  // ── Preference flags ─────────────────────────────────────────────────────

  bool _globalEnabled = true;
  bool _taskReminders = true;
  bool _appointmentReminders = true;
  bool _medicationReminders = true;
  bool _supplementReminders = true;
  bool _woundWarnings = true;
  bool _observations = true;
  bool _systemNotifications = true;

  // ── Getters ──────────────────────────────────────────────────────────────

  bool get globalEnabled => _globalEnabled;
  bool get taskReminders => _taskReminders;
  bool get appointmentReminders => _appointmentReminders;
  bool get medicationReminders => _medicationReminders;
  bool get supplementReminders => _supplementReminders;
  bool get woundWarnings => _woundWarnings;
  bool get observations => _observations;
  bool get systemNotifications => _systemNotifications;

  int get enabledCount => [
    _taskReminders,
    _appointmentReminders,
    _medicationReminders,
    _supplementReminders,
    _woundWarnings,
    _observations,
    _systemNotifications,
  ].where((v) => v).length;

  static const int totalCategories = 7;

  // ── Setters ──────────────────────────────────────────────────────────────

  void setGlobalEnabled(bool value) {
    _globalEnabled = value;
    if (!value) {
      _taskReminders = false;
      _appointmentReminders = false;
      _medicationReminders = false;
      _supplementReminders = false;
      _woundWarnings = false;
      _observations = false;
      _systemNotifications = false;
    }
    notifyListeners();
    _scheduleSave();
  }

  void setTaskReminders(bool value) {
    _taskReminders = value;
    _syncGlobal();
    notifyListeners();
    _scheduleSave();
  }

  void setAppointmentReminders(bool value) {
    _appointmentReminders = value;
    _syncGlobal();
    notifyListeners();
    _scheduleSave();
  }

  void setMedicationReminders(bool value) {
    _medicationReminders = value;
    _syncGlobal();
    notifyListeners();
    _scheduleSave();
  }

  void setSupplementReminders(bool value) {
    _supplementReminders = value;
    _syncGlobal();
    notifyListeners();
    _scheduleSave();
  }

  void setWoundWarnings(bool value) {
    _woundWarnings = value;
    _syncGlobal();
    notifyListeners();
    _scheduleSave();
  }

  void setObservations(bool value) {
    _observations = value;
    _syncGlobal();
    notifyListeners();
    _scheduleSave();
  }

  void setSystemNotifications(bool value) {
    _systemNotifications = value;
    _syncGlobal();
    notifyListeners();
    _scheduleSave();
  }

  void enableAll() {
    _globalEnabled = true;
    _taskReminders = true;
    _appointmentReminders = true;
    _medicationReminders = true;
    _supplementReminders = true;
    _woundWarnings = true;
    _observations = true;
    _systemNotifications = true;
    notifyListeners();
    _scheduleSave();
  }

  // ── Persistence ──────────────────────────────────────────────────────────

  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _syncGlobal() {
    _globalEnabled = _taskReminders ||
        _appointmentReminders ||
        _medicationReminders ||
        _supplementReminders ||
        _woundWarnings ||
        _observations ||
        _systemNotifications;
  }

  void _scheduleSave() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      unawaited(save());
    });
  }

  bool _loaded = false;

  Future<void> load() async {
    if (_loaded || kIsWeb) return;
    _loaded = true;
    try {
      final file = await _file();
      if (!await file.exists()) return;
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) return;
      final json = jsonDecode(raw) as Map<String, dynamic>;
      _globalEnabled = json['globalEnabled'] as bool? ?? true;
      _taskReminders = json['taskReminders'] as bool? ?? true;
      _appointmentReminders = json['appointmentReminders'] as bool? ?? true;
      _medicationReminders = json['medicationReminders'] as bool? ?? true;
      _supplementReminders = json['supplementReminders'] as bool? ?? true;
      _woundWarnings = json['woundWarnings'] as bool? ?? true;
      _observations = json['observations'] as bool? ?? true;
      _systemNotifications = json['systemNotifications'] as bool? ?? true;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) debugPrint('[NotificationPreferences] load: $e');
    }
  }

  Future<void> save() async {
    if (kIsWeb) return;
    try {
      final file = await _file();
      await file.writeAsString(
        jsonEncode({
          'globalEnabled': _globalEnabled,
          'taskReminders': _taskReminders,
          'appointmentReminders': _appointmentReminders,
          'medicationReminders': _medicationReminders,
          'supplementReminders': _supplementReminders,
          'woundWarnings': _woundWarnings,
          'observations': _observations,
          'systemNotifications': _systemNotifications,
        }),
        flush: true,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('[NotificationPreferences] save: $e');
    }
  }

  Future<File> _file() async {
    if (kIsWeb) return File('');
    final docs = await getApplicationDocumentsDirectory();
    return File('${docs.path}/notification_preferences.json');
  }
}
