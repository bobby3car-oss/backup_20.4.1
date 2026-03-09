import 'nutrition_entry.dart';

/// A reusable meal template for quick entry creation.
class MealTemplate {
  const MealTemplate({
    required this.id,
    required this.name,
    required this.mealType,
    this.description = '',
    this.calories,
    this.protein,
    this.carbs,
    this.fat,
    this.waterMl,
    this.symptoms = const <NutritionSymptom>[],
    this.tolerability,
    required this.createdAt,
  });

  final String id;
  final String name;
  final MealType mealType;
  final String description;
  final int? calories;
  final int? protein;
  final int? carbs;
  final int? fat;
  final int? waterMl;
  final List<NutritionSymptom> symptoms;
  final int? tolerability;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'mealType': mealType.name,
        'description': description,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'waterMl': waterMl,
        'symptoms': symptoms.map((s) => s.name).toList(),
        'tolerability': tolerability,
        'createdAt': createdAt.toIso8601String(),
      };

  factory MealTemplate.fromJson(Map<String, dynamic> json) {
    return MealTemplate(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      mealType: _parseMealType(json['mealType']) ?? MealType.snack,
      description: (json['description'] ?? '').toString(),
      calories: _parseInt(json['calories']),
      protein: _parseInt(json['protein']),
      carbs: _parseInt(json['carbs']),
      fat: _parseInt(json['fat']),
      waterMl: _parseInt(json['waterMl']),
      symptoms: _parseSymptoms(json['symptoms']),
      tolerability: _parseInt(json['tolerability']),
      createdAt:
          DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
              DateTime.now(),
    );
  }

  /// Create a template from an existing nutrition entry.
  factory MealTemplate.fromEntry(NutritionEntry entry, {required String name}) {
    return MealTemplate(
      id: DateTime.now().microsecondsSinceEpoch.toRadixString(36),
      name: name,
      mealType: entry.mealType,
      description: entry.description,
      calories: entry.calories,
      protein: entry.protein,
      carbs: entry.carbs,
      fat: entry.fat,
      waterMl: entry.waterMl,
      symptoms: entry.symptoms,
      tolerability: entry.tolerability,
      createdAt: DateTime.now(),
    );
  }

  static int? _parseInt(Object? raw) {
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw);
    return null;
  }

  static MealType? _parseMealType(Object? raw) {
    if (raw == null) return null;
    final name = raw.toString().trim().toLowerCase();
    for (final value in MealType.values) {
      if (value.name == name) return value;
    }
    return null;
  }

  static List<NutritionSymptom> _parseSymptoms(Object? raw) {
    if (raw is! List) return const <NutritionSymptom>[];
    final result = <NutritionSymptom>[];
    for (final item in raw) {
      final name = item.toString().trim().toLowerCase();
      for (final value in NutritionSymptom.values) {
        if (value.name == name) {
          result.add(value);
          break;
        }
      }
    }
    return result;
  }
}
