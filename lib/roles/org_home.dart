import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../auth/user_totp_gate.dart';
import '../features/organisation/presentation/org_doctors_tab.dart';
import '../features/organisation/presentation/org_overview_tab.dart';
import '../l10n/app_localizations.dart';
import '../ui/ui.dart';
import 'org_mehr_screen.dart';

/// Root navigation shell for organisation accounts.
///
/// Three tabs: Übersicht, Ärzte, Mehr.
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
    'OrgMehrScreen',
  ];

  static const _screens = <Widget>[
    OrgOverviewTab(),
    OrgDoctorsTab(),
    OrgMehrScreen(),
  ];

  List<GlassNavItem> _items(AppLocalizations l) => <GlassNavItem>[
    GlassNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: l.tabOverview,
    ),
    GlassNavItem(
      icon: Icons.group_outlined,
      activeIcon: Icons.group_rounded,
      label: l.tabTeam,
    ),
    GlassNavItem(
      icon: Icons.grid_view_outlined,
      activeIcon: Icons.grid_view_rounded,
      label: l.tabMore,
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
    return UserTotpGate(
      child: PopScope(
        canPop: false,
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
