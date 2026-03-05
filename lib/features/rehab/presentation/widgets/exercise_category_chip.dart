import 'package:flutter/material.dart';

import '../../../../ui/ui.dart';
import '../../domain/rehab_exercise.dart';

/// Small colored chip displaying exercise category.
class ExerciseCategoryChip extends StatelessWidget {
  const ExerciseCategoryChip({super.key, required this.category});

  final RehabCategory category;

  @override
  Widget build(BuildContext context) {
    final label = switch (category) {
      RehabCategory.mobilization => 'Mobilisation',
      RehabCategory.strengthening => 'Kräftigung',
      RehabCategory.stretching => 'Dehnung',
      RehabCategory.breathing => 'Atmung',
    };

    final color = categoryColor(category);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.borderRadiusPill,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  static Color categoryColor(RehabCategory cat) {
    return switch (cat) {
      RehabCategory.mobilization => AppColors.primary,
      RehabCategory.strengthening => const Color(0xFFFF6B6B),
      RehabCategory.stretching => AppColors.accent,
      RehabCategory.breathing => AppColors.success,
    };
  }
}
