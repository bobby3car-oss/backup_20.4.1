import 'package:flutter/material.dart';

import '../../../domain/timeline_engine.dart';
import '../../../ui/ui.dart';
import '../home_view_model.dart';

// ── Day section ──────────────────────────────────────────────────────────────

class TimelineDaySection extends StatelessWidget {
  const TimelineDaySection({
    super.key,
    required this.section,
    required this.sectionIndex,
    required this.onDone,
    required this.onToggle,
    required this.onSkip,
    required this.onSnooze,
    required this.onNavigate,
  });

  final TimelineSection section;
  final int sectionIndex;
  final ValueChanged<int> onDone;
  final ValueChanged<int> onToggle;
  final ValueChanged<int> onSkip;
  final ValueChanged<int> onSnooze;
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey900.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Day header ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 16, 8),
            child: Row(
              children: [
                // Offset badge circle
                if (section.opOffsetLabel != null)
                  _OffsetCircleBadge(label: section.opOffsetLabel!),
                if (section.opOffsetLabel != null)
                  const SizedBox(width: 12),
                // Date + completed count
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.offsetLabel,
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${section.completedCount}/${section.totalCount} erledigt',
                        style: tt.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Task tiles ──────────────────────────────────────
          for (var i = 0; i < section.tasks.length; i++) ...[
            FadeSlideIn(
              delay: Duration(milliseconds: 80 + sectionIndex * 40 + i * 35),
              slideOffset: 6,
              duration: const Duration(milliseconds: 280),
              child: _TaskTile(
                task: section.tasks[i],
                onToggle: () => onToggle(i),
                onNavigate: () => onNavigate(i),
              ),
            ),
            if (i < section.tasks.length - 1)
              Padding(
                padding: const EdgeInsets.only(left: 60, right: 16),
                child: Divider(
                  height: 1,
                  color: AppColors.grey200.withValues(alpha: 0.6),
                ),
              ),
          ],

          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ── Offset circle badge (like in the screenshot: "-14 Tage") ─────────────────

class _OffsetCircleBadge extends StatelessWidget {
  const _OffsetCircleBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.1,
            ),
          ),
          const Text(
            'Tage',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Task card (grouped, iOS-like) ────────────────────────────────────────────

// Kept for backwards compat but no longer used by the redesigned TimelineDaySection.

// ── Task tile ────────────────────────────────────────────────────────────────

class _TaskTile extends StatelessWidget {
  const _TaskTile({
    required this.task,
    required this.onToggle,
    required this.onNavigate,
  });

  final TimelineTask task;
  final VoidCallback onToggle;
  final VoidCallback onNavigate;

  @override
  Widget build(BuildContext context) {
    final isFinalized = task.isDone || task.isSkipped;

    return PressableScale(
      onTap: onNavigate,
      scaleFactor: 0.988,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        child: Row(
          children: [
            // ── Status indicator ─────────────────────────
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onToggle,
              child: SizedBox(
                width: 36,
                height: 36,
                child: Center(child: _TaskStateIndicator(state: task.state)),
              ),
            ),
            const SizedBox(width: 10),

            // ── Emoji icon ───────────────────────────────
            Text(task.emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 10),

            // ── Title + subtitle ─────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          isFinalized ? FontWeight.w500 : FontWeight.w600,
                      color: isFinalized
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                      decoration:
                          isFinalized ? TextDecoration.lineThrough : null,
                      decorationColor:
                          AppColors.textSecondary.withValues(alpha: 0.6),
                      decorationThickness: 1.0,
                    ),
                  ),
                  if (task.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      task.subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),

            // ── Chevron ──────────────────────────────────
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.grey400,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Task state indicator ─────────────────────────────────────────────────────

class _TaskStateIndicator extends StatelessWidget {
  const _TaskStateIndicator({required this.state});

  final TaskState state;

  @override
  Widget build(BuildContext context) {
    const size = 26.0;

    switch (state) {
      case TaskState.done:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
        );
      case TaskState.skipped:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.grey400,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.remove_rounded, size: 16, color: Colors.white),
        );
      case TaskState.due:
      case TaskState.inProgress:
      case TaskState.planned:
        // Simple open circle matching the screenshot
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.4),
              width: 2,
            ),
          ),
        );
    }
  }
}
