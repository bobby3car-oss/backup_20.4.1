import 'package:flutter/material.dart';

import '../../../domain/timeline_engine.dart';
import '../../../ui/ui.dart';
import '../home_view_model.dart';

/// Compact timeline section showing today's tasks with a clean list.
/// No heavy hero header – just a tight section header + task rows + footer.
class HomeTimelineSection extends StatelessWidget {
  const HomeTimelineSection({
    super.key,
    required this.tasks,
    required this.onToggle,
    required this.onNavigate,
    required this.onShowAll,
    required this.onAddEntry,
  });

  final List<TimelineTask> tasks;
  final void Function(String id, TaskState state) onToggle;
  final void Function(String? routeKey, String id) onNavigate;
  final VoidCallback onShowAll;
  final VoidCallback onAddEntry;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final doneCount = tasks.where((t) => t.isDone).length;

    return GlassContainer(
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(20),
      variant: GlassVariant.medium,
      elevation: GlassElevation.medium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 14, 8),
            child: Row(
              children: [
                Icon(Icons.timeline_rounded, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Mein Plan',
                  style: tt.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                if (tasks.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: doneCount == tasks.length
                          ? AppColors.success.withValues(alpha: 0.12)
                          : AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$doneCount/${tasks.length}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: doneCount == tasks.length
                            ? AppColors.success
                            : AppColors.primary,
                      ),
                    ),
                  ),
                const SizedBox(width: 6),
                PressableScale(
                  onTap: onAddEntry,
                  scaleFactor: 0.90,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Task list ──
          if (tasks.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: 20,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Heute keine offenen Aufgaben',
                    style: tt.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          else
            for (var i = 0; i < tasks.length; i++) ...[
              _TaskRow(
                task: tasks[i],
                onToggle: () => onToggle(tasks[i].id, tasks[i].state),
                onTap: () => onNavigate(tasks[i].routeKey, tasks[i].id),
              ),
              if (i < tasks.length - 1)
                Padding(
                  padding: const EdgeInsets.only(left: 52, right: 16),
                  child: Divider(
                    height: 1,
                    color: AppColors.grey200.withValues(alpha: 0.4),
                  ),
                ),
            ],

          // ── Footer: "Gesamten Plan ansehen" ──
          PressableScale(
            onTap: onShowAll,
            scaleFactor: 0.97,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppColors.grey200.withValues(alpha: 0.5),
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.timeline_rounded, size: 14, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    'Gesamten Plan ansehen',
                    style: tt.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: AppColors.primary,
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

// ── Task row ─────────────────────────────────────────────────────────────────

class _TaskRow extends StatelessWidget {
  const _TaskRow({
    required this.task,
    required this.onToggle,
    required this.onTap,
  });

  final TimelineTask task;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDone = task.isDone;

    return PressableScale(
      onTap: onTap,
      scaleFactor: 0.988,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            // Toggle circle
            GestureDetector(
              onTap: () {
                Haptic.light();
                onToggle();
              },
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone
                        ? AppColors.success
                        : Colors.transparent,
                    border: isDone
                        ? null
                        : Border.all(
                            color: task.state == TaskState.due
                                ? AppColors.error
                                : AppColors.grey400,
                            width: 2,
                          ),
                  ),
                  child: isDone
                      ? const Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
            ),

            const SizedBox(width: 10),

            // Icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: task.iconColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(task.icon, size: 16, color: task.iconColor),
            ),

            const SizedBox(width: 10),

            // Title
            Expanded(
              child: Text(
                task.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDone
                      ? AppColors.textSecondary
                      : AppColors.textPrimary,
                  decoration: isDone ? TextDecoration.lineThrough : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // State indicator for due tasks
            if (task.state == TaskState.due) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Fällig',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.error,
                  ),
                ),
              ),
            ],

            const SizedBox(width: 4),

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
