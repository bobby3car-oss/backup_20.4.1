import 'dart:ui';

import 'package:flutter/material.dart';

import '../motion/motion.dart';
import '../theme/colors.dart';
import '../theme/glass.dart';
import '../theme/radius.dart';
import '../theme/spacing.dart';
import 'glass_bottom_navigation.dart';

/// A floating frosted-glass bottom navigation bar with an animated
/// selection bubble that slides behind the active tab.
///
/// Sits above the screen edge with rounded corners and soft shadow,
/// adapts blur intensity per platform via [GlassConfig].
///
/// On wider screens (>= 600 dp) the bar caps at 480 px and centers itself,
/// keeping the layout clean on tablets and web.
///
/// Hides automatically when the software keyboard is open.
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

  static const double _barHeight = 72;
  static const double _maxWidth = 480;

  @override
  Widget build(BuildContext context) {
    final cfg = GlassConfig.platform;
    final mq = MediaQuery.of(context);
    final bottomPadding = mq.padding.bottom;
    final screenWidth = mq.size.width;
    final isWide = screenWidth >= 600;
    final keyboardOpen = mq.viewInsets.bottom > 80;

    final horizontalMargin = isWide
        ? (screenWidth - _maxWidth) / 2
        : AppSpacing.lg;
    final clampedMargin = horizontalMargin.clamp(
      AppSpacing.lg,
      double.infinity,
    );

    final edgeInsets = EdgeInsets.only(
      left: clampedMargin,
      right: clampedMargin,
      bottom: bottomPadding + AppSpacing.md,
    );

    final fillAlpha = (cfg.fillOpacity + 0.18).clamp(0.0, 1.0);
    final borderAlpha = (cfg.borderOpacity + 0.12).clamp(0.0, 1.0);

    final decoration = BoxDecoration(
      color: AppColors.white.withValues(alpha: fillAlpha),
      borderRadius: AppRadius.borderRadiusXxl,
      border: Border.all(
        color: AppColors.white.withValues(alpha: borderAlpha),
        width: 0.5,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.black.withValues(alpha: 0.10),
          blurRadius: 40,
          offset: const Offset(0, 10),
          spreadRadius: -6,
        ),
        BoxShadow(
          color: AppColors.black.withValues(alpha: 0.04),
          blurRadius: 12,
          offset: const Offset(0, 2),
        ),
      ],
    );

    final tabRow = _TabRow(
      items: items,
      currentIndex: currentIndex,
      onTap: onTap,
    );

    Widget bar;

    if (!cfg.useBlur) {
      bar = Container(
        height: _barHeight,
        margin: edgeInsets,
        decoration: decoration,
        child: tabRow,
      );
    } else {
      final blurSigma = cfg.sigmaX * 1.2;

      bar = Padding(
        padding: edgeInsets,
        child: ClipRRect(
          borderRadius: AppRadius.borderRadiusXxl,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: Container(
              height: _barHeight,
              decoration: decoration,
              child: tabRow,
            ),
          ),
        ),
      );
    }

    return AnimatedSlide(
      duration: MotionDuration.medium,
      curve: keyboardOpen ? MotionCurve.standard : MotionCurve.emphasized,
      offset: keyboardOpen ? const Offset(0, 1.5) : Offset.zero,
      child: AnimatedOpacity(
        duration: MotionDuration.fast,
        opacity: keyboardOpen ? 0.0 : 1.0,
        child: bar,
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
            // ── Animated selection bubble ────────────────────────
            AnimatedPositioned(
              duration: const Duration(milliseconds: 240),
              curve: MotionCurve.emphasized,
              left: currentIndex * tabWidth + tabWidth * 0.10,
              top: 8,
              width: tabWidth * 0.80,
              height: constraints.maxHeight - 16,
              child: _SelectionBubble(key: const ValueKey('bubble')),
            ),

            // ── Active tab top-edge accent ───────────────────────
            ...List.generate(items.length, (i) {
              final isActive = i == currentIndex;
              return AnimatedPositioned(
                duration: const Duration(milliseconds: 240),
                curve: MotionCurve.emphasized,
                left: i * tabWidth + tabWidth / 2 - 14,
                top: 0,
                width: 28,
                height: 3,
                child: AnimatedOpacity(
                  opacity: isActive ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(3),
                      ),
                    ),
                  ),
                ),
              );
            }),

            // ── Tab items ───────────────────────────────────────
            Row(
              children: List.generate(items.length, (i) {
                final selected = i == currentIndex;
                final item = items[i];

                Widget tab = PressableScale(
                    scaleFactor: 0.90,
                    onTap: () {
                      Haptic.light();
                      onTap(i);
                    },
                    child: SizedBox.expand(
                      child: _TabItem(
                        icon: selected
                            ? item.activeIcon ?? item.icon
                            : item.icon,
                        label: item.label,
                        selected: selected,
                      ),
                    ),
                );

                if (item.tutorialKey != null) {
                  tab = KeyedSubtree(
                    key: item.tutorialKey,
                    child: tab,
                  );
                }

                return Expanded(child: tab);
              }),
            ),
          ],
        );
      },
    );
  }
}

// ── Selection bubble ─────────────────────────────────────────────────────────

class _SelectionBubble extends StatelessWidget {
  const _SelectionBubble({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.13),
        borderRadius: AppRadius.borderRadiusXl,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.20),
          width: 0.5,
        ),
      ),
    );
  }
}

// ── Tab item ─────────────────────────────────────────────────────────────────

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
        // Icon: scale + opacity + color
        AnimatedScale(
          scale: selected ? 1.15 : 0.95,
          duration: const Duration(milliseconds: 240),
          curve: MotionCurve.emphasized,
          child: AnimatedOpacity(
            opacity: selected ? 1.0 : 0.35,
            duration: MotionDuration.medium,
            curve: MotionCurve.standard,
            child: Icon(
              icon,
              size: 26,
              color: selected ? AppColors.primary : AppColors.grey600,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),

        // Label: style + opacity
        AnimatedOpacity(
          opacity: selected ? 1.0 : 0.35,
          duration: MotionDuration.medium,
          curve: MotionCurve.standard,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 240),
            curve: MotionCurve.standard,
            style: TextStyle(
              fontSize: selected ? 11 : 10.5,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? AppColors.primary : AppColors.grey600,
              letterSpacing: selected ? -0.1 : 0,
            ),
            child: Text(label),
          ),
        ),
      ],
    );
  }
}
