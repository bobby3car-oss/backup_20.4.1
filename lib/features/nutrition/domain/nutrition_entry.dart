import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

import '../../../ui/theme/app_icons.dart';

/// Type of meal.
enum MealType {
  fruehstueck, // breakfast
  mittagessen, // lunch
  abendessen,  // dinner
  snack;

  String get label => switch (this) {
        MealType.fruehstueck => 'Frühstück',
        MealType.mittagessen => 'Mittagessen',
        MealType.abendessen => 'Abendessen',
        MealType.snack => 'Snack',
      };

  String get emoji => switch (this) {
        MealType.fruehstueck => '🥣',
        MealType.mittagessen => '🍽️',
        MealType.abendessen => '🌙',
        MealType.snack => '🍎',
      };

  IconData get icon => switch (this) {
        MealType.fruehstueck => AppIcons.breakfast,
        MealType.mittagessen => AppIcons.lunch,
        MealType.abendessen => AppIcons.dinner,
        MealType.snack => AppIcons.snack,
      };

  Color get iconColor => switch (this) {
        MealType.fruehstueck => AppIcons.breakfastColor,
        MealType.mittagessen => AppIcons.lunchColor,
        MealType.abendessen => AppIcons.dinnerColor,
        MealType.snack => AppIcons.snackColor,
      };
}

/// Symptom experienced after a meal.
enum NutritionSymptom {
  uebelkeit,  // nausea
  blaehungen, // bloating
  schmerzen,  // pain
  sodbrennen, // heartburn
  durchfall,  // diarrhea
  verstopfung, // constipation
  muedigkeit, // fatigue
  sonstige;   // other

  String get label => switch (this) {
        NutritionSymptom.uebelkeit => 'Übelkeit',
        NutritionSymptom.blaehungen => 'Blähungen',
        NutritionSymptom.schmerzen => 'Schmerzen',
        NutritionSymptom.sodbrennen => 'Sodbrennen',
        NutritionSymptom.durchfall => 'Durchfall',
        NutritionSymptom.verstopfung => 'Verstopfung',
        NutritionSymptom.muedigkeit => 'Müdigkeit',
        NutritionSymptom.sonstige => 'Sonstige',
      };

  String get emoji => switch (this) {
        NutritionSymptom.uebelkeit => '🤢',
        NutritionSymptom.blaehungen => '💨',
        NutritionSymptom.schmerzen => '😣',
        NutritionSymptom.sodbrennen => '🔥',
        NutritionSymptom.durchfall => '💧',
        NutritionSymptom.verstopfung => '🚫',
        NutritionSymptom.muedigkeit => '😴',
        NutritionSymptom.sonstige => '❓',
      };

  IconData get icon => switch (this) {
        NutritionSymptom.uebelkeit => AppIcons.nausea,
        NutritionSymptom.blaehungen => AppIcons.bloating,
        NutritionSymptom.schmerzen => AppIcons.pain,
        NutritionSymptom.sodbrennen => AppIcons.heartburn,
        NutritionSymptom.durchfall => AppIcons.diarrhea,
        NutritionSymptom.verstopfung => AppIcons.constipation,
        NutritionSymptom.muedigkeit => AppIcons.fatigue,
        NutritionSymptom.sonstige => AppIcons.other,
      };

  Color get iconColor => switch (this) {
        NutritionSymptom.uebelkeit => AppIcons.nauseaColor,
        NutritionSymptom.blaehungen => AppIcons.bloatingColor,
        NutritionSymptom.schmerzen => AppIcons.painColor,
        NutritionSymptom.sodbrennen => AppIcons.heartburnColor,
        NutritionSymptom.durchfall => AppIcons.diarrheaColor,
        NutritionSymptom.verstopfung => AppIcons.constipationColor,
        NutritionSymptom.muedigkeit => AppIcons.fatigueColor,
        NutritionSymptom.sonstige => AppIcons.otherColor,
      };
}

class NutritionEntry {
  const NutritionEntry({
    required this.id,
    required this.ownerId,
    required this.occurredAt,
    required this.mealType,
    required this.description,
    this.calories,
    this.protein,
    this.carbs,
    this.fat,
    this.waterMl,
    this.symptoms = const <NutritionSymptom>[],
    this.symptomNote,
    this.tolerability,
    required this.createdAt,
    required this.updatedAt,
    this.metadata = const <String, dynamic>{},
  });

  final String id;
  final String ownerId;
  final DateTime occurredAt;
  final MealType mealType;
  final String description;
  final int? calories;
  final int? protein; // grams
  final int? carbs;   // grams
  final int? fat;     // grams
  final int? waterMl;
  final List<NutritionSymptom> symptoms;
  final String? symptomNote;
  /// 1 = sehr schlecht, 5 = sehr gut
  final int? tolerability;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  NutritionEntry copyWith({
    String? id,
    String? ownerId,
    DateTime? occurredAt,
    MealType? mealType,
    String? description,
    int? calories,
    bool clearCalories = false,
    int? protein,
    bool clearProtein = false,
    int? carbs,
    bool clearCarbs = false,
    int? fat,
    bool clearFat = false,
    int? waterMl,
    bool clearWaterMl = false,
    List<NutritionSymptom>? symptoms,
    String? symptomNote,
    bool clearSymptomNote = false,
    int? tolerability,
    bool clearTolerability = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return NutritionEntry(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      occurredAt: occurredAt ?? this.occurredAt,
      mealType: mealType ?? this.mealType,
      description: description ?? this.description,
      calories: clearCalories ? null : (calories ?? this.calories),
      protein: clearProtein ? null : (protein ?? this.protein),
      carbs: clearCarbs ? null : (carbs ?? this.carbs),
      fat: clearFat ? null : (fat ?? this.fat),
      waterMl: clearWaterMl ? null : (waterMl ?? this.waterMl),
      symptoms: symptoms ?? this.symptoms,
      symptomNote:
          clearSymptomNote ? null : (symptomNote ?? this.symptomNote),
      tolerability:
          clearTolerability ? null : (tolerability ?? this.tolerability),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'ownerId': ownerId,
      'occurredAt': occurredAt.toIso8601String(),
      'mealType': mealType.name,
      'description': description,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'waterMl': waterMl,
      'symptoms': symptoms.map((s) => s.name).toList(),
      'symptomNote': symptomNote,
      'tolerability': tolerability,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory NutritionEntry.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    final occurredAt = _parseDateTime(json['occurredAt']) ?? now;
    return NutritionEntry(
      id: (json['id'] ?? '').toString(),
      ownerId: (json['ownerId'] ?? '').toString(),
      occurredAt: occurredAt,
      mealType: _parseMealType(json['mealType']) ?? MealType.snack,
      description: (json['description'] ?? '').toString(),
      calories: _parseInt(json['calories']),
      protein: _parseInt(json['protein']),
      carbs: _parseInt(json['carbs']),
      fat: _parseInt(json['fat']),
      waterMl: _parseInt(json['waterMl']),
      symptoms: _parseSymptoms(json['symptoms']),
      symptomNote: _parseStringOrNull(json['symptomNote']),
      tolerability: _parseInt(json['tolerability']),
      createdAt: _parseDateTime(json['createdAt']) ?? occurredAt,
      updatedAt: _parseDateTime(json['updatedAt']) ?? occurredAt,
      metadata: _parseMetadata(json['metadata']),
    );
  }

  // ── Parsing helpers ───────────────────────────────────────────────────

  static DateTime? _parseDateTime(Object? raw) {
    if (raw is String && raw.trim().isNotEmpty) {
      return DateTime.tryParse(raw);
    }
    return null;
  }

  static int? _parseInt(Object? raw) {
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw);
    return null;
  }

  static String? _parseStringOrNull(Object? raw) {
    if (raw == null) return null;
    final value = raw.toString().trim();
    return value.isEmpty ? null : value;
  }

  static Map<String, dynamic> _parseMetadata(Object? raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) {
      return raw.map(
        (dynamic key, dynamic value) => MapEntry(key.toString(), value),
      );
    }
    return const <String, dynamic>{};
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
