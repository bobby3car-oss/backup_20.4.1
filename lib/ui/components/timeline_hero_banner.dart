import 'package:flutter/material.dart';

import '../motion/motion.dart';
import '../theme/colors.dart';
import '../theme/radius.dart';
import '../theme/spacing.dart';

// ── Model ────────────────────────────────────────────────────────────────────

class HeroBannerData {
  const HeroBannerData({
    required this.dayLabel,
    required this.encouragementText,
    required this.doneCount,
    required this.totalCount,
    required this.currentStreak,
    required this.todayXp,
    required this.level,
    required this.levelProgress,
    required this.streakMultiplier,
    required this.recentDaysActive,
    this.isPro = false,
  });

  final String dayLabel;
  final String encouragementText;
  final int doneCount;
  final int totalCount;
  final int currentStreak;
  final int todayXp;
  final int level;
  final double levelProgress;
  final double streakMultiplier;

  /// Which of the last 7 days (index 0 = 6 days ago, 6 = today) had activity.
  final List<bool> recentDaysActive;

  final bool isPro;

  double get progress => totalCount == 0 ? 0.0 : doneCount / totalCount;
  int get progressPercent => (progress * 100).round();
}

// ── Widget ───────────────────────────────────────────────────────────────────

class TimelineHeroBanner extends StatelessWidget {
  const TimelineHeroBanner({
    super.key,
    required this.data,
    this.onTap,
    this.onActionsPressed,
  });

  final HeroBannerData data;
  final VoidCallback? onTap;
  final VoidCallback? onActionsPressed;

  static const _borderRadius = BorderRadius.all(Radius.circular(28));

  static const _gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A6EF5), Color(0xFF3D8BFD), Color(0xFF59A5FF)],
    stops: [0.0, 0.55, 1.0],
  );

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: () {
        Haptic.light();
        onTap?.call();
      },
      scaleFactor: 0.975,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: _borderRadius,
          gradient: _gradient,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A6EF5).withValues(alpha: 0.28),
              blurRadius: 32,
              offset: const Offset(0, 12),
              spreadRadius: -6,
            ),
            BoxShadow(
              color: const Color(0xFF1A6EF5).withValues(alpha: 0.10),
              blurRadius: 56,
              offset: const Offset(0, 24),
              spreadRadius: -10,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: _borderRadius,
          child: CustomPaint(
            painter: _HighlightPainter(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                AppSpacing.xxl,
                AppSpacing.xxl,
                AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _topRow(context),
                  const SizedBox(height: AppSpacing.lg + 2),
                  _titleBlock(context),
                  const SizedBox(height: AppSpacing.xl),
                  _streakSection(context),
                  const SizedBox(height: AppSpacing.xl),
                  _progressSection(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Top row: streak fire + chips ───────────────────────────────────────────

  Widget _topRow(BuildContext context) {
    return Row(
      children: [
        // Streak fire badge
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs + 1,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF9500), Color(0xFFFF6B00)],
            ),
            borderRadius: AppRadius.borderRadiusPill,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF9500).withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔥', style: TextStyle(fontSize: 14)),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${data.currentStreak} Tage',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        if (data.isPro && data.streakMultiplier > 1.0)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm + 2,
              vertical: AppSpacing.xs + 1,
            ),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.18),
              borderRadius: AppRadius.borderRadiusPill,
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.22),
                width: 0.5,
              ),
            ),
            child: Text(
              '${data.streakMultiplier.toStringAsFixed(1)}x XP',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xDDFFFFFF),
                letterSpacing: 0.1,
              ),
            ),
          ),
        const Spacer(),
        if (onActionsPressed != null)
          GestureDetector(
            onTap: () {
              Haptic.light();
              onActionsPressed?.call();
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs + 1,
              ),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.20),
                borderRadius: AppRadius.borderRadiusPill,
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.25),
                  width: 0.5,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('⚡', style: TextStyle(fontSize: 12)),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    'Aktionen',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xE6FFFFFF),
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ── Title block ────────────────────────────────────────────────────────────

  Widget _titleBlock(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data.dayLabel,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.white,
            letterSpacing: -0.5,
            height: 1.15,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          data.encouragementText,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Color(0xB3FFFFFF),
            height: 1.3,
          ),
        ),
      ],
    );
  }

  // ── Streak section: 7-day dots + XP/Level pills ───────────────────────────

  Widget _streakSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md + 2),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.10),
        borderRadius: AppRadius.borderRadiusLg,
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.12),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          // 7-day activity dots
          Row(
            children: [
              const Text(
                'Letzte 7 Tage',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0x99FFFFFF),
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              ...List.generate(7, (i) {
                final active = i < data.recentDaysActive.length &&
                    data.recentDaysActive[i];
                return Padding(
                  padding: EdgeInsets.only(left: i > 0 ? AppSpacing.xs : 0),
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: active
                          ? const Color(0xFF4ADE80)
                          : AppColors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                      border: active
                          ? null
                          : Border.all(
                              color: AppColors.white.withValues(alpha: 0.15),
                              width: 0.5,
                            ),
                      boxShadow: active
                          ? [
                              BoxShadow(
                                color: const Color(0xFF4ADE80)
                                    .withValues(alpha: 0.5),
                                blurRadius: 6,
                                spreadRadius: -1,
                              ),
                            ]
                          : null,
                    ),
                  ),
                );
              }),
            ],
          ),
          if (data.isPro) ...[
            const SizedBox(height: AppSpacing.md),
            // XP + Level row for Pro users
            Row(
              children: [
                _GlassPill(
                  emoji: '⚡',
                  text: '+${data.todayXp} XP heute',
                ),
                const SizedBox(width: AppSpacing.sm),
                _GlassPill(
                  emoji: '🎯',
                  text: 'Lv.${data.level} · ${(data.levelProgress * 100).round()}%',
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── Progress section ───────────────────────────────────────────────────────

  Widget _progressSection(BuildContext context) {
    return Column(
      children: [
        // Progress bar
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.16),
            borderRadius: AppRadius.borderRadiusPill,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final fillWidth = constraints.maxWidth * data.progress;
              return Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    width: fillWidth,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xF2FFFFFF), Color(0xD9FFFFFF)],
                      ),
                      borderRadius: AppRadius.borderRadiusPill,
                      boxShadow: data.progress > 0.02
                          ? [
                              BoxShadow(
                                color: AppColors.white.withValues(alpha: 0.45),
                                blurRadius: 10,
                                offset: const Offset(0, 1),
                              ),
                            ]
                          : null,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.sm + 4),
        Row(
          children: [
            Text(
              '${data.doneCount} von ${data.totalCount} erledigt',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xAAFFFFFF),
                letterSpacing: 0.05,
              ),
            ),
            const Spacer(),
            Text(
              '${data.progressPercent}%',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xDDFFFFFF),
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Glass pill ───────────────────────────────────────────────────────────────

class _GlassPill extends StatelessWidget {
  const _GlassPill({required this.emoji, required this.text});

  final String emoji;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.12),
        borderRadius: AppRadius.borderRadiusPill,
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.15),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: AppSpacing.xs),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xCCFFFFFF),
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Highlight painter ────────────────────────────────────────────────────────

class _HighlightPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Top-left radial glow
    final topGlow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.7, -0.9),
        radius: 0.8,
        colors: [
          AppColors.white.withValues(alpha: 0.14),
          AppColors.white.withValues(alpha: 0.0),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, topGlow);

    // Bottom-right warm glow
    final bottomGlow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.8, 1.0),
        radius: 0.7,
        colors: [
          AppColors.white.withValues(alpha: 0.06),
          AppColors.white.withValues(alpha: 0.0),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, bottomGlow);

    // Top edge highlight line
    final topLine = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          AppColors.white.withValues(alpha: 0.0),
          AppColors.white.withValues(alpha: 0.30),
          AppColors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.05, 0.5, 0.95],
      ).createShader(Offset.zero & Size(size.width, 1))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    canvas.drawLine(const Offset(0, 0.5), Offset(size.width, 0.5), topLine);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
