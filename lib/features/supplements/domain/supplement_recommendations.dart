import 'package:flutter/cupertino.dart';

import '../../../ui/theme/app_icons.dart';
import '../../../ui/theme/colors.dart';
import 'supplement_category.dart';

/// Evidence level for a supplement recommendation.
enum EvidenceLevel {
  high,
  moderate,
  low;

  String get label => switch (this) {
        high => 'Hohe Evidenz',
        moderate => 'Mittlere Evidenz',
        low => 'Geringe Evidenz',
      };

  String get emoji => switch (this) {
        high => '🟢',
        moderate => '🟡',
        low => '🟠',
      };
}

/// A single OP-type–specific supplement recommendation.
class SupplementRecommendation {
  const SupplementRecommendation({
    required this.title,
    required this.body,
    required this.icon,
    required this.iconColor,
    required this.category,
    required this.evidenceLevel,
    this.doseGuidance,
    this.minDay,
    this.maxDay,
  });

  final String title;
  final String body;
  final IconData icon;
  final Color iconColor;
  final SupplementCategory category;
  final EvidenceLevel evidenceLevel;

  /// E.g. '1000 IE täglich', '400 mg morgens'.
  final String? doseGuidance;

  /// Earliest post-OP day this recommendation applies (inclusive).
  final int? minDay;

  /// Latest post-OP day this recommendation applies (inclusive).
  final int? maxDay;

  bool appliesOnDay(int? daysSinceOp) {
    if (daysSinceOp == null) return minDay == null && maxDay == null;
    if (minDay != null && daysSinceOp < minDay!) return false;
    if (maxDay != null && daysSinceOp > maxDay!) return false;
    return true;
  }
}

/// OP-type–keyed supplement recommendations.
const Map<String, List<SupplementRecommendation>> opSupplementRecommendations = {
  // ── Darm-OP ──────────────────────────────────────────────────────
  'darm': [
    SupplementRecommendation(
      title: 'Probiotika',
      body: 'Probiotika können die Darmflora nach einer Darm-OP unterstützen. '
          'Achten Sie auf Stämme wie Lactobacillus und Bifidobacterium.',
      icon: CupertinoIcons.leaf_arrow_circlepath,
      iconColor: AppColors.success,
      category: SupplementCategory.probiotika,
      evidenceLevel: EvidenceLevel.high,
      doseGuidance: '10–20 Mrd. KBE täglich',
      minDay: 3,
    ),
    SupplementRecommendation(
      title: 'Zink',
      body: 'Zink fördert die Wundheilung und unterstützt das Immunsystem. '
          'Besonders wichtig nach operativen Eingriffen am Darm.',
      icon: AppIcons.vitals,
      iconColor: AppColors.accent,
      category: SupplementCategory.mineralien,
      evidenceLevel: EvidenceLevel.moderate,
      doseGuidance: '15–25 mg täglich',
      minDay: 0,
      maxDay: 42,
    ),
    SupplementRecommendation(
      title: 'Vitamin C',
      body: 'Vitamin C ist essenziell für die Kollagenbildung und '
          'Wundheilung. Unterstützt zudem die Eisenaufnahme.',
      icon: AppIcons.nutrition,
      iconColor: AppColors.warning,
      category: SupplementCategory.vitamine,
      evidenceLevel: EvidenceLevel.high,
      doseGuidance: '500–1000 mg täglich',
      minDay: 0,
      maxDay: 28,
    ),
    SupplementRecommendation(
      title: 'Glutamin',
      body: 'Die Aminosäure Glutamin dient als Energiequelle für Darmzellen '
          'und kann die Regeneration der Darmschleimhaut unterstützen.',
      icon: AppIcons.protein,
      iconColor: AppColors.primary,
      category: SupplementCategory.aminosaeuren,
      evidenceLevel: EvidenceLevel.moderate,
      doseGuidance: '5–10 g täglich',
      minDay: 3,
      maxDay: 28,
    ),
  ],

  // ── Knie-OP ──────────────────────────────────────────────────────
  'knie': [
    SupplementRecommendation(
      title: 'Vitamin D',
      body: 'Vitamin D verbessert die Kalziumaufnahme und ist entscheidend '
          'für die Knochenheilung nach einer Knie-OP.',
      icon: AppIcons.nutrition,
      iconColor: AppColors.warning,
      category: SupplementCategory.vitamine,
      evidenceLevel: EvidenceLevel.high,
      doseGuidance: '1000–2000 IE täglich',
    ),
    SupplementRecommendation(
      title: 'Kalzium',
      body: 'Kalzium ist der wichtigste Baustein für Knochen. In Kombination '
          'mit Vitamin D wird es optimal aufgenommen.',
      icon: AppIcons.vitals,
      iconColor: AppColors.accent,
      category: SupplementCategory.mineralien,
      evidenceLevel: EvidenceLevel.high,
      doseGuidance: '1000 mg täglich',
    ),
    SupplementRecommendation(
      title: 'Omega-3-Fettsäuren',
      body: 'Omega-3-Fettsäuren (EPA/DHA) haben entzündungshemmende '
          'Eigenschaften und können Schwellungen reduzieren.',
      icon: AppIcons.water,
      iconColor: AppColors.primary,
      category: SupplementCategory.fettsaeuren,
      evidenceLevel: EvidenceLevel.moderate,
      doseGuidance: '2–3 g täglich (EPA+DHA)',
      minDay: 0,
      maxDay: 56,
    ),
    SupplementRecommendation(
      title: 'Kollagen-Peptide',
      body: 'Kollagen-Peptide können die Regeneration von Knorpel, Sehnen '
          'und Bändern nach einer Knie-OP unterstützen.',
      icon: AppIcons.protein,
      iconColor: AppColors.error,
      category: SupplementCategory.proteine,
      evidenceLevel: EvidenceLevel.moderate,
      doseGuidance: '10–15 g täglich',
      minDay: 7,
    ),
    SupplementRecommendation(
      title: 'Magnesium',
      body: 'Magnesium unterstützt die Muskelfunktion und kann '
          'Krämpfe nach der OP vorbeugen.',
      icon: AppIcons.vitals,
      iconColor: AppColors.accent,
      category: SupplementCategory.mineralien,
      evidenceLevel: EvidenceLevel.moderate,
      doseGuidance: '300–400 mg täglich',
    ),
  ],

  // ── Hüft-OP ──────────────────────────────────────────────────────
  'hueft': [
    SupplementRecommendation(
      title: 'Vitamin D + Kalzium',
      body: 'Die Kombination aus Vitamin D und Kalzium ist für die '
          'Knochenheilung nach einer Hüft-OP essenziell.',
      icon: AppIcons.nutrition,
      iconColor: AppColors.warning,
      category: SupplementCategory.vitamine,
      evidenceLevel: EvidenceLevel.high,
      doseGuidance: '1000 IE Vit. D + 1000 mg Ca²⁺',
    ),
    SupplementRecommendation(
      title: 'Omega-3-Fettsäuren',
      body: 'Reduzieren Entzündungsmarker und können die Rehabilitation '
          'nach Hüft-OP unterstützen.',
      icon: AppIcons.water,
      iconColor: AppColors.primary,
      category: SupplementCategory.fettsaeuren,
      evidenceLevel: EvidenceLevel.moderate,
      doseGuidance: '2 g täglich',
    ),
    SupplementRecommendation(
      title: 'Magnesium',
      body: 'Beugt Muskelkrämpfen vor und unterstützt über 300 '
          'Enzymreaktionen im Körper.',
      icon: AppIcons.vitals,
      iconColor: AppColors.accent,
      category: SupplementCategory.mineralien,
      evidenceLevel: EvidenceLevel.moderate,
      doseGuidance: '300–400 mg täglich',
    ),
    SupplementRecommendation(
      title: 'Kollagen-Peptide',
      body: 'Können die Heilung von Bindegewebe, Knorpel und '
          'Gelenkstrukturen fördern.',
      icon: AppIcons.protein,
      iconColor: AppColors.error,
      category: SupplementCategory.proteine,
      evidenceLevel: EvidenceLevel.low,
      doseGuidance: '10 g täglich',
      minDay: 7,
    ),
  ],

  // ── Herz-OP ──────────────────────────────────────────────────────
  'herz': [
    SupplementRecommendation(
      title: 'Omega-3-Fettsäuren',
      body: 'Omega-3 kann nach einer Herz-OP den Blutdruck und '
          'Triglyceride senken. Sprechen Sie die Dosierung mit Ihrem Arzt ab.',
      icon: AppIcons.water,
      iconColor: AppColors.primary,
      category: SupplementCategory.fettsaeuren,
      evidenceLevel: EvidenceLevel.high,
      doseGuidance: '2–4 g täglich (ärztlich abklären)',
    ),
    SupplementRecommendation(
      title: 'Coenzym Q10',
      body: 'CoQ10 unterstützt die zelluläre Energieproduktion im Herzen. '
          'Studien zeigen einen möglichen Nutzen nach Herzoperationen.',
      icon: AppIcons.vitals,
      iconColor: AppColors.error,
      category: SupplementCategory.sonstiges,
      evidenceLevel: EvidenceLevel.moderate,
      doseGuidance: '100–200 mg täglich',
    ),
    SupplementRecommendation(
      title: 'Magnesium',
      body: 'Magnesium ist wichtig für den Herzrhythmus und kann '
          'postoperativen Herzrhythmusstörungen vorbeugen.',
      icon: AppIcons.vitals,
      iconColor: AppColors.accent,
      category: SupplementCategory.mineralien,
      evidenceLevel: EvidenceLevel.high,
      doseGuidance: '300–400 mg täglich',
    ),
    SupplementRecommendation(
      title: 'Vitamin K2',
      body: 'Vitamin K2 unterstützt die Kalziumverteilung – '
          'weg von den Arterien, hin zu den Knochen. Achtung bei Blutverdünnern!',
      icon: AppIcons.nutrition,
      iconColor: AppColors.warning,
      category: SupplementCategory.vitamine,
      evidenceLevel: EvidenceLevel.low,
      doseGuidance: '100–200 µg täglich (Arzt fragen bei Marcumar)',
    ),
  ],

  // ── Magen-OP ─────────────────────────────────────────────────────
  'magen': [
    SupplementRecommendation(
      title: 'Probiotika',
      body: 'Probiotika unterstützen die Magenflora nach einem Eingriff '
          'und können Übelkeit und Verdauungsprobleme lindern.',
      icon: CupertinoIcons.leaf_arrow_circlepath,
      iconColor: AppColors.success,
      category: SupplementCategory.probiotika,
      evidenceLevel: EvidenceLevel.moderate,
      doseGuidance: '10 Mrd. KBE täglich',
      minDay: 5,
    ),
    SupplementRecommendation(
      title: 'Vitamin B12',
      body: 'Nach Magen-OPs kann die B12-Aufnahme gestört sein. '
          'Eine Supplementierung beugt Mangelerscheinungen vor.',
      icon: AppIcons.nutrition,
      iconColor: AppColors.warning,
      category: SupplementCategory.vitamine,
      evidenceLevel: EvidenceLevel.high,
      doseGuidance: '1000 µg täglich oder Spritze',
    ),
    SupplementRecommendation(
      title: 'Eisen',
      body: 'Die Eisenaufnahme kann nach Magen-OPs vermindert sein. '
          'Kontrollieren Sie regelmäßig Ihren Eisenstatus.',
      icon: AppIcons.vitals,
      iconColor: AppColors.error,
      category: SupplementCategory.mineralien,
      evidenceLevel: EvidenceLevel.high,
      doseGuidance: 'Laut Blutwerten, 50–100 mg',
    ),
    SupplementRecommendation(
      title: 'Zink',
      body: 'Zink ist wichtig für die Wundheilung und das Immunsystem '
          'nach einer Magen-Operation.',
      icon: AppIcons.vitals,
      iconColor: AppColors.accent,
      category: SupplementCategory.mineralien,
      evidenceLevel: EvidenceLevel.moderate,
      doseGuidance: '15 mg täglich',
      minDay: 0,
      maxDay: 42,
    ),
  ],

  // ── Allgemein (Fallback) ─────────────────────────────────────────
  'allgemein': [
    SupplementRecommendation(
      title: 'Vitamin D',
      body: 'Vitamin D unterstützt Immunsystem und Knochenstoffwechsel. '
          'Besonders wichtig in der Genesungsphase.',
      icon: AppIcons.nutrition,
      iconColor: AppColors.warning,
      category: SupplementCategory.vitamine,
      evidenceLevel: EvidenceLevel.high,
      doseGuidance: '1000–2000 IE täglich',
    ),
    SupplementRecommendation(
      title: 'Magnesium',
      body: 'Magnesium ist an über 300 Enzymreaktionen beteiligt, '
          'unterstützt die Muskelregeneration und den Schlaf.',
      icon: AppIcons.vitals,
      iconColor: AppColors.accent,
      category: SupplementCategory.mineralien,
      evidenceLevel: EvidenceLevel.high,
      doseGuidance: '300–400 mg täglich',
    ),
    SupplementRecommendation(
      title: 'Omega-3-Fettsäuren',
      body: 'Wirken entzündungshemmend und unterstützen die allgemeine '
          'Genesung nach Operationen.',
      icon: AppIcons.water,
      iconColor: AppColors.primary,
      category: SupplementCategory.fettsaeuren,
      evidenceLevel: EvidenceLevel.moderate,
      doseGuidance: '2 g täglich',
    ),
    SupplementRecommendation(
      title: 'Vitamin C',
      body: 'Essenziell für die Wundheilung und Kollagenbildung. '
          'Unterstützt das Immunsystem in der Genesungsphase.',
      icon: AppIcons.nutrition,
      iconColor: AppColors.warning,
      category: SupplementCategory.vitamine,
      evidenceLevel: EvidenceLevel.high,
      doseGuidance: '500 mg täglich',
    ),
    SupplementRecommendation(
      title: 'Zink',
      body: 'Fördert die Wundheilung, stärkt das Immunsystem und '
          'ist an der Zellteilung beteiligt.',
      icon: AppIcons.vitals,
      iconColor: AppColors.accent,
      category: SupplementCategory.mineralien,
      evidenceLevel: EvidenceLevel.moderate,
      doseGuidance: '15 mg täglich',
      minDay: 0,
      maxDay: 42,
    ),
  ],
};

/// Returns relevant supplement recommendations for the given OP type and day.
List<SupplementRecommendation> getSupplementRecommendationsForOp({
  String? opType,
  int? daysSinceOp,
}) {
  final key = (opType ?? '').toLowerCase().trim();
  final specific = opSupplementRecommendations[key] ?? const [];
  final general = opSupplementRecommendations['allgemein'] ?? const [];

  final results = <SupplementRecommendation>[
    ...specific.where((r) => r.appliesOnDay(daysSinceOp)),
    ...general.where((r) => r.appliesOnDay(daysSinceOp)),
  ];

  // De-duplicate by title.
  final seen = <String>{};
  return results.where((r) => seen.add(r.title)).toList();
}


