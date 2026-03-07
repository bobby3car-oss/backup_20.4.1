import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../home_view_model.dart';

// ── Sticky timeline header delegate ──────────────────────────────────────────

class StickyTimelineHeaderDelegate extends SliverPersistentHeaderDelegate {
  StickyTimelineHeaderDelegate({
    required this.summary,
    required this.onNewEntry,
  });

  final TimelineHeaderSummary summary;
  final VoidCallback onNewEntry;

  static const double _maxHeight = 136.0;
  static const double _minHeight = 120.0;

  @override
  double get maxExtent => _maxHeight;

  @override
  double get minExtent => _minHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final pinProgress = (shrinkOffset / (maxExtent - minExtent)).clamp(
      0.0,
      1.0,
    );
    return _StickyTimelineHeader(
      summary: summary,
      pinProgress: pinProgress,
      overlapsContent: overlapsContent,
      onNewEntry: onNewEntry,
    );
  }

  @override
  bool shouldRebuild(covariant StickyTimelineHeaderDelegate old) => true;
}

// ── Sticky header content ────────────────────────────────────────────────────

class _StickyTimelineHeader extends StatelessWidget {
  const _StickyTimelineHeader({
    required this.summary,
    required this.pinProgress,
    required this.overlapsContent,
    required this.onNewEntry,
  });

  final TimelineHeaderSummary summary;
  final double pinProgress;
  final bool overlapsContent;
  final VoidCallback onNewEntry;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cardRadius = BorderRadius.circular(26);
    final topPadding =
        AppSpacing.md - ((AppSpacing.md - AppSpacing.sm) * pinProgress);
    final bottomPadding =
        AppSpacing.md - ((AppSpacing.md - AppSpacing.xs) * pinProgress);
    final horizontalPadding =
        AppSpacing.lg - ((AppSpacing.lg - AppSpacing.md) * pinProgress);
    final titleStyle = (pinProgress > 0.55 ? tt.titleLarge : tt.headlineMedium)
        ?.copyWith(
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          letterSpacing: -0.35,
        );

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.background.withValues(
              alpha: overlapsContent ? 0.98 : 0.78,
            ),
            AppColors.background.withValues(alpha: 0.94),
          ],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          topPadding,
          AppSpacing.lg,
          bottomPadding,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          child: GlassContainer(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: AppSpacing.md,
            ),
            borderRadius: cardRadius,
            variant:
                overlapsContent ? GlassVariant.medium : GlassVariant.thin,
            elevation:
                overlapsContent ? GlassElevation.medium : GlassElevation.low,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.18 + (pinProgress * 0.10),
                                  ),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                  spreadRadius: -6,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.timeline_rounded,
                              size: 18,
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Timeline', style: titleStyle),
                                const SizedBox(height: 2),
                                Text(
                                  '${summary.progressPercent}% abgeschlossen · ${summary.doneCount}/${summary.totalCount} erledigt',
                                  style: tt.labelMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        summary.focusLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tt.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            _TimelineHeaderChip(
                              icon: Icons.today_rounded,
                              label: '${summary.todayCount} heute',
                              tint: AppColors.primary,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            _TimelineHeaderChip(
                              icon: summary.dueCount > 0
                                  ? Icons.priority_high_rounded
                                  : Icons.check_circle_outline_rounded,
                              label: summary.dueCount > 0
                                  ? '${summary.dueCount} faellig'
                                  : 'im Plan',
                              tint: summary.dueCount > 0
                                  ? AppColors.error
                                  : AppColors.success,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            _TimelineHeaderChip(
                              icon: Icons.layers_outlined,
                              label: '${summary.openCount} offen',
                              tint: AppColors.warning,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: GlassButton(
                    onPressed: onNewEntry,
                    label: 'Neu',
                    icon: Icons.add_rounded,
                    variant: GlassButtonVariant.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Header chip ──────────────────────────────────────────────────────────────

class _TimelineHeaderChip extends StatelessWidget {
  const _TimelineHeaderChip({
    required this.icon,
    required this.label,
    required this.tint,
  });

  final IconData icon;
  final String label;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.08),
        borderRadius: AppRadius.borderRadiusPill,
        border: Border.all(color: tint.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: tint),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: tt.labelMedium?.copyWith(
              color: tint,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
