import 'package:flutter/material.dart';

import '../../ui/ui.dart';
import 'admin_pin_gate.dart';
import 'dashboard_tab.dart';
import 'doctors_admin_tab.dart';
import 'users_tab.dart';
import 'tickets_tab.dart';
import 'stats_tab.dart';

/// Root navigation shell for admin accounts.
class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _currentIndex = 0;

  late final List<Widget> _screens = [
    DashboardTab(onNavigate: (i) => setState(() => _currentIndex = i)),
    const DoctorsAdminTab(),
    const UsersTab(),
    const TicketsTab(),
    const StatsTab(),
  ];

  static const _items = [
    GlassNavItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      label: 'Dashboard',
    ),
    GlassNavItem(
      icon: Icons.local_hospital_outlined,
      activeIcon: Icons.local_hospital_rounded,
      label: 'Ärzte',
    ),
    GlassNavItem(
      icon: Icons.people_outline_rounded,
      activeIcon: Icons.people_rounded,
      label: 'Nutzer',
    ),
    GlassNavItem(
      icon: Icons.support_agent_outlined,
      activeIcon: Icons.support_agent_rounded,
      label: 'Tickets',
    ),
    GlassNavItem(
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart_rounded,
      label: 'Stats',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final safeIndex = _currentIndex.clamp(0, _screens.length - 1);
    return AdminPinGate(
      child: PopScope(
        canPop: false,
        child: Scaffold(
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
                    onTap: (i) => setState(() => _currentIndex = i),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
