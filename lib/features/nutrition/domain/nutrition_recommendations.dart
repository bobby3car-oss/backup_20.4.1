import 'package:flutter/cupertino.dart';

import '../../../ui/theme/app_icons.dart';

/// A single OP-type–specific nutrition recommendation.
class OpNutritionRecommendation {
  const OpNutritionRecommendation({
    required this.title,
    required this.body,
    required this.icon,
    required this.iconColor,
    this.minDay,
    this.maxDay,
  });

  final String title;
  final String body;
  final IconData icon;
  final Color iconColor;

  /// Earliest post-OP day this recommendation applies (inclusive). Null = always.
  final int? minDay;

  /// Latest post-OP day this recommendation applies (inclusive). Null = always.
  final int? maxDay;

  /// Whether this recommendation is relevant for the given OP-day.
  bool appliesOnDay(int? daysSinceOp) {
    if (daysSinceOp == null) return minDay == null && maxDay == null;
    if (minDay != null && daysSinceOp < minDay!) return false;
    if (maxDay != null && daysSinceOp > maxDay!) return false;
    return true;
  }
}

/// OP-type–keyed nutrition recommendations.
///
/// Keys match `opType` values stored in the user's Firestore profile
/// (e.g. 'darm', 'knie', 'hueft', 'herz', 'magen').
/// The special key 'allgemein' contains universal recommendations shown
/// when no specific OP-type is known or as fallback.
const Map<String, List<OpNutritionRecommendation>> opNutritionRecommendations = {
  // ── Darm-OP ──────────────────────────────────────────────────────
  'darm': [
    OpNutritionRecommendation(
      title: 'Rohkost meiden',
      body: 'Meiden Sie Rohkost in den ersten 2 Wochen nach der Darm-OP. '
          'Gedünstetes Gemüse ist besser verträglich.',
      icon: AppIcons.nutrition,
      iconColor: AppIcons.nutritionColor,
      minDay: 0,
      maxDay: 14,
    ),
    OpNutritionRecommendation(
      title: 'Ballaststoffe langsam steigern',
      body: 'Steigern Sie Ballaststoffe nach und nach, um den Darm nicht '
          'zu überlasten. Beginnen Sie mit leicht verdaulichen Lebensmitteln.',
      icon: AppIcons.nutrition,
      iconColor: AppIcons.nutritionColor,
      minDay: 7,
      maxDay: 28,
    ),
    OpNutritionRecommendation(
      title: 'Ausreichend Flüssigkeit',
      body: 'Trinken Sie mindestens 2 Liter pro Tag. Durchfall nach einer '
          'Darm-OP kann zu Flüssigkeitsverlust führen.',
      icon: AppIcons.water,
      iconColor: AppIcons.waterColor,
    ),
    OpNutritionRecommendation(
      title: 'Kleine Portionen',
      body: 'Essen Sie lieber 5–6 kleine Mahlzeiten statt 3 große. '
          'Das entlastet den Darm.',
      icon: AppIcons.dining,
      iconColor: AppIcons.diningColor,
      minDay: 0,
      maxDay: 21,
    ),
  ],

  // ── Knie-OP ──────────────────────────────────────────────────────
  'knie': [
    OpNutritionRecommendation(
      title: 'Kalziumreiche Ernährung',
      body: 'Kalziumreiche Ernährung fördert die Knochenheilung. '
          'Gute Quellen: Milchprodukte, Brokkoli, Grünkohl, Mandeln.',
      icon: AppIcons.protein,
      iconColor: AppIcons.proteinColor,
    ),
    OpNutritionRecommendation(
      title: 'Vitamin D beachten',
      body: 'Vitamin D verbessert die Kalziumaufnahme. Sonnenlicht, fetter '
          'Fisch und Eier sind natürliche Quellen.',
      icon: AppIcons.nutrition,
      iconColor: AppIcons.nutritionColor,
    ),
    OpNutritionRecommendation(
      title: 'Entzündungshemmend essen',
      body: 'Omega-3-Fettsäuren (Lachs, Leinsamen, Walnüsse) können '
          'Schwellungen und Entzündungen reduzieren.',
      icon: AppIcons.dining,
      iconColor: AppIcons.diningColor,
      minDay: 0,
      maxDay: 28,
    ),
  ],

  // ── Hüft-OP ──────────────────────────────────────────────────────
  'hueft': [
    OpNutritionRecommendation(
      title: 'Kalzium & Vitamin D',
      body: 'Für die Knochenheilung nach der Hüft-OP sind Kalzium und '
          'Vitamin D essenziell. Milch, Joghurt und Käse helfen.',
      icon: AppIcons.protein,
      iconColor: AppIcons.proteinColor,
    ),
    OpNutritionRecommendation(
      title: 'Verstopfung vorbeugen',
      body: 'Schmerzmedikamente können Verstopfung auslösen. Trinken Sie '
          'viel und essen Sie ballaststoffreich (Vollkorn, Obst).',
      icon: AppIcons.water,
      iconColor: AppIcons.waterColor,
      minDay: 0,
      maxDay: 14,
    ),
  ],

  // ── Herz-OP ──────────────────────────────────────────────────────
  'herz': [
    OpNutritionRecommendation(
      title: 'Salzarm essen',
      body: 'Reduzieren Sie den Salzkonsum, um den Blutdruck und die '
          'Herzbelastung zu senken. Würzen Sie mit Kräutern.',
      icon: AppIcons.dining,
      iconColor: AppIcons.diningColor,
    ),
    OpNutritionRecommendation(
      title: 'Herzgesunde Fette',
      body: 'Bevorzugen Sie ungesättigte Fette (Olivenöl, Nüsse, Avocado) '
          'und meiden Sie Transfette und gesättigte Fette.',
      icon: AppIcons.fat,
      iconColor: AppIcons.fatColor,
    ),
    OpNutritionRecommendation(
      title: 'Ballaststoffe für das Herz',
      body: 'Vollkornprodukte, Hülsenfrüchte und Gemüse senken den '
          'Cholesterinspiegel und unterstützen die Genesung.',
      icon: AppIcons.nutrition,
      iconColor: AppIcons.nutritionColor,
    ),
  ],

  // ── Magen-OP ─────────────────────────────────────────────────────
  'magen': [
    OpNutritionRecommendation(
      title: 'Langsam essen & gut kauen',
      body: 'Nehmen Sie sich Zeit beim Essen und kauen Sie gründlich. '
          'Das entlastet den Magen.',
      icon: AppIcons.dining,
      iconColor: AppIcons.diningColor,
    ),
    OpNutritionRecommendation(
      title: 'Flüssige Kost zuerst',
      body: 'In den ersten Tagen nach der Magen-OP nur klare Flüssigkeiten, '
          'dann schrittweise zu passierter und fester Kost übergehen.',
      icon: AppIcons.water,
      iconColor: AppIcons.waterColor,
      minDay: 0,
      maxDay: 7,
    ),
    OpNutritionRecommendation(
      title: 'Kohlensäure meiden',
      body: 'Kohlensäurehaltige Getränke können Blähungen und Beschwerden '
          'verursachen. Wählen Sie stilles Wasser und Tee.',
      icon: AppIcons.water,
      iconColor: AppIcons.waterColor,
      minDay: 0,
      maxDay: 28,
    ),
  ],

  // ── Allgemein (Fallback) ─────────────────────────────────────────
  'allgemein': [
    OpNutritionRecommendation(
      title: 'Eiweißreich essen',
      body: 'Eiweißreich essen für die Wundheilung. Gute Quellen: Quark, '
          'Eier, Fisch, Hülsenfrüchte und mageres Fleisch.',
      icon: AppIcons.protein,
      iconColor: AppIcons.proteinColor,
    ),
    OpNutritionRecommendation(
      title: 'Vitamin C für die Heilung',
      body: 'Vitamin C unterstützt die Wundheilung und das Immunsystem. '
          'Paprika, Zitrusfrüchte und Beeren sind reich an Vitamin C.',
      icon: AppIcons.nutrition,
      iconColor: AppIcons.nutritionColor,
    ),
    OpNutritionRecommendation(
      title: 'Ausreichend trinken',
      body: 'Mindestens 1,5–2 Liter Wasser täglich. Ausreichend Flüssigkeit '
          'fördert die Wundheilung und beugt Komplikationen vor.',
      icon: AppIcons.water,
      iconColor: AppIcons.waterColor,
    ),
  ],
};

/// Returns relevant recommendations for the given OP type and day since surgery.
List<OpNutritionRecommendation> getRecommendationsForOp({
  String? opType,
  int? daysSinceOp,
}) {
  final key = (opType ?? '').toLowerCase().trim();
  final specific = opNutritionRecommendations[key] ?? const [];
  final general = opNutritionRecommendations['allgemein'] ?? const [];

  final results = <OpNutritionRecommendation>[
    ...specific.where((r) => r.appliesOnDay(daysSinceOp)),
    ...general.where((r) => r.appliesOnDay(daysSinceOp)),
  ];

  return results;
}
