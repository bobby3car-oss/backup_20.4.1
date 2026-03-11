import 'package:flutter/material.dart';

import '../../../../ui/ui.dart';
import '../../domain/rehab_session.dart';
import '../../../../ui/theme/app_icons.dart';

/// Banner showing session statistics: total sessions, total minutes, streak.
class RehabStatsBanner extends StatelessWidget {
  const RehabStatsBanner({super.key, required this.sessions});

  final List<RehabSession> sessions;

  @override
  Widget build(BuildContext context) {
    final totalSessions = sessions.length;
    final totalMinutes = sessions.fold<int>(
      0,
      (sum, s) => sum + s.totalDurationSeconds,
    ) ~/ 60;
    final streak = _calculateStreak(sessions);

    return GlassCard(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(icon: AppIcons.calories,
                    iconColor: AppIcons.caloriesColor, value: '$streak', label: 'Tage-Streak'),
            _StatItem(icon: AppIcons.done, iconColor: AppIcons.doneColor, value: '$totalSessions', label: 'Sessions'),
            _StatItem(icon: AppIcons.timer, iconColor: AppIcons.timerColor, value: '${totalMinutes}m', label: 'Gesamt'),
          ],
        ),
      ),
    );
  }

  int _calculateStreak(List<RehabSession> sessions) {
    if (sessions.isEmpty) return 0;

    // Get unique dates (sorted descending).
    final dates = sessions
        .map((s) => DateTime(
              s.completedAt.year,
              s.completedAt.month,
              s.completedAt.day,
            ))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    // Streak must start from today or yesterday.
    if (dates.first.difference(todayDate).inDays.abs() > 1) return 0;

    int streak = 1;
    for (int i = 1; i < dates.length; i++) {
      final diff = dates[i - 1].difference(dates[i]).inDays;
      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;


  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GlassIcon(icon: icon, color: iconColor, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
