import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/glass.dart';
import '../theme/spacing.dart';

/// A bottom navigation bar rendered on a frosted‑glass surface.
class GlassBottomNavigation extends StatelessWidget {
  const GlassBottomNavigation({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<GlassNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final cfg = GlassConfig.platform;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    Widget bar = Container(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.sm,
        bottom: AppSpacing.sm + bottomPadding,
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: cfg.fillOpacity + 0.05),
        border: Border(
          top: BorderSide(
            color: AppColors.white.withValues(alpha: cfg.borderOpacity),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final selected = i == currentIndex;
          final item = items[i];
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(i),
              child: Padding(
                padding: AppSpacing.paddingVerticalSm,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary.withValues(alpha: 0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppSpacing.lg),
                      ),
                      child: Icon(
                        selected ? item.activeIcon ?? item.icon : item.icon,
                        size: 22,
                        color: selected ? AppColors.primary : AppColors.grey600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: selected ? AppColors.primary : AppColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );

    if (!cfg.useBlur) return bar;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: cfg.sigmaX, sigmaY: cfg.sigmaY),
        child: bar,
      ),
    );
  }
}

class GlassNavItem {
  const GlassNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.tutorialKey,
  });

  final IconData icon;
  final IconData? activeIcon;
  final String label;

  /// Optional [GlobalKey] used by the onboarding tutorial to spotlight
  /// this tab with a coach mark.
  final GlobalKey? tutorialKey;
}
