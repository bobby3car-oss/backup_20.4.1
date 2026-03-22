import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../features/organisation/presentation/org_doctors_tab.dart';
import '../features/organisation/presentation/org_overview_tab.dart';
import '../features/organisation/presentation/org_patients_tab.dart';
import '../features/organisation/presentation/org_profile_tab.dart';
import '../features/organisation/presentation/org_staff_tab.dart';
import '../ui/ui.dart';

/// Root navigation shell for organisation accounts.
///
/// Five tabs: Übersicht, Ärzte, Mitarbeiter, Patienten, Profil.
class OrgHome extends StatefulWidget {
  const OrgHome({super.key});

  @override
  State<OrgHome> createState() => _OrgHomeState();
}

class _OrgHomeState extends State<OrgHome> {
  int _currentIndex = 0;

  static const _tabDebugNames = [
    'OrgOverviewTab',
    'OrgDoctorsTab',
    'OrgStaffTab',
    'OrgPatientsTab',
    'OrgProfileTab',
  ];

  static const _screens = <Widget>[
    OrgOverviewTab(),
    OrgDoctorsTab(),
    OrgStaffTab(),
    OrgPatientsTab(),
    OrgProfileTab(),
  ];

  static const _items = <GlassNavItem>[
    GlassNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Übersicht',
    ),
    GlassNavItem(
      icon: Icons.medical_services_outlined,
      activeIcon: Icons.medical_services_rounded,
      label: 'Ärzte',
    ),
    GlassNavItem(
      icon: Icons.group_outlined,
      activeIcon: Icons.group_rounded,
      label: 'Team',
    ),
    GlassNavItem(
      icon: Icons.people_outline_rounded,
      activeIcon: Icons.people_rounded,
      label: 'Patienten',
    ),
    GlassNavItem(
      icon: Icons.business_outlined,
      activeIcon: Icons.business_rounded,
      label: 'Profil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        child: Stack(
          children: [
            Positioned.fill(
              child: ResponsiveContent(
                child: IndexedStack(index: _currentIndex, children: _screens),
              ),
            ),
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
                items: _items,
                currentIndex: _currentIndex,
                onTap: (index) {
                  Haptic.selection();
                  if (kDebugMode) {
                    debugPrint(
                      '[OrgHome] onTap index=$index tab=${_tabDebugNames[index]}',
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
