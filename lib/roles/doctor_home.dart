import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../features/doctor_calendar/presentation/doctor_calendar_tab.dart';
import '../features/doctor_patients/presentation/doctor_patients_tab.dart';
import '../features/doctor_profile/presentation/doctor_profile_tab.dart';
import '../ui/ui.dart';

/// Root navigation shell for doctor accounts.
///
/// Three tabs: Meine Patienten | Kalender | Profil.
class DoctorHome extends StatefulWidget {
  const DoctorHome({super.key});

  @override
  State<DoctorHome> createState() => _DoctorHomeState();
}

class _DoctorHomeState extends State<DoctorHome> {
  int _currentIndex = 0;

  static const _tabDebugNames = <String>[
    'DoctorPatientsTab',
    'DoctorCalendarTab',
    'DoctorProfileTab',
  ];

  static const _screens = <Widget>[
    DoctorPatientsTab(),
    DoctorCalendarTab(),
    DoctorProfileTab(),
  ];

  static const _items = <GlassNavItem>[
    GlassNavItem(
      icon: Icons.people_outline_rounded,
      activeIcon: Icons.people_rounded,
      label: 'Patienten',
    ),
    GlassNavItem(
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_today_rounded,
      label: 'Kalender',
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
              child: ResponsiveContent(
                child: IndexedStack(index: safeIndex, children: _screens),
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
