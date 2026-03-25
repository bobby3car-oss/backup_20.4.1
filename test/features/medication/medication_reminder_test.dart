import 'package:flutter_test/flutter_test.dart';
import 'package:operationsbegleiter_v3/features/medication/domain/medication_reminder.dart';

void main() {
  final baseDate = DateTime(2026, 3, 21, 8, 0); // Saturday

  MedicationReminder make({
    String id = 'r1',
    int hour = 9,
    int minute = 0,
    RepeatPattern repeatPattern = RepeatPattern.daily,
    List<int>? repeatDays,
    DateTime? createdAt,
    DateTime? endDate,
    bool isEnabled = true,
    int? totalCount,
    int? remainingCount,
  }) {
    return MedicationReminder(
      id: id,
      ownerId: 'u1',
      medicationName: 'Ibuprofen',
      hour: hour,
      minute: minute,
      isEnabled: isEnabled,
      createdAt: createdAt ?? baseDate,
      updatedAt: createdAt ?? baseDate,
      repeatPattern: repeatPattern,
      repeatDays: repeatDays,
      endDate: endDate,
      totalCount: totalCount,
      remainingCount: remainingCount,
    );
  }

  group('nextOccurrence — daily', () {
    test('before reminder time → today', () {
      final reminder = make(hour: 14, minute: 0);
      final from = DateTime(2026, 3, 21, 10, 0); // 10:00, reminder at 14:00
      final next = reminder.nextOccurrence(from);

      expect(next.day, 21);
      expect(next.hour, 14);
      expect(next.minute, 0);
    });

    test('after reminder time → tomorrow', () {
      final reminder = make(hour: 8, minute: 0);
      final from = DateTime(2026, 3, 21, 10, 0); // 10:00, reminder was at 8:00
      final next = reminder.nextOccurrence(from);

      expect(next.day, 22);
      expect(next.hour, 8);
    });

    test('exactly at reminder time → tomorrow (not isAfter)', () {
      final reminder = make(hour: 10, minute: 0);
      final from = DateTime(2026, 3, 21, 10, 0);
      final next = reminder.nextOccurrence(from);

      expect(next.day, 22);
    });
  });

  group('nextOccurrence — everyOtherDay', () {
    test('skips to correct day based on createdAt', () {
      final createdAt = DateTime(2026, 3, 20, 8, 0); // Friday
      final reminder = make(
        hour: 9,
        minute: 0,
        repeatPattern: RepeatPattern.everyOtherDay,
        createdAt: createdAt,
      );
      // From Saturday 10:00 — created Friday, so next allowed: Sunday (day 2)
      final from = DateTime(2026, 3, 21, 10, 0);
      final next = reminder.nextOccurrence(from);

      // Should be on an even-day offset from creation
      final daysSinceCreation = DateTime(next.year, next.month, next.day)
          .difference(DateTime(createdAt.year, createdAt.month, createdAt.day))
          .inDays;
      expect(daysSinceCreation % 2, 0);
    });
  });

  group('nextOccurrence — weekly', () {
    test('returns date 7 days from creation alignment', () {
      final createdAt = DateTime(2026, 3, 14, 8, 0); // Saturday
      final reminder = make(
        hour: 9,
        minute: 0,
        repeatPattern: RepeatPattern.weekly,
        createdAt: createdAt,
      );
      final from = DateTime(2026, 3, 21, 10, 0); // After 9:00 on the 7th day
      final next = reminder.nextOccurrence(from);

      final daysSinceCreation = DateTime(next.year, next.month, next.day)
          .difference(DateTime(createdAt.year, createdAt.month, createdAt.day))
          .inDays;
      expect(daysSinceCreation % 7, 0);
    });
  });

  group('nextOccurrence — custom days', () {
    test('finds next matching weekday', () {
      // repeatDays: [1, 3, 5] = Mon, Wed, Fri
      final reminder = make(
        hour: 9,
        minute: 0,
        repeatPattern: RepeatPattern.custom,
        repeatDays: [1, 3, 5],
      );
      // Saturday 10:00 → next should be Monday (weekday 1)
      final from = DateTime(2026, 3, 21, 10, 0); // Saturday = weekday 6
      final next = reminder.nextOccurrence(from);

      expect(next.weekday, 1); // Monday
    });
  });

  group('nextOccurrence — endDate clamping', () {
    test('clamps to endDate when next occurrence would be after', () {
      final reminder = make(
        hour: 9,
        minute: 0,
        endDate: DateTime(2026, 3, 22), // Tomorrow
      );
      // Far in the future
      final from = DateTime(2026, 3, 22, 10, 0); // After 9:00 on end day
      final next = reminder.nextOccurrence(from);

      // Should not go past end date's 23:59:59
      expect(next.isBefore(DateTime(2026, 3, 23)), true);
    });
  });

  group('occursOn', () {
    test('daily reminder occurs every day', () {
      final reminder = make();
      expect(reminder.occursOn(DateTime(2026, 3, 25)), true);
      expect(reminder.occursOn(DateTime(2026, 3, 26)), true);
    });

    test('disabled reminder does not occur', () {
      final reminder = make(isEnabled: false);
      expect(reminder.occursOn(DateTime(2026, 3, 25)), false);
    });

    test('does not occur before creation date', () {
      final reminder = make(createdAt: DateTime(2026, 3, 21));
      expect(reminder.occursOn(DateTime(2026, 3, 20)), false);
    });

    test('does not occur after end date', () {
      final reminder = make(endDate: DateTime(2026, 3, 25));
      expect(reminder.occursOn(DateTime(2026, 3, 26)), false);
    });

    test('custom days only matches specified weekdays', () {
      final reminder = make(
        repeatPattern: RepeatPattern.custom,
        repeatDays: [1, 3, 5], // Mon, Wed, Fri
      );
      // March 24, 2026 is Tuesday (weekday 2)
      expect(reminder.occursOn(DateTime(2026, 3, 24)), false);
      // March 25, 2026 is Wednesday (weekday 3)
      expect(reminder.occursOn(DateTime(2026, 3, 25)), true);
    });
  });

  group('isExpired', () {
    test('no endDate → not expired', () {
      final reminder = make();
      expect(reminder.isExpired, false);
    });

    test('endDate in far future → not expired', () {
      final reminder = make(endDate: DateTime(2030, 12, 31));
      expect(reminder.isExpired, false);
    });

    test('endDate in the past → expired', () {
      final reminder = make(endDate: DateTime(2020, 1, 1));
      expect(reminder.isExpired, true);
    });
  });

  group('isStockLow', () {
    test('no stock tracking → not low', () {
      final reminder = make();
      expect(reminder.isStockLow, false);
    });

    test('remaining 10 → not low', () {
      final reminder = make(remainingCount: 10);
      expect(reminder.isStockLow, false);
    });

    test('remaining 4 → low', () {
      final reminder = make(remainingCount: 4);
      expect(reminder.isStockLow, true);
    });

    test('remaining 0 → empty, not low', () {
      final reminder = make(remainingCount: 0);
      expect(reminder.isStockLow, false);
      expect(reminder.isStockEmpty, true);
    });
  });

  group('MedicationReminder toJson/fromJson', () {
    test('roundtrip preserves all fields', () {
      final reminder = make(
        repeatPattern: RepeatPattern.custom,
        repeatDays: [1, 3, 5],
        endDate: DateTime(2026, 6, 1),
        totalCount: 60,
        remainingCount: 45,
      );
      final json = reminder.toJson();
      final restored = MedicationReminder.fromJson(json);

      expect(restored.id, reminder.id);
      expect(restored.medicationName, 'Ibuprofen');
      expect(restored.hour, 9);
      expect(restored.minute, 0);
      expect(restored.repeatPattern, RepeatPattern.custom);
      expect(restored.repeatDays, [1, 3, 5]);
      expect(restored.totalCount, 60);
      expect(restored.remainingCount, 45);
    });
  });
}
