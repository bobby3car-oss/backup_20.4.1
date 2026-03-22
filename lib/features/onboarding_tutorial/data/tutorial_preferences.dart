import 'package:shared_preferences/shared_preferences.dart';

/// Manages SharedPreferences flags for the onboarding tutorial
/// and feature discovery tooltips.
class TutorialPreferences {
  TutorialPreferences._();
  static final TutorialPreferences instance = TutorialPreferences._();

  static const _kTutorialCompleted = 'tutorial_completed';
  static const _kTutorialNeverShow = 'tutorial_never_show';
  static const _kFeatureDiscoveredPrefix = 'feature_discovered_';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  // ── First-launch tutorial ──────────────────────────────────────────────

  Future<bool> isTutorialCompleted() async {
    final prefs = await _preferences;
    return prefs.getBool(_kTutorialCompleted) ?? false;
  }

  Future<bool> isTutorialNeverShow() async {
    final prefs = await _preferences;
    return prefs.getBool(_kTutorialNeverShow) ?? false;
  }

  Future<void> setTutorialCompleted() async {
    final prefs = await _preferences;
    await prefs.setBool(_kTutorialCompleted, true);
  }

  Future<void> setTutorialNeverShow() async {
    final prefs = await _preferences;
    await prefs.setBool(_kTutorialNeverShow, true);
    await prefs.setBool(_kTutorialCompleted, true);
  }

  Future<void> resetTutorial() async {
    final prefs = await _preferences;
    await prefs.remove(_kTutorialCompleted);
    await prefs.remove(_kTutorialNeverShow);
  }

  // ── Feature discovery ─────────────────────────────────────────────────

  Future<bool> isFeatureDiscovered(String featureName) async {
    final prefs = await _preferences;
    return prefs.getBool('$_kFeatureDiscoveredPrefix$featureName') ?? false;
  }

  Future<void> markFeatureDiscovered(String featureName) async {
    final prefs = await _preferences;
    await prefs.setBool('$_kFeatureDiscoveredPrefix$featureName', true);
  }

  Future<void> resetFeatureDiscovery() async {
    final prefs = await _preferences;
    final keys = prefs
        .getKeys()
        .where((k) => k.startsWith(_kFeatureDiscoveredPrefix));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}
