import 'package:flutter_test/flutter_test.dart';
import 'package:operationsbegleiter_v3/features/gamification/domain/xp_config.dart';

void main() {
  group('XpConfig.levelFromXp', () {
    test('0 XP → level 1', () {
      expect(XpConfig.levelFromXp(0), 1);
    });

    test('99 XP → still level 1 (need 100 to reach level 2)', () {
      expect(XpConfig.levelFromXp(99), 1);
    });

    test('100 XP → level 2 (exactly crosses threshold)', () {
      expect(XpConfig.levelFromXp(100), 2);
    });

    test('299 XP → level 2 (need 100+200=300 for level 3)', () {
      expect(XpConfig.levelFromXp(299), 2);
    });

    test('300 XP → level 3', () {
      expect(XpConfig.levelFromXp(300), 3);
    });

    test('600 XP → level 4 (100+200+300=600)', () {
      expect(XpConfig.levelFromXp(600), 4);
    });

    test('1000 XP → level 5 (100+200+300+400=1000)', () {
      expect(XpConfig.levelFromXp(1000), 5);
    });

    test('large XP value computes correctly', () {
      // Sum 100*1 + 100*2 + ... + 100*9 = 100*(1+2+...+9) = 4500 → level 10
      expect(XpConfig.levelFromXp(4500), 10);
    });
  });

  group('XpConfig.xpForLevel', () {
    test('level 1 needs 100 XP', () {
      expect(XpConfig.xpForLevel(1), 100);
    });

    test('level 5 needs 500 XP', () {
      expect(XpConfig.xpForLevel(5), 500);
    });

    test('level 10 needs 1000 XP', () {
      expect(XpConfig.xpForLevel(10), 1000);
    });
  });

  group('XpConfig.streakMultiplier', () {
    test('streak 0 → 1.0', () {
      expect(XpConfig.streakMultiplier(0), 1.0);
    });

    test('streak 6 → 1.0 (below 7)', () {
      expect(XpConfig.streakMultiplier(6), 1.0);
    });

    test('streak 7 → 1.15', () {
      expect(XpConfig.streakMultiplier(7), 1.15);
    });

    test('streak 13 → 1.15 (still in 7-13 range)', () {
      expect(XpConfig.streakMultiplier(13), 1.15);
    });

    test('streak 14 → 1.3', () {
      expect(XpConfig.streakMultiplier(14), 1.3);
    });

    test('streak 29 → 1.3 (still in 14-29 range)', () {
      expect(XpConfig.streakMultiplier(29), 1.3);
    });

    test('streak 30 → 1.5', () {
      expect(XpConfig.streakMultiplier(30), 1.5);
    });

    test('streak 100 → 1.5 (caps at 1.5)', () {
      expect(XpConfig.streakMultiplier(100), 1.5);
    });
  });

  group('XpConfig constants', () {
    test('reward values are positive', () {
      expect(XpConfig.taskDone, greaterThan(0));
      expect(XpConfig.woundPhoto, greaterThan(0));
      expect(XpConfig.painLog, greaterThan(0));
      expect(XpConfig.vitalsLog, greaterThan(0));
      expect(XpConfig.medicationLog, greaterThan(0));
      expect(XpConfig.dailyCompleteBonus, greaterThan(0));
    });
  });
}
