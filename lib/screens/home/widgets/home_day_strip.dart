import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../home_view_model.dart';

/// Horizontal scrollable day-chip strip showing ±3 days around today.
///
/// Each chip shows:
///  - Day label ("Gestern", "Morgen", "Mi. 12. Mär.")
///  - Progress fraction (e.g. "2/4")
///
/// Today is highlighted with primary gradient.
/// Past days with open tasks show an error-tinted chip.
class HomeDayStrip extends StatefulWidget {
  const HomeDayStrip({
    super.key,
    required this.sections,
    required this.todayDoneCount,
    required this.todayTotalCount,
    this.onTap,
  });

  final List<NearbyDaySection> sections;
  final int todayDoneCount;
  final int todayTotalCount;
  final VoidCallback? onTap;

  @override
  State<HomeDayStrip> createState() => _HomeDayStripState();
}

class _HomeDayStripState extends State<HomeDayStrip> {
  late ScrollController _scrollController;
  double _initialOffset = 0;

  @override
  void initState() {
    super.initState();
    _initialOffset = _computeOffset();
    _scrollController = ScrollController(initialScrollOffset: _initialOffset);
  }

  double _computeOffset() {
    final pastCount =
        widget.sections.where((s) => s.isPast).length;
    return pastCount > 1 ? (pastCount - 1) * 88.0 : 0;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.sections.isEmpty && widget.todayTotalCount == 0) return const SizedBox.shrink();

    // Build chips: sort by date, inject "Heute" at the right position.
    final allChips = <_DayChipData>[];

    // Past sections (date < today)
    final past = widget.sections.where((s) => s.isPast).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    for (final s in past) {
      allChips.add(_DayChipData(
        label: s.label,
        doneCount: s.doneCount,
        totalCount: s.totalCount,
        isToday: false,
        hasOverdue: s.tasks.any((t) => !t.isDone && !t.isSkipped),
      ));
    }

    // Today
    allChips.add(_DayChipData(
      label: 'Heute',
      doneCount: widget.todayDoneCount,
      totalCount: widget.todayTotalCount,
      isToday: true,
      hasOverdue: false,
    ));

    // Future sections (date > today)
    final future = widget.sections.where((s) => !s.isPast).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    for (final s in future) {
      allChips.add(_DayChipData(
        label: s.label,
        doneCount: s.doneCount,
        totalCount: s.totalCount,
        isToday: false,
        hasOverdue: false,
      ));
    }

    // Find the index of "Heute" to use as initial scroll anchor.
    final todayIndex = allChips.indexWhere((c) => c.isToday);
    // Don't recreate controller – just use the one from initState.
    // If sections changed significantly, jump to today.
    if (_scrollController.hasClients && todayIndex > 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final target = (todayIndex - 1) * 88.0;
        if ((_scrollController.offset - target).abs() > 200) {
          _scrollController.jumpTo(target);
        }
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Row(
            children: [
              Icon(Icons.date_range_rounded, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                'Wochenüberblick',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              PressableScale(
                onTap: widget.onTap,
                scaleFactor: 0.95,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Gesamter Plan',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(Icons.chevron_right_rounded,
                        size: 16, color: AppColors.primary),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Horizontal chip scroll
        SizedBox(
          height: 76,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.zero,
            controller: _scrollController,
            itemCount: allChips.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final chip = allChips[index];
              return _DayChip(
                data: chip,
                onTap: widget.onTap,
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Data model ───────────────────────────────────────────────────────────────

class _DayChipData {
  const _DayChipData({
    required this.label,
    required this.doneCount,
    required this.totalCount,
    required this.isToday,
    required this.hasOverdue,
  });

  final String label;
  final int doneCount;
  final int totalCount;
  final bool isToday;
  final bool hasOverdue;

  bool get allDone => totalCount > 0 && doneCount == totalCount;
}

// ── Day chip widget ──────────────────────────────────────────────────────────

class _DayChip extends StatelessWidget {
  const _DayChip({required this.data, this.onTap});

  final _DayChipData data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isToday = data.isToday;
    final hasOverdue = data.hasOverdue;
    final allDone = data.allDone;

    // Color scheme
    final Color bgColor;
    final Color textColor;
    final Color badgeColor;
    final Color badgeTextColor;

    if (isToday) {
      bgColor = AppColors.primary;
      textColor = AppColors.white;
      badgeColor = AppColors.white.withValues(alpha: 0.25);
      badgeTextColor = AppColors.white;
    } else if (hasOverdue) {
      bgColor = AppColors.error.withValues(alpha: 0.08);
      textColor = AppColors.error;
      badgeColor = AppColors.error.withValues(alpha: 0.12);
      badgeTextColor = AppColors.error;
    } else if (allDone) {
      bgColor = AppColors.success.withValues(alpha: 0.08);
      textColor = AppColors.success;
      badgeColor = AppColors.success.withValues(alpha: 0.12);
      badgeTextColor = AppColors.success;
    } else {
      bgColor = AppColors.grey100;
      textColor = AppColors.textPrimary;
      badgeColor = AppColors.textSecondary.withValues(alpha: 0.10);
      badgeTextColor = AppColors.textSecondary;
    }

    return PressableScale(
      onTap: onTap,
      scaleFactor: 0.95,
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isToday ? null : bgColor,
          gradient: isToday ? AppColors.primaryGradient : null,
          borderRadius: BorderRadius.circular(16),
          border: isToday
              ? null
              : Border.all(
                  color: hasOverdue
                      ? AppColors.error.withValues(alpha: 0.2)
                      : AppColors.grey200.withValues(alpha: 0.6),
                  width: 0.5,
                ),
          boxShadow: isToday
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Day label
            Text(
              data.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                color: textColor,
                letterSpacing: -0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),

            // Progress badge
            if (data.totalCount > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${data.doneCount}/${data.totalCount}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: badgeTextColor,
                  ),
                ),
              ),


          ],
        ),
      ),
    );
  }
}
