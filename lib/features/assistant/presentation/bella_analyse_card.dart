import 'package:flutter/cupertino.dart';

import '../domain/bella_analyse.dart';
import '../../../ui/ui.dart';

/// Banner card showing the daily Bella AI analysis in the Timeline feed.
class BellaAnalyseCard extends StatelessWidget {
  const BellaAnalyseCard({super.key, required this.analyse});

  final BellaAnalyse analyse;

  static const _accent = Color(0xFF5856D6);

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      slideOffset: 4,
      duration: const Duration(milliseconds: 300),
      child: GlassContainer(
        padding: const EdgeInsets.all(AppSpacing.md),
        borderRadius: AppRadius.borderRadiusLg,
        color: _accent.withValues(alpha: 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ──
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _accent.withValues(alpha: 0.15),
                        _accent.withValues(alpha: 0.08),
                      ],
                    ),
                    borderRadius: AppRadius.borderRadiusSm,
                    border: Border.all(
                      color: _accent.withValues(alpha: 0.2),
                      width: 0.5,
                    ),
                  ),
                  child: const Center(
                    child: Text('🐰', style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bella Tagesanalyse',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _accent,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        _formattedDate(analyse.date),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs + 1,
                  ),
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.10),
                    borderRadius: AppRadius.borderRadiusPill,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.sparkles,
                        size: 12,
                        color: _accent,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'PRO',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: _accent,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.sm + 2),

            // ── Summary text ──
            Text(
              analyse.summary,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: AppSpacing.sm),

            // ── Metric pills ──
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                _MetricPill(
                  emoji: analyse.painTrend.emoji,
                  label: 'Schmerz ${analyse.painTrend.label.toLowerCase()}',
                ),
                if (analyse.vitalsNote != null)
                  const _MetricPill(emoji: '💓', label: 'Vitals'),
                if (analyse.openTaskCount > 0)
                  _MetricPill(
                    emoji: '📋',
                    label: '${analyse.openTaskCount} offen',
                  ),
              ],
            ),

            // ── Encouragement ──
            if (analyse.encouragement != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                analyse.encouragement!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                  color: _accent.withValues(alpha: 0.8),
                  height: 1.35,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formattedDate(String isoDate) {
    final parts = isoDate.split('-');
    if (parts.length != 3) return isoDate;
    return '${parts[2]}.${parts[1]}.${parts[0]}';
  }
}

// ── Small metric pill ─────────────────────────────────────────────────────────

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.emoji, required this.label});

  final String emoji;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs + 1,
      ),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: AppRadius.borderRadiusPill,
        border: Border.all(
          color: AppColors.grey200,
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
