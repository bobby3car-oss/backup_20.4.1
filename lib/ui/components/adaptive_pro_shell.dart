import 'package:flutter/material.dart';

import '../theme/colors.dart';
import 'app_background.dart';
import 'glass_bottom_navigation.dart';
import 'glass_bottom_navigation_bar.dart';
import 'offline_banner.dart';
import 'responsive_content.dart';

/// Breakpoint above which a side [NavigationRail] is shown instead of the
/// floating [GlassBottomNavigationBar].
const _kDesktopBreakpoint = 900.0;

/// A responsive navigation shell for pro-tier screens (Doctor, Organisation).
///
/// - **≥ 900 dp**: transparent [NavigationRail] on the left, content on the
///   right, with an [OfflineBanner] pinned at the top of the content area.
/// - **< 900 dp**: [GlassBottomNavigationBar] at the bottom, [OfflineBanner]
///   pinned at the top of the stack.
///
/// Uses [IndexedStack] to keep each tab's state alive when switching.
/// Content is wrapped in [ResponsiveContent] with the given [maxWidth].
///
/// The [tabs] list uses [GlassNavItem] (icon, activeIcon, label).
/// State management (currentIndex / onTap) is left to the caller.
class AdaptiveProShell extends StatefulWidget {
  const AdaptiveProShell({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
    required this.screens,
    this.maxWidth = 1200,
  }) : assert(
         tabs.length == screens.length,
         'tabs and screens must have the same length',
       );

  /// Navigation items shown in Rail or BottomBar.
  final List<GlassNavItem> tabs;

  /// Currently selected tab index.
  final int currentIndex;

  /// Called when the user taps a tab.
  final ValueChanged<int> onTap;

  /// Screens rendered inside [IndexedStack].
  final List<Widget> screens;

  /// Maximum content width forwarded to [ResponsiveContent].
  final double maxWidth;

  @override
  State<AdaptiveProShell> createState() => _AdaptiveProShellState();
}

class _AdaptiveProShellState extends State<AdaptiveProShell> {
  final Set<int> _loadedIndices = <int>{};

  @override
  void initState() {
    super.initState();
    _markLoaded(widget.currentIndex, widget.screens.length);
  }

  @override
  void didUpdateWidget(covariant AdaptiveProShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadedIndices.removeWhere((index) => index >= widget.screens.length);
    _markLoaded(widget.currentIndex, widget.screens.length);
  }

  void _markLoaded(int index, int length) {
    if (length <= 0) return;
    _loadedIndices.add(index.clamp(0, length - 1));
  }

  List<Widget> _buildLazyScreens() {
    return List<Widget>.generate(widget.screens.length, (index) {
      if (!_loadedIndices.contains(index)) {
        return const SizedBox.shrink();
      }
      return widget.screens[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    final safeIndex = widget.currentIndex.clamp(0, widget.screens.length - 1);
    final width = MediaQuery.of(context).size.width;
    final useRail = width >= _kDesktopBreakpoint;

    final body = ResponsiveContent(
      maxWidth: widget.maxWidth,
      child: IndexedStack(index: safeIndex, children: _buildLazyScreens()),
    );

    if (useRail) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: AppBackground(
          child: Row(
            children: [
              NavigationRail(
                selectedIndex: safeIndex,
                onDestinationSelected: widget.onTap,
                labelType: NavigationRailLabelType.all,
                backgroundColor: Colors.transparent,
                indicatorColor: AppColors.primary.withValues(alpha: 0.15),
                selectedIconTheme: IconThemeData(color: AppColors.primary),
                unselectedIconTheme: IconThemeData(
                  color: AppColors.textSecondary,
                ),
                selectedLabelTextStyle: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelTextStyle: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
                destinations: widget.tabs
                    .map(
                      (item) => NavigationRailDestination(
                        icon: Icon(item.icon),
                        selectedIcon: Icon(item.activeIcon ?? item.icon),
                        label: Text(item.label),
                      ),
                    )
                    .toList(),
              ),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(child: body),
                    const Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      child: OfflineBanner(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        child: Stack(
          children: [
            Positioned.fill(child: body),
            const Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: OfflineBanner(),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: GlassBottomNavigationBar(
                items: widget.tabs,
                currentIndex: safeIndex,
                onTap: widget.onTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
