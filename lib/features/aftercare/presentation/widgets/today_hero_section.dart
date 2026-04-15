import 'package:flutter/material.dart';

import '../../../../ui/ui.dart';
import '../../domain/aftercare_item.dart';
import '../../domain/aftercare_item_category.dart';
import '../../domain/aftercare_item_progress.dart';
import '../../domain/aftercare_phase.dart';
import '../../domain/patient_aftercare_plan.dart';
import '../../domain/plan_status.dart';
import 'confetti_burst.dart';

/// Hero section showing today's tasks with interactive checkboxes.
///
/// Computes "today" by comparing [DateTime.now()] against the plan's
/// surgery date + each item's [startDayOffset] / [endDayOffset].
class TodayHeroSection extends StatelessWidget {
  const TodayHeroSection({
    super.key,
    required this.plan,
    required this.progress,
    required this.onToggleItem,
    this.confettiKey,
  });

  final PatientAftercarePlan plan;
  final AftercareItemProgress progress;
  final Future<void> Function(AftercareItem item, bool wasCompleted)
      onToggleItem;
  final GlobalKey<ConfettiBurstState>? confettiKey;

  static const _criticalCategories = {
    AftercareItemCategory.wound,
    AftercareItemCategory.dressing,
    AftercareItemCategory.sutureRemoval,
    AftercareItemCategory.medication,
  };

  @override
  Widget build(BuildContext context) {
    final daysSinceSurgery =
        DateTime.now().difference(plan.surgeryDate).inDays;

    // Before surgery — show pre-op message.
    if (daysSinceSurgery < 0) {
      return _buildPreOpCard(context);
    }

    // Collect today's items across all phases.
    final todayItems = <_TodayItem>[];
    for (final phase in plan.phases) {
      for (final item in phase.items) {
        if (_isItemForToday(item, phase, daysSinceSurgery)) {
          todayItems.add(_TodayItem(
            item: item,
            isCompleted: progress.isCompleted(item.id),
            isPendingSync: progress.pendingItemIds.contains(item.id),
          ));
        }
      }
    }

    todayItems.sort((a, b) {
      int rank(_TodayItem t) {
        final isCritical = _criticalCategories.contains(t.item.category);
        if (!t.isCompleted && isCritical) return 0;
        if (!t.isCompleted) return 1;
        return 2;
      }

      final byRank = rank(a).compareTo(rank(b));
      if (byRank != 0) return byRank;
      return a.item.order.compareTo(b.item.order);
    });

    if (todayItems.isEmpty) {
      return _buildNoTasksCard(context);
    }

    final completedCount = todayItems.where((t) => t.isCompleted).length;
    final openCount = todayItems.length - completedCount;
    final criticalOpenCount = todayItems
        .where((t) =>
            !t.isCompleted && _criticalCategories.contains(t.item.category))
        .length;
    final hasPendingSync = todayItems.any((t) => t.isPendingSync);
    final hasCriticalToday =
        todayItems.any((t) => _criticalCategories.contains(t.item.category));
    final totalCount = todayItems.length;
    final allDone = completedCount == totalCount;
    final fraction = totalCount > 0 ? completedCount / totalCount : 0.0;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.today_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Heute',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const Spacer(),
              Text(
                '$completedCount von $totalCount ✓',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color:
                          allDone ? AppColors.success : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxs),
          Row(
            children: [
              _StatePill(
                label: '$openCount offen',
                color: AppColors.textSecondary,
                icon: Icons.schedule_rounded,
              ),
              const SizedBox(width: AppSpacing.xs),
              if (criticalOpenCount > 0)
                _StatePill(
                  label: '$criticalOpenCount kritisch',
                  color: AppColors.warning,
                  icon: Icons.warning_amber_rounded,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          GlassProgressBar(
            value: fraction,
            height: 4,
            gradient: const LinearGradient(
              colors: [Color(0xFF007AFF), Color(0xFF34C759)],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Items
          for (final todayItem in todayItems)
            _TodayItemTile(
              todayItem: todayItem,
              onToggle: () =>
                  onToggleItem(todayItem.item, todayItem.isCompleted),
              isPlanActive: plan.status == PlanStatus.active,
            ),

          if (hasPendingSync) ...[
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Icon(Icons.sync_rounded,
                    size: 13, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Aenderungen werden synchronisiert, sobald eine Verbindung besteht.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                  ),
                ),
              ],
            ),
          ],

          // All done message
          if (allDone) ...[
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: hasCriticalToday
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.task_alt_rounded,
                            size: 18, color: AppColors.success),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'Alles fuer heute erledigt',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    )
                  : ConfettiBurst(
                      key: confettiKey,
                      child: Text(
                        'Alles geschafft! 🎉',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
              ),
          ],
        ],
      ),
    );
  }

  bool _isItemForToday(
      AftercareItem item, AftercarePhase phase, int daysSinceSurgery) {
    // 1. exactDate takes priority
    if (item.exactDate != null) {
      final now = DateTime.now();
      return item.exactDate!.year == now.year &&
          item.exactDate!.month == now.month &&
          item.exactDate!.day == now.day;
    }

    // 2. Item-level day offset (absolute from surgery)
    if (item.startDayOffset != null) {
      final effectiveEnd = item.endDayOffset ?? item.startDayOffset!;
      return daysSinceSurgery >= item.startDayOffset! &&
          daysSinceSurgery <= effectiveEnd;
    }

    // 3. Fall back to phase offset for time-bound items
    if (item.isTimeBound) {
      final effectiveEnd = phase.endDayOffset ?? phase.startDayOffset;
      return daysSinceSurgery >= phase.startDayOffset &&
          daysSinceSurgery <= effectiveEnd;
    }

    return false;
  }

  Widget _buildPreOpCard(BuildContext context) {
    final fmt =
        '${plan.surgeryDate.day.toString().padLeft(2, '0')}.${plan.surgeryDate.month.toString().padLeft(2, '0')}.${plan.surgeryDate.year}';
    return GlassCard(
      child: Column(
        children: [
          Icon(Icons.event_rounded, size: 32, color: AppColors.primary),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Dein Plan startet am $fmt',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'Gute Besserung!',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.grey500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoTasksCard(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.today_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Heute',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Icon(Icons.event_available_rounded,
              size: 28, color: AppColors.grey400),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Heute keine Aufgaben.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          Text(
            'Genieße deinen Tag!',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.grey500,
                ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _TodayItemTile extends StatelessWidget {
  const _TodayItemTile({
    required this.todayItem,
    required this.onToggle,
    required this.isPlanActive,
  });

  final _TodayItem todayItem;
  final Future<void> Function() onToggle;
  final bool isPlanActive;

  static const _criticalCategories = {
    AftercareItemCategory.wound,
    AftercareItemCategory.dressing,
    AftercareItemCategory.sutureRemoval,
    AftercareItemCategory.medication,
  };

  @override
  Widget build(BuildContext context) {
    final item = todayItem.item;
    final done = todayItem.isCompleted;
    final isCritical = _criticalCategories.contains(item.category);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      decoration: isCritical && !done
          ? BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: AppColors.warning.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
            )
          : null,
      child: Opacity(
        opacity: done ? 0.6 : 1.0,
        child: Padding(
          padding: EdgeInsets.only(
            left: isCritical && !done ? AppSpacing.sm : 0,
            top: AppSpacing.xxs,
            bottom: AppSpacing.xxs,
          ),
          child: Row(
            children: [
              AnimatedCheckbox(
                value: done,
                onChanged: isPlanActive
                    ? (_) async {
                        if (isCritical) {
                          Haptic.selection();
                        } else {
                          Haptic.light();
                        }
                        await onToggle();
                      }
                    : null,
                size: 22,
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                item.category.icon,
                size: 14,
                color: isCritical && !done
                    ? AppColors.warning
                    : done
                        ? AppColors.grey400
                        : AppColors.grey500,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  item.title.isNotEmpty ? item.title : item.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        decoration:
                            done ? TextDecoration.lineThrough : null,
                        decorationColor:
                            AppColors.textSecondary.withValues(alpha: 0.6),
                        color: done
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                        fontWeight: done ? FontWeight.w400 : FontWeight.w500,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              _StatePill(
                label: todayItem.isPendingSync
                    ? 'Sync...'
                    : done
                    ? 'Erledigt'
                    : isCritical
                    ? 'Kritisch'
                    : 'Offen',
                color: todayItem.isPendingSync
                  ? AppColors.accent
                    : done
                    ? AppColors.success
                    : isCritical
                    ? AppColors.warning
                    : AppColors.textSecondary,
                icon: todayItem.isPendingSync
                    ? Icons.sync_rounded
                    : done
                    ? Icons.check_rounded
                    : isCritical
                    ? Icons.priority_high_rounded
                    : Icons.radio_button_unchecked_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatePill extends StatelessWidget {
  const _StatePill({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.borderRadiusXs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _TodayItem {
  const _TodayItem({
    required this.item,
    required this.isCompleted,
    this.isPendingSync = false,
  });
  final AftercareItem item;
  final bool isCompleted;
  final bool isPendingSync;
}
