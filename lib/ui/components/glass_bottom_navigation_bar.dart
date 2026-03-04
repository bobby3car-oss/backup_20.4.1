import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/glass.dart';
import '../theme/radius.dart';
import '../theme/spacing.dart';
import 'glass_bottom_navigation.dart';

/// A floating frosted‑glass bottom navigation bar with an animated
/// selection bubble that slides behind the active tab.
///
/// Sits above the screen edge with rounded corners and soft shadow,
/// adapts blur intensity per platform via [GlassConfig].
///
/// On wider screens (≥ 600 dp) the bar caps at 480 px and centers itself,
/// keeping the layout clean on tablets and web.
class GlassBottomNavigationBar extends StatelessWidget {
  const GlassBottomNavigationBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<GlassNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  static const double _barHeight = 68;
  static const double _maxWidth = 480;

  @override
  Widget build(BuildContext context) {
    final cfg = GlassConfig.platform;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 600;

    final horizontalMargin =
        isWide ? (screenWidth - _maxWidth) / 2 : AppSpacing.lg;

    Widget bar = Container(
      height: _barHeight,
      margin: EdgeInsets.only(
        left: horizontalMargin.clamp(AppSpacing.lg, double.infinity),
        right: horizontalMargin.clamp(AppSpacing.lg, double.infinity),
        bottom: bottomPadding + AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: cfg.fillOpacity + 0.12),
        borderRadius: AppRadius.borderRadiusXxl,
        border: Border.all(
          color: AppColors.white.withValues(alpha: cfg.borderOpacity + 0.08),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: cfg.shadowOpacity + 0.04),
            blurRadius: 32,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _TabRow(
        items: items,
        currentIndex: currentIndex,
        onTap: onTap,
      ),
    );

    if (!cfg.useBlur) return bar;

    return Padding(
      padding: EdgeInsets.only(
        left: horizontalMargin.clamp(AppSpacing.lg, double.infinity),
        right: horizontalMargin.clamp(AppSpacing.lg, double.infinity),
        bottom: bottomPadding + AppSpacing.md,
      ),
      child: ClipRRect(
        borderRadius: AppRadius.borderRadiusXxl,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: cfg.sigmaX, sigmaY: cfg.sigmaY),
          child: Container(
            height: _barHeight,
            decoration: BoxDecoration(
              color:
                  AppColors.white.withValues(alpha: cfg.fillOpacity + 0.12),
              borderRadius: AppRadius.borderRadiusXxl,
              border: Border.all(
                color: AppColors.white
                    .withValues(alpha: cfg.borderOpacity + 0.08),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black
                      .withValues(alpha: cfg.shadowOpacity + 0.04),
                  blurRadius: 32,
                  offset: const Offset(0, 8),
                  spreadRadius: -4,
                ),
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _TabRow(
              items: items,
              currentIndex: currentIndex,
              onTap: onTap,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _TabRow extends StatelessWidget {
  const _TabRow({
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<GlassNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tabWidth = constraints.maxWidth / items.length;

        return Stack(
          children: [
            // ── Animated selection bubble ──────────────────────────
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              left: currentIndex * tabWidth + tabWidth * 0.12,
              top: 8,
              width: tabWidth * 0.76,
              height: constraints.maxHeight - 16,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: AppRadius.borderRadiusXl,
                ),
              ),
            ),

            // ── Tab items ─────────────────────────────────────────
            Row(
              children: List.generate(items.length, (i) {
                final selected = i == currentIndex;
                final item = items[i];

                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onTap(i),
                    child: _TabItem(
                      icon: selected
                          ? item.activeIcon ?? item.icon
                          : item.icon,
                      label: item.label,
                      selected: selected,
                    ),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.icon,
    required this.label,
    required this.selected,
  });

  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedScale(
          scale: selected ? 1.1 : 1.0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          child: Icon(
            icon,
            size: 24,
            color: selected ? AppColors.primary : AppColors.grey500,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 250),
          style: TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? AppColors.primary : AppColors.grey500,
            letterSpacing: -0.1,
          ),
          child: Text(label),
        ),
      ],
    );
  }
}
