import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/glass.dart';
import '../theme/radius.dart';
import '../theme/spacing.dart';

enum GlassButtonVariant { primary, secondary, ghost }

/// A button rendered on a frosted‑glass surface.
///
/// [variant] controls fill:
/// - **primary** – gradient‑filled, white text.
/// - **secondary** – translucent glass fill.
/// - **ghost** – fully transparent, border only.
class GlassButton extends StatefulWidget {
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
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cfg = GlassConfig.platform;
    final disabled = widget.onPressed == null;

    final Color foreground;
    final Decoration decoration;

    switch (widget.variant) {
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
      mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading)
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
        else if (widget.icon != null) ...[
          Icon(widget.icon, size: 18, color: foreground),
          const SizedBox(width: AppSpacing.sm),
        ],
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
            color: foreground,
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

    if (widget.variant == GlassButtonVariant.secondary && cfg.useBlur) {
      button = ClipRRect(
        borderRadius: AppRadius.borderRadiusPill,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: cfg.sigmaX, sigmaY: cfg.sigmaY),
          child: button,
        ),
      );
    }

    return GestureDetector(
      onTapDown: disabled ? null : (_) => _controller.forward(),
      onTapUp: disabled
          ? null
          : (_) {
              _controller.reverse();
              widget.onPressed?.call();
            },
      onTapCancel: disabled ? null : () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: Opacity(
            opacity: disabled ? 0.45 : 1.0,
            child: child,
          ),
        ),
        child: button,
      ),
    );
  }
}
