import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import 'family_messages_tab.dart';
import 'family_overview_tab.dart';
import 'family_profile_tab.dart';

/// Root navigation shell for family member accounts.
///
/// Three tabs: Übersicht (dashboard) | Nachrichten | Profil.
class FamilyHome extends StatefulWidget {
  const FamilyHome({super.key});

  @override
  State<FamilyHome> createState() => _FamilyHomeState();
}

class _FamilyHomeState extends State<FamilyHome> {
  int _currentIndex = 0;

  static const _screens = <Widget>[
    FamilyOverviewTab(),
    FamilyMessagesTab(),
    FamilyProfileTab(),
  ];

  static const _items = <GlassNavItem>[
    GlassNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Übersicht',
    ),
    GlassNavItem(
      icon: Icons.chat_bubble_outline_rounded,
      activeIcon: Icons.chat_bubble_rounded,
      label: 'Nachrichten',
    ),
    GlassNavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final safeIndex = _currentIndex.clamp(0, _screens.length - 1);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        child: ResponsiveContent(
          child: Stack(
            children: [
              Positioned.fill(
                child: Column(
                  children: [
                    const OfflineBanner(),
                    Expanded(
                      child: IndexedStack(
                          index: safeIndex, children: _screens),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: GlassBottomNavigationBar(
                  items: _items,
                  currentIndex: safeIndex,
                  onTap: (index) {
                    Haptic.light();
                    setState(() => _currentIndex = index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
