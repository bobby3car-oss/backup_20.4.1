import 'package:flutter_test/flutter_test.dart';
import 'package:operationsbegleiter_v3/features/pain/domain/pain_entry.dart';
import 'package:operationsbegleiter_v3/features/vitals/domain/vital_entry.dart';
import 'package:operationsbegleiter_v3/features/warnings/domain/warning_check.dart';
import 'package:operationsbegleiter_v3/features/observations/domain/observation_entry.dart';
import 'package:operationsbegleiter_v3/features/red_flags/domain/red_flag.dart';
import 'package:operationsbegleiter_v3/features/red_flags/domain/red_flag_engine.dart';

void main() {
  final now = DateTime(2026, 3, 21, 10, 0);

  group('evaluateRedFlags — empty input', () {
    test('no data → empty flags list', () {
      final flags = evaluateRedFlags(
        ownerId: 'u1',
        input: const RedFlagEvalInput(),
      );
      expect(flags, isEmpty);
    });
  });

  group('evaluateRedFlags — warning check rules', () {
    test('red warning check → red flag', () {
      final wc = WarningCheck(
        id: 'wc1',
        ownerId: 'u1',
        createdAt: now,
        answers: const WarningCheckAnswers(
          feverHigh: true,
          increasingRedness: false,
          strongPain: false,
          badSmellSecretion: false,
          shortnessOfBreath: false,
          strongBleeding: false,
        ),
        level: WarningLevel.red,
        actionText: 'Sofort handeln',
      );
      final flags = evaluateRedFlags(
        ownerId: 'u1',
        input: RedFlagEvalInput(latestWarningCheck: wc),
      );
      expect(flags, isNotEmpty);
      expect(flags.first.severity, RedFlagSeverity.red);
      expect(flags.first.source, RedFlagSource.warningCheck);
    });

    test('yellow warning check → yellow flag', () {
      final wc = WarningCheck(
        id: 'wc2',
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
      final flags = evaluateRedFlags(
        ownerId: 'u1',
        input: RedFlagEvalInput(latestWarningCheck: wc),
      );
      expect(flags, isNotEmpty);
      expect(flags.first.severity, RedFlagSeverity.yellow);
    });

    test('green warning check → no flags', () {
      final wc = WarningCheck(
        id: 'wc3',
        ownerId: 'u1',
        createdAt: now,
        answers: const WarningCheckAnswers(
          feverHigh: false,
          increasingRedness: false,
          strongPain: false,
          badSmellSecretion: false,
          shortnessOfBreath: false,
          strongBleeding: false,
        ),
        level: WarningLevel.green,
        actionText: 'Alles ok',
      );
      final flags = evaluateRedFlags(
        ownerId: 'u1',
        input: RedFlagEvalInput(latestWarningCheck: wc),
      );
      expect(flags, isEmpty);
    });
  });

  group('evaluateRedFlags — pain rules', () {
    PainEntry pain(int level) => PainEntry(
          id: 'p1',
          ownerId: 'u1',
          occurredAt: now,
          painLevel: level,
          note: '',
          createdAt: now,
          updatedAt: now,
        );

    test('painLevel 9 → red flag', () {
      final flags = evaluateRedFlags(
        ownerId: 'u1',
        input: RedFlagEvalInput(recentPainEntries: [pain(9)]),
      );
      expect(flags.any((f) => f.severity == RedFlagSeverity.red), true);
      expect(flags.first.source, RedFlagSource.pain);
    });

    test('painLevel 10 → red flag', () {
      final flags = evaluateRedFlags(
        ownerId: 'u1',
        input: RedFlagEvalInput(recentPainEntries: [pain(10)]),
      );
      expect(flags.any((f) => f.severity == RedFlagSeverity.red), true);
    });

    test('painLevel 7 → orange flag', () {
      final flags = evaluateRedFlags(
        ownerId: 'u1',
        input: RedFlagEvalInput(recentPainEntries: [pain(7)]),
      );
      expect(flags.any((f) => f.severity == RedFlagSeverity.orange), true);
    });

    test('painLevel 5 with rising trend → yellow flag', () {
      // Trend: latest=6, previous=5, oldest=4 → rising
      final entries = [pain(6), pain(5), pain(4)];
      // Adjust painLevels
      final adjustedEntries = [
        entries[0].copyWith(painLevel: 6),
        entries[1].copyWith(painLevel: 5),
        entries[2].copyWith(painLevel: 4),
      ];
      final flags = evaluateRedFlags(
        ownerId: 'u1',
        input: RedFlagEvalInput(recentPainEntries: adjustedEntries),
      );
      expect(flags.any((f) => f.severity == RedFlagSeverity.yellow), true);
    });

    test('painLevel 3 → no flags', () {
      final flags = evaluateRedFlags(
        ownerId: 'u1',
        input: RedFlagEvalInput(recentPainEntries: [pain(3)]),
      );
      expect(flags, isEmpty);
    });
  });

  group('evaluateRedFlags — vital sign rules', () {
    VitalEntry vital({
      int systolic = 120,
      int diastolic = 80,
      int pulse = 72,
    }) =>
        VitalEntry(
          id: 'v1',
          ownerId: 'u1',
          systolic: systolic,
          diastolic: diastolic,
          pulse: pulse,
          createdAt: now,
          updatedAt: now,
        );

    test('hypertensive crisis (systolic ≥ 180) → red flag', () {
      final flags = evaluateRedFlags(
        ownerId: 'u1',
        input: RedFlagEvalInput(
          recentVitalEntries: [vital(systolic: 185)],
        ),
      );
      expect(flags.any((f) =>
          f.severity == RedFlagSeverity.red &&
          f.source == RedFlagSource.vitals), true);
    });

    test('hypertensive crisis (diastolic ≥ 120) → red flag', () {
      final flags = evaluateRedFlags(
        ownerId: 'u1',
        input: RedFlagEvalInput(
          recentVitalEntries: [vital(diastolic: 125)],
        ),
      );
      expect(flags.any((f) => f.severity == RedFlagSeverity.red), true);
    });

    test('tachycardia (pulse ≥ 130) → red flag', () {
      final flags = evaluateRedFlags(
        ownerId: 'u1',
        input: RedFlagEvalInput(
          recentVitalEntries: [vital(pulse: 135)],
        ),
      );
      expect(flags.any((f) => f.severity == RedFlagSeverity.red), true);
    });

    test('bradycardia (pulse ≤ 40) → red flag', () {
      final flags = evaluateRedFlags(
        ownerId: 'u1',
        input: RedFlagEvalInput(
          recentVitalEntries: [vital(pulse: 38)],
        ),
      );
      expect(flags.any((f) => f.severity == RedFlagSeverity.red), true);
    });

    test('elevated BP (systolic ≥ 160) → orange flag', () {
      final flags = evaluateRedFlags(
        ownerId: 'u1',
        input: RedFlagEvalInput(
          recentVitalEntries: [vital(systolic: 165)],
        ),
      );
      expect(flags.any((f) => f.severity == RedFlagSeverity.orange), true);
    });

    test('mildly elevated pulse (110-129) → yellow flag', () {
      final flags = evaluateRedFlags(
        ownerId: 'u1',
        input: RedFlagEvalInput(
          recentVitalEntries: [vital(pulse: 115)],
        ),
      );
      expect(flags.any((f) => f.severity == RedFlagSeverity.yellow), true);
    });

    test('normal vitals → no flags', () {
      final flags = evaluateRedFlags(
        ownerId: 'u1',
        input: RedFlagEvalInput(
          recentVitalEntries: [vital()],
        ),
      );
      expect(flags, isEmpty);
    });
  });

  group('evaluateRedFlags — observation rules', () {
    test('critical observation → red flag', () {
      final obs = ObservationEntry(
        id: 'obs1',
        patientId: 'u1',
        authorUid: 'doc1',
        authorName: 'Dr. Test',
        text: 'Wunde stark entzündet',
        severity: ObservationSeverity.critical,
        createdAt: now,
        updatedAt: now,
      );
      final flags = evaluateRedFlags(
        ownerId: 'u1',
        input: RedFlagEvalInput(recentObservations: [obs]),
      );
      expect(flags.any((f) => f.severity == RedFlagSeverity.red), true);
    });

    test('warning observation → yellow flag', () {
      final obs = ObservationEntry(
        id: 'obs2',
        patientId: 'u1',
        authorUid: 'doc1',
        authorName: 'Dr. Test',
        text: 'Leichte Schwellung',
        severity: ObservationSeverity.warning,
        createdAt: now,
        updatedAt: now,
      );
      final flags = evaluateRedFlags(
        ownerId: 'u1',
        input: RedFlagEvalInput(recentObservations: [obs]),
      );
      expect(flags.any((f) => f.severity == RedFlagSeverity.yellow), true);
    });

    test('info observation → no flags', () {
      final obs = ObservationEntry(
        id: 'obs3',
        patientId: 'u1',
        authorUid: 'doc1',
        authorName: 'Dr. Test',
        text: 'Alles normal',
        severity: ObservationSeverity.info,
        createdAt: now,
        updatedAt: now,
      );
      final flags = evaluateRedFlags(
        ownerId: 'u1',
        input: RedFlagEvalInput(recentObservations: [obs]),
      );
      expect(flags, isEmpty);
    });
  });

  group('evaluateRedFlags — overdue task rules', () {
    test('5 overdue tasks → yellow flag', () {
      final flags = evaluateRedFlags(
        ownerId: 'u1',
        input: const RedFlagEvalInput(overdueTaskCount: 5),
      );
      expect(flags.any((f) => f.severity == RedFlagSeverity.yellow), true);
      expect(flags.first.source, RedFlagSource.timeline);
    });

    test('4 overdue tasks → no flags', () {
      final flags = evaluateRedFlags(
        ownerId: 'u1',
        input: const RedFlagEvalInput(overdueTaskCount: 4),
      );
      expect(flags, isEmpty);
    });
  });

  group('evaluateRedFlags — sorting', () {
    test('flags are sorted by severity (red first)', () {
      final obs = ObservationEntry(
        id: 'obs1',
        patientId: 'u1',
        authorUid: 'doc1',
        authorName: 'Dr. Test',
        text: 'Kritisch',
        severity: ObservationSeverity.critical,
        createdAt: now,
        updatedAt: now,
      );
      final flags = evaluateRedFlags(
        ownerId: 'u1',
        input: RedFlagEvalInput(
          recentObservations: [obs],
          overdueTaskCount: 10,
        ),
      );
      expect(flags.length, greaterThanOrEqualTo(2));
      // First flag should have higher or equal severity than second
      expect(
        flags.first.severity.index,
        greaterThanOrEqualTo(flags.last.severity.index),
      );
    });
  });

  group('overallSeverity', () {
    test('empty list → green', () {
      expect(overallSeverity([]), RedFlagSeverity.green);
    });

    test('returns highest active severity', () {
      final flags = evaluateRedFlags(
        ownerId: 'u1',
        input: RedFlagEvalInput(
          recentPainEntries: [
            PainEntry(
              id: 'p1',
              ownerId: 'u1',
              occurredAt: now,
              painLevel: 10,
              note: '',
              createdAt: now,
              updatedAt: now,
            ),
          ],
          overdueTaskCount: 10,
        ),
      );
      expect(overallSeverity(flags), RedFlagSeverity.red);
    });
  });
}
