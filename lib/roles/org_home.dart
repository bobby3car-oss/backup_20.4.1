import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../features/organisation/presentation/org_doctors_tab.dart';
import '../l10n/app_localizations.dart';
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

  List<GlassNavItem> _items(AppLocalizations l) => <GlassNavItem>[
    GlassNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: l.tabOverview,
    ),
    GlassNavItem(
      icon: Icons.medical_services_outlined,
      activeIcon: Icons.medical_services_rounded,
      label: l.tabDoctors,
    ),
    GlassNavItem(
      icon: Icons.group_outlined,
      activeIcon: Icons.group_rounded,
      label: l.tabTeam,
    ),
    GlassNavItem(
      icon: Icons.people_outline_rounded,
      activeIcon: Icons.people_rounded,
      label: l.tabPatients,
    ),
    GlassNavItem(
      icon: Icons.business_outlined,
      activeIcon: Icons.business_rounded,
      label: l.tabProfile,
    ),
  ];

  void _onTabTap(int index) {
    Haptic.selection();
    if (kDebugMode) {
      debugPrint(
        '[OrgHome] onTap index=$index tab=${_tabDebugNames[index]}',
      );
    }
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return PopScope(
      canPop: false,
      child: OrgTabSwitcher(
        switchTo: _onTabTap,
        child: AdaptiveProShell(
          tabs: _items(l),
          currentIndex: _currentIndex,
          onTap: _onTabTap,
          screens: _screens,
          maxWidth: 1200,
        ),
      ),
    );
  }
}
