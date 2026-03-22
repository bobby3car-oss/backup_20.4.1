import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../gamification_service.dart';

/// A card showing the weekly gamification summary,
/// displayed on the home screen on Mondays.
class WeeklySummaryCard extends StatelessWidget {
  const WeeklySummaryCard({
    super.key,
    required this.summary,
    this.onTap,
  });

  final WeeklySummaryData summary;
  final VoidCallback? onTap;

  /// Whether to show the card (only on Mondays).
  static bool shouldShow() => DateTime.now().weekday == DateTime.monday;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.all(AppSpacing.lg),
        borderRadius: AppRadius.borderRadiusXl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.accent, AppColors.primary],
                    ),
                    borderRadius: AppRadius.borderRadiusMd,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.bar_chart_rounded,
                    size: 22,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Letzte Woche',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Dein Wochen-Rückblick',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppColors.grey400,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(height: 0.5, color: AppColors.grey200),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                _SummaryStat(
                  icon: Icons.bolt_rounded,
                  value: '${summary.weeklyXp}',
                  label: 'XP',
                  color: AppColors.accent,
                ),
                _SummaryStat(
                  icon: Icons.checklist_rounded,
                  value: '${summary.weeklyTasks}',
                  label: 'Tasks',
                  color: AppColors.success,
                ),
                _SummaryStat(
                  icon: Icons.local_fire_department_rounded,
                  value: '${summary.currentStreak}',
                  label: 'Streak',
                  color: AppColors.warning,
                ),
                _SummaryStat(
                  icon: Icons.calendar_today_rounded,
                  value: '${summary.activeDays}',
                  label: 'Aktiv',
                  color: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: AppRadius.borderRadiusSm,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
