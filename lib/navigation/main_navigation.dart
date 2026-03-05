import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../features/documents/presentation/documents_screen.dart';
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
  static const _tabDebugNames = <String>[
    'TimelineFeedScreen',
    'TermineScreen',
    'DokumenteScreen',
    'MehrScreen',
  ];

  static const _screens = <Widget>[
    TimelineFeedScreen(),
    TermineScreen(),
    DocumentsScreen(),
    MehrScreen(),
  ];

  static const _items = <GlassNavItem>[
    GlassNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Start',
    ),
    GlassNavItem(
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_today_rounded,
      label: 'Termine',
    ),
    GlassNavItem(
      icon: Icons.folder_outlined,
      activeIcon: Icons.folder_rounded,
      label: 'Dokumente',
    ),
    GlassNavItem(
      icon: Icons.more_horiz_rounded,
      activeIcon: Icons.more_horiz_rounded,
      label: 'Mehr',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final safeIndex = _currentIndex.clamp(0, _screens.length - 1);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        child: Stack(
          children: [
            // ── Screen content ──────────────────────────────────────
            Positioned.fill(
              child: ResponsiveContent(
                child: IndexedStack(index: safeIndex, children: _screens),
              ),
            ),

            // ── Floating bottom nav ─────────────────────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: GlassBottomNavigationBar(
                items: _items,
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
