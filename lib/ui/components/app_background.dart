import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/colors.dart';

/// A premium background layer with a subtle vertical gradient and a soft
/// radial light spot. Wrap screen content in this widget on main screens
/// for depth and visual hierarchy.
///
/// [spotAlignment] controls where the radial glow appears (defaults to
/// top-center, behind the hero card area).
class AppBackground extends StatelessWidget {
  const AppBackground({
    super.key,
    required this.child,
    this.spotAlignment = const Alignment(0.0, -0.55),
    this.spotRadius = 0.55,
    this.spotOpacity = 0.08,
  });

  final Widget child;
  final Alignment spotAlignment;
  final double spotRadius;
  final double spotOpacity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Vertical gradient base
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.25, 0.7, 1.0],
                colors: [
                  const Color(0xFFFCFCFD),
                  AppColors.grey50,
                  AppColors.grey100,
                  const Color(0xFFECECF1),
                ],
              ),
            ),
          ),
        ),

        // Radial light spot
        Positioned.fill(
          child: CustomPaint(
            painter: _RadialSpotPainter(
              alignment: spotAlignment,
              radius: spotRadius,
              opacity: spotOpacity,
            ),
          ),
        ),

        // Subtle noise overlay (very cheap: just a few faint dots via paint)
        Positioned.fill(
          child: CustomPaint(
            painter: _NoisePainter(),
          ),
        ),

        // Actual content
        Positioned.fill(child: child),
      ],
    );
  }
}

class _RadialSpotPainter extends CustomPainter {
  _RadialSpotPainter({
    required this.alignment,
    required this.radius,
    required this.opacity,
  });

  final Alignment alignment;
  final double radius;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final center = alignment.alongSize(size);
    final r = size.longestSide * radius;

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.primaryLight.withValues(alpha: opacity),
          AppColors.primaryLight.withValues(alpha: opacity * 0.3),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: r));

    canvas.drawCircle(center, r, paint);
  }

  @override
  bool shouldRepaint(covariant _RadialSpotPainter old) =>
      old.alignment != alignment ||
      old.radius != radius ||
      old.opacity != opacity;
}

/// Very lightweight pseudo-noise: scatters a fixed set of semi-transparent
/// dots across the canvas. No image assets or packages needed.
class _NoisePainter extends CustomPainter {
  static const _dotCount = 400;
  static final _rng = math.Random(7);
  static final _dots = List.generate(_dotCount, (_) {
    return Offset(
      _rng.nextDouble(),
      _rng.nextDouble(),
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.012)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    for (final dot in _dots) {
      canvas.drawPoints(
        ui.PointMode.points,
        [Offset(dot.dx * size.width, dot.dy * size.height)],
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _NoisePainter old) => false;
}
