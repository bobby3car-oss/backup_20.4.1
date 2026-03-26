import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../l10n/app_localizations.dart';

import '../features/gamification/gamification_service.dart';
import '../features/gamification/presentation/recovery_reward_listener.dart';
import '../features/onboarding_tutorial/presentation/tutorial_keys.dart';
import '../features/onboarding_tutorial/presentation/tutorial_overlay.dart';
import '../screens/screens.dart';
import '../ui/ui.dart';

/// Breakpoint above which a side NavigationRail is used instead of
/// the bottom floating bar.
const _kDesktopBreakpoint = 900.0;

/// Root navigation shell.
///
/// Uses [IndexedStack] to keep each tab's state alive when switching.
/// On narrow screens a floating [GlassBottomNavigationBar] sits at the bottom.
/// On wide screens (≥ 900 dp) a [NavigationRail] replaces it on the left
/// for a clean desktop layout.
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  late final GamificationService _gamificationService;

  static const _tabDebugNames = <String>[
    'HomeScreen',
    'TermineScreen',
    'MehrScreen',
  ];

  static const _screens = <Widget>[
    HomeScreen(),
    TermineScreen(),
    MehrScreen(),
  ];

  bool _tutorialScheduled = false;

  static List<GlassNavItem> _items(AppLocalizations l) => <GlassNavItem>[
    GlassNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: l.tabStart,
    ),
    GlassNavItem(
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_today_rounded,
      label: l.tabAppointments,
      tutorialKey: TutorialKeys.instance.painKey,
    ),
    GlassNavItem(
      icon: Icons.grid_view_outlined,
      activeIcon: Icons.grid_view_rounded,
      label: l.tabMore,
      tutorialKey: TutorialKeys.instance.mehrTabKey,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _gamificationService = GamificationService();
  }

  void _onTabTap(int index) {
    if (kDebugMode) {
      debugPrint(
        '[MainNavigation] onTap index=$index tab=${_tabDebugNames[index]}',
      );
    }
    setState(() => _currentIndex = index);
  }

  void _scheduleTutorial() {
    if (_tutorialScheduled) return;
    _tutorialScheduled = true;
    // Wait a bit so the UI is fully laid out and keys are attached.
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      final keys = TutorialKeys.instance;
      TutorialOverlay(
        context: context,
        timelineKey: keys.timelineKey,
        painKey: keys.painKey,
        bellaKey: keys.bellaKey,
        mehrTabKey: keys.mehrTabKey,
      ).showIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    _scheduleTutorial();

    final safeIndex = _currentIndex.clamp(0, _screens.length - 1);
    final l = AppLocalizations.of(context)!;
    final items = _items(l);
    final width = MediaQuery.of(context).size.width;
    final useRail = width >= _kDesktopBreakpoint;

    final body = ResponsiveContent(
      child: RecoveryRewardListener(
        service: _gamificationService,
        child: IndexedStack(index: safeIndex, children: _screens),
      ),
    );

    if (useRail) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: AppBackground(
          child: Row(
            children: [
              NavigationRail(
                selectedIndex: safeIndex,
                onDestinationSelected: _onTabTap,
                labelType: NavigationRailLabelType.all,
                backgroundColor: Colors.transparent,
                indicatorColor: AppColors.primary.withValues(alpha: 0.15),
                selectedIconTheme: IconThemeData(color: AppColors.primary),
                unselectedIconTheme: IconThemeData(
                  color: AppColors.textSecondary,
                ),
                selectedLabelTextStyle: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelTextStyle: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
                destinations: items
                    .map(
                      (item) => NavigationRailDestination(
                        icon: Icon(item.icon),
                        selectedIcon: Icon(item.activeIcon),
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
            // ── Screen content ──────────────────────────────────────
            Positioned.fill(child: body),

            // ── Offline banner ──────────────────────────────────────
            const Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: OfflineBanner(),
            ),

            // ── Floating bottom nav ─────────────────────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: GlassBottomNavigationBar(
                items: items,
                currentIndex: safeIndex,
                onTap: _onTabTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
