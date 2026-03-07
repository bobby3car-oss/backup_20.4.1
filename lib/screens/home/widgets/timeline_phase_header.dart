import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../home_view_model.dart';

class TimelinePhaseHeader extends StatelessWidget {
  const TimelinePhaseHeader({
    super.key,
    required this.data,
  });

  final PhaseHeaderData data;

  static String _phaseEmoji(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('vor')) return '✂️';
    if (lower.contains('op-tag') || lower.contains('optag')) return '🏥';
    if (lower.contains('woche 1') || lower.contains('week1')) return '🩹';
    if (lower.contains('woche 2') || lower.contains('week2')) return '💪';
    if (lower.contains('nachsorge') || lower.contains('follow')) return '✅';
    return '📋';
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl, bottom: AppSpacing.xs),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              AppColors.primary.withValues(alpha: 0.10),
              AppColors.primary.withValues(alpha: 0.03),
            ],
          ),
          borderRadius: AppRadius.borderRadiusLg,
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.15),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(9),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.28),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _phaseEmoji(data.title),
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                data.title,
                style: tt.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm + 2,
                vertical: AppSpacing.xxs + 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: AppRadius.borderRadiusPill,
              ),
              child: Text(
                '${data.doneCount}/${data.totalCount} erledigt',
                style: tt.labelSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
