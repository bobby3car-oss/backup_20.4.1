import 'dart:ui';

import 'package:flutter/material.dart';

import '../motion/motion.dart';
import '../theme/colors.dart';
import '../theme/glass.dart';
import '../theme/spacing.dart';
import 'glass_bottom_navigation.dart';

/// Instagram-style floating glass bottom navigation pill.
///
/// **Expanded** (default): Icons + labels in a full-width glass bar.
/// **Compact** (on scroll): Shrinks to a narrow icon-only pill centered
/// at the bottom — similar to Instagram's dynamic nav that collapses
/// when scrolling down and reappears when scrolling up.
///
/// Hides automatically when the software keyboard is open.
class GlassBottomNavigationBar extends StatelessWidget {
  const GlassBottomNavigationBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.compact = false,
  });

  final List<GlassNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  /// When true the bar collapses to a compact icon-only pill.
  final bool compact;

  // ── Dimensions ──────────────────────────────────────────────
  static const double _expandedHeight = 64;
  static const double _compactHeight = 48;
  /// Per-icon slot width in compact mode.
  static const double _compactSlotWidth = 52;

  static const _animDuration = Duration(milliseconds: 380);
  static const _animCurve = Curves.easeOutCubic;

  @override
  Widget build(BuildContext context) {
    final cfg = GlassConfig.platform;
    final mq = MediaQuery.of(context);
    final bottomPadding = mq.padding.bottom;
    final screenWidth = mq.size.width;
    final keyboardOpen = mq.viewInsets.bottom > 80;

    // ── Target sizing ────────────────────────────────────────
    final targetHeight = compact ? _compactHeight : _expandedHeight;
    final compactWidth = items.length * _compactSlotWidth + 16;
    final expandedMargin = screenWidth >= 600
        ? ((screenWidth - 480) / 2).clamp(AppSpacing.lg, double.infinity)
        : AppSpacing.lg;

    // In compact mode: centred narrow pill.
    // In expanded mode: full-width with side margins.
    final targetLeft = compact ? (screenWidth - compactWidth) / 2 : expandedMargin;
    final targetRight = compact ? (screenWidth - compactWidth) / 2 : expandedMargin;

    final fillAlpha = (cfg.fillOpacity + 0.22).clamp(0.0, 1.0);
    final borderAlpha = (cfg.borderOpacity + 0.14).clamp(0.0, 1.0);
    final borderRadius = BorderRadius.circular(compact ? 28 : 26);

    final decoration = BoxDecoration(
      color: AppColors.white.withValues(alpha: fillAlpha),
      borderRadius: borderRadius,
      border: Border.all(
        color: AppColors.white.withValues(alpha: borderAlpha),
        width: 0.5,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.black.withValues(alpha: compact ? 0.14 : 0.10),
          blurRadius: compact ? 28 : 40,
          offset: Offset(0, compact ? 6 : 10),
          spreadRadius: compact ? -4 : -6,
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
      compact: compact,
    );

    final blurSigma = cfg.useBlur ? cfg.sigmaX * 1.2 : 0.0;

    Widget bar = AnimatedContainer(
      duration: _animDuration,
      curve: _animCurve,
      height: targetHeight,
      margin: EdgeInsets.only(
        left: targetLeft,
        right: targetRight,
        bottom: bottomPadding + AppSpacing.sm,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: cfg.useBlur
            ? BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: blurSigma,
                  sigmaY: blurSigma,
                ),
                child: DecoratedBox(
                  decoration: decoration,
                  child: tabRow,
                ),
              )
            : DecoratedBox(
                decoration: decoration,
                child: tabRow,
              ),
      ),
    );

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
    this.compact = false,
  });

  final List<GlassNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(items.length, (i) {
        final selected = i == currentIndex;
        final item = items[i];

        Widget tab = PressableScale(
          scaleFactor: 0.88,
          onTap: () {
            Haptic.light();
            onTap(i);
          },
          child: SizedBox.expand(
            child: _TabItem(
              icon: selected ? item.activeIcon ?? item.icon : item.icon,
              label: item.label,
              selected: selected,
              compact: compact,
            ),
          ),
        );

        if (item.tutorialKey != null) {
          tab = KeyedSubtree(key: item.tutorialKey, child: tab);
        }

        return Expanded(child: tab);
      }),
    );
  }
}

// ── Tab item ─────────────────────────────────────────────────────────────────

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.icon,
    required this.label,
    required this.selected,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final iconSize = compact ? 22.0 : 24.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // ── Icon ──────────────────────────────────────────────
        AnimatedScale(
          scale: selected ? 1.08 : 1.0,
          duration: const Duration(milliseconds: 260),
          curve: MotionCurve.emphasized,
          child: Icon(
            icon,
            size: iconSize,
            color: selected ? AppColors.textPrimary : AppColors.grey400,
          ),
        ),

        // ── Label (hidden in compact mode) ───────────────────
        AnimatedSize(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          child: compact
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w400,
                      color: selected
                          ? AppColors.textPrimary
                          : AppColors.grey400,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
        ),

        // ── Active dot indicator ─────────────────────────────
        AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          margin: EdgeInsets.only(top: compact ? 4 : 2),
          width: selected ? 4.5 : 0,
          height: selected ? 4.5 : 0,
          decoration: BoxDecoration(
            color: AppColors.textPrimary,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}
