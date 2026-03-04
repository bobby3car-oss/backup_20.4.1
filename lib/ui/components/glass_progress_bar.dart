import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/glass.dart';
import '../theme/radius.dart';
import '../theme/spacing.dart';

/// An animated progress bar rendered on a frosted‑glass track.
class GlassProgressBar extends StatelessWidget {
  const GlassProgressBar({
    super.key,
    required this.value,
    this.height = 8,
    this.trackColor,
    this.fillColor,
    this.gradient,
    this.label,
    this.showPercentage = false,
    this.borderRadius,
  });

  /// Progress from 0.0 to 1.0.
  final double value;
  final double height;
  final Color? trackColor;
  final Color? fillColor;
  final Gradient? gradient;
  final String? label;
  final bool showPercentage;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final cfg = GlassConfig.platform;
    final radius = borderRadius ?? AppRadius.borderRadiusPill;
    final clampedValue = value.clamp(0.0, 1.0);

    Widget track = Container(
      height: height,
      decoration: BoxDecoration(
        color: trackColor ??
            AppColors.white.withValues(alpha: cfg.fillOpacity),
        borderRadius: radius,
        border: Border.all(
          color: AppColors.white.withValues(alpha: cfg.borderOpacity),
          width: 0.5,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                width: constraints.maxWidth * clampedValue,
                decoration: BoxDecoration(
                  gradient: gradient ?? AppColors.primaryGradient,
                  color: fillColor,
                  borderRadius: radius,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.30),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    if (cfg.useBlur) {
      track = ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: cfg.sigmaX, sigmaY: cfg.sigmaY),
          child: track,
        ),
      );
    }

    if (label != null || showPercentage) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null || showPercentage)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (label != null)
                    Text(
                      label!,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  if (showPercentage)
                    Text(
                      '${(clampedValue * 100).round()}%',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                ],
              ),
            ),
          track,
        ],
      );
    }

    return track;
  }
}
