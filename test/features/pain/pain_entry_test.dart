import 'package:flutter_test/flutter_test.dart';
import 'package:operationsbegleiter_v3/features/pain/domain/pain_entry.dart';

void main() {
  final now = DateTime(2026, 3, 21, 10, 30);

  PainEntry make({
    String id = 'p1',
    String ownerId = 'u1',
    DateTime? occurredAt,
    int painLevel = 5,
    String? location,
    String note = 'test note',
    String? trigger,
    bool? medicationTaken,
    PainType? painType,
    BodyRegion? bodyRegion,
    int? durationMinutes,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic> metadata = const {},
  }) {
    return PainEntry(
      id: id,
      ownerId: ownerId,
      occurredAt: occurredAt ?? now,
      painLevel: painLevel,
      location: location,
      note: note,
      trigger: trigger,
      medicationTaken: medicationTaken,
      painType: painType,
      bodyRegion: bodyRegion,
      durationMinutes: durationMinutes,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
      metadata: metadata,
    );
  }

  group('PainEntry toJson/fromJson roundtrip', () {
    test('minimal entry survives roundtrip', () {
      final entry = make();
      final json = entry.toJson();
      final restored = PainEntry.fromJson(json);

      expect(restored.id, entry.id);
      expect(restored.ownerId, entry.ownerId);
      expect(restored.occurredAt, entry.occurredAt);
      expect(restored.painLevel, entry.painLevel);
      expect(restored.note, entry.note);
      expect(restored.location, isNull);
      expect(restored.trigger, isNull);
      expect(restored.medicationTaken, isNull);
      expect(restored.painType, isNull);
      expect(restored.bodyRegion, isNull);
      expect(restored.durationMinutes, isNull);
    });

    test('full entry survives roundtrip', () {
      final entry = make(
        location: 'Bauch rechts',
        trigger: 'Husten',
        medicationTaken: true,
        painType: PainType.stechend,
        bodyRegion: BodyRegion.bauch,
        durationMinutes: 30,
        metadata: {'source': 'manual'},
      );
      final json = entry.toJson();
      final restored = PainEntry.fromJson(json);

      expect(restored.location, 'Bauch rechts');
      expect(restored.trigger, 'Husten');
      expect(restored.medicationTaken, true);
      expect(restored.painType, PainType.stechend);
      expect(restored.bodyRegion, BodyRegion.bauch);
      expect(restored.durationMinutes, 30);
      expect(restored.metadata['source'], 'manual');
    });

    test('painLevel is clamped to 0..10', () {
      final tooHigh = PainEntry.fromJson({'painLevel': 15});
      expect(tooHigh.painLevel, 10);

      final tooLow = PainEntry.fromJson({'painLevel': -3});
      expect(tooLow.painLevel, 0);
    });

    test('all PainType values roundtrip', () {
      for (final pt in PainType.values) {
        final entry = make(painType: pt);
        final restored = PainEntry.fromJson(entry.toJson());
        expect(restored.painType, pt);
      }
    });

    test('all BodyRegion values roundtrip', () {
      for (final br in BodyRegion.values) {
        final entry = make(bodyRegion: br);
        final restored = PainEntry.fromJson(entry.toJson());
        expect(restored.bodyRegion, br);
      }
    });
  });

  group('PainEntry copyWith', () {
    test('changes only specified fields', () {
      final original = make(
        painLevel: 3,
        note: 'original',
        painType: PainType.dumpf,
      );
      final copy = original.copyWith(painLevel: 8, note: 'updated');

      expect(copy.painLevel, 8);
      expect(copy.note, 'updated');
      expect(copy.painType, PainType.dumpf); // unchanged
      expect(copy.id, original.id); // unchanged
    });

    test('clears nullable fields with clear flags', () {
      final entry = make(
        location: 'Arm',
        trigger: 'Sport',
        medicationTaken: true,
        painType: PainType.brennend,
        bodyRegion: BodyRegion.oberarm,
        durationMinutes: 15,
      );
      final cleared = entry.copyWith(
        clearLocation: true,
        clearTrigger: true,
        clearMedicationTaken: true,
        clearPainType: true,
        clearBodyRegion: true,
        clearDurationMinutes: true,
      );

      expect(cleared.location, isNull);
      expect(cleared.trigger, isNull);
      expect(cleared.medicationTaken, isNull);
      expect(cleared.painType, isNull);
      expect(cleared.bodyRegion, isNull);
      expect(cleared.durationMinutes, isNull);
    });

    test('preserves values when no changes', () {
      final original = make(painLevel: 7, note: 'keep');
      final copy = original.copyWith();

      expect(copy.painLevel, 7);
      expect(copy.note, 'keep');
      expect(copy.occurredAt, original.occurredAt);
    });

    test('deletedAt roundtrips correctly', () {
      final deletedTime = DateTime(2026, 3, 21, 12, 0);
      final entry = make().copyWith(deletedAt: deletedTime);
      expect(entry.isDeleted, true);

      final json = entry.toJson();
      final restored = PainEntry.fromJson(json);
      expect(restored.deletedAt, deletedTime);
      expect(restored.isDeleted, true);
    });

    test('clearDeletedAt resets deletedAt', () {
      final entry = make().copyWith(deletedAt: DateTime.now());
      expect(entry.isDeleted, true);

      final cleared = entry.copyWith(clearDeletedAt: true);
      expect(cleared.isDeleted, false);
      expect(cleared.deletedAt, isNull);
    });
  });
}
