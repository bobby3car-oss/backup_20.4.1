import 'package:flutter/material.dart';

import '../../../domain/timeline_engine.dart';
import '../../../ui/ui.dart';
import '../home_view_model.dart';

/// Compact list of today's tasks (max 5).
class TodayTasksCard extends StatelessWidget {
  const TodayTasksCard({
    super.key,
    required this.tasks,
    required this.onToggle,
    required this.onNavigate,
    required this.onShowAll,
  });

  final List<TimelineTask> tasks;
  final void Function(String id, TaskState state) onToggle;
  final void Function(String? routeKey, String id) onNavigate;
  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    if (tasks.isEmpty) {
      return GlassContainer(
        padding: const EdgeInsets.all(20),
        borderRadius: BorderRadius.circular(20),
        variant: GlassVariant.thin,
        elevation: GlassElevation.low,
        child: Row(
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              size: 24,
              color: AppColors.success,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Heute keine offenen Aufgaben',
                style: tt.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return GlassContainer(
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(20),
      variant: GlassVariant.thin,
      elevation: GlassElevation.low,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
            child: Row(
              children: [
                Icon(
                  Icons.today_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Heutige Aufgaben',
                  style: tt.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                _CompactBadge(
                  done: tasks.where((t) => t.isDone).length,
                  total: tasks.length,
                ),
              ],
            ),
          ),

          // ── Task rows ───────────────────────────────────────
          for (var i = 0; i < tasks.length; i++) ...[
            _TodayTaskRow(
              task: tasks[i],
              onToggle: () => onToggle(tasks[i].id, tasks[i].state),
              onTap: () => onNavigate(tasks[i].routeKey, tasks[i].id),
            ),
            if (i < tasks.length - 1)
              Padding(
                padding: const EdgeInsets.only(left: 54, right: 16),
                child: Divider(
                  height: 1,
                  color: AppColors.grey200.withValues(alpha: 0.5),
                ),
              ),
          ],

          // ── Footer link ─────────────────────────────────────
          PressableScale(
            onTap: onShowAll,
            scaleFactor: 0.97,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.list_alt_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Gesamten Plan ansehen',
                    style: tt.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Single task row ──────────────────────────────────────────────────────────

class _TodayTaskRow extends StatelessWidget {
  const _TodayTaskRow({
    required this.task,
    required this.onToggle,
    required this.onTap,
  });

  final TimelineTask task;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isFinalized = task.isDone || task.isSkipped;

    return PressableScale(
      onTap: onTap,
      scaleFactor: 0.988,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            // Toggle circle
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Haptic.light();
                onToggle();
              },
              child: SizedBox(
                width: 32,
                height: 32,
                child: Center(child: _StateCircle(state: task.state)),
              ),
            ),
            const SizedBox(width: 10),

            // Icon
            GlassIcon(icon: task.icon, color: task.iconColor, size: 16),
            const SizedBox(width: 10),

            // Title
            Expanded(
              child: Text(
                task.title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isFinalized ? FontWeight.w400 : FontWeight.w600,
                  color: isFinalized
                      ? AppColors.textSecondary
                      : AppColors.textPrimary,
                  decoration: isFinalized ? TextDecoration.lineThrough : null,
                  decorationColor:
                      AppColors.textSecondary.withValues(alpha: 0.6),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Chevron
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.grey400,
            ),
          ],
        ),
      ),
    );
  }
}

// ── State circle ─────────────────────────────────────────────────────────────

class _StateCircle extends StatelessWidget {
  const _StateCircle({required this.state});

  final TaskState state;

  @override
  Widget build(BuildContext context) {
    const size = 24.0;

    switch (state) {
      case TaskState.done:
        return Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF16A34A), Color(0xFF34D399)],
            ),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, size: 14, color: Colors.white),
        );
      case TaskState.skipped:
        return Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: AppColors.grey400,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.remove_rounded, size: 14, color: Colors.white),
        );
      case TaskState.due:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.error, width: 2),
          ),
          child: Center(
            child: Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      case TaskState.inProgress:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.warning, width: 2),
          ),
          child: Center(
            child: Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: AppColors.warning,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      case TaskState.planned:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.grey300, width: 1.5),
          ),
        );
    }
  }
}

// ── Compact badge ────────────────────────────────────────────────────────────

class _CompactBadge extends StatelessWidget {
  const _CompactBadge({required this.done, required this.total});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final allDone = done == total && total > 0;
    final color = allDone ? AppColors.success : AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$done/$total',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
