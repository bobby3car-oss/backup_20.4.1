import 'package:flutter/material.dart';

import '../theme/radius.dart';
import '../theme/spacing.dart';
import 'glass_container.dart';

/// A higher‑level glass card with title / subtitle / trailing support.
///
/// Use this as a drop‑in replacement for [Card] with a frosted glass look.
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

  @override
  Widget build(BuildContext context) {
    final content = child ??
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

    return Padding(
      padding: margin ?? AppSpacing.paddingSm,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: GlassContainer(
          padding: padding ?? AppSpacing.cardPadding,
          borderRadius: borderRadius ?? AppRadius.borderRadiusLg,
          child: content,
        ),
      ),
    );
  }
}
