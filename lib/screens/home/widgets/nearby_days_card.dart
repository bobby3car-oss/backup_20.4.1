import 'package:flutter/material.dart';

import '../../../domain/timeline_engine.dart';
import '../../../ui/ui.dart';
import '../home_view_model.dart';

/// Collapsible sections showing tasks from recent past and upcoming days.
class NearbyDaysCard extends StatelessWidget {
  const NearbyDaysCard({
    super.key,
    required this.sections,
    required this.onToggle,
    required this.onNavigate,
  });

  final List<NearbyDaySection> sections;
  final void Function(String id, TaskState state) onToggle;
  final void Function(String? routeKey, String id) onNavigate;

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) return const SizedBox.shrink();

    final tt = Theme.of(context).textTheme;

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
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 4),
            child: Row(
              children: [
                Icon(
                  Icons.date_range_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Weitere Tage',
                  style: tt.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // ── Day sections ────────────────────────────────────
          for (var i = 0; i < sections.length; i++) ...[
            _CollapsibleDaySection(
              section: sections[i],
              onToggle: onToggle,
              onNavigate: onNavigate,
            ),
            if (i < sections.length - 1)
              Divider(
                height: 1,
                indent: 18,
                endIndent: 18,
                color: AppColors.grey200.withValues(alpha: 0.5),
              ),
          ],

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ── Collapsible day section ──────────────────────────────────────────────────

class _CollapsibleDaySection extends StatefulWidget {
  const _CollapsibleDaySection({
    required this.section,
    required this.onToggle,
    required this.onNavigate,
  });

  final NearbyDaySection section;
  final void Function(String id, TaskState state) onToggle;
  final void Function(String? routeKey, String id) onNavigate;

  @override
  State<_CollapsibleDaySection> createState() => _CollapsibleDaySectionState();
}

class _CollapsibleDaySectionState extends State<_CollapsibleDaySection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final section = widget.section;
    final hasOpenTasks = section.tasks.any((t) => !t.isDone && !t.isSkipped);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Day header (tap to expand/collapse) ────────────
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Row(
              children: [
                // Day label
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        section.label,
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Done/total badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: (section.doneCount == section.totalCount &&
                                      section.totalCount > 0
                                  ? AppColors.success
                                  : AppColors.textSecondary)
                              .withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          '${section.doneCount}/${section.totalCount}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: section.doneCount == section.totalCount &&
                                    section.totalCount > 0
                                ? AppColors.success
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      if (hasOpenTasks && section.isPast) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Chevron
                AnimatedRotation(
                  turns: _expanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: AppColors.grey400,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Task list (visible when expanded) ──────────────
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            children: [
              for (var i = 0; i < section.tasks.length; i++)
                _NearbyTaskRow(
                  task: section.tasks[i],
                  onToggle: () => widget.onToggle(
                    section.tasks[i].id,
                    section.tasks[i].state,
                  ),
                  onTap: () => widget.onNavigate(
                    section.tasks[i].routeKey,
                    section.tasks[i].id,
                  ),
                ),
            ],
          ),
          crossFadeState:
              _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
          sizeCurve: Curves.easeOut,
        ),
      ],
    );
  }
}

// ── Task row ─────────────────────────────────────────────────────────────────

class _NearbyTaskRow extends StatelessWidget {
  const _NearbyTaskRow({
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Haptic.light();
                onToggle();
              },
              child: SizedBox(
                width: 28,
                height: 28,
                child: Center(child: _MiniStateCircle(state: task.state)),
              ),
            ),
            const SizedBox(width: 8),
            GlassIcon(icon: task.icon, color: task.iconColor, size: 14),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                task.title,
                style: TextStyle(
                  fontSize: 14,
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
            Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: AppColors.grey400,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Mini state circle ────────────────────────────────────────────────────────

class _MiniStateCircle extends StatelessWidget {
  const _MiniStateCircle({required this.state});

  final TaskState state;

  @override
  Widget build(BuildContext context) {
    const size = 20.0;

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
          child: const Icon(Icons.check_rounded, size: 12, color: Colors.white),
        );
      case TaskState.skipped:
        return Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: AppColors.grey400,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.remove_rounded, size: 12, color: Colors.white),
        );
      case TaskState.due:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.error, width: 1.5),
          ),
          child: Center(
            child: Container(
              width: 6,
              height: 6,
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
            border: Border.all(color: AppColors.warning, width: 1.5),
          ),
          child: Center(
            child: Container(
              width: 6,
              height: 6,
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
