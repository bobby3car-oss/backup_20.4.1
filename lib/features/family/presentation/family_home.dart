import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import 'family_patients_tab.dart';
import 'family_profile_tab.dart';

/// Root navigation shell for family member accounts.
///
/// Two main tabs: Patienten (multi-patient overview) | Profil.
/// Tapping a patient card navigates into a detail screen.
class FamilyHome extends StatefulWidget {
  const FamilyHome({super.key});

  @override
  State<FamilyHome> createState() => _FamilyHomeState();
}

class _FamilyHomeState extends State<FamilyHome> {
  int _currentIndex = 0;

  static const _screens = <Widget>[
    FamilyPatientsTab(),
    FamilyProfileTab(),
  ];

  static const _items = <GlassNavItem>[
    GlassNavItem(
      icon: Icons.people_outline_rounded,
      activeIcon: Icons.people_rounded,
      label: 'Patienten',
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
        child: Stack(
          children: [
            Positioned.fill(
              child: IndexedStack(index: safeIndex, children: _screens),
            ),
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
                      '[FamilyHome] onTap index=$index',
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
