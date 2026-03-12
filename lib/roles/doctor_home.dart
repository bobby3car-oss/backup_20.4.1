import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../features/doctor_calendar/presentation/doctor_calendar_tab.dart';
import '../features/doctor_overview/presentation/doctor_overview_tab.dart';
import '../features/doctor_patients/presentation/doctor_patients_tab.dart';
import '../features/doctor_profile/presentation/doctor_profile_tab.dart';
import '../features/doctor_staff/presentation/doctor_staff_tab.dart';
import '../ui/components/offline_banner.dart';
import '../ui/ui.dart';

/// Root navigation shell for doctor accounts.
///
/// Four tabs for staff, five tabs for doctors (+ Team tab).
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
  late List<GlassNavItem> _items;

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
      setState(() {
        _buildTabs();
        // Clamp index if Team tab was removed.
        if (_currentIndex >= _screens.length) {
          _currentIndex = _screens.length - 1;
        }
      });
    }
  }

  void _buildTabs() {
    final showTeamTab = !widget.isStaff || widget.canManageStaff;

    _tabDebugNames = [
      'DoctorOverviewTab',
      'DoctorPatientsTab',
      'DoctorCalendarTab',
      'DoctorProfileTab',
      if (showTeamTab) 'DoctorStaffTab',
    ];

    _screens = [
      DoctorOverviewTab(isStaff: widget.isStaff, doctorUid: widget.doctorUid),
      DoctorPatientsTab(doctorUid: widget.doctorUid),
      DoctorCalendarTab(doctorUid: widget.doctorUid),
      DoctorProfileTab(isStaff: widget.isStaff, doctorUid: widget.doctorUid),
      if (showTeamTab)
        DoctorStaffTab(
          isStaff: widget.isStaff,
          doctorUid: widget.doctorUid,
        ),
    ];

    _items = [
      const GlassNavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: 'Übersicht',
      ),
      const GlassNavItem(
        icon: Icons.people_outline_rounded,
        activeIcon: Icons.people_rounded,
        label: 'Patienten',
      ),
      const GlassNavItem(
        icon: Icons.calendar_today_outlined,
        activeIcon: Icons.calendar_today_rounded,
        label: 'Kalender',
      ),
      const GlassNavItem(
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: 'Profil',
      ),
      if (showTeamTab)
        const GlassNavItem(
          icon: Icons.group_outlined,
          activeIcon: Icons.group_rounded,
          label: 'Team',
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final safeIndex = _currentIndex.clamp(0, _screens.length - 1);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        child: Stack(
          children: [
            Positioned.fill(
              child: ResponsiveContent(
                child: IndexedStack(index: safeIndex, children: _screens),
              ),
            ),
            Positioned(
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
                currentIndex: safeIndex,
                onTap: (index) {
                  Haptic.selection();
                  if (kDebugMode) {
                    debugPrint(
                      '[DoctorHome] onTap index=$index tab=${_tabDebugNames[index]}',
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
