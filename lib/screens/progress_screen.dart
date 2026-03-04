import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../ui/ui.dart';

// ── Data models ──────────────────────────────────────────────────────────────

class _Badge {
  const _Badge({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.earned = false,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool earned;
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

// ─────────────────────────────────────────────────────────────────────────────

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  static const _streakDays = 12;
  static const _longestStreak = 18;
  static const _recoveryScore = 74;

  static const _badges = <_Badge>[
    _Badge(
      icon: Icons.local_fire_department_rounded,
      title: '7-Tage Streak',
      subtitle: '7 Tage in Folge dokumentiert',
      color: AppColors.warning,
      earned: true,
    ),
    _Badge(
      icon: Icons.emoji_events_rounded,
      title: 'Erste Woche',
      subtitle: 'Erste Woche nach OP gemeistert',
      color: Color(0xFFFFD700),
      earned: true,
    ),
    _Badge(
      icon: Icons.favorite_rounded,
      title: 'Vital-Profi',
      subtitle: '30× Vitalwerte eingetragen',
      color: AppColors.error,
      earned: true,
    ),
    _Badge(
      icon: Icons.camera_alt_rounded,
      title: 'Foto-Dokumentar',
      subtitle: '14 Wundfotos hochgeladen',
      color: AppColors.primary,
      earned: true,
    ),
    _Badge(
      icon: Icons.medication_rounded,
      title: 'Medikamenten-Held',
      subtitle: 'Keine Einnahme verpasst',
      color: AppColors.success,
      earned: false,
    ),
    _Badge(
      icon: Icons.star_rounded,
      title: '30-Tage Streak',
      subtitle: '30 Tage in Folge aktiv',
      color: AppColors.accent,
      earned: false,
    ),
  ];

  static const _metrics = <_RecoveryMetric>[
    _RecoveryMetric(
      label: 'Checkliste',
      value: 18,
      maxValue: 24,
      unit: 'Aufgaben',
      icon: Icons.checklist_rounded,
      color: AppColors.success,
    ),
    _RecoveryMetric(
      label: 'Mobilität',
      value: 6,
      maxValue: 10,
      unit: 'Punkte',
      icon: Icons.directions_walk_rounded,
      color: AppColors.primary,
    ),
    _RecoveryMetric(
      label: 'Schmerzlevel',
      value: 3,
      maxValue: 10,
      unit: '/ 10',
      icon: Icons.sentiment_satisfied_rounded,
      color: AppColors.warning,
    ),
    _RecoveryMetric(
      label: 'Schlafqualität',
      value: 7,
      maxValue: 10,
      unit: '/ 10',
      icon: Icons.bedtime_rounded,
      color: AppColors.accent,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.grey100,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: AppSpacing.xl,
          right: AppSpacing.xl,
          top: topPadding + AppSpacing.sm,
          bottom: AppSpacing.huge,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(context),
            const SizedBox(height: AppSpacing.xxl),
            const _StreakCard(
              currentStreak: _streakDays,
              longestStreak: _longestStreak,
            ),
            const SizedBox(height: AppSpacing.xxl),
            _sectionTitle(context, 'Recovery Score'),
            const SizedBox(height: AppSpacing.md),
            _RecoveryScoreCard(
              score: _recoveryScore,
              metrics: _metrics,
            ),
            const SizedBox(height: AppSpacing.xxl),
            _sectionTitle(context, 'Aktivität'),
            const SizedBox(height: AppSpacing.md),
            const _HeatmapCard(),
            const SizedBox(height: AppSpacing.xxl),
            _sectionTitle(context, 'Abzeichen'),
            const SizedBox(height: AppSpacing.md),
            _BadgeGrid(badges: _badges),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: GlassContainer(
            padding: const EdgeInsets.all(AppSpacing.sm),
            borderRadius: AppRadius.borderRadiusMd,
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
            'Fortschritt',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
      ],
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
  });

  final int currentStreak;
  final int longestStreak;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.xl),
      borderRadius: AppRadius.borderRadiusXl,
      child: Row(
        children: [
          // Flame icon with glow
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
          // Last 7 day dots
          Column(
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
                  final active = i < 5 || i == 6;
                  return Padding(
                    padding: EdgeInsets.only(
                      left: i > 0 ? AppSpacing.xxs : 0,
                    ),
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.success
                            : AppColors.grey300,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Recovery score card ──────────────────────────────────────────────────────

class _RecoveryScoreCard extends StatelessWidget {
  const _RecoveryScoreCard({
    required this.score,
    required this.metrics,
  });

  final int score;
  final List<_RecoveryMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.xl),
      borderRadius: AppRadius.borderRadiusXl,
      child: Column(
        children: [
          // Score ring
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
            child: const Text(
              'Gute Erholung – weiter so!',
              style: TextStyle(
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
            if (i < metrics.length - 1)
              const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

class _ScoreRingPainter extends CustomPainter {
  _ScoreRingPainter({required this.score});
  final double score;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 14) / 2;
    const strokeWidth = 10.0;

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.grey200
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // Progress arc
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
    final progress = metric.value / metric.maxValue;

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

// ── Heatmap card ─────────────────────────────────────────────────────────────

class _HeatmapCard extends StatelessWidget {
  const _HeatmapCard();

  static final _rng = math.Random(42);

  static final _activityData = List.generate(
    35,
    (i) => _rng.nextInt(5),
  );

  static const _weekdays = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];

  @override
  Widget build(BuildContext context) {
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
                  '${_activityData.where((v) => v > 0).length} / 35 aktiv',
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

          // Grid
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Weekday labels
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
              // Heatmap cells
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(5, (col) {
                    return Column(
                      children: List.generate(7, (row) {
                        final index = col * 7 + row;
                        final level = index < _activityData.length
                            ? _activityData[index]
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

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Weniger',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
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
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
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

// ── Badge grid ───────────────────────────────────────────────────────────────

class _BadgeGrid extends StatelessWidget {
  const _BadgeGrid({required this.badges});

  final List<_Badge> badges;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 0.95,
      children: badges.map((b) => _BadgeCard(badge: b)).toList(),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.badge});

  final _Badge badge;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppRadius.borderRadiusXl,
      child: Opacity(
        opacity: badge.earned ? 1.0 : 0.38,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: badge.earned
                    ? badge.color.withValues(alpha: 0.12)
                    : AppColors.grey200,
                shape: BoxShape.circle,
                border: Border.all(
                  color: badge.earned
                      ? badge.color.withValues(alpha: 0.30)
                      : AppColors.grey300,
                  width: 1.5,
                ),
                boxShadow: badge.earned
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
                color: badge.earned ? badge.color : AppColors.grey400,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
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
              badge.subtitle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                height: 1.3,
              ),
            ),
            if (badge.earned) ...[
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
                    Icon(
                      Icons.check_rounded,
                      size: 10,
                      color: AppColors.success,
                    ),
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
            ],
          ],
        ),
      ),
    );
  }
}
