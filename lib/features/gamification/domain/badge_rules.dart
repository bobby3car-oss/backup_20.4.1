import 'gamification_state.dart';
import 'xp_config.dart';

/// Tracks activity counts for evaluating badge conditions.
class ActivityCounts {
  const ActivityCounts({
    this.totalWoundPhotos = 0,
    this.totalPainEntries = 0,
    this.totalVitalsEntries = 0,
    this.totalMedicationDays = 0,
    this.totalTasksDone = 0,
    this.totalMoodEntries = 0,
    this.totalSleepEntries = 0,
    this.daysActive = 0,
  });

  final int totalWoundPhotos;
  final int totalPainEntries;
  final int totalVitalsEntries;
  final int totalMedicationDays;
  final int totalTasksDone;
  final int totalMoodEntries;
  final int totalSleepEntries;
  final int daysActive;
}

/// Pure functions that check whether each badge condition is met.
abstract final class BadgeRules {
  /// Returns badge IDs that are newly earned (not yet in [state.badges]).
  static List<String> evaluate(GamificationState state, ActivityCounts counts) {
    final earnedIds = state.badges.map((b) => b.id).toSet();
    final newBadges = <String>[];

    void check(String id, bool condition) {
      if (!earnedIds.contains(id) && condition) {
        newBadges.add(id);
      }
    }

    // Streak badges
    check(BadgeCatalog.streak7.id, state.currentStreak >= 7);
    check(BadgeCatalog.streak14.id, state.currentStreak >= 14);
    check(BadgeCatalog.streak30.id, state.currentStreak >= 30);

    // First week (7 days active total)
    check(BadgeCatalog.firstWeek.id, state.totalDaysActive >= 7);

    // Feature-specific badges
    check(BadgeCatalog.vitalsPro.id, counts.totalVitalsEntries >= 30);
    check(BadgeCatalog.photoDocumentor.id, counts.totalWoundPhotos >= 14);
    check(BadgeCatalog.medicationHero.id, counts.totalMedicationDays >= 7);
    check(BadgeCatalog.painDiaryPro.id, counts.totalPainEntries >= 20);
    check(BadgeCatalog.moodDiaryPro.id, counts.totalMoodEntries >= 20);

    // Task master
    check(BadgeCatalog.taskMaster.id, state.totalTasksDone >= 50);

    // Early bird (first task done)
    check(BadgeCatalog.earlyBird.id, state.totalTasksDone >= 1);

    // Level badges
    check(BadgeCatalog.level5.id, state.level >= 5);
    check(BadgeCatalog.level10.id, state.level >= 10);

    return newBadges;
  }
}
