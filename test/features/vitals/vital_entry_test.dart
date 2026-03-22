import 'package:flutter_test/flutter_test.dart';
import 'package:operationsbegleiter_v3/features/vitals/domain/vital_entry.dart';

void main() {
  final now = DateTime(2026, 3, 21, 10, 30);

  VitalEntry make({
    String id = 'v1',
    String ownerId = 'u1',
    int systolic = 120,
    int diastolic = 80,
    int pulse = 72,
    double? temperature,
    int? oxygenSaturation,
    double? weight,
    String? note,
    String source = 'manual',
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VitalEntry(
      id: id,
      ownerId: ownerId,
      systolic: systolic,
      diastolic: diastolic,
      pulse: pulse,
      temperature: temperature,
      oxygenSaturation: oxygenSaturation,
      weight: weight,
      note: note,
      source: source,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
    );
  }

  group('VitalEntry toJson/fromJson roundtrip', () {
    test('minimal entry survives roundtrip', () {
      final entry = make();
      final json = entry.toJson();
      final restored = VitalEntry.fromJson(json);

      expect(restored.id, entry.id);
      expect(restored.ownerId, entry.ownerId);
      expect(restored.systolic, 120);
      expect(restored.diastolic, 80);
      expect(restored.pulse, 72);
      expect(restored.source, 'manual');
      expect(restored.temperature, isNull);
      expect(restored.oxygenSaturation, isNull);
      expect(restored.weight, isNull);
      expect(restored.note, isNull);
    });

    test('full entry survives roundtrip', () {
      final entry = make(
        systolic: 140,
        diastolic: 90,
        pulse: 95,
        temperature: 37.2,
        oxygenSaturation: 98,
        weight: 82.5,
        note: 'Nach Belastung',
        source: 'healthkit',
      );
      final json = entry.toJson();
      final restored = VitalEntry.fromJson(json);

      expect(restored.systolic, 140);
      expect(restored.diastolic, 90);
      expect(restored.pulse, 95);
      expect(restored.temperature, 37.2);
      expect(restored.oxygenSaturation, 98);
      expect(restored.weight, 82.5);
      expect(restored.note, 'Nach Belastung');
      expect(restored.source, 'healthkit');
    });

    test('defaults for missing JSON fields', () {
      final restored = VitalEntry.fromJson(<String, dynamic>{});

      expect(restored.systolic, 120);
      expect(restored.diastolic, 80);
      expect(restored.pulse, 70);
      expect(restored.source, 'manual');
    });

    test('parses string numbers correctly', () {
      final json = <String, dynamic>{
        'id': 'v2',
        'ownerId': 'u2',
        'systolic': '135',
        'diastolic': '85',
        'pulse': '88',
        'temperature': '36.8',
        'weight': '75.3',
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      };
      final restored = VitalEntry.fromJson(json);

      expect(restored.systolic, 135);
      expect(restored.diastolic, 85);
      expect(restored.pulse, 88);
      expect(restored.temperature, 36.8);
      expect(restored.weight, 75.3);
    });
  });

  group('VitalEntry copyWith', () {
    test('changes specified fields', () {
      final original = make(systolic: 120, pulse: 72);
      final copy = original.copyWith(systolic: 145, pulse: 100);

      expect(copy.systolic, 145);
      expect(copy.pulse, 100);
      expect(copy.diastolic, original.diastolic); // unchanged
    });

    test('nullable fields can be set and cleared', () {
      final entry = make(temperature: 37.5, note: 'test');

      // Clear temperature
      final cleared = entry.copyWith(
        temperature: () => null,
        note: () => null,
      );
      expect(cleared.temperature, isNull);
      expect(cleared.note, isNull);

      // Set new value
      final updated = cleared.copyWith(
        temperature: () => 38.0,
        note: () => 'fieber',
      );
      expect(updated.temperature, 38.0);
      expect(updated.note, 'fieber');
    });
  });
}
