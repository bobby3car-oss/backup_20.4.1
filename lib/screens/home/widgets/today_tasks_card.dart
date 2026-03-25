import 'package:flutter/material.dart';

import '../../../domain/timeline_engine.dart';
import '../../../ui/ui.dart';
import '../home_view_model.dart';

/// Prominent timeline card with hero header and today's tasks.
class TodayTasksCard extends StatelessWidget {
  const TodayTasksCard({
    super.key,
    required this.tasks,
    required this.onToggle,
    required this.onNavigate,
    required this.onShowAll,
    this.dayLabel = 'Heute',
    this.encouragement = '',
    this.progress = 0.0,
    this.hasOpDate = false,
  });

  final List<TimelineTask> tasks;
  final void Function(String id, TaskState state) onToggle;
  final void Function(String? routeKey, String id) onNavigate;
  final VoidCallback onShowAll;

  final String dayLabel;
  final String encouragement;
  final double progress;
  final bool hasOpDate;

  static const _headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0055D4), Color(0xFF007AFF), Color(0xFF5AC8FA)],
    stops: [0.0, 0.55, 1.0],
  );

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final doneCount = tasks.where((t) => t.isDone).length;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF007AFF).withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: AppColors.grey900.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero header with gradient ───────────────────────
          _HeroHeader(
            dayLabel: dayLabel,
            encouragement: encouragement,
            progress: progress,
            hasOpDate: hasOpDate,
            doneCount: doneCount,
            totalCount: tasks.length,
            onTap: onShowAll,
          ),

          // ── Task list section ──────────────────────────────
          if (tasks.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 8),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: 22,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 10),
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
            )
          else ...[
            // Section label
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 4),
              child: Row(
                children: [
                  Icon(
                    Icons.today_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Heutige Aufgaben',
                    style: tt.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const Spacer(),
                  _CompactBadge(done: doneCount, total: tasks.length),
                ],
              ),
            ),

            // Task rows
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
                    color: AppColors.grey200.withValues(alpha: 0.4),
                  ),
                ),
            ],
          ],

          // ── Footer: full plan link ─────────────────────────
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: PressableScale(
              onTap: onShowAll,
              scaleFactor: 0.97,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 13),
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
                    Icon(
                      Icons.timeline_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
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
          ),
        ],
      ),
    );
  }
}

// ── Hero header ──────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.dayLabel,
    required this.encouragement,
    required this.progress,
    required this.hasOpDate,
    required this.doneCount,
    required this.totalCount,
    required this.onTap,
  });

  final String dayLabel;
  final String encouragement;
  final double progress;
  final bool hasOpDate;
  final int doneCount;
  final int totalCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(
          gradient: TodayTasksCard._headerGradient,
        ),
        child: CustomPaint(
          painter: _HeroPainter(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 18, 18),
            child: Row(
              children: [
                // Left: text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dayLabel,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                          height: 1.15,
                        ),
                      ),
                      if (encouragement.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          encouragement,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xB3FFFFFF),
                            height: 1.3,
                          ),
                        ),
                      ],
                      if (totalCount > 0) ...[
                        const SizedBox(height: 10),
                        // Mini progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: SizedBox(
                            height: 5,
                            child: LinearProgressIndicator(
                              value: totalCount == 0
                                  ? 0.0
                                  : (doneCount / totalCount).clamp(0.0, 1.0),
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.18),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$doneCount von $totalCount erledigt',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0x99FFFFFF),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Right: circular progress ring
                if (hasOpDate) _progressRing(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _progressRing() {
    final percent = (progress * 100).round();
    return SizedBox(
      width: 62,
      height: 62,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 62,
            height: 62,
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              strokeWidth: 5,
              backgroundColor: Colors.white.withValues(alpha: 0.18),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$percent%',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
              const Text(
                'Gesamt',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Color(0x99FFFFFF),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Decorative painter for hero section ──────────────────────────────────────

class _HeroPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;

    // Subtle decorative circle top-right
    canvas.drawCircle(
      Offset(size.width - 20, -10),
      60,
      paint,
    );
    // Smaller circle bottom-left
    canvas.drawCircle(
      Offset(30, size.height + 20),
      40,
      paint..color = Colors.white.withValues(alpha: 0.04),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
