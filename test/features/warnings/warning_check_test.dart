import 'package:flutter_test/flutter_test.dart';
import 'package:operationsbegleiter_v3/features/warnings/domain/warning_check.dart';

void main() {
  group('evaluateWarningCheck', () {
    test('all false → green', () {
      const answers = WarningCheckAnswers(
        feverHigh: false,
        increasingRedness: false,
        strongPain: false,
        badSmellSecretion: false,
        shortnessOfBreath: false,
        strongBleeding: false,
      );
      final result = evaluateWarningCheck(answers);
      expect(result.level, WarningLevel.green);
    });

    test('feverHigh → red', () {
      const answers = WarningCheckAnswers(
        feverHigh: true,
        increasingRedness: false,
        strongPain: false,
        badSmellSecretion: false,
        shortnessOfBreath: false,
        strongBleeding: false,
      );
      final result = evaluateWarningCheck(answers);
      expect(result.level, WarningLevel.red);
    });

    test('shortnessOfBreath → red', () {
      const answers = WarningCheckAnswers(
        feverHigh: false,
        increasingRedness: false,
        strongPain: false,
        badSmellSecretion: false,
        shortnessOfBreath: true,
        strongBleeding: false,
      );
      final result = evaluateWarningCheck(answers);
      expect(result.level, WarningLevel.red);
    });

    test('strongBleeding → red', () {
      const answers = WarningCheckAnswers(
        feverHigh: false,
        increasingRedness: false,
        strongPain: false,
        badSmellSecretion: false,
        shortnessOfBreath: false,
        strongBleeding: true,
      );
      final result = evaluateWarningCheck(answers);
      expect(result.level, WarningLevel.red);
    });

    test('increasingRedness only → yellow', () {
      const answers = WarningCheckAnswers(
        feverHigh: false,
        increasingRedness: true,
        strongPain: false,
        badSmellSecretion: false,
        shortnessOfBreath: false,
        strongBleeding: false,
      );
      final result = evaluateWarningCheck(answers);
      expect(result.level, WarningLevel.yellow);
    });

    test('strongPain only → yellow', () {
      const answers = WarningCheckAnswers(
        feverHigh: false,
        increasingRedness: false,
        strongPain: true,
        badSmellSecretion: false,
        shortnessOfBreath: false,
        strongBleeding: false,
      );
      final result = evaluateWarningCheck(answers);
      expect(result.level, WarningLevel.yellow);
    });

    test('badSmellSecretion only → yellow', () {
      const answers = WarningCheckAnswers(
        feverHigh: false,
        increasingRedness: false,
        strongPain: false,
        badSmellSecretion: true,
        shortnessOfBreath: false,
        strongBleeding: false,
      );
      final result = evaluateWarningCheck(answers);
      expect(result.level, WarningLevel.yellow);
    });

    test('multiple moderate symptoms → yellow (not red)', () {
      const answers = WarningCheckAnswers(
        feverHigh: false,
        increasingRedness: true,
        strongPain: true,
        badSmellSecretion: true,
        shortnessOfBreath: false,
        strongBleeding: false,
      );
      final result = evaluateWarningCheck(answers);
      expect(result.level, WarningLevel.yellow);
    });

    test('red wins over yellow when both present', () {
      const answers = WarningCheckAnswers(
        feverHigh: true,
        increasingRedness: true,
        strongPain: true,
        badSmellSecretion: false,
        shortnessOfBreath: false,
        strongBleeding: false,
      );
      final result = evaluateWarningCheck(answers);
      expect(result.level, WarningLevel.red);
    });

    test('result always has non-empty actionText', () {
      for (final allFalse in [
        const WarningCheckAnswers(
          feverHigh: false,
          increasingRedness: false,
          strongPain: false,
          badSmellSecretion: false,
          shortnessOfBreath: false,
          strongBleeding: false,
        ),
        const WarningCheckAnswers(
          feverHigh: true,
          increasingRedness: false,
          strongPain: false,
          badSmellSecretion: false,
          shortnessOfBreath: false,
          strongBleeding: false,
        ),
      ]) {
        final result = evaluateWarningCheck(allFalse);
        expect(result.actionText, isNotEmpty);
      }
    });
  });

  group('WarningCheckAnswers toJson/fromJson', () {
    test('roundtrip preserves all fields', () {
      const answers = WarningCheckAnswers(
        feverHigh: true,
        increasingRedness: false,
        strongPain: true,
        badSmellSecretion: false,
        shortnessOfBreath: true,
        strongBleeding: false,
      );
      final json = answers.toJson();
      final restored = WarningCheckAnswers.fromJson(json);

      expect(restored.feverHigh, true);
      expect(restored.increasingRedness, false);
      expect(restored.strongPain, true);
      expect(restored.badSmellSecretion, false);
      expect(restored.shortnessOfBreath, true);
      expect(restored.strongBleeding, false);
    });

    test('missing JSON fields default to false', () {
      final restored = WarningCheckAnswers.fromJson(<String, dynamic>{});
      expect(restored.feverHigh, false);
      expect(restored.increasingRedness, false);
      expect(restored.strongPain, false);
      expect(restored.badSmellSecretion, false);
      expect(restored.shortnessOfBreath, false);
      expect(restored.strongBleeding, false);
    });

    test('string "true" is parsed as true', () {
      final restored = WarningCheckAnswers.fromJson(<String, dynamic>{
        'feverHigh': 'true',
        'strongPain': 'TRUE',
        'increasingRedness': 'false',
        'badSmellSecretion': false,
        'shortnessOfBreath': false,
        'strongBleeding': false,
      });
      expect(restored.feverHigh, true);
      expect(restored.strongPain, true);
      expect(restored.increasingRedness, false);
    });
  });

  group('WarningCheck toJson/fromJson', () {
    test('roundtrip preserves all fields', () {
      final now = DateTime(2026, 3, 21);
      final wc = WarningCheck(
        id: 'wc1',
        ownerId: 'u1',
        createdAt: now,
        answers: const WarningCheckAnswers(
          feverHigh: false,
          increasingRedness: true,
          strongPain: false,
          badSmellSecretion: false,
          shortnessOfBreath: false,
          strongBleeding: false,
        ),
        level: WarningLevel.yellow,
        actionText: 'Beobachten',
      );
      final json = wc.toJson();
      final restored = WarningCheck.fromJson(json);

      expect(restored.id, 'wc1');
      expect(restored.ownerId, 'u1');
      expect(restored.level, WarningLevel.yellow);
      expect(restored.actionText, 'Beobachten');
      expect(restored.answers.increasingRedness, true);
    });
  });
}
