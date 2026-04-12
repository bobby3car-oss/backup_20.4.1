import 'package:flutter_test/flutter_test.dart';
import 'package:operationsbegleiter_v3/features/nutrition/domain/nutrition_entry.dart';

void main() {
  final now = DateTime(2026, 3, 21, 12, 0);

  NutritionEntry make({
    String id = 'n1',
    MealType mealType = MealType.mittagessen,
    String description = 'Hühnersuppe',
    int? calories,
    int? protein,
    int? carbs,
    int? fat,
    int? waterMl,
    List<NutritionSymptom> symptoms = const [],
    String? symptomNote,
    int? tolerability,
    bool isFavorite = false,
  }) {
    return NutritionEntry(
      id: id,
      ownerId: 'u1',
      occurredAt: now,
      mealType: mealType,
      description: description,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      waterMl: waterMl,
      symptoms: symptoms,
      symptomNote: symptomNote,
      tolerability: tolerability,
      isFavorite: isFavorite,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('NutritionEntry toJson/fromJson roundtrip', () {
    test('minimal entry survives roundtrip', () {
      final entry = make();
      final json = entry.toJson();
      final restored = NutritionEntry.fromJson(json);

      expect(restored.id, 'n1');
      expect(restored.mealType, MealType.mittagessen);
      expect(restored.description, 'Hühnersuppe');
      expect(restored.calories, isNull);
      expect(restored.protein, isNull);
      expect(restored.symptoms, isEmpty);
      expect(restored.isFavorite, false);
    });

    test('full entry survives roundtrip', () {
      final entry = make(
        calories: 350,
        protein: 28,
        carbs: 15,
        fat: 12,
        waterMl: 500,
        symptoms: [NutritionSymptom.uebelkeit, NutritionSymptom.blaehungen],
        symptomNote: 'Nach dem Essen',
        tolerability: 3,
        isFavorite: true,
      );
      final json = entry.toJson();
      final restored = NutritionEntry.fromJson(json);

      expect(restored.calories, 350);
      expect(restored.protein, 28);
      expect(restored.carbs, 15);
      expect(restored.fat, 12);
      expect(restored.waterMl, 500);
      expect(restored.symptoms, [
        NutritionSymptom.uebelkeit,
        NutritionSymptom.blaehungen,
      ]);
      expect(restored.symptomNote, 'Nach dem Essen');
      expect(restored.tolerability, 3);
      expect(restored.isFavorite, true);
    });

    test('all MealType values roundtrip', () {
      for (final mt in MealType.values) {
        final entry = make(mealType: mt);
        final restored = NutritionEntry.fromJson(entry.toJson());
        expect(restored.mealType, mt);
      }
    });

    test('all NutritionSymptom values roundtrip', () {
      for (final symptom in NutritionSymptom.values) {
        final entry = make(symptoms: [symptom]);
        final restored = NutritionEntry.fromJson(entry.toJson());
        expect(restored.symptoms, contains(symptom));
      }
    });

    test('empty JSON provides sensible defaults', () {
      final restored = NutritionEntry.fromJson(<String, dynamic>{});

      expect(restored.id, '');
      expect(restored.mealType, MealType.snack); // default fallback
      expect(restored.description, '');
      expect(restored.symptoms, isEmpty);
      expect(restored.isFavorite, false);
    });

    test('string numbers are parsed correctly', () {
      final json = <String, dynamic>{
        'id': 'n2',
        'ownerId': 'u1',
        'mealType': 'fruehstueck',
        'description': 'Müsli',
        'calories': '280',
        'protein': '12',
        'waterMl': '200',
        'occurredAt': now.toIso8601String(),
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      };
      final restored = NutritionEntry.fromJson(json);
      expect(restored.calories, 280);
      expect(restored.protein, 12);
      expect(restored.waterMl, 200);
    });
  });

  group('NutritionEntry copyWith', () {
    test('changes only specified fields', () {
      final original = make(calories: 400, tolerability: 4);
      final copy = original.copyWith(calories: 500);

      expect(copy.calories, 500);
      expect(copy.tolerability, 4); // unchanged
      expect(copy.description, original.description);
    });

    test('clears nullable fields with clear flags', () {
      final entry = make(
        calories: 300,
        protein: 20,
        carbs: 30,
        fat: 10,
        waterMl: 250,
        symptomNote: 'test',
        tolerability: 3,
      );
      final cleared = entry.copyWith(
        clearCalories: true,
        clearProtein: true,
        clearCarbs: true,
        clearFat: true,
        clearWaterMl: true,
        clearSymptomNote: true,
        clearTolerability: true,
      );

      expect(cleared.calories, isNull);
      expect(cleared.protein, isNull);
      expect(cleared.carbs, isNull);
      expect(cleared.fat, isNull);
      expect(cleared.waterMl, isNull);
      expect(cleared.symptomNote, isNull);
      expect(cleared.tolerability, isNull);
    });

    test('replaces symptoms list', () {
      final entry = make(symptoms: [NutritionSymptom.uebelkeit]);
      final copy = entry.copyWith(
        symptoms: [NutritionSymptom.schmerzen, NutritionSymptom.durchfall],
      );
      expect(copy.symptoms.length, 2);
      expect(copy.symptoms, contains(NutritionSymptom.schmerzen));
    });

    test('deletedAt survives json roundtrip', () {
      final deleted = now.subtract(const Duration(hours: 1));
      final entry = make().copyWith(deletedAt: deleted);
      expect(entry.isDeleted, true);
      final restored = NutritionEntry.fromJson(entry.toJson());
      expect(restored.deletedAt, deleted);
      expect(restored.isDeleted, true);
    });

    test('clearDeletedAt clears the field', () {
      final entry = make().copyWith(
        deletedAt: now.subtract(const Duration(hours: 1)),
      );
      expect(entry.isDeleted, true);
      final cleared = entry.copyWith(clearDeletedAt: true);
      expect(cleared.isDeleted, false);
      expect(cleared.deletedAt, isNull);
    });
  });
}
