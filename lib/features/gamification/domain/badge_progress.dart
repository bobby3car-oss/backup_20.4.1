import 'xp_config.dart';
import 'badge_rules.dart';
import 'gamification_state.dart';

/// Progress toward a single badge, for UI display.
class BadgeProgress {
  const BadgeProgress({
    required this.badge,
    required this.currentValue,
    required this.targetValue,
    required this.earned,
    this.earnedAt,
  });

  final BadgeDefinition badge;
  final int currentValue;
  final int targetValue;
  final bool earned;
  final DateTime? earnedAt;

  /// 0.0 – 1.0 progress ratio.
  double get progress =>
      targetValue <= 0 ? (earned ? 1.0 : 0.0) : (currentValue / targetValue).clamp(0.0, 1.0);

  /// Remaining count to unlock.
  int get remaining => earned ? 0 : (targetValue - currentValue).clamp(0, targetValue);
}

/// Computes progress for every badge in the catalog.
abstract final class BadgeProgressCalculator {
  static List<BadgeProgress> computeAll(
    GamificationState state,
    ActivityCounts counts,
  ) {
    final earnedIds = <String, DateTime>{};
    for (final b in state.badges) {
      earnedIds[b.id] = b.earnedAt;
    }

    return BadgeCatalog.all.map((badge) {
      final earned = earnedIds.containsKey(badge.id);
      final earnedAt = earnedIds[badge.id];
      final (current, target) = _valuesFor(badge.id, state, counts);

      return BadgeProgress(
        badge: badge,
        currentValue: earned ? target : current,
        targetValue: target,
        earned: earned,
        earnedAt: earnedAt,
      );
    }).toList();
  }

  /// Returns (currentValue, targetValue) for each badge id.
  static (int, int) _valuesFor(
    String id,
    GamificationState state,
    ActivityCounts counts,
  ) {
    return switch (id) {
      'streak_7' => (state.currentStreak.clamp(0, 7), 7),
      'streak_14' => (state.currentStreak.clamp(0, 14), 14),
      'streak_30' => (state.currentStreak.clamp(0, 30), 30),
      'first_week' => (state.totalDaysActive.clamp(0, 7), 7),
      'vitals_pro' => (counts.totalVitalsEntries.clamp(0, 30), 30),
      'photo_doc' => (counts.totalWoundPhotos.clamp(0, 14), 14),
      'medication_hero' => (counts.totalMedicationDays.clamp(0, 7), 7),
      'pain_diary_pro' => (counts.totalPainEntries.clamp(0, 20), 20),
      'task_master' => (state.totalTasksDone.clamp(0, 50), 50),
      'early_bird' => (state.totalTasksDone.clamp(0, 1), 1),
      'level_5' => (state.level.clamp(0, 5), 5),
      'level_10' => (state.level.clamp(0, 10), 10),
      _ => (0, 1),
    };
  }
}
