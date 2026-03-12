import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../l10n/app_localizations.dart';
import '../ui/components/offline_banner.dart';

import '../features/gamification/gamification_service.dart';
import '../features/gamification/presentation/recovery_reward_listener.dart';
import '../screens/screens.dart';
import '../ui/ui.dart';

/// Root navigation shell.
///
/// Uses [IndexedStack] to keep each tab's state alive when switching.
/// The floating [GlassBottomNavigationBar] sits on top of the body
/// via a [Stack] so it renders over the screen content with blur.
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
    ),
    GlassNavItem(
      icon: Icons.grid_view_outlined,
      activeIcon: Icons.grid_view_rounded,
      label: l.tabMore,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _gamificationService = GamificationService();
  }

  @override
  Widget build(BuildContext context) {
    final safeIndex = _currentIndex.clamp(0, _screens.length - 1);
    final l = AppLocalizations.of(context)!;
    final items = _items(l);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        child: Stack(
          children: [
            // ── Screen content ──────────────────────────────────────
            Positioned.fill(
              child: ResponsiveContent(
                child: RecoveryRewardListener(
                  service: _gamificationService,
                  child: IndexedStack(index: safeIndex, children: _screens),
                ),
              ),
            ),

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
                onTap: (index) {
                  if (kDebugMode) {
                    debugPrint(
                      '[MainNavigation] onTap index=$index tab=${_tabDebugNames[index]}',
                    );
                  }
                  setState(() => _currentIndex = index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
