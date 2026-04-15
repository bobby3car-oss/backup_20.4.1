import 'package:flutter/material.dart';

import '../../../domain/timeline_engine.dart';
import '../../../ui/theme/app_icons.dart';
import '../../../ui/ui.dart';
import '../home_view_model.dart';

// ── Day section ──────────────────────────────────────────────────────────────

class TimelineDaySection extends StatefulWidget {
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

  /// Threshold for collapsing — past sections with more tasks get collapsed.
  static const int _collapseThreshold = 4;

  @override
  State<TimelineDaySection> createState() => _TimelineDaySectionState();
}

class _TimelineDaySectionState extends State<TimelineDaySection> {
  bool _expanded = true;

  @override
  void initState() {
    super.initState();
    // Auto-collapse past sections with many tasks
    final isToday = widget.section.offsetLabel == 'Heute';
    final isTomorrow = widget.section.offsetLabel == 'Morgen';
    if (!isToday &&
        !isTomorrow &&
        widget.section.tasks.length > TimelineDaySection._collapseThreshold) {
      _expanded = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final tasks = widget.section.tasks;
    final visibleTasks =
        _expanded ? tasks : tasks.take(TimelineDaySection._collapseThreshold).toList();
    final hiddenCount = tasks.length - visibleTasks.length;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey900.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Day header ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                // Offset pill badge
                if (widget.section.opOffsetLabel != null) ...[
                  _OffsetPillBadge(label: widget.section.opOffsetLabel!),
                  const SizedBox(width: 10),
                ],
                // Day label
                Expanded(
                  child: Text(
                    widget.section.offsetLabel,
                    style: tt.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                // Completed count badge
                _CompletedBadge(
                  done: widget.section.completedCount,
                  total: widget.section.totalCount,
                ),
              ],
            ),
          ),

          // ── Task tiles ──────────────────────────────────────
          for (var i = 0; i < visibleTasks.length; i++) ...[
            FadeSlideIn(
              delay: Duration(
                  milliseconds:
                      80 + widget.sectionIndex * 40 + i * 35),
              slideOffset: 6,
              duration: const Duration(milliseconds: 280),
              child: _TaskTile(
                task: visibleTasks[i],
                onToggle: () => widget.onToggle(i),
                onNavigate: () => widget.onNavigate(i),
              ),
            ),
            if (i < visibleTasks.length - 1)
              Padding(
                padding: const EdgeInsets.only(left: 60, right: 14),
                child: Divider(
                  height: 1,
                  color: AppColors.grey200.withValues(alpha: 0.5),
                ),
              ),
          ],

          // ── Expand button ─────────────────────────────────
          if (!_expanded && hiddenCount > 0)
            GestureDetector(
              onTap: () => setState(() => _expanded = true),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.expand_more_rounded,
                        size: 18, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      '$hiddenCount weitere anzeigen',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ── Offset pill badge (compact replacement for the old square) ───────────────

class _OffsetPillBadge extends StatelessWidget {
  const _OffsetPillBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$label T',
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          height: 1.1,
        ),
      ),
    );
  }
}

// ── Completed badge ──────────────────────────────────────────────────────────

class _CompletedBadge extends StatelessWidget {
  const _CompletedBadge({required this.done, required this.total});

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

// ── Task tile ────────────────────────────────────────────────────────────────

Color _colorForType(TaskType type) {
  switch (type) {
    case TaskType.wound:
      return AppIcons.photosColor;
    case TaskType.meds:
      return AppIcons.medicationColor;
    case TaskType.checklist:
      return AppIcons.doneColor;
    case TaskType.appointment:
      return AppIcons.appointmentsColor;
    case TaskType.nutrition:
      return AppIcons.nutritionColor;
    case TaskType.message:
      return AppIcons.messagesColor;
    case TaskType.custom:
      return AppIcons.notesColor;
    case TaskType.note:
      return AppIcons.messagesColor;
    case TaskType.aftercare:
      return AppIcons.doctorColor;
  }
}

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
    final typeColor = _colorForType(task.type);

    return PressableScale(
      onTap: onNavigate,
      scaleFactor: 0.988,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: isFinalized
                  ? typeColor.withValues(alpha: 0.20)
                  : typeColor,
              width: 3,
            ),
          ),
        ),
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
                  child:
                      Center(child: _TaskStateIndicator(state: task.state)),
                ),
              ),
              const SizedBox(width: 10),

              // ── Emoji icon ───────────────────────────────
              GlassIcon(icon: task.icon, color: task.iconColor, size: 18),
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
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF16A34A), Color(0xFF34D399)],
            ),
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
          child:
              const Icon(Icons.remove_rounded, size: 16, color: Colors.white),
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
              width: 8,
              height: 8,
              decoration: BoxDecoration(
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
              width: 8,
              height: 8,
              decoration: BoxDecoration(
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
            border: Border.all(
              color: AppColors.grey300,
              width: 1.5,
            ),
          ),
        );
    }
  }
}
