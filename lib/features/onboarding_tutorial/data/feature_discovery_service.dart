import 'tutorial_preferences.dart';

/// Thin facade over [TutorialPreferences] for feature-discovery tooltip state.
///
/// Use [hasSeenFeature] to check whether a one-time hint has already been
/// shown, and [markSeen] to record that the user has seen it.
///
/// Feature IDs are arbitrary strings — use descriptive snake_case names
/// (e.g. `'wound_hub'`, `'vitals'`).
class FeatureDiscoveryService {
  FeatureDiscoveryService._();
  static final FeatureDiscoveryService instance = FeatureDiscoveryService._();

  /// Returns `true` if the hint for [id] has already been shown.
  Future<bool> hasSeenFeature(String id) =>
      TutorialPreferences.instance.isFeatureDiscovered(id);

  /// Marks the hint for [id] as seen so it is not shown again.
  Future<void> markSeen(String id) =>
      TutorialPreferences.instance.markFeatureDiscovered(id);
}
