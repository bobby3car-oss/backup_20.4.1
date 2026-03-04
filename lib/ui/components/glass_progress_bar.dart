import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/glass.dart';
import '../theme/radius.dart';
import '../theme/spacing.dart';

/// An animated progress bar rendered on a frosted-glass track.
///
/// Features rounded ends, gradient fill, and a soft glow on the filled portion.
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
            AppColors.grey200.withValues(alpha: 0.6),
        borderRadius: radius,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final fillWidth = constraints.maxWidth * clampedValue;
          return Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                width: fillWidth,
                decoration: BoxDecoration(
                  gradient: gradient ??
                      const LinearGradient(
                        colors: [
                          Color(0xFF007AFF),
                          Color(0xFF5AC8FA),
                        ],
                      ),
                  color: fillColor,
                  borderRadius: radius,
                  boxShadow: clampedValue > 0.05
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
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
          filter: ImageFilter.blur(
            sigmaX: cfg.sigmaX * 0.3,
            sigmaY: cfg.sigmaY * 0.3,
          ),
          child: track,
        ),
      );
    }

    if (label != null || showPercentage) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (label != null)
                  Text(
                    label!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.1,
                    ),
                  ),
                if (showPercentage)
                  Text(
                    '${(clampedValue * 100).round()} %',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
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
