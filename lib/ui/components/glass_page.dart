import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/radius.dart';
import '../theme/spacing.dart';
import 'app_background.dart';
import 'glass_icon.dart';
import '../motion/motion.dart';

/// A premium page scaffold with [AppBackground] and a **sticky frosted-glass
/// header** that stays visible while the content scrolls beneath it.
///
/// The header auto-renders a back button when the screen [canPop].
/// Pass [title] and optionally [titleIcon], [trailing], or [titleColor].
///
/// The child list (or single widget via [body]) scrolls under the header with
/// matching horizontal padding.
class GlassPage extends StatelessWidget {
  const GlassPage({
    super.key,
    required this.title,
    this.titleIcon,
    this.titleColor,
    this.trailing,
    this.body,
    this.children,
    this.scrollableBody,
    this.floatingActionButton,
    this.horizontalPadding = AppSpacing.xl,
    this.showBackButton = true,
  }) : assert(
         body != null || children != null || scrollableBody != null,
         'Provide body, children, or scrollableBody',
       );

  /// The screen title displayed in the sticky header.
  final String title;

  /// An optional leading icon shown in a solid-gradient bubble (Apple style).
  final IconData? titleIcon;

  /// Accent colour for the icon bubble. Defaults to [AppColors.primary].
  final Color? titleColor;

  /// Optional trailing widget in the header (e.g. action buttons).
  final Widget? trailing;

  /// A single scrollable body widget. Mutually exclusive with [children].
  final Widget? body;

  /// A list of children rendered inside a `Column` within a `ListView`.
  /// Mutually exclusive with [body].
  final List<Widget>? children;

  /// A pre-scrolled body widget (e.g. StreamBuilder that returns ListView).
  /// Placed directly without extra ScrollView wrapping. The widget must
  /// handle its own scrolling and apply [headerHeight] as top padding.
  final Widget Function(double headerHeight)? scrollableBody;

  /// Optional FAB.
  final Widget? floatingActionButton;

  /// Horizontal padding applied to the scrollable content. Default 20.
  final double horizontalPadding;

  /// Whether to show the back button. Defaults to `true`.
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    // Total header height: safe-area + content
    const headerContent = 56.0;
    final headerHeight = topPadding + headerContent;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: floatingActionButton,
      body: AppBackground(
        child: Stack(
          children: [
            // ── Scrollable content ───────────────────────────────
            if (scrollableBody != null)
              Positioned.fill(child: scrollableBody!(headerHeight))
            else if (body != null)
              Positioned.fill(
                child: SingleChildScrollView(
                  physics: _adaptivePhysics,
                  padding: EdgeInsets.only(
                    left: horizontalPadding,
                    right: horizontalPadding,
                    top: headerHeight + AppSpacing.md,
                    bottom: 120,
                  ),
                  child: body!,
                ),
              )
            else
              Positioned.fill(
                child: ListView(
                  physics: _adaptivePhysics,
                  padding: EdgeInsets.only(
                    left: horizontalPadding,
                    right: horizontalPadding,
                    top: headerHeight + AppSpacing.md,
                    bottom: 120,
                  ),
                  children: children!,
                ),
              ),

            // ── Sticky glass header ──────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _StickyGlassHeader(
                title: title,
                titleIcon: titleIcon,
                titleColor: titleColor ?? AppColors.primary,
                trailing: trailing,
                topPadding: topPadding,
                height: headerContent,
                showBackButton:
                    showBackButton && Navigator.of(context).canPop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _adaptivePhysics = BouncingScrollPhysics(
    parent: AlwaysScrollableScrollPhysics(),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// _StickyGlassHeader
// ─────────────────────────────────────────────────────────────────────────────

class _StickyGlassHeader extends StatelessWidget {
  const _StickyGlassHeader({
    required this.title,
    required this.titleColor,
    required this.topPadding,
    required this.height,
    required this.showBackButton,
    this.titleIcon,
    this.trailing,
  });

  final String title;
  final IconData? titleIcon;
  final Color titleColor;
  final Widget? trailing;
  final double topPadding;
  final double height;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          padding: EdgeInsets.only(top: topPadding),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.background.withValues(alpha: 0.92),
                AppColors.background.withValues(alpha: 0.78),
              ],
            ),
            border: Border(
              bottom: BorderSide(
                color: AppColors.white.withValues(alpha: 0.45),
                width: 0.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SizedBox(
            height: height,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  // Back button
                  if (showBackButton) ...[
                    PressableScale(
                      onTap: () {
                        Haptic.light();
                        Navigator.of(context).pop();
                      },
                      scaleFactor: 0.90,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.65),
                          borderRadius: AppRadius.borderRadiusMd,
                          border: Border.all(
                            color: AppColors.white.withValues(alpha: 0.80),
                            width: 0.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withValues(alpha: 0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                  ],

                  // Icon bubble
                  if (titleIcon != null) ...[
                    GlassIcon(
                      icon: titleIcon!,
                      color: titleColor,
                      size: 34,
                    ),
                    const SizedBox(width: AppSpacing.sm + 2),
                  ],

                  // Title
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Trailing
                  ?trailing,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
