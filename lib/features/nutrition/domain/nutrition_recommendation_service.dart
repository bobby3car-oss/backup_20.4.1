import 'package:flutter/cupertino.dart';

import '../domain/nutrition_entry.dart';
import '../../../ui/theme/app_icons.dart';

/// A single personalized nutrition recommendation.
class NutritionRecommendation {
  const NutritionRecommendation({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    this.priority = 0,
  });

  final IconData icon;


  final Color iconColor;
  final String title;
  final String body;

  /// Higher = more important; used for sorting.
  final int priority;
}

/// Generates rule-based nutrition recommendations from patient context and
/// recent nutrition entries.
///
/// This is intentionally kept lightweight and deterministic; the Bella AI
/// provides complementary conversational recommendations via Cloud Functions.
class NutritionRecommendationService {
  const NutritionRecommendationService();

  /// Compute recommendations based on available context.
  ///
  /// [entries] – most recent nutrition entries (sorted desc by occurredAt).
  /// [opPhase] – current recovery phase (preop, opday, week1, week2, followup).
  /// [allergies] – patient allergies as free-text list.
  /// [weight] – patient weight in kg (if available).
  List<NutritionRecommendation> compute({
    required List<NutritionEntry> entries,
    String? opPhase,
    List<String> allergies = const [],
    double? weight,
  }) {
    final recs = <NutritionRecommendation>[];

    // ── Phase-based recommendations ────────────────────────────────────
    _addPhaseRecommendations(recs, opPhase);

    // ── Data-driven recommendations from recent entries ────────────────
    if (entries.isNotEmpty) {
      _addProteinCheck(recs, entries, opPhase);
      _addHydrationCheck(recs, entries);
      _addSymptomWarnings(recs, entries);
      _addCalorieCheck(recs, entries);
      _addTolerabilityInsight(recs, entries);
    } else {
      recs.add(const NutritionRecommendation(
        icon: AppIcons.notes,
                    iconColor: AppIcons.notesColor,
        title: 'Erste Mahlzeit erfassen',
        body:
            'Erfasse deine erste Mahlzeit, damit wir dir personalisierte '
            'Empfehlungen geben können.',
        priority: 10,
      ));
    }

    // ── Allergy-aware hints ────────────────────────────────────────────
    if (allergies.isNotEmpty) {
      recs.add(NutritionRecommendation(
        icon: AppIcons.warnings,
                    iconColor: AppIcons.warningsColor,
        title: 'Allergien beachten',
        body:
            'Achte bei der Ernährung auf deine bekannten Allergien: '
            '${allergies.join(", ")}.',
        priority: 8,
      ));
    }

    recs.sort((a, b) => b.priority.compareTo(a.priority));
    return recs;
  }

  // ── Phase-based ──────────────────────────────────────────────────────

  void _addPhaseRecommendations(
    List<NutritionRecommendation> recs,
    String? opPhase,
  ) {
    switch (opPhase) {
      case 'preop':
        recs.add(const NutritionRecommendation(
          icon: AppIcons.protein,
          iconColor: AppIcons.proteinColor,
          title: 'Eiweißreich essen',
          body:
              'Vor der OP ist eine proteinreiche Ernährung wichtig für die '
              'Wundheilung. Gute Quellen: Quark, Eier, Fisch, Hülsenfrüchte.',
          priority: 9,
        ));
        recs.add(const NutritionRecommendation(
          icon: AppIcons.water,
                    iconColor: AppIcons.waterColor,
          title: 'Ausreichend trinken',
          body:
              'Trinke mindestens 1,5–2 Liter Wasser pro Tag. Beachte die '
              'Nüchternheitsregeln vor der OP.',
          priority: 7,
        ));
      case 'opday':
        recs.add(const NutritionRecommendation(
          icon: AppIcons.warnings,
          iconColor: AppIcons.warningsColor,
          title: 'Nüchternheit beachten',
          body:
              '6 Stunden vor der OP nichts essen, 2 Stunden vorher keine '
              'klaren Flüssigkeiten. Nach der OP langsam mit leichter Kost starten.',
          priority: 10,
        ));
      case 'week1':
        recs.add(const NutritionRecommendation(
          icon: AppIcons.dining,
          iconColor: AppIcons.diningColor,
          title: 'Leichte & proteinreiche Kost',
          body:
              'In der ersten Woche nach der OP sind leicht verdauliche, '
              'proteinreiche Mahlzeiten ideal. Vermeide fettiges und stark gewürztes Essen.',
          priority: 9,
        ));
        recs.add(const NutritionRecommendation(
          icon: AppIcons.water,
          iconColor: AppIcons.waterColor,
          title: 'Flüssigkeit ist entscheidend',
          body:
              'Trinke regelmäßig Wasser und ungesüßten Tee. Dein Körper braucht '
              'Flüssigkeit für die Heilung.',
          priority: 8,
        ));
      case 'week2':
        recs.add(const NutritionRecommendation(
          icon: AppIcons.nutrition,
                    iconColor: AppIcons.nutritionColor,
          title: 'Abwechslungsreicher essen',
          body:
              'Du kannst jetzt abwechslungsreicher essen. Achte weiterhin auf '
              'Protein (Fisch, Geflügel, Hülsenfrüchte) und Vitamin C (Paprika, Zitrusfrüchte).',
          priority: 7,
        ));
      case 'followup':
        recs.add(const NutritionRecommendation(
          icon: AppIcons.done,
          iconColor: AppIcons.doneColor,
          title: 'Gesunde Gewohnheiten beibehalten',
          body:
              'Ausgewogene Ernährung unterstützt die langfristige Genesung. '
              'Proteinreiche Kost, viel Gemüse und ausreichend Wasser bleiben wichtig.',
          priority: 5,
        ));
      default:
        recs.add(const NutritionRecommendation(
          icon: AppIcons.dining,
                    iconColor: AppIcons.diningColor,
          title: 'Ausgewogen ernähren',
          body:
              'Eine ausgewogene Ernährung mit ausreichend Protein, Gemüse '
              'und Flüssigkeit unterstützt deinen Heilungsprozess.',
          priority: 4,
        ));
    }
  }

  // ── Protein check ────────────────────────────────────────────────────

  void _addProteinCheck(
    List<NutritionRecommendation> recs,
    List<NutritionEntry> entries,
    String? opPhase,
  ) {
    final recent = entries.take(10).toList();
    final withProtein = recent.where((e) => e.protein != null).toList();
    if (withProtein.isEmpty) return;

    final avgProtein =
        withProtein.map((e) => e.protein!).reduce((a, b) => a + b) /
            withProtein.length;

    // In healing phases, recommend ≥ 60g/day on average per meal × 3.
    final isHealingPhase =
        opPhase == 'week1' || opPhase == 'week2' || opPhase == 'preop';
    if (isHealingPhase && avgProtein < 15) {
      recs.add(const NutritionRecommendation(
        icon: AppIcons.protein,
                    iconColor: AppIcons.proteinColor,
        title: 'Mehr Protein empfohlen',
        body:
            'Dein durchschnittlicher Proteinwert pro Mahlzeit ist niedrig. '
            'Für eine gute Wundheilung empfehlen wir mindestens 15–20g pro Mahlzeit.',
        priority: 8,
      ));
    }
  }

  // ── Hydration check ──────────────────────────────────────────────────

  void _addHydrationCheck(
    List<NutritionRecommendation> recs,
    List<NutritionEntry> entries,
  ) {
    // Check last 24 hours
    final cutoff = DateTime.now().subtract(const Duration(hours: 24));
    final last24 =
        entries.where((e) => e.occurredAt.isAfter(cutoff)).toList();

    final totalWater = last24
        .where((e) => e.waterMl != null)
        .fold<int>(0, (sum, e) => sum + e.waterMl!);

    if (last24.isNotEmpty && totalWater < 1000 && totalWater > 0) {
      recs.add(NutritionRecommendation(
        icon: AppIcons.water,
                    iconColor: AppIcons.waterColor,
        title: 'Mehr trinken',
        body:
            'Du hast heute bisher ${totalWater}ml getrunken. '
            'Versuche mindestens 1.500ml zu erreichen.',
        priority: 7,
      ));
    }
  }

  // ── Symptom warnings ─────────────────────────────────────────────────

  void _addSymptomWarnings(
    List<NutritionRecommendation> recs,
    List<NutritionEntry> entries,
  ) {
    final recent = entries.take(7).toList();
    final withSymptoms = recent.where((e) => e.symptoms.isNotEmpty).toList();

    if (withSymptoms.length >= 3) {
      // Count most frequent symptom
      final counts = <NutritionSymptom, int>{};
      for (final entry in withSymptoms) {
        for (final symptom in entry.symptoms) {
          counts[symptom] = (counts[symptom] ?? 0) + 1;
        }
      }
      final sorted = counts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final top = sorted.first;

      recs.add(NutritionRecommendation(
        icon: AppIcons.search,
                    iconColor: AppIcons.searchColor,
        title: 'Häufiges Symptom: ${top.key.label}',
        body:
            '${top.key.label} tritt bei ${top.value} deiner letzten Mahlzeiten auf. '
            'Besprich wiederkehrende Beschwerden mit deinem Behandlungsteam.',
        priority: 9,
      ));
    }
  }

  // ── Calorie check ────────────────────────────────────────────────────

  void _addCalorieCheck(
    List<NutritionRecommendation> recs,
    List<NutritionEntry> entries,
  ) {
    // Check daily calorie average from last 3 days
    final cutoff = DateTime.now().subtract(const Duration(days: 3));
    final recent =
        entries.where((e) => e.occurredAt.isAfter(cutoff)).toList();

    final withCalories = recent.where((e) => e.calories != null).toList();
    if (withCalories.length < 3) return;

    // Group by day
    final perDay = <String, int>{};
    for (final e in withCalories) {
      final key = e.occurredAt.toIso8601String().substring(0, 10);
      perDay[key] = (perDay[key] ?? 0) + e.calories!;
    }
    if (perDay.isEmpty) return;

    final avgDaily =
        perDay.values.reduce((a, b) => a + b) / perDay.length;

    if (avgDaily < 1200) {
      recs.add(const NutritionRecommendation(
        icon: AppIcons.stabbing,
                    iconColor: AppIcons.stabbingColor,
        title: 'Kalorienzufuhr niedrig',
        body:
            'Dein Tagesdurchschnitt liegt unter 1.200 kcal. Für eine gute '
            'Genesung brauchst du ausreichend Energie. Sprich bei Appetitlosigkeit '
            'mit deinem Behandlungsteam.',
        priority: 8,
      ));
    }
  }

  // ── Tolerability insight ─────────────────────────────────────────────

  void _addTolerabilityInsight(
    List<NutritionRecommendation> recs,
    List<NutritionEntry> entries,
  ) {
    final recent = entries.take(10).toList();
    final withTolerability =
        recent.where((e) => e.tolerability != null).toList();
    if (withTolerability.length < 3) return;

    final avg = withTolerability
            .map((e) => e.tolerability!)
            .reduce((a, b) => a + b) /
        withTolerability.length;

    if (avg <= 2.5) {
      recs.add(const NutritionRecommendation(
        icon: AppIcons.nausea,
        iconColor: AppIcons.nauseaColor,
        title: 'Verträglichkeit niedrig',
        body:
            'Die letzten Mahlzeiten wurden schlecht vertragen. Versuche '
            'mildere, leicht verdauliche Speisen und sprich mit deinem '
            'Behandlungsteam darüber.',
        priority: 9,
      ));
    } else if (avg >= 4.0) {
      recs.add(const NutritionRecommendation(
        icon: AppIcons.done,
        iconColor: AppIcons.doneColor,
        title: 'Gute Verträglichkeit',
        body:
            'Super, deine letzten Mahlzeiten wurden gut vertragen! '
            'Behalte dieses Ernährungsmuster bei.',
        priority: 2,
      ));
    }
  }
}
