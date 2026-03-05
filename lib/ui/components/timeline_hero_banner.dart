import 'package:flutter/material.dart';

import '../motion/motion.dart';
import '../theme/colors.dart';
import '../theme/radius.dart';
import '../theme/spacing.dart';

// ── Model ────────────────────────────────────────────────────────────────────

class HeroBannerData {
  const HeroBannerData({
    required this.opTypeLabel,
    required this.locationLabel,
    required this.dayLabel,
    required this.encouragementText,
    required this.dateLabel,
    required this.doneCount,
    required this.totalCount,
  });

  final String opTypeLabel;
  final String locationLabel;
  final String dayLabel;
  final String encouragementText;
  final String dateLabel;
  final int doneCount;
  final int totalCount;

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
                  const SizedBox(height: AppSpacing.xl + 2),
                  _progressSection(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Top row: type label + date chip ────────────────────────────────────────

  Widget _topRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '${data.opTypeLabel} · ${data.locationLabel}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xB3FFFFFF),
              letterSpacing: 0.2,
            ),
          ),
        ),
        if (onActionsPressed != null)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: GestureDetector(
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
          ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs + 1,
          ),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.15),
            borderRadius: AppRadius.borderRadiusPill,
            border: Border.all(
              color: AppColors.white.withValues(alpha: 0.18),
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 13,
                color: Color(0xCCFFFFFF),
              ),
              const SizedBox(width: AppSpacing.xs + 1),
              Text(
                data.dateLabel,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xCCFFFFFF),
                  letterSpacing: 0.1,
                ),
              ),
            ],
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

        // Counter row — clearer typography
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

    // Bottom-right warm glow for dimension
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

    // Top edge highlight line — stronger for crisp depth
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
