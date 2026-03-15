import 'dart:ui';

import 'package:flutter/material.dart';

import '../motion/motion.dart';
import '../theme/colors.dart';
import '../theme/glass.dart';
import '../theme/radius.dart';
import '../theme/spacing.dart';

enum GlassButtonVariant { primary, secondary, ghost }

/// A button rendered on a frosted-glass surface.
///
/// [variant] controls fill:
/// - **primary** – gradient-filled, white text.
/// - **secondary** – translucent glass fill.
/// - **ghost** – fully transparent, border only.
///
/// Uses [PressableScale] for a tactile iOS-like press animation.
class GlassButton extends StatelessWidget {
  const GlassButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.variant = GlassButtonVariant.primary,
    this.isLoading = false,
    this.expand = false,
  });

  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;
  final GlassButtonVariant variant;
  final bool isLoading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final cfg = GlassConfig.platform;
    final disabled = onPressed == null;

    final Color foreground;
    final Decoration decoration;

    switch (variant) {
      case GlassButtonVariant.primary:
        foreground = AppColors.textOnPrimary;
        decoration = BoxDecoration(
          gradient: disabled ? null : AppColors.primaryGradient,
          color: disabled ? AppColors.grey300 : null,
          borderRadius: AppRadius.borderRadiusPill,
          boxShadow: disabled
              ? null
              : [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        );
      case GlassButtonVariant.secondary:
        foreground = AppColors.textPrimary;
        decoration = BoxDecoration(
          color: AppColors.white.withValues(alpha: cfg.fillOpacity),
          borderRadius: AppRadius.borderRadiusPill,
          border: Border.all(
            color: AppColors.white.withValues(alpha: cfg.borderOpacity),
            width: 0.5,
          ),
        );
      case GlassButtonVariant.ghost:
        foreground = AppColors.primary;
        decoration = BoxDecoration(
          color: Colors.transparent,
          borderRadius: AppRadius.borderRadiusPill,
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1,
          ),
        );
    }

    Widget inner = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: foreground,
              ),
            ),
          )
        else if (icon != null) ...[
          Icon(icon, size: 18, color: foreground),
          const SizedBox(width: AppSpacing.sm),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.1,
              color: foreground,
            ),
          ),
        ),
      ],
    );

    Widget button = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.md,
      ),
      decoration: decoration,
      child: inner,
    );

    if (variant == GlassButtonVariant.secondary && cfg.useBlur) {
      button = ClipRRect(
        borderRadius: AppRadius.borderRadiusPill,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: cfg.sigmaX, sigmaY: cfg.sigmaY),
          child: button,
        ),
      );
    }

    return Opacity(
      opacity: disabled ? 0.45 : 1.0,
      child: PressableScale(
        onTap: onPressed,
        enabled: !disabled,
        scaleFactor: 0.96,
        child: button,
      ),
    );
  }
}
