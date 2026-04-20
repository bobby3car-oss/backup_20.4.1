import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../auth/user_totp_gate.dart';
import '../features/doctor_calendar/presentation/doctor_calendar_tab.dart';
import '../l10n/app_localizations.dart';
import '../features/doctor_overview/presentation/doctor_overview_tab.dart';
import '../features/doctor_patients/presentation/doctor_patients_tab.dart';
import '../ui/ui.dart';
import 'doctor_mehr_screen.dart';

/// Root navigation shell for doctor accounts.
///
/// Three tabs: Übersicht, Patienten, Mehr.
class DoctorHome extends StatefulWidget {
  const DoctorHome({
    super.key,
    this.isStaff = false,
    this.doctorUid,
    this.canManageStaff = false,
  });

  /// Whether the current user is a staff member (not the doctor).
  final bool isStaff;

  /// The UID of the doctor. Required for staff; null for actual doctors.
  final String? doctorUid;

  /// Whether this staff member has the manageStaff permission.
  final bool canManageStaff;

  @override
  State<DoctorHome> createState() => _DoctorHomeState();
}

class _DoctorHomeState extends State<DoctorHome> {
  int _currentIndex = 0;

  late List<String> _tabDebugNames;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _buildTabs();
  }

  @override
  void didUpdateWidget(covariant DoctorHome oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.canManageStaff != widget.canManageStaff ||
        oldWidget.isStaff != widget.isStaff ||
        oldWidget.doctorUid != widget.doctorUid) {
      setState(_buildTabs);
    }
  }

  void _buildTabs() {
    _tabDebugNames = [
      'DoctorOverviewTab',
      'DoctorPatientsTab',
      'DoctorMehrScreen',
    ];

    _screens = [
      DoctorOverviewTab(
        isStaff: widget.isStaff,
        doctorUid: widget.doctorUid,
        onNavigateToCalendar: () => Navigator.of(context).push(
          CupertinoPageRoute<void>(
            builder: (_) => DoctorCalendarTab(doctorUid: widget.doctorUid),
          ),
        ),
      ),
      DoctorPatientsTab(doctorUid: widget.doctorUid),
      DoctorMehrScreen(
        isStaff: widget.isStaff,
        doctorUid: widget.doctorUid,
        canManageStaff: widget.canManageStaff,
      ),
    ];
  }

  List<GlassNavItem> _buildItems(AppLocalizations l) {
    return [
      GlassNavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: l.tabOverview,
      ),
      GlassNavItem(
        icon: Icons.people_outline_rounded,
        activeIcon: Icons.people_rounded,
        label: l.tabPatients,
      ),
      GlassNavItem(
        icon: Icons.grid_view_outlined,
        activeIcon: Icons.grid_view_rounded,
        label: l.tabMore,
      ),
    ];
  }

  void _onTabTap(int index) {
    Haptic.selection();
    if (kDebugMode) {
      debugPrint(
        '[DoctorHome] onTap index=$index tab=${_tabDebugNames[index]}',
      );
    }
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    // PopScope prevents the system back button from popping the root
    // doctor screen, which would leave an empty navigator (grey screen).
    return UserTotpGate(
      child: PopScope(
        canPop: false,
        child: AdaptiveProShell(
          tabs: _buildItems(l),
          currentIndex: _currentIndex,
          onTap: _onTabTap,
          screens: _screens,
          maxWidth: 1200,
        ),
      ),
    );
  }
}
