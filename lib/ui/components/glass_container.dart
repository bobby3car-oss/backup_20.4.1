import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/glass.dart';
import '../theme/radius.dart';
import '../theme/spacing.dart';

/// A frosted-glass surface that adapts its blur intensity per platform.
///
/// [variant] controls glass thickness (thin / medium / thick).
/// [elevation] controls shadow depth (flat / low / medium / high).
/// Both default sensibly when omitted.
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.color,
    this.config,
    this.width,
    this.height,
    this.variant = GlassVariant.medium,
    this.elevation,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? color;
  final GlassConfig? config;
  final double? width;
  final double? height;
  final GlassVariant variant;
  final GlassElevation? elevation;

  @override
  Widget build(BuildContext context) {
    final cfg = config ?? GlassConfig.platform;
    final radius = borderRadius ?? AppRadius.borderRadiusLg;
    final elev = elevation ?? variant.defaultElevation;

    final fillAlpha = (cfg.fillOpacity + variant.fillBoost).clamp(0.0, 1.0);
    final borderAlpha =
        (cfg.borderOpacity + variant.borderBoost).clamp(0.0, 1.0);
    final fillColor = color ?? AppColors.white.withValues(alpha: fillAlpha);

    Widget surface = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          // Main diffuse shadow
          if (elev != GlassElevation.flat)
            BoxShadow(
              color: AppColors.black.withValues(alpha: elev.opacity),
              blurRadius: elev.blurRadius,
              offset: Offset(0, elev.yOffset),
              spreadRadius: elev.spreadRadius,
            ),
          // Secondary ambient shadow for depth
          if (elev.index >= GlassElevation.medium.index)
            BoxShadow(
              color: AppColors.black.withValues(alpha: elev.opacity * 0.3),
              blurRadius: elev.blurRadius * 0.5,
              offset: Offset(0, elev.yOffset * 0.3),
            ),
        ],
      ),
      child: CustomPaint(
        painter: _GlassEdgePainter(
          radius: radius,
          topEdgeAlpha: variant.topEdgeAlpha,
          bottomEdgeAlpha: variant.bottomEdgeAlpha,
        ),
        child: Container(
          padding: padding ?? AppSpacing.cardPadding,
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: radius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.white.withValues(alpha: variant.highlightAlpha),
                AppColors.white.withValues(alpha: variant.highlightAlpha * 0.15),
              ],
            ),
            border: Border.all(
              color: AppColors.white.withValues(alpha: borderAlpha),
              width: 0.5,
            ),
          ),
          child: child,
        ),
      ),
    );

    if (!cfg.useBlur) return surface;

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: cfg.sigmaX, sigmaY: cfg.sigmaY),
        child: surface,
      ),
    );
  }
}

/// Paints a subtle top highlight edge and a darker bottom edge to simulate
/// a 3-D glass surface lit from above.
class _GlassEdgePainter extends CustomPainter {
  _GlassEdgePainter({
    required this.radius,
    required this.topEdgeAlpha,
    required this.bottomEdgeAlpha,
  });

  final BorderRadius radius;
  final double topEdgeAlpha;
  final double bottomEdgeAlpha;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = radius.resolve(TextDirection.ltr).toRRect(
      Rect.fromLTWH(0.5, 0.5, size.width - 1, size.height - 1),
    );

    // Top highlight: 1px bright edge
    final topPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [0.0, 0.06],
        colors: [
          Colors.white.withValues(alpha: topEdgeAlpha),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawRRect(rrect, topPaint);

    // Bottom darkening edge
    if (bottomEdgeAlpha > 0) {
      final bottomPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.92, 1.0],
          colors: [
            Colors.black.withValues(alpha: 0.0),
            Colors.black.withValues(alpha: bottomEdgeAlpha),
          ],
        ).createShader(Offset.zero & size)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      canvas.drawRRect(rrect, bottomPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GlassEdgePainter old) =>
      old.topEdgeAlpha != topEdgeAlpha || old.bottomEdgeAlpha != bottomEdgeAlpha;
}
