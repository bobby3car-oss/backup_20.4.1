import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../features/doctor_patients/domain/linked_patient.dart';
import '../../../firebase/firebase_paths.dart';
import '../../../ui/ui.dart';

/// Aggregated statistics for the doctor's patient cohort.
class DoctorStatsData {
  const DoctorStatsData({
    this.totalPatients = 0,
    this.activeThisWeek = 0,
    this.avgPainLevel = 0,
    this.openRedFlags = 0,
    this.unansweredQuestions = 0,
    this.prevActiveThisWeek,
    this.prevAvgPainLevel,
    this.prevOpenRedFlags,
    this.prevUnansweredQuestions,
  });

  final int totalPatients;
  final int activeThisWeek;
  final double avgPainLevel;
  final int openRedFlags;
  final int unansweredQuestions;

  // Previous week for trend arrows (null = no data)
  final int? prevActiveThisWeek;
  final double? prevAvgPainLevel;
  final int? prevOpenRedFlags;
  final int? prevUnansweredQuestions;
}

/// Computes aggregated statistics from linked patients.
Future<DoctorStatsData> computeDoctorStats(
  List<LinkedPatient> patients,
  FirebaseFirestore firestore,
) async {
  final now = DateTime.now();
  final weekAgo = now.subtract(const Duration(days: 7));
  final twoWeeksAgo = now.subtract(const Duration(days: 14));

  int activeThisWeek = 0;
  int prevActiveThisWeek = 0;
  double painSum = 0;
  int painCount = 0;
  double prevPainSum = 0;
  int prevPainCount = 0;
  int openRedFlags = 0;
  int unansweredQuestions = 0;

  // Process patients in parallel batches to avoid N+1 query latency.
  const batchSize = 10;
  for (var i = 0; i < patients.length; i += batchSize) {
    final batch = patients.skip(i).take(batchSize);
    await Future.wait(batch.map((patient) async {
      // Active this week: had any entry in the last 7 days
      if (patient.lastEntryAt != null &&
          patient.lastEntryAt!.isAfter(weekAgo)) {
        activeThisWeek++;
      }
      // Active prev week
      if (patient.lastEntryAt != null &&
          patient.lastEntryAt!.isAfter(twoWeeksAgo) &&
          patient.lastEntryAt!.isBefore(weekAgo)) {
        prevActiveThisWeek++;
      }

      // Red flags from enriched data
      openRedFlags += patient.redFlagCount;

      // Fetch recent pain entries
      try {
        final painSnap = await firestore
            .collection(FirestorePaths.painCollection(patient.uid))
            .orderBy('occurredAt', descending: true)
            .limit(5)
            .get();
        for (final doc in painSnap.docs) {
          final data = doc.data();
          final level = (data['painLevel'] as num?)?.toDouble() ?? 0;
          final occurredAt =
              DateTime.tryParse(data['occurredAt']?.toString() ?? '');
          if (occurredAt != null && occurredAt.isAfter(weekAgo)) {
            painSum += level;
            painCount++;
          } else if (occurredAt != null &&
              occurredAt.isAfter(twoWeeksAgo) &&
              occurredAt.isBefore(weekAgo)) {
            prevPainSum += level;
            prevPainCount++;
          }
        }
      } catch (_) {}

      // Fetch unanswered questions
      try {
        final qSnap = await firestore
            .collection(FirestorePaths.questionsCollection(patient.uid))
            .where('status', whereIn: ['open', 'asked'])
            .get();
        unansweredQuestions += qSnap.docs.length;
      } catch (_) {}
    }));
  }

  return DoctorStatsData(
    totalPatients: patients.length,
    activeThisWeek: activeThisWeek,
    avgPainLevel: painCount > 0 ? painSum / painCount : 0,
    openRedFlags: openRedFlags,
    unansweredQuestions: unansweredQuestions,
    prevActiveThisWeek: prevActiveThisWeek,
    prevAvgPainLevel: prevPainCount > 0 ? prevPainSum / prevPainCount : null,
    prevOpenRedFlags: null, // Would need historical data
    prevUnansweredQuestions: null,
  );
}

/// Displays aggregated statistics cards at the top of the doctor overview.
class DoctorStatsCard extends StatelessWidget {
  const DoctorStatsCard({super.key, required this.stats});

  final DoctorStatsData stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.analytics_rounded, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Statistik-Übersicht',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _MiniStatCard(
                icon: Icons.people_rounded,
                label: 'Aktiv diese Woche',
                value: '${stats.activeThisWeek}',
                subtitle: 'von ${stats.totalPatients}',
                color: AppColors.primary,
                trend: _trendInt(
                    stats.activeThisWeek, stats.prevActiveThisWeek),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _MiniStatCard(
                icon: Icons.thermostat_rounded,
                label: 'Ø Schmerzlevel',
                value: stats.avgPainLevel.toStringAsFixed(1),
                subtitle: 'von 10',
                color: _painColor(stats.avgPainLevel),
                trend:
                    _trendDouble(stats.avgPainLevel, stats.prevAvgPainLevel),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _MiniStatCard(
                icon: Icons.flag_rounded,
                label: 'Offene Red Flags',
                value: '${stats.openRedFlags}',
                color: stats.openRedFlags > 0
                    ? AppColors.error
                    : AppColors.success,
                trend: null,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _MiniStatCard(
                icon: Icons.question_answer_rounded,
                label: 'Offene Fragen',
                value: '${stats.unansweredQuestions}',
                color: stats.unansweredQuestions > 0
                    ? AppColors.warning
                    : AppColors.success,
                trend: null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  static Color _painColor(double level) {
    if (level >= 7) return AppColors.error;
    if (level >= 4) return AppColors.warning;
    return AppColors.success;
  }

  static _Trend? _trendInt(int current, int? previous) {
    if (previous == null) return null;
    if (current > previous) return _Trend.up;
    if (current < previous) return _Trend.down;
    return _Trend.stable;
  }

  static _Trend? _trendDouble(double current, double? previous) {
    if (previous == null) return null;
    final diff = current - previous;
    if (diff > 0.3) return _Trend.up;
    if (diff < -0.3) return _Trend.down;
    return _Trend.stable;
  }
}

enum _Trend { up, down, stable }

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.subtitle,
    this.trend,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;
  final Color color;
  final _Trend? trend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const Spacer(),
              if (trend != null) _TrendArrow(trend: trend!, color: color),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              TweenAnimationBuilder<int>(
                tween: IntTween(
                    begin: 0,
                    end: int.tryParse(value) ?? 0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (_, val, _) {
                  // If value has a decimal, show it properly
                  final hasDecimal = value.contains('.');
                  return Text(
                    hasDecimal ? value : '$val',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  );
                },
              ),
              if (subtitle != null) ...[
                const SizedBox(width: 4),
                Text(
                  subtitle!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _TrendArrow extends StatelessWidget {
  const _TrendArrow({required this.trend, required this.color});

  final _Trend trend;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final (icon, trendColor) = switch (trend) {
      _Trend.up => (Icons.trending_up_rounded, AppColors.error),
      _Trend.down => (Icons.trending_down_rounded, AppColors.success),
      _Trend.stable => (Icons.trending_flat_rounded, AppColors.textSecondary),
    };

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: trendColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, size: 14, color: trendColor),
    );
  }
}
