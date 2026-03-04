import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/glass.dart';
import '../theme/radius.dart';
import '../theme/spacing.dart';

/// A frosted‑glass surface that adapts its blur intensity per platform.
///
/// Wrap any content to give it an iOS‑style translucent backdrop.
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
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? color;
  final GlassConfig? config;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final cfg = config ?? GlassConfig.platform;
    final radius = borderRadius ?? AppRadius.borderRadiusLg;
    final fillColor =
        color ?? AppColors.white.withValues(alpha: cfg.fillOpacity);

    Widget surface = Container(
      width: width,
      height: height,
      padding: padding ?? AppSpacing.cardPadding,
      margin: margin,
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: radius,
        gradient: AppColors.glassHighlight,
        border: Border.all(
          color: AppColors.white.withValues(alpha: cfg.borderOpacity),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: cfg.shadowOpacity),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: child,
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
