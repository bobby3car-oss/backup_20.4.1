import 'package:shared_preferences/shared_preferences.dart';

class VitalReminderStorage {
  VitalReminderStorage({SharedPreferences? prefs}) : _prefs = prefs;

  static final VitalReminderStorage instance = VitalReminderStorage();

  SharedPreferences? _prefs;

  static const _kEnabled = 'vital_reminder_enabled';
  static const _kHour = 'vital_reminder_hour';
  static const _kMinute = 'vital_reminder_minute';

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  bool get isEnabled => _prefs?.getBool(_kEnabled) ?? false;

  int get hour => _prefs?.getInt(_kHour) ?? 8;

  int get minute => _prefs?.getInt(_kMinute) ?? 0;

  Future<void> setEnabled(bool value) async {
    await init();
    await _prefs!.setBool(_kEnabled, value);
  }

  Future<void> setTime(int hour, int minute) async {
    await init();
    await _prefs!.setInt(_kHour, hour);
    await _prefs!.setInt(_kMinute, minute);
  }
}
