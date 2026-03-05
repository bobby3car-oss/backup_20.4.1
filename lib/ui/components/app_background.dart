import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/colors.dart';

/// A premium background layer with a vertical gradient, two radial light spots,
/// and a subtle noise overlay. Wrap screen content in this widget on main
/// screens for depth and visual hierarchy.
///
/// The top spot illuminates the hero card area while a softer bottom spot
/// lifts the navigation zone, preventing the lower half from going too flat.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.15, 0.50, 0.80, 1.0],
                colors: [
                  const Color(0xFFF1F2F7),
                  const Color(0xFFEEEFF5),
                  AppColors.background,
                  const Color(0xFFE7E9F0),
                  const Color(0xFFE2E4EB),
                ],
              ),
            ),
          ),
        ),

        Positioned.fill(child: CustomPaint(painter: _DualSpotPainter())),

        Positioned.fill(child: CustomPaint(painter: _NoisePainter())),

        Positioned.fill(child: child),
      ],
    );
  }
}

/// Paints two radial light spots: a warm blue-tinted glow behind the top
/// hero area and a cooler, fainter glow near the bottom nav.
class _DualSpotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // ── Top spot (hero area) ────────────────────────────────────
    final topCenter = Offset(size.width * 0.5, size.height * 0.18);
    final topRadius = size.longestSide * 0.55;

    final topPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.primaryLight.withValues(alpha: 0.07),
          AppColors.primaryLight.withValues(alpha: 0.025),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: topCenter, radius: topRadius));

    canvas.drawCircle(topCenter, topRadius, topPaint);

    // ── Bottom spot (nav area) ──────────────────────────────────
    final bottomCenter = Offset(size.width * 0.5, size.height * 0.92);
    final bottomRadius = size.longestSide * 0.35;

    final bottomPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.035),
              AppColors.primary.withValues(alpha: 0.01),
              Colors.transparent,
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(
            Rect.fromCircle(center: bottomCenter, radius: bottomRadius),
          );

    canvas.drawCircle(bottomCenter, bottomRadius, bottomPaint);
  }

  @override
  bool shouldRepaint(covariant _DualSpotPainter old) => false;
}

class _NoisePainter extends CustomPainter {
  static const _dotCount = 400;
  static final _rng = math.Random(7);
  static final _dots = List.generate(_dotCount, (_) {
    return Offset(_rng.nextDouble(), _rng.nextDouble());
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.012)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    for (final dot in _dots) {
      canvas.drawPoints(ui.PointMode.points, [
        Offset(dot.dx * size.width, dot.dy * size.height),
      ], paint);
    }
  }

  @override
  bool shouldRepaint(covariant _NoisePainter old) => false;
}
