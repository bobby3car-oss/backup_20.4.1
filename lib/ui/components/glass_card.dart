import 'package:flutter/material.dart';

import '../motion/motion.dart';
import '../theme/glass.dart';
import '../theme/radius.dart';
import '../theme/spacing.dart';
import 'glass_container.dart';

/// A higher-level glass card with title / subtitle / trailing support.
///
/// Use this as a drop-in replacement for [Card] with a frosted glass look.
/// [variant] defaults to [GlassVariant.medium]; use `.thick` for hero cards.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.borderRadius,
    this.variant = GlassVariant.medium,
    this.elevation,
  });

  final Widget? title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final Widget? child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final GlassVariant variant;
  final GlassElevation? elevation;

  @override
  Widget build(BuildContext context) {
    final content =
        child ??
        Row(
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: AppSpacing.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ?title,
                  if (subtitle != null) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    subtitle!,
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: AppSpacing.md),
              trailing!,
            ],
          ],
        );

    Widget card = GlassContainer(
      padding: padding ?? AppSpacing.cardPadding,
      borderRadius: borderRadius ?? AppRadius.borderRadiusLg,
      variant: variant,
      elevation: elevation,
      child: content,
    );

    if (onTap != null) {
      card = PressableScale(onTap: onTap, child: card);
    }

    return Padding(padding: margin ?? AppSpacing.paddingSm, child: card);
  }
}
