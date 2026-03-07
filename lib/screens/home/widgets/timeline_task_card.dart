import 'package:flutter/material.dart';

import '../../../domain/timeline_engine.dart';
import '../../../theme/app_colors.dart' as timeline_theme;
import '../../../ui/ui.dart';
import '../home_view_model.dart';

timeline_theme.TimelineStatusColors _statusColorsForState(TaskState state) {
  switch (state) {
    case TaskState.planned:
      return timeline_theme.TimelineAppColors.planned;
    case TaskState.due:
      return timeline_theme.TimelineAppColors.due;
    case TaskState.inProgress:
      return timeline_theme.TimelineAppColors.inProgress;
    case TaskState.done:
      return timeline_theme.TimelineAppColors.done;
    case TaskState.skipped:
      return timeline_theme.TimelineAppColors.skipped;
  }
}

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
    final sectionTone = _statusColorsForState(section.sectionState);
    final isDueSection = section.sectionState == TaskState.due;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Day header ───────────────────────────────────────
        Container(
          padding: const EdgeInsets.only(
            left: AppSpacing.sm,
            right: AppSpacing.sm,
            top: AppSpacing.sm,
            bottom: AppSpacing.sm + 2,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [sectionTone.bg, Colors.transparent],
            ),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.md),
            ),
          ),
          child: Row(
            children: [
              if (isDueSection)
                Container(
                  width: 3,
                  height: 20,
                  margin: const EdgeInsets.only(right: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: sectionTone.fg,
                    borderRadius: AppRadius.borderRadiusPill,
                  ),
                ),
              _OffsetBadge(label: section.offsetLabel, tone: sectionTone),
              const SizedBox(width: AppSpacing.md),
              const Spacer(),
              Text(
                section.dateLabel,
                style: tt.labelMedium?.copyWith(
                  color: timeline_theme.TimelineAppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // ── Task card ────────────────────────────────────────
        _TaskCard(
          section: section,
          sectionIndex: sectionIndex,
          sectionTone: sectionTone,
          isDueSection: isDueSection,
          onDone: onDone,
          onToggle: onToggle,
          onSkip: onSkip,
          onSnooze: onSnooze,
          onNavigate: onNavigate,
        ),
      ],
    );
  }
}

// ── Offset badge pill ────────────────────────────────────────────────────────

class _OffsetBadge extends StatelessWidget {
  const _OffsetBadge({required this.label, required this.tone});

  final String label;
  final timeline_theme.TimelineStatusColors tone;

  @override
  Widget build(BuildContext context) {
    final isToday = label == 'Heute';
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md + 2,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        gradient: isToday ? AppColors.primaryGradient : null,
        color: isToday
            ? null
            : Color.alphaBlend(
                tone.bg.withValues(alpha: 0.9),
                timeline_theme.TimelineAppColors.surface,
              ),
        borderRadius: AppRadius.borderRadiusPill,
        border: isToday ? null : Border.all(color: tone.border, width: 0.8),
        boxShadow: isToday
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: isToday ? AppColors.white : tone.fg,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

// ── Task card (grouped, iOS-like) ────────────────────────────────────────────

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.section,
    required this.sectionIndex,
    required this.onDone,
    required this.onToggle,
    required this.onSkip,
    required this.onSnooze,
    required this.onNavigate,
    required this.sectionTone,
    required this.isDueSection,
  });

  final TimelineSection section;
  final int sectionIndex;
  final ValueChanged<int> onDone;
  final ValueChanged<int> onToggle;
  final ValueChanged<int> onSkip;
  final ValueChanged<int> onSnooze;
  final ValueChanged<int> onNavigate;
  final timeline_theme.TimelineStatusColors sectionTone;
  final bool isDueSection;

  @override
  Widget build(BuildContext context) {
    Widget card = GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      borderRadius: AppRadius.borderRadiusLg,
      variant: GlassVariant.medium,
      elevation: GlassElevation.medium,
      color: isDueSection ? sectionTone.bg : null,
      child: Column(
        children: [
          for (var i = 0; i < section.tasks.length; i++) ...[
            FadeSlideIn(
              delay: Duration(milliseconds: 80 + sectionIndex * 40 + i * 35),
              slideOffset: 6,
              duration: const Duration(milliseconds: 280),
              child: _TaskTile(
                task: section.tasks[i],
                onDone: () => onDone(i),
                onToggle: () => onToggle(i),
                onSkip: () => onSkip(i),
                onSnooze: () => onSnooze(i),
                onNavigate: () => onNavigate(i),
              ),
            ),
            if (i < section.tasks.length - 1) _separator(),
          ],
        ],
      ),
    );

    card = IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 3,
            decoration: BoxDecoration(
              color: sectionTone.fg.withValues(
                alpha: isDueSection ? 1.0 : 0.45,
              ),
              borderRadius: AppRadius.borderRadiusPill,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(child: card),
        ],
      ),
    );

    return card;
  }

  Widget _separator() {
    return Padding(
      padding: const EdgeInsets.only(left: 72, right: AppSpacing.lg),
      child: Container(
        height: 0.33,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              timeline_theme.TimelineAppColors.surface2.withValues(alpha: 0.0),
              timeline_theme.TimelineAppColors.surface2.withValues(alpha: 0.8),
              timeline_theme.TimelineAppColors.surface2.withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Task tile ────────────────────────────────────────────────────────────────

class _TaskTile extends StatelessWidget {
  const _TaskTile({
    required this.task,
    required this.onDone,
    required this.onToggle,
    required this.onSkip,
    required this.onSnooze,
    required this.onNavigate,
  });

  final TimelineTask task;
  final VoidCallback onDone;
  final VoidCallback onToggle;
  final VoidCallback onSkip;
  final VoidCallback onSnooze;
  final VoidCallback onNavigate;

  @override
  Widget build(BuildContext context) {
    final isFinalized = task.isDone || task.isSkipped;
    final stateTone = _statusColorsForState(task.state);

    return PressableScale(
      onTap: onNavigate,
      scaleFactor: 0.988,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            // ── Status indicator ─────────────────────────
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onToggle,
              child: SizedBox(
                width: 44,
                height: 44,
                child: Center(child: _TaskStateIndicator(state: task.state)),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),

            // ── Emoji icon ───────────────────────────────
            AnimatedContainer(
              duration: MotionDuration.medium,
              curve: MotionCurve.standard,
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: stateTone.bg,
                borderRadius: AppRadius.borderRadiusSm,
                border: Border.all(color: stateTone.border, width: 0.5),
              ),
              child: Center(
                child: AnimatedOpacity(
                  duration: MotionDuration.medium,
                  opacity: isFinalized ? 0.5 : 1.0,
                  child: Text(task.emoji, style: const TextStyle(fontSize: 18)),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // ── Title + subtitle ─────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: MotionDuration.medium,
                    curve: MotionCurve.standard,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          isFinalized ? FontWeight.w500 : FontWeight.w600,
                      color: isFinalized
                          ? timeline_theme.TimelineAppColors.textSecondary
                          : timeline_theme.TimelineAppColors.textPrimary,
                      decoration:
                          isFinalized ? TextDecoration.lineThrough : null,
                      decorationColor: timeline_theme
                          .TimelineAppColors.textMuted
                          .withValues(alpha: 0.6),
                      decorationThickness: 1.0,
                    ),
                    child: Text(task.title),
                  ),
                  if (task.subtitle != null) ...[
                    const SizedBox(height: 3),
                    AnimatedDefaultTextStyle(
                      duration: MotionDuration.medium,
                      curve: MotionCurve.standard,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: timeline_theme.TimelineAppColors.textMuted,
                        height: 1.3,
                      ),
                      child: Text(
                        task.subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  if (task.milestone != null &&
                      task.milestone!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    _MilestoneChip(label: task.milestone!),
                  ],
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      _StateActionPill(
                        label: 'Done',
                        isPrimary: true,
                        tone: timeline_theme.TimelineAppColors.done,
                        onTap: onDone,
                      ),
                      _StateActionPill(
                        label: 'Skip',
                        tone: timeline_theme.TimelineAppColors.skipped,
                        onTap: onSkip,
                      ),
                      if (task.state == TaskState.due)
                        _StateActionPill(
                          label: 'Snooze 30m',
                          tone: timeline_theme.TimelineAppColors.inProgress,
                          onTap: onSnooze,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),

            // ── Chevron ──────────────────────────────────
            AnimatedOpacity(
              duration: MotionDuration.medium,
              opacity: isFinalized ? 0.3 : 0.5,
              child: const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.grey500,
              ),
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
    final tone = _statusColorsForState(state);
    const size = 30.0;

    switch (state) {
      case TaskState.done:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF16A34A), Color(0xFF34D399)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF16A34A).withValues(alpha: 0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child:
              const Icon(Icons.check_rounded, size: 17, color: Colors.white),
        );
      case TaskState.skipped:
        return _filledIndicator(
          size: size,
          color: tone.fg,
          icon: Icons.remove_rounded,
        );
      case TaskState.due:
        return _PulsingDueIndicator(size: size, tone: tone);
      case TaskState.inProgress:
        return Stack(
          alignment: Alignment.center,
          children: [
            _ringIndicator(size: size, color: tone.fg, bg: tone.bg),
            Container(
              width: 12,
              height: 3,
              decoration: BoxDecoration(
                color: tone.fg,
                borderRadius: AppRadius.borderRadiusPill,
              ),
            ),
          ],
        );
      case TaskState.planned:
        return _ringIndicator(size: size, color: tone.fg, bg: tone.bg);
    }
  }

  Widget _ringIndicator({
    required double size,
    required Color color,
    required Color bg,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.45),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.85), width: 2),
      ),
    );
  }

  Widget _filledIndicator({
    required double size,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(icon, size: 17, color: Colors.white),
    );
  }
}

// ── Pulsing due indicator ────────────────────────────────────────────────────

class _PulsingDueIndicator extends StatefulWidget {
  const _PulsingDueIndicator({required this.size, required this.tone});

  final double size;
  final timeline_theme.TimelineStatusColors tone;

  @override
  State<_PulsingDueIndicator> createState() => _PulsingDueIndicatorState();
}

class _PulsingDueIndicatorState extends State<_PulsingDueIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final scale = 1.0 + _ctrl.value * 0.12;
        final glowAlpha = 0.15 + _ctrl.value * 0.3;
        return Transform.scale(
          scale: scale,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: widget.tone.bg.withValues(alpha: 0.45),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.tone.fg.withValues(alpha: 0.85),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.tone.fg.withValues(alpha: glowAlpha),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: widget.tone.fg,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Milestone chip ───────────────────────────────────────────────────────────

class _MilestoneChip extends StatelessWidget {
  const _MilestoneChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs + 1,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: AppRadius.borderRadiusPill,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.18),
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

// ── State action pill ────────────────────────────────────────────────────────

class _StateActionPill extends StatelessWidget {
  const _StateActionPill({
    required this.label,
    required this.tone,
    required this.onTap,
    this.isPrimary = false,
  });

  final String label;
  final timeline_theme.TimelineStatusColors tone;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      scaleFactor: 0.94,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          gradient: isPrimary
              ? LinearGradient(
                  colors: [tone.fg.withValues(alpha: 0.9), tone.fg],
                )
              : null,
          color: isPrimary ? null : tone.bg,
          borderRadius: AppRadius.borderRadiusPill,
          border:
              isPrimary ? null : Border.all(color: tone.border, width: 0.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isPrimary ? Colors.white : tone.fg,
          ),
        ),
      ),
    );
  }
}
