import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../../pain/data/pain_repository_sync.dart';
import '../../pain/domain/pain_entry.dart';
import '../data/sleep_repository_sync.dart';
import '../domain/sleep_entry.dart';
import '../../../l10n/app_localizations.dart';

const _kNightPurple = Color(0xFF5C4D9A);
const _kNightAccent = Color(0xFF7C6FE0);
const _kNightSurface = Color(0x1A5C4D9A);
const _kNightBorder = Color(0x335C4D9A);
const _kStarYellow = Color(0xFFFFD700);

/// Analytics tab: averages, trend, correlation to pain scores.
class SleepAnalyticsTab extends StatelessWidget {
  const SleepAnalyticsTab({super.key, required this.repository});

  final SleepRepositorySync repository;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SleepEntry>>(
      stream: repository.watchAll(),
      builder: (context, snapshot) {
        final items = snapshot.data ?? [];
        if (items.isEmpty) return _buildEmptyState(context);

        // Last 30 days.
        final now = DateTime.now();
        final cutoff = now.subtract(const Duration(days: 30));
        final recent = items.where((e) => e.bedTime.isAfter(cutoff)).toList();

        return Column(
          children: [
            _SummaryCard(items: recent),
            const SizedBox(height: AppSpacing.md),
            _TrendCard(items: recent),
            const SizedBox(height: AppSpacing.md),
            _PainCorrelationCard(sleepItems: recent),
            const SizedBox(height: AppSpacing.xxl),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
      child: Column(
        children: [
          Icon(
            CupertinoIcons.chart_bar_fill,
            size: 48,
            color: _kNightPurple.withValues(alpha: 0.3),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Noch keine Daten für Analyse',
            style: tt.titleMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Erfasse Schlafeinträge, um Trends zu sehen.',
            style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Summary card
// ═════════════════════════════════════════════════════════════════════════════

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.items});
  final List<SleepEntry> items;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final tt = Theme.of(context).textTheme;
    if (items.isEmpty) return const SizedBox.shrink();

    final avgMin =
        items.fold<int>(0, (s, e) => s + e.durationMinutes) / items.length;
    final avgH = avgMin ~/ 60;
    final avgM = (avgMin % 60).round();

    final avgQuality =
        items.fold<int>(0, (s, e) => s + e.quality.value) / items.length;

    final avgDisturbances =
        items.fold<int>(0, (s, e) => s + e.disturbances) / items.length;

    final totalNights = items.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: _kNightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kNightBorder),
      ),
      child: Column(
        children: [
          Text(
            'Durchschnitt (letzte 30 Tage)',
            style: tt.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: _kNightPurple,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                icon: CupertinoIcons.timer,
                label: 'Schlafdauer',
                value: '${avgH}h ${avgM}m',
              ),
              _StatItem(
                icon: CupertinoIcons.star_fill,
                label: l.qualitaet,
                value: avgQuality.toStringAsFixed(1),
                valueColor: _kStarYellow,
              ),
              _StatItem(
                icon: CupertinoIcons.exclamationmark_circle,
                label: l.stoerungen,
                value: avgDisturbances.toStringAsFixed(1),
              ),
              _StatItem(
                icon: CupertinoIcons.moon_fill,
                label: l.naechte,
                value: '$totalNights',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Trend card (last 7 entries)
// ═════════════════════════════════════════════════════════════════════════════

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.items});
  final List<SleepEntry> items;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    if (items.length < 2) {
      final l = AppLocalizations.of(context)!;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: _kNightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _kNightBorder),
        ),
        child: Text(
          l.mindestens2EintraegeFuerTrendanalyseBenoetigt,
          style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      );
    }

    // Last 7 entries sorted chronologically.
    final sorted = List<SleepEntry>.from(items)
      ..sort((a, b) => a.bedTime.compareTo(b.bedTime));
    final last7 = sorted.length > 7
        ? sorted.sublist(sorted.length - 7)
        : sorted;

    // Trend: compare first half vs second half.
    final mid = last7.length ~/ 2;
    final firstHalf = last7.sublist(0, mid);
    final secondHalf = last7.sublist(mid);

    final avgFirst = firstHalf.fold<double>(
            0, (s, e) => s + e.durationMinutes) /
        firstHalf.length;
    final avgSecond = secondHalf.fold<double>(
            0, (s, e) => s + e.durationMinutes) /
        secondHalf.length;

    final diff = avgSecond - avgFirst;
    final trendUp = diff > 15;
    final trendDown = diff < -15;

    String trendLabel;
    IconData trendIcon;
    Color trendColor;
    if (trendUp) {
      trendLabel = 'Schlaf verbessert sich';
      trendIcon = CupertinoIcons.arrow_up_circle_fill;
      trendColor = AppColors.success;
    } else if (trendDown) {
      trendLabel = 'Schlaf verschlechtert sich';
      trendIcon = CupertinoIcons.arrow_down_circle_fill;
      trendColor = AppColors.warning;
    } else {
      trendLabel = 'Schlaf stabil';
      trendIcon = CupertinoIcons.equal_circle_fill;
      trendColor = _kNightAccent;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: _kNightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kNightBorder),
      ),
      child: Column(
        children: [
          Text(
            'Trend',
            style: tt.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: _kNightPurple,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(trendIcon, size: 24, color: trendColor),
              const SizedBox(width: AppSpacing.sm),
              Text(
                trendLabel,
                style: tt.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: trendColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Mini sparkline.
          SizedBox(
            height: 60,
            child: CustomPaint(
              size: const Size(double.infinity, 60),
              painter: _SparklinePainter(
                values: last7
                    .map((e) => e.durationMinutes / 60.0)
                    .toList(),
                color: _kNightAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Pain correlation card
// ═════════════════════════════════════════════════════════════════════════════

class _PainCorrelationCard extends StatelessWidget {
  const _PainCorrelationCard({required this.sleepItems});
  final List<SleepEntry> sleepItems;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return StreamBuilder<List<PainEntry>>(
      stream: PainRepositorySync.instance.watchAll(),
      builder: (context, painSnap) {
        final l = AppLocalizations.of(context)!;
        final painItems = painSnap.data ?? [];
        if (painItems.isEmpty || sleepItems.length < 3) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: _kNightSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _kNightBorder),
            ),
            child: Column(
              children: [
                Text(
                  'Schlaf-Schmerz-Korrelation',
                  style: tt.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _kNightPurple,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Mehr Schlaf- und Schmerzeinträge benötigt für Korrelationsanalyse.',
                  style: tt.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // Match sleep entries with same-day pain entries.
        final pairs = <({double sleepH, int painLevel})>[];
        for (final sleep in sleepItems) {
          final wakeDate = DateTime(
            sleep.wakeTime.year,
            sleep.wakeTime.month,
            sleep.wakeTime.day,
          );
          final dayPain = painItems.where((p) {
            final pd = DateTime(
              p.occurredAt.year,
              p.occurredAt.month,
              p.occurredAt.day,
            );
            return pd == wakeDate;
          });
          if (dayPain.isNotEmpty) {
            final avgPain = dayPain.fold<int>(0, (s, p) => s + p.painLevel) /
                dayPain.length;
            pairs.add((
              sleepH: sleep.durationMinutes / 60.0,
              painLevel: avgPain.round(),
            ));
          }
        }

        String insight;
        if (pairs.length < 3) {
          insight =
              l.nochNichtGenugGemeinsameTageFuerEineKorrelation;
        } else {
          // Simple: compare avg pain on good sleep vs poor sleep days.
          final sorted = List.of(pairs)
            ..sort((a, b) => a.sleepH.compareTo(b.sleepH));
          final bottom = sorted.sublist(0, (sorted.length / 3).ceil());
          final top = sorted.sublist(
              sorted.length - (sorted.length / 3).ceil());

          final avgPainLowSleep =
              bottom.fold<int>(0, (s, p) => s + p.painLevel) / bottom.length;
          final avgPainHighSleep =
              top.fold<int>(0, (s, p) => s + p.painLevel) / top.length;

          if (avgPainLowSleep > avgPainHighSleep + 0.5) {
            insight =
                'Weniger Schlaf (Ø ${_fmt(bottom.map((p) => p.sleepH).reduce((a, b) => a + b) / bottom.length)}h) korreliert mit höherem Schmerzlevel (Ø ${avgPainLowSleep.toStringAsFixed(1)}) verglichen mit besseren Nächten (Ø ${avgPainHighSleep.toStringAsFixed(1)}).';
          } else {
            insight =
                'Kein deutlicher Zusammenhang zwischen Schlafdauer und Schmerzlevel erkennbar (${pairs.length} gemeinsame Tage analysiert).';
          }
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: _kNightSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _kNightBorder),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(CupertinoIcons.moon_fill,
                      size: 18, color: _kNightPurple),
                  const SizedBox(width: 6),
                  Text(
                    'Schlaf-Schmerz-Korrelation',
                    style: tt.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _kNightPurple,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(CupertinoIcons.waveform_path_ecg,
                      size: 18, color: AppColors.error),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                insight,
                style: tt.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  String _fmt(double v) => v.toStringAsFixed(1);
}

// ═════════════════════════════════════════════════════════════════════════════
// Shared
// ═════════════════════════════════════════════════════════════════════════════

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      children: [
        Icon(icon, size: 20, color: _kNightPurple),
        const SizedBox(height: 4),
        Text(
          value,
          style: tt.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: valueColor ?? _kNightPurple,
          ),
        ),
        Text(
          label,
          style: tt.labelSmall?.copyWith(
            color: AppColors.textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.values, required this.color});
  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final minV = values.reduce(math.min);
    final maxV = values.reduce(math.max);
    final range = maxV - minV;
    if (range == 0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();
    final step = size.width / (values.length - 1);

    for (var i = 0; i < values.length; i++) {
      final x = i * step;
      final y = size.height - ((values[i] - minV) / range * size.height);
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Dots.
    final dotPaint = Paint()..color = color;
    for (var i = 0; i < values.length; i++) {
      final x = i * step;
      final y = size.height - ((values[i] - minV) / range * size.height);
      canvas.drawCircle(Offset(x, y), 3.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter old) =>
      values != old.values || color != old.color;
}
