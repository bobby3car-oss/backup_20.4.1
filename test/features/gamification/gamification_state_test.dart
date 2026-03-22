import 'package:flutter_test/flutter_test.dart';
import 'package:operationsbegleiter_v3/features/gamification/domain/gamification_state.dart';

void main() {
  group('GamificationState.xpInCurrentLevel', () {
    test('level 1 with 0 XP → 0 in current level', () {
      const state = GamificationState(xp: 0, level: 1);
      expect(state.xpInCurrentLevel, 0);
    });

    test('level 1 with 50 XP → 50 in current level', () {
      const state = GamificationState(xp: 50, level: 1);
      expect(state.xpInCurrentLevel, 50);
    });

    test('level 2 with 100 XP → 0 in current level (just leveled up)', () {
      // Accumulated for levels <2: 100*1 = 100
      const state = GamificationState(xp: 100, level: 2);
      expect(state.xpInCurrentLevel, 0);
    });

    test('level 2 with 180 XP → 80 in current level', () {
      const state = GamificationState(xp: 180, level: 2);
      expect(state.xpInCurrentLevel, 80);
    });

    test('level 3 with 300 XP → 0 in current level', () {
      // Accumulated for levels <3: 100*1 + 100*2 = 300
      const state = GamificationState(xp: 300, level: 3);
      expect(state.xpInCurrentLevel, 0);
    });

    test('level 3 with 450 XP → 150 in current level', () {
      const state = GamificationState(xp: 450, level: 3);
      expect(state.xpInCurrentLevel, 150);
    });
  });

  group('GamificationState.xpForNextLevel', () {
    test('level 1 → needs 100 XP', () {
      const state = GamificationState(level: 1);
      expect(state.xpForNextLevel, 100);
    });

    test('level 5 → needs 500 XP', () {
      const state = GamificationState(level: 5);
      expect(state.xpForNextLevel, 500);
    });
  });

  group('GamificationState.levelProgress', () {
    test('level 1 with 0 XP → 0.0', () {
      const state = GamificationState(xp: 0, level: 1);
      expect(state.levelProgress, 0.0);
    });

    test('level 1 with 50 XP → 0.5', () {
      const state = GamificationState(xp: 50, level: 1);
      expect(state.levelProgress, 0.5);
    });

    test('level 1 with 100 XP → 1.0 (clamped)', () {
      const state = GamificationState(xp: 100, level: 1);
      expect(state.levelProgress, 1.0);
    });

    test('level 2 with 100 XP → 0.0 (just started)', () {
      const state = GamificationState(xp: 100, level: 2);
      expect(state.levelProgress, 0.0);
    });

    test('level 2 with 200 XP → 0.5', () {
      const state = GamificationState(xp: 200, level: 2);
      expect(state.levelProgress, 0.5);
    });

    test('progress is clamped between 0.0 and 1.0', () {
      const state = GamificationState(xp: 0, level: 1);
      expect(state.levelProgress, greaterThanOrEqualTo(0.0));
      expect(state.levelProgress, lessThanOrEqualTo(1.0));
    });
  });

  group('GamificationState.milestoneById', () {
    test('returns null when milestones list is empty', () {
      const state = GamificationState();
      expect(state.milestoneById('streak_7'), isNull);
    });
  });

  group('GamificationState.copyWith', () {
    test('updates specified fields', () {
      const state = GamificationState(xp: 100, level: 2, currentStreak: 5);
      final updated = state.copyWith(xp: 200, currentStreak: 6);

      expect(updated.xp, 200);
      expect(updated.currentStreak, 6);
      expect(updated.level, 2); // unchanged
    });

    test('clearLastActiveDate nulls the date', () {
      final state = GamificationState(
        lastActiveDate: DateTime(2026, 3, 20),
      );
      final cleared = state.copyWith(clearLastActiveDate: true);
      expect(cleared.lastActiveDate, isNull);
    });
  });
}
