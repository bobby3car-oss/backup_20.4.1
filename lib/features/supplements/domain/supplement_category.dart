import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;

import '../../../l10n/app_localizations.dart';
import '../../../ui/theme/colors.dart';

/// Category of a dietary supplement.
enum SupplementCategory {
  vitamine,
  mineralien,
  aminosaeuren,
  kraeuter,
  probiotika,
  fettsaeuren,
  proteine,
  sonstiges;

  String get label => switch (this) {
        vitamine => 'Vitamine',
        mineralien => 'Mineralien',
        aminosaeuren => 'Aminosäuren',
        kraeuter => 'Kräuter & Pflanzen',
        probiotika => 'Probiotika',
        fettsaeuren => 'Fettsäuren',
        proteine => 'Proteine',
        sonstiges => 'Sonstiges',
      };

  String localizedLabel(AppLocalizations l) => switch (this) {
        vitamine => l.supplementCategoryVitamine,
        mineralien => l.supplementCategoryMineralien,
        aminosaeuren => l.supplementCategoryAminosaeuren,
        kraeuter => l.supplementCategoryKraeuter,
        probiotika => l.supplementCategoryProbiotika,
        fettsaeuren => l.supplementCategoryFettsaeuren,
        proteine => l.supplementCategoryProteine,
        sonstiges => l.supplementCategorySonstiges,
      };

  String get emoji => switch (this) {
        vitamine => '💊',
        mineralien => '🪨',
        aminosaeuren => '🧬',
        kraeuter => '🌿',
        probiotika => '🦠',
        fettsaeuren => '🐟',
        proteine => '💪',
        sonstiges => '📦',
      };

  IconData get icon => switch (this) {
        vitamine => CupertinoIcons.capsule_fill,
        mineralien => Icons.diamond_rounded,
        aminosaeuren => CupertinoIcons.bolt_fill,
        kraeuter => CupertinoIcons.leaf_arrow_circlepath,
        probiotika => Icons.biotech_rounded,
        fettsaeuren => CupertinoIcons.drop_fill,
        proteine => Icons.fitness_center_rounded,
        sonstiges => CupertinoIcons.cube_box_fill,
      };

  Color get iconColor => switch (this) {
        vitamine => AppColors.warning,
        mineralien => AppColors.accent,
        aminosaeuren => AppColors.primary,
        kraeuter => AppColors.success,
        probiotika => const Color(0xFF5856D6),
        fettsaeuren => AppColors.primaryLight,
        proteine => AppColors.error,
        sonstiges => AppColors.grey600,
      };

  static SupplementCategory fromName(String? name) {
    if (name == null || name.isEmpty) return sonstiges;
    return SupplementCategory.values.firstWhere(
      (e) => e.name == name,
      orElse: () => sonstiges,
    );
  }
}


