import 'package:flutter/material.dart';

import '../ui/ui.dart';

// ── Data model ───────────────────────────────────────────────────────────────

class _Task {
  _Task({required this.title, required this.dayOffset, this.done = false});

  final String title;

  /// Relative to OP day. Negative = before, 0 = OP day, positive = after.
  final int dayOffset;
  bool done;
}

class _Phase {
  _Phase({
    required this.label,
    required this.icon,
    required this.color,
    required this.tasks,
  });

  final String label;
  final IconData icon;
  final Color color;
  final List<_Task> tasks;

  int get completed => tasks.where((t) => t.done).length;
  int get total => tasks.length;
  double get progress => total == 0 ? 0 : completed / total;
}

// ─────────────────────────────────────────────────────────────────────────────

class OperationTimelineScreen extends StatefulWidget {
  const OperationTimelineScreen({super.key});

  @override
  State<OperationTimelineScreen> createState() =>
      _OperationTimelineScreenState();
}

class _OperationTimelineScreenState extends State<OperationTimelineScreen> {
  late final List<_Phase> _phases = [
    _Phase(
      label: 'PRE OP',
      icon: Icons.assignment_outlined,
      color: AppColors.primary,
      tasks: [
        _Task(title: 'Unterlagen sammeln', dayOffset: -14, done: true),
        _Task(title: 'Medikamentenliste erstellen', dayOffset: -14, done: true),
        _Task(title: 'Aufklärungsgespräch führen', dayOffset: -10, done: true),
        _Task(title: 'Blutwerte abgeben', dayOffset: -7, done: true),
        _Task(title: 'Transport organisieren', dayOffset: -5),
        _Task(title: 'Fragen an den Arzt notieren', dayOffset: -3),
        _Task(title: 'Kleidung & Tasche vorbereiten', dayOffset: -1),
        _Task(title: 'Nüchternheit ab 22 Uhr', dayOffset: -1),
      ],
    ),
    _Phase(
      label: 'OP TAG',
      icon: Icons.local_hospital_rounded,
      color: AppColors.warning,
      tasks: [
        _Task(title: 'Nüchtern bleiben', dayOffset: 0),
        _Task(title: 'Dokumente mitbringen', dayOffset: 0),
        _Task(title: 'Einwilligung unterschreiben', dayOffset: 0),
        _Task(title: 'OP‑Kleidung anziehen', dayOffset: 0),
      ],
    ),
    _Phase(
      label: 'POST OP',
      icon: Icons.healing_rounded,
      color: AppColors.success,
      tasks: [
        _Task(title: 'Vitalzeichen kontrollieren', dayOffset: 0),
        _Task(title: 'Schmerzprotokoll führen', dayOffset: 1),
        _Task(title: 'Erste Mobilisation', dayOffset: 1),
        _Task(title: 'Entlassungsgespräch', dayOffset: 2),
        _Task(title: 'Medikamentenplan erhalten', dayOffset: 2),
      ],
    ),
    _Phase(
      label: 'REHA',
      icon: Icons.fitness_center_rounded,
      color: AppColors.accent,
      tasks: [
        _Task(title: 'Reha‑Termin vereinbaren', dayOffset: 3),
        _Task(title: 'Physiotherapie starten', dayOffset: 7),
        _Task(title: 'Nachkontrolle beim Arzt', dayOffset: 14),
        _Task(title: 'Belastung steigern', dayOffset: 28),
        _Task(title: 'Abschlusskontrolle', dayOffset: 42),
      ],
    ),
  ];

  int get _totalTasks => _phases.fold(0, (s, p) => s + p.total);
  int get _completedTasks => _phases.fold(0, (s, p) => s + p.completed);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(child: _buildBody(context)),
    );
  }

  Widget _buildBody(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return SingleChildScrollView(
      physics: adaptiveScrollPhysics,
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: topPadding + AppSpacing.sm,
        bottom: AppSpacing.huge,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAppBar(context),
          const SizedBox(height: AppSpacing.xxl),
          FadeSlideIn(
            delay: const Duration(milliseconds: 80),
            child: _buildOverallProgress(context),
          ),
          const SizedBox(height: AppSpacing.xxl),
          for (var i = 0; i < _phases.length; i++) ...[
            FadeSlideIn(
              delay: Duration(milliseconds: 160 + i * 70),
              child: _PhaseSection(
                phase: _phases[i],
                phaseIndex: i,
                totalPhases: _phases.length,
                onToggle: (taskIndex) {
                  Haptic.light();
                  setState(() {
                    _phases[i].tasks[taskIndex].done =
                        !_phases[i].tasks[taskIndex].done;
                  });
                },
              ),
            ),
            if (i < _phases.length - 1) const SizedBox(height: AppSpacing.lg),
          ],
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Row(
      children: [
        PressableScale(
          onTap: () => Navigator.of(context).pop(),
          scaleFactor: 0.90,
          child: GlassContainer(
            padding: const EdgeInsets.all(AppSpacing.sm + 2),
            borderRadius: AppRadius.borderRadiusMd,
            variant: GlassVariant.thin,
            elevation: GlassElevation.low,
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            'OP‑Timeline',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        GlassContainer(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          borderRadius: AppRadius.borderRadiusPill,
          variant: GlassVariant.thin,
          elevation: GlassElevation.low,
          child: Text(
            '$_completedTasks / $_totalTasks',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOverallProgress(BuildContext context) {
    final progress = _totalTasks == 0 ? 0.0 : _completedTasks / _totalTasks;

    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.xl),
      borderRadius: AppRadius.borderRadiusXxl,
      variant: GlassVariant.medium,
      elevation: GlassElevation.medium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: AppRadius.borderRadiusMd,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.timeline_rounded,
                  size: 24,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gesamtfortschritt',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      '$_completedTasks von $_totalTasks Aufgaben erledigt',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          GlassProgressBar(value: progress, height: 10, showPercentage: true),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              for (var i = 0; i < _phases.length; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.sm),
                Expanded(child: _PhasePill(phase: _phases[i])),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ── Phase pill ───────────────────────────────────────────────────────────────

class _PhasePill extends StatelessWidget {
  const _PhasePill({required this.phase});

  final _Phase phase;

  @override
  Widget build(BuildContext context) {
    final allDone = phase.completed == phase.total && phase.total > 0;

    return AnimatedContainer(
      duration: MotionDuration.medium,
      curve: MotionCurve.standard,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: allDone
            ? phase.color.withValues(alpha: 0.12)
            : AppColors.grey100,
        borderRadius: AppRadius.borderRadiusPill,
        border: Border.all(
          color: allDone
              ? phase.color.withValues(alpha: 0.3)
              : AppColors.grey200,
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Icon(
            allDone ? Icons.check_rounded : phase.icon,
            size: 14,
            color: allDone ? phase.color : AppColors.grey500,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            '${phase.completed}/${phase.total}',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: allDone ? phase.color : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Phase section ────────────────────────────────────────────────────────────

class _PhaseSection extends StatelessWidget {
  const _PhaseSection({
    required this.phase,
    required this.phaseIndex,
    required this.totalPhases,
    required this.onToggle,
  });

  final _Phase phase;
  final int phaseIndex;
  final int totalPhases;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PhaseHeader(
          phase: phase,
          phaseIndex: phaseIndex,
          totalPhases: totalPhases,
        ),
        const SizedBox(height: AppSpacing.md),
        GlassContainer(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          borderRadius: AppRadius.borderRadiusXxl,
          variant: GlassVariant.thin,
          elevation: GlassElevation.low,
          child: Column(
            children: [
              for (var i = 0; i < phase.tasks.length; i++) ...[
                _TaskRow(
                  task: phase.tasks[i],
                  color: phase.color,
                  onToggle: () => onToggle(i),
                ),
                if (i < phase.tasks.length - 1)
                  Container(
                    height: 0.5,
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.grey200.withValues(alpha: 0),
                          AppColors.grey200.withValues(alpha: 0.5),
                          AppColors.grey200.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ── Phase header ─────────────────────────────────────────────────────────────

class _PhaseHeader extends StatelessWidget {
  const _PhaseHeader({
    required this.phase,
    required this.phaseIndex,
    required this.totalPhases,
  });

  final _Phase phase;
  final int phaseIndex;
  final int totalPhases;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: phase.color.withValues(alpha: 0.12),
            borderRadius: AppRadius.borderRadiusMd,
          ),
          child: Icon(phase.icon, size: 20, color: phase.color),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                phase.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: phase.color,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                'Phase ${phaseIndex + 1} von $totalPhases',
                style: tt.bodySmall,
              ),
            ],
          ),
        ),
        Text(
          '${phase.completed}/${phase.total}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: phase.color,
          ),
        ),
      ],
    );
  }
}

// ── Task row ─────────────────────────────────────────────────────────────────

class _TaskRow extends StatelessWidget {
  const _TaskRow({
    required this.task,
    required this.color,
    required this.onToggle,
  });

  final _Task task;
  final Color color;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: () {
        Haptic.selection();
        onToggle();
      },
      scaleFactor: 0.99,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          children: [
            AnimatedCheckbox(
              value: task.done,
              activeColor: color,
              inactiveColor: AppColors.grey300,
              borderRadius: AppRadius.borderRadiusXs,
              iconSize: 16,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AnimatedDefaultTextStyle(
                duration: MotionDuration.medium,
                curve: MotionCurve.standard,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: task.done ? FontWeight.w400 : FontWeight.w500,
                  color: task.done
                      ? AppColors.textSecondary.withValues(alpha: 0.7)
                      : AppColors.textPrimary,
                  decoration: task.done ? TextDecoration.lineThrough : null,
                  decorationColor: AppColors.textSecondary.withValues(
                    alpha: 0.5,
                  ),
                ),
                child: Text(task.title),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            _DayOffsetBadge(dayOffset: task.dayOffset),
          ],
        ),
      ),
    );
  }
}

// ── Day offset badge ─────────────────────────────────────────────────────────

class _DayOffsetBadge extends StatelessWidget {
  const _DayOffsetBadge({required this.dayOffset});

  final int dayOffset;

  @override
  Widget build(BuildContext context) {
    final String text;
    final Color bgColor;
    final Color fgColor;

    if (dayOffset < 0) {
      text = 'Tag $dayOffset';
      bgColor = AppColors.primary.withValues(alpha: 0.08);
      fgColor = AppColors.primary;
    } else if (dayOffset == 0) {
      text = 'Tag 0';
      bgColor = AppColors.warning.withValues(alpha: 0.10);
      fgColor = AppColors.warning;
    } else {
      text = 'Tag +$dayOffset';
      bgColor = AppColors.success.withValues(alpha: 0.08);
      fgColor = AppColors.success;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.borderRadiusPill,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fgColor,
        ),
      ),
    );
  }
}
