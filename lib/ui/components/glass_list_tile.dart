import 'package:flutter/material.dart';

import '../motion/motion.dart';
import '../theme/colors.dart';
import '../theme/glass.dart';
import '../theme/radius.dart';
import '../theme/spacing.dart';
import 'glass_container.dart';

/// A list-tile rendered on a frosted-glass surface.
///
/// Drop-in alternative to [ListTile] with the glass design system.
/// Defaults to [GlassVariant.thin] for a lighter, list-appropriate weight.
class GlassListTile extends StatelessWidget {
  const GlassListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.borderRadius,
    this.showDivider = false,
    this.dense = false,
    this.variant = GlassVariant.thin,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final bool showDivider;
  final bool dense;
  final GlassVariant variant;

  @override
  Widget build(BuildContext context) {
    final verticalPadding = dense ? AppSpacing.sm : AppSpacing.md;

    Widget tile = GlassContainer(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: verticalPadding,
      ),
      borderRadius: borderRadius ?? AppRadius.borderRadiusMd,
      variant: variant,
      elevation: GlassElevation.low,
      child: Row(
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
                DefaultTextStyle.merge(
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  child: title,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  DefaultTextStyle.merge(
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                    child: subtitle!,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.sm),
            trailing!,
          ] else
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.grey400,
              size: 20,
            ),
        ],
      ),
    );

    if (onTap != null) {
      tile = PressableScale(onTap: onTap, scaleFactor: 0.98, child: tile);
    }

    if (showDivider) {
      tile = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          tile,
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.huge),
            child: Divider(
              height: 0.5,
              thickness: 0.5,
              color: AppColors.grey200.withValues(alpha: 0.6),
            ),
          ),
        ],
      );
    }

    return tile;
  }
}
