import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../features/gamification/domain/badge_progress.dart';
import '../features/gamification/domain/badge_rules.dart';
import '../features/gamification/domain/daily_challenge.dart';
import '../features/gamification/domain/daily_log.dart';
import '../features/gamification/domain/gamification_state.dart';
import '../features/gamification/domain/milestone.dart';
import '../features/gamification/domain/recovery_event.dart';
import '../features/gamification/domain/xp_config.dart';
import '../features/gamification/gamification_service.dart';
import '../main.dart';
import '../ui/ui.dart';

// ─────────────────────────────────────────────────────────────────────────────

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  late final GamificationService _service;

  @override
  void initState() {
    super.initState();
    _service = GamificationService();
  }

  bool _isPro(BuildContext context) {
    final pro = ProServices.maybeOf(context);
    return pro?.entitlementService.isPro ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isPro = _isPro(context);

    return StreamBuilder<GamificationState>(
      stream: _service.watchState(),
      builder: (context, stateSnap) {
        final state = stateSnap.data ?? const GamificationState();

        return GlassPage(
          title: 'Fortschritt',
          titleEmoji: '💪',
          titleColor: AppColors.success,
          children: [
            // ── Streak ──
            _StreakCard(
              currentStreak: state.currentStreak,
              longestStreak: state.longestStreak,
              recentLogs: _service.watchRecentLogs(days: 7),
            ),

            // ── Level / XP (Pro) ──
            const SizedBox(height: AppSpacing.xxl),
            if (isPro) ...[
              _LevelCard(state: state),
            ] else ...[
              _ProTeaser(
                title: 'XP & Level-System',
                subtitle: 'Schalte Level, XP-Tracking und mehr frei',
                icon: Icons.workspace_premium_rounded,
              ),
            ],

            // ── Milestones (Pro) ──
            const SizedBox(height: AppSpacing.xxl),
            _sectionTitle(context, 'Meilensteine'),
            const SizedBox(height: AppSpacing.md),
            if (isPro) ...[
              _MilestoneList(milestones: state.milestones),
            ] else ...[
              _ProTeaser(
                title: 'Meilensteine & Ziele',
                subtitle: 'Verfolge deine Recovery-Meilensteine',
                icon: Icons.emoji_events_rounded,
              ),
            ],

            // ── Daily Challenges (Pro) ──
            const SizedBox(height: AppSpacing.xxl),
            _sectionTitle(context, 'Heutige Aufgaben'),
            const SizedBox(height: AppSpacing.md),
            if (isPro) ...[
              _DailyChallengesCard(service: _service),
            ] else ...[
              _ProTeaser(
                title: 'Tägliche Challenges',
                subtitle: '3 neue Aufgaben jeden Tag – nur für Pro',
                icon: Icons.bolt_rounded,
              ),
            ],

            // ── Recovery Score ──
            const SizedBox(height: AppSpacing.xxl),
            _sectionTitle(context, 'Recovery Score'),
            const SizedBox(height: AppSpacing.md),
            _RecoveryScoreCard(state: state),

            // ── Recovery Feed Highlights (Pro) ──
            const SizedBox(height: AppSpacing.xxl),
            _sectionTitle(context, 'Recovery Feed'),
            const SizedBox(height: AppSpacing.md),
            if (isPro) ...[
              _RecentEventsCard(service: _service),
            ] else ...[
              _ProTeaser(
                title: 'Recovery Feed',
                subtitle: 'Alle deine Aktivitäten auf einen Blick',
                icon: Icons.dynamic_feed_rounded,
              ),
            ],

            // ── Heatmap (Pro) ──
            const SizedBox(height: AppSpacing.xxl),
            _sectionTitle(context, 'Aktivität'),
            const SizedBox(height: AppSpacing.md),
            if (isPro) ...[
              _HeatmapCard(logsStream: _service.watchRecentLogs(days: 35)),
            ] else ...[
              _ProTeaser(
                title: 'Aktivitäts-Heatmap',
                subtitle: 'Visualisiere deine tägliche Aktivität',
                icon: Icons.grid_on_rounded,
              ),
            ],

            // ── Badges with progress ──
            const SizedBox(height: AppSpacing.xxl),
            _sectionTitle(context, 'Abzeichen'),
            const SizedBox(height: AppSpacing.md),
            _BadgeProgressGrid(
              state: state,
              isPro: isPro,
            ),
          ],
        );
      },
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}

// ── Streak card ──────────────────────────────────────────────────────────────

class _StreakCard extends StatelessWidget {
  const _StreakCard({
    required this.currentStreak,
    required this.longestStreak,
    required this.recentLogs,
  });

  final int currentStreak;
  final int longestStreak;
  final Stream<List<DailyLog>> recentLogs;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.xl),
      borderRadius: AppRadius.borderRadiusXl,
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFF9500), Color(0xFFFF3B30)],
              ),
              borderRadius: AppRadius.borderRadiusLg,
              boxShadow: [
                BoxShadow(
                  color: AppColors.warning.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              size: 34,
              color: AppColors.white,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$currentStreak',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Text(
                        'Tage',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'Aktuelle Serie',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const Icon(
                      Icons.emoji_events_outlined,
                      size: 14,
                      color: AppColors.grey500,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Längste Serie: $longestStreak Tage',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          StreamBuilder<List<DailyLog>>(
            stream: recentLogs,
            builder: (context, snap) {
              final logs = snap.data ?? [];
              final logDates = {for (final l in logs) l.date};
              final now = DateTime.now();

              return Column(
                children: [
                  const Text(
                    'Letzte 7 Tage',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: List.generate(7, (i) {
                      final day = now.subtract(Duration(days: 6 - i));
                      final key =
                          '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
                      final active = logDates.contains(key);
                      return Padding(
                        padding:
                            EdgeInsets.only(left: i > 0 ? AppSpacing.xxs : 0),
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color:
                                active ? AppColors.success : AppColors.grey300,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Level card (Pro) ─────────────────────────────────────────────────────────

class _LevelCard extends StatelessWidget {
  const _LevelCard({required this.state});

  final GamificationState state;

  @override
  Widget build(BuildContext context) {
    final levelName = LevelNames.forLevel(state.level);

    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.xl),
      borderRadius: AppRadius.borderRadiusXl,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.accent, AppColors.primary],
                  ),
                  borderRadius: AppRadius.borderRadiusLg,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.30),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${state.level}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      levelName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      '${state.xp} XP gesamt',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${state.xpInCurrentLevel} / ${state.xpForNextLevel} XP',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    'Level ${state.level + 1}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: state.levelProgress,
                  minHeight: 8,
                  backgroundColor: AppColors.grey200,
                  valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Daily challenges card (Pro) ──────────────────────────────────────────────

class _DailyChallengesCard extends StatefulWidget {
  const _DailyChallengesCard({required this.service});

  final GamificationService service;

  @override
  State<_DailyChallengesCard> createState() => _DailyChallengesCardState();
}

class _DailyChallengesCardState extends State<_DailyChallengesCard> {
  late Future<DailyChallengeSet> _challengesFuture;

  @override
  void initState() {
    super.initState();
    _challengesFuture = widget.service.getOrGenerateDailyChallenges();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DailyChallengeSet>(
      future: _challengesFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return GlassContainer(
            padding: const EdgeInsets.all(AppSpacing.xl),
            borderRadius: AppRadius.borderRadiusXl,
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        final set = snap.data;
        if (set == null || set.challenges.isEmpty) {
          return const SizedBox.shrink();
        }

        return StreamBuilder<DailyChallengeSet?>(
          stream: widget.service.watchDailyChallenges(),
          initialData: set,
          builder: (context, liveSnap) {
            final liveSet = liveSnap.data ?? set;

            return GlassContainer(
              padding: const EdgeInsets.all(AppSpacing.xl),
              borderRadius: AppRadius.borderRadiusXl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.bolt_rounded,
                          size: 20, color: AppColors.warning),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '${liveSet.completedCount} / ${liveSet.challenges.length} erledigt',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (liveSet.allCompleted) ...[
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.10),
                            borderRadius: AppRadius.borderRadiusPill,
                          ),
                          child: const Text(
                            '🎉 Alle geschafft!',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  for (var i = 0; i < liveSet.challenges.length; i++) ...[
                    _ChallengeRow(
                      challenge: liveSet.challenges[i],
                      onComplete: () {
                        widget.service
                            .completeChallenge(liveSet.challenges[i].id);
                      },
                    ),
                    if (i < liveSet.challenges.length - 1)
                      const SizedBox(height: AppSpacing.md),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ChallengeRow extends StatelessWidget {
  const _ChallengeRow({required this.challenge, required this.onComplete});

  final DailyChallenge challenge;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: challenge.completed ? null : onComplete,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color:
                  challenge.completed ? AppColors.success : AppColors.grey200,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: challenge.completed
                    ? AppColors.success
                    : AppColors.grey400,
                width: 1.5,
              ),
            ),
            child: challenge.completed
                ? const Icon(Icons.check_rounded,
                    size: 18, color: AppColors.white)
                : null,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                challenge.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: challenge.completed
                      ? AppColors.textSecondary
                      : AppColors.textPrimary,
                  decoration:
                      challenge.completed ? TextDecoration.lineThrough : null,
                ),
              ),
              Text(
                challenge.description,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xxs,
          ),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.10),
            borderRadius: AppRadius.borderRadiusPill,
          ),
          child: Text(
            '+${challenge.xpReward} XP',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Recovery score card ──────────────────────────────────────────────────────

class _RecoveryScoreCard extends StatelessWidget {
  const _RecoveryScoreCard({required this.state});

  final GamificationState state;

  int _computeScore() {
    final streakScore = (state.currentStreak / 30.0 * 30).clamp(0, 30).toInt();
    final taskScore = (state.totalTasksDone / 50.0 * 30).clamp(0, 30).toInt();
    final daysScore = (state.totalDaysActive / 30.0 * 20).clamp(0, 20).toInt();
    final levelScore = (state.level / 10.0 * 20).clamp(0, 20).toInt();
    return (streakScore + taskScore + daysScore + levelScore).clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    final score = _computeScore();

    final metrics = <_RecoveryMetric>[
      _RecoveryMetric(
        label: 'Aufgaben',
        value: state.totalTasksDone.toDouble(),
        maxValue: 50,
        unit: 'erledigt',
        icon: Icons.checklist_rounded,
        color: AppColors.success,
      ),
      _RecoveryMetric(
        label: 'Streak',
        value: state.currentStreak.toDouble(),
        maxValue: 30,
        unit: 'Tage',
        icon: Icons.local_fire_department_rounded,
        color: AppColors.warning,
      ),
      _RecoveryMetric(
        label: 'Aktive Tage',
        value: state.totalDaysActive.toDouble(),
        maxValue: 30,
        unit: 'Tage',
        icon: Icons.calendar_today_rounded,
        color: AppColors.primary,
      ),
      _RecoveryMetric(
        label: 'Level',
        value: state.level.toDouble(),
        maxValue: 10,
        unit: '/ 10',
        icon: Icons.trending_up_rounded,
        color: AppColors.accent,
      ),
    ];

    final label = score >= 80
        ? 'Sehr gute Erholung – weiter so!'
        : score >= 50
            ? 'Gute Erholung – weiter so!'
            : 'Du bist auf dem Weg – bleib dran!';

    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.xl),
      borderRadius: AppRadius.borderRadiusXl,
      child: Column(
        children: [
          SizedBox(
            height: 140,
            child: Center(
              child: SizedBox(
                width: 130,
                height: 130,
                child: CustomPaint(
                  painter: _ScoreRingPainter(score: score / 100),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$score',
                          style: const TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            height: 1,
                          ),
                        ),
                        const Text(
                          'von 100',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.10),
              borderRadius: AppRadius.borderRadiusPill,
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.success,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(height: 1, color: AppColors.grey200),
          const SizedBox(height: AppSpacing.lg),
          for (var i = 0; i < metrics.length; i++) ...[
            _MetricRow(metric: metrics[i]),
            if (i < metrics.length - 1) const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

class _RecoveryMetric {
  const _RecoveryMetric({
    required this.label,
    required this.value,
    required this.maxValue,
    required this.unit,
    required this.icon,
    required this.color,
  });
  final String label;
  final double value;
  final double maxValue;
  final String unit;
  final IconData icon;
  final Color color;
}

class _ScoreRingPainter extends CustomPainter {
  _ScoreRingPainter({required this.score});
  final double score;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 14) / 2;
    const strokeWidth = 10.0;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.grey200
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    final sweepAngle = 2 * math.pi * score;
    final gradient = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: -math.pi / 2 + sweepAngle,
      colors: const [AppColors.primaryLight, AppColors.primary],
    );

    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweepAngle,
      false,
      Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreRingPainter old) => old.score != score;
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.metric});

  final _RecoveryMetric metric;

  @override
  Widget build(BuildContext context) {
    final progress = (metric.value / metric.maxValue).clamp(0.0, 1.0);

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: metric.color.withValues(alpha: 0.10),
            borderRadius: AppRadius.borderRadiusSm,
          ),
          child: Icon(metric.icon, size: 18, color: metric.color),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    metric.label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${metric.value.toInt()} ${metric.unit}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: metric.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: AppColors.grey200,
                  valueColor: AlwaysStoppedAnimation(metric.color),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Heatmap card (Pro) ───────────────────────────────────────────────────────

class _HeatmapCard extends StatelessWidget {
  const _HeatmapCard({required this.logsStream});

  final Stream<List<DailyLog>> logsStream;
  static const _weekdays = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DailyLog>>(
      stream: logsStream,
      builder: (context, snap) {
        final logs = snap.data ?? [];

        final now = DateTime.now();
        final activityData = List<int>.filled(35, 0);
        final logMap = <String, int>{};
        for (final l in logs) {
          logMap[l.date] = l.activityCount;
        }
        for (var i = 0; i < 35; i++) {
          final day = now.subtract(Duration(days: 34 - i));
          final key =
              '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
          activityData[i] = logMap[key] ?? 0;
        }

        final activeDays = activityData.where((v) => v > 0).length;

        return GlassContainer(
          padding: const EdgeInsets.all(AppSpacing.xl),
          borderRadius: AppRadius.borderRadiusXl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Letzte 5 Wochen',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.10),
                      borderRadius: AppRadius.borderRadiusPill,
                    ),
                    child: Text(
                      '$activeDays / 35 aktiv',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: List.generate(7, (row) {
                      return Container(
                        height: 22,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: Text(
                          _weekdays[row],
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    }),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(5, (col) {
                        return Column(
                          children: List.generate(7, (row) {
                            final index = col * 7 + row;
                            final level = index < activityData.length
                                ? activityData[index]
                                : 0;
                            return Padding(
                              padding: const EdgeInsets.all(1.5),
                              child: Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: _colorForLevel(level),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            );
                          }),
                        );
                      }),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Weniger',
                    style:
                        TextStyle(fontSize: 10, color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  for (var i = 0; i <= 4; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1.5),
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: _colorForLevel(i),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  const SizedBox(width: AppSpacing.sm),
                  const Text(
                    'Mehr',
                    style:
                        TextStyle(fontSize: 10, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  static Color _colorForLevel(int level) => switch (level) {
        0 => AppColors.grey200,
        1 => AppColors.success.withValues(alpha: 0.20),
        2 => AppColors.success.withValues(alpha: 0.40),
        3 => AppColors.success.withValues(alpha: 0.65),
        _ => AppColors.success,
      };
}

// ── Badge grid with progress ─────────────────────────────────────────────────

class _BadgeProgressGrid extends StatelessWidget {
  const _BadgeProgressGrid({
    required this.state,
    required this.isPro,
  });

  final GamificationState state;
  final bool isPro;

  @override
  Widget build(BuildContext context) {
    final badges = BadgeProgressCalculator.computeAll(
      state,
      const ActivityCounts(),
    );

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 0.85,
      children: badges.map((bp) {
        return _BadgeProgressCard(
          badgeProgress: bp,
          showProgress: isPro,
        );
      }).toList(),
    );
  }
}

class _BadgeProgressCard extends StatelessWidget {
  const _BadgeProgressCard({
    required this.badgeProgress,
    required this.showProgress,
  });

  final BadgeProgress badgeProgress;
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    final badge = badgeProgress.badge;
    final earned = badgeProgress.earned;

    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppRadius.borderRadiusXl,
      child: Opacity(
        opacity: earned ? 1.0 : 0.55,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: earned
                    ? badge.color.withValues(alpha: 0.12)
                    : AppColors.grey200,
                shape: BoxShape.circle,
                border: Border.all(
                  color: earned
                      ? badge.color.withValues(alpha: 0.30)
                      : AppColors.grey300,
                  width: 1.5,
                ),
                boxShadow: earned
                    ? [
                        BoxShadow(
                          color: badge.color.withValues(alpha: 0.20),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                badge.icon,
                size: 26,
                color: earned ? badge.color : AppColors.grey400,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              badge.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              badge.description,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                height: 1.3,
              ),
            ),
            if (earned) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.10),
                  borderRadius: AppRadius.borderRadiusPill,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_rounded, size: 10, color: AppColors.success),
                    SizedBox(width: 2),
                    Text(
                      'Verdient',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (showProgress) ...[
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: AppRadius.borderRadiusPill,
                child: LinearProgressIndicator(
                  value: badgeProgress.progress,
                  minHeight: 4,
                  backgroundColor: AppColors.grey200,
                  valueColor: AlwaysStoppedAnimation(badge.color.withValues(alpha: 0.6)),
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                '${badgeProgress.currentValue}/${badgeProgress.targetValue}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: badge.color.withValues(alpha: 0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Milestone list (Pro) ─────────────────────────────────────────────────────

class _MilestoneList extends StatelessWidget {
  const _MilestoneList({required this.milestones});

  final List<MilestoneProgress> milestones;

  @override
  Widget build(BuildContext context) {
    final allDefs = MilestoneCatalog.all;

    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppRadius.borderRadiusXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < allDefs.length; i++) ...[
            _MilestoneRow(
              definition: allDefs[i],
              progress: milestones
                  .where((m) => m.milestoneId == allDefs[i].id)
                  .firstOrNull,
            ),
            if (i < allDefs.length - 1) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(height: 0.5, color: AppColors.grey200),
              const SizedBox(height: AppSpacing.sm),
            ],
          ],
        ],
      ),
    );
  }
}

class _MilestoneRow extends StatelessWidget {
  const _MilestoneRow({required this.definition, this.progress});

  final MilestoneDefinition definition;
  final MilestoneProgress? progress;

  @override
  Widget build(BuildContext context) {
    final isComplete = progress?.status == MilestoneStatus.completed;
    final progressValue = progress?.progressFor(definition) ?? 0.0;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isComplete
                ? definition.color.withValues(alpha: 0.12)
                : AppColors.grey200,
            borderRadius: AppRadius.borderRadiusSm,
            border: Border.all(
              color: isComplete
                  ? definition.color.withValues(alpha: 0.25)
                  : AppColors.grey300,
              width: 0.5,
            ),
          ),
          child: Center(
            child: Icon(
              isComplete ? Icons.check_circle_rounded : definition.icon,
              size: 20,
              color: isComplete ? definition.color : AppColors.grey500,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                definition.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isComplete
                      ? AppColors.textSecondary
                      : AppColors.textPrimary,
                  decoration: isComplete ? TextDecoration.lineThrough : null,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                definition.description,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (!isComplete) ...[
                const SizedBox(height: AppSpacing.xs),
                ClipRRect(
                  borderRadius: AppRadius.borderRadiusPill,
                  child: LinearProgressIndicator(
                    value: progressValue.clamp(0.0, 1.0),
                    minHeight: 4,
                    backgroundColor: AppColors.grey200,
                    valueColor:
                        AlwaysStoppedAnimation(definition.color.withValues(alpha: 0.7)),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        if (isComplete)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.10),
              borderRadius: AppRadius.borderRadiusPill,
            ),
            child: const Text(
              '✓',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.success,
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: definition.color.withValues(alpha: 0.08),
              borderRadius: AppRadius.borderRadiusPill,
            ),
            child: Text(
              '+${definition.xpReward} XP',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: definition.color,
              ),
            ),
          ),
      ],
    );
  }
}

// ── Recent recovery events card (Pro) ────────────────────────────────────────

class _RecentEventsCard extends StatelessWidget {
  const _RecentEventsCard({required this.service});

  final GamificationService service;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<RecoveryEvent>>(
      stream: service.watchRecentEvents(days: 3),
      builder: (context, snap) {
        final events = snap.data ?? [];
        if (events.isEmpty) {
          return GlassContainer(
            padding: const EdgeInsets.all(AppSpacing.xl),
            borderRadius: AppRadius.borderRadiusXl,
            child: const Center(
              child: Text(
                'Noch keine Aktivitäten',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          );
        }

        final shown = events.take(8).toList();
        return GlassContainer(
          padding: const EdgeInsets.all(AppSpacing.lg),
          borderRadius: AppRadius.borderRadiusXl,
          child: Column(
            children: [
              for (var i = 0; i < shown.length; i++) ...[
                _EventRow(event: shown[i]),
                if (i < shown.length - 1) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Container(height: 0.5, color: AppColors.grey200),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ],
            ],
          ),
        );
      },
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.event});

  final RecoveryEvent event;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(event.emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (event.subtitle != null)
                Text(
                  event.subtitle!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        if (event.xpDelta > 0)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: AppRadius.borderRadiusPill,
            ),
            child: Text(
              '+${event.xpDelta}',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }
}

// ── Pro teaser card ──────────────────────────────────────────────────────────

class _ProTeaser extends StatelessWidget {
  const _ProTeaser({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(
        '/paywall',
        arguments: {'source': 'progress_teaser'},
      ),
      child: GlassContainer(
        padding: const EdgeInsets.all(AppSpacing.xl),
        borderRadius: AppRadius.borderRadiusXl,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.accent, AppColors.primary],
                ),
                borderRadius: AppRadius.borderRadiusMd,
              ),
              child: Icon(icon, size: 22, color: AppColors.white),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.10),
                borderRadius: AppRadius.borderRadiusPill,
              ),
              child: const Text(
                'PRO',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.accent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
