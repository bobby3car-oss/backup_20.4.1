import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'admin_functions.dart';

import '../../auth/auth_service.dart';
import '../../features/ads/presentation/admin/ads_admin_tab.dart';
import '../../ui/components/offline_banner.dart';
import '../../ui/theme/admin_theme.dart';
import 'admin_patient_view_screen.dart';
import 'audit_log_tab.dart';
import 'dashboard_tab.dart';
import 'doctors_admin_tab.dart';
import 'invites_tab.dart';
import 'pro_keys_tab.dart';
import 'push_tab.dart';
import 'stats_tab.dart';
import 'tickets_tab.dart';
import 'users_tab.dart';

/// Navigation item descriptor used by both NavigationRail and Drawer.
class _NavItem {
  const _NavItem(this.icon, this.selectedIcon, this.label, {this.group});
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String? group;
}

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _currentIndex = 0;
  int _pendingDoctorCount = 0;

  static const _doctorNavIndex = 4;

  late final Stream<QuerySnapshot> _pendingDoctorsStream;
  StreamSubscription<QuerySnapshot>? _pendingDoctorsSub;

  @override
  void initState() {
    super.initState();
    _pendingDoctorsStream = FirebaseFirestore.instance
        .collection('doctor_verifications')
        .where('status', isEqualTo: 'pending')
        .snapshots();
    _pendingDoctorsSub = _pendingDoctorsStream.listen((snap) {
      if (mounted) setState(() => _pendingDoctorCount = snap.size);
    });
    _initScreens();
    _ensureAdminClaim();
  }

  @override
  void dispose() {
    _pendingDoctorsSub?.cancel();
    super.dispose();
  }

  /// Ensures the current user has the admin custom claim set.
  /// Required so Firestore rules (isAdmin() → token.admin == true) work.
  Future<void> _ensureAdminClaim() async {
    try {
      // Only refresh if claim isn't already set.
      final token = await FirebaseAuth.instance.currentUser?.getIdTokenResult();
      if (!mounted) return;
      if (token?.claims?['admin'] == true) return;
      await adminFunctions().httpsCallable('refreshAdminClaim').call<void>({});
      // Force token refresh so the new claim is active immediately.
      await FirebaseAuth.instance.currentUser?.getIdToken(true);
    } catch (e) {
      if (kDebugMode) debugPrint('[AdminHome] refreshAdminClaim error: $e');
    }
  }

  static const _navItems = <_NavItem>[
    _NavItem(Icons.dashboard_outlined, Icons.dashboard, 'Dashboard'),
    _NavItem(Icons.people_outline, Icons.people, 'Nutzer', group: 'Verwaltung'),
    _NavItem(Icons.vpn_key_outlined, Icons.vpn_key, 'Pro-Keys', group: 'Verwaltung'),
    _NavItem(Icons.folder_shared_outlined, Icons.folder_shared, 'Patientendaten', group: 'Verwaltung'),
    _NavItem(Icons.medical_services_outlined, Icons.medical_services, 'Ärzte', group: 'Verwaltung'),
    _NavItem(Icons.link_outlined, Icons.link, 'Einladungen', group: 'Verwaltung'),
    _NavItem(Icons.notifications_outlined, Icons.notifications, 'Push', group: 'Kommunikation'),
    _NavItem(Icons.support_agent_outlined, Icons.support_agent, 'Tickets', group: 'Kommunikation'),
    _NavItem(Icons.analytics_outlined, Icons.analytics, 'Statistiken', group: 'System'),
    _NavItem(Icons.history_outlined, Icons.history, 'Audit-Log', group: 'System'),
    _NavItem(Icons.campaign_outlined, Icons.campaign, 'Werbung', group: 'System'),
  ];

  late final List<Widget> _screens;

  void _initScreens() {
    _screens = [
      DashboardTab(onNavigate: _goTo),
      const UsersTab(),
      const ProKeysTab(),
      const AdminPatientViewScreen(),
      const DoctorsAdminTab(),
      const InvitesTab(),
      const PushTab(),
      const TicketsTab(),
      const StatsTab(),
      const AuditLogTab(),
      const AdsAdminTab(),
    ];
  }


  void _goTo(int index) {
    if (index >= 0 && index < _screens.length) {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AdminTheme.dark,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 720;
          if (isWide) return _buildWide(context);
          return _buildNarrow(context);
        },
      ),
    );
  }

  // ── Wide layout: NavigationRail + content ───────────────────────
  Widget _buildWide(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: Row(
              children: [
                _AdminNavRail(
                  currentIndex: _currentIndex,
                  onSelected: _goTo,
                  onSignOut: () => AuthService().signOut(),
                  pendingDoctorCount: _pendingDoctorCount,
                ),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: _screens,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Narrow layout: Drawer + content ────────────────────────────
  Widget _buildNarrow(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_navItems[_currentIndex].label),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Abmelden',
            onPressed: () => AuthService().signOut(),
          ),
        ],
      ),
      drawer: _AdminDrawer(
        currentIndex: _currentIndex,
        onSelected: (i) {
          _goTo(i);
          Navigator.of(context).pop(); // close drawer
        },
        onSignOut: () => AuthService().signOut(),
        pendingDoctorCount: _pendingDoctorCount,
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// NavigationRail for wide screens
// ══════════════════════════════════════════════════════════════════════════════

class _AdminNavRail extends StatelessWidget {
  const _AdminNavRail({
    required this.currentIndex,
    required this.onSelected,
    required this.onSignOut,
    this.pendingDoctorCount = 0,
  });

  final int currentIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onSignOut;
  final int pendingDoctorCount;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: currentIndex,
      onDestinationSelected: onSelected,
      extended: MediaQuery.sizeOf(context).width >= 1100,
      minWidth: 72,
      minExtendedWidth: 200,
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Icon(Icons.admin_panel_settings, size: 32,
              color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 4),
            Text('Admin', style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
      trailing: Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Abmelden',
              onPressed: onSignOut,
            ),
          ),
        ),
      ),
      destinations: _AdminHomeState._navItems.asMap().entries.map((e) {
        final i = e.key;
        final item = e.value;
        final icon = i == _AdminHomeState._doctorNavIndex && pendingDoctorCount > 0
            ? Badge.count(count: pendingDoctorCount, child: Icon(item.icon))
            : Icon(item.icon);
        final selectedIcon = i == _AdminHomeState._doctorNavIndex && pendingDoctorCount > 0
            ? Badge.count(count: pendingDoctorCount, child: Icon(item.selectedIcon))
            : Icon(item.selectedIcon);
        return NavigationRailDestination(
          icon: icon,
          selectedIcon: selectedIcon,
          label: Text(item.label),
        );
      }).toList(),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Drawer for narrow screens
// ══════════════════════════════════════════════════════════════════════════════

class _AdminDrawer extends StatelessWidget {
  const _AdminDrawer({
    required this.currentIndex,
    required this.onSelected,
    required this.onSignOut,
    this.pendingDoctorCount = 0,
  });

  final int currentIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onSignOut;
  final int pendingDoctorCount;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    String? lastGroup;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Row(
                children: [
                  Icon(Icons.admin_panel_settings, size: 28, color: cs.primary),
                  const SizedBox(width: 12),
                  Text('Admin Panel',
                    style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
            ),
            const Divider(),

            // Navigation items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  for (var i = 0; i < _AdminHomeState._navItems.length; i++) ...[
                    if (_AdminHomeState._navItems[i].group != null &&
                        _AdminHomeState._navItems[i].group != lastGroup) ...[
                      Padding(
                        padding: EdgeInsets.fromLTRB(16, i == 0 ? 8 : 16, 16, 4),
                        child: Text(
                          (() {
                            lastGroup = _AdminHomeState._navItems[i].group;
                            return lastGroup!;
                          })(),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ],
                    ListTile(
                      leading: i == _AdminHomeState._doctorNavIndex && pendingDoctorCount > 0
                          ? Badge.count(
                              count: pendingDoctorCount,
                              child: Icon(
                                i == currentIndex
                                    ? _AdminHomeState._navItems[i].selectedIcon
                                    : _AdminHomeState._navItems[i].icon,
                                color: i == currentIndex ? cs.primary : cs.onSurfaceVariant,
                              ),
                            )
                          : Icon(
                              i == currentIndex
                                  ? _AdminHomeState._navItems[i].selectedIcon
                                  : _AdminHomeState._navItems[i].icon,
                              color: i == currentIndex ? cs.primary : cs.onSurfaceVariant,
                            ),
                      title: Text(
                        _AdminHomeState._navItems[i].label,
                        style: TextStyle(
                          color: i == currentIndex ? cs.primary : null,
                          fontWeight: i == currentIndex ? FontWeight.w600 : null,
                        ),
                      ),
                      selected: i == currentIndex,
                      selectedTileColor: cs.primary.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      onTap: () => onSelected(i),
                    ),
                  ],
                ],
              ),
            ),

            // Sign out
            const Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: cs.error),
              title: Text('Abmelden',
                style: TextStyle(color: cs.error)),
              onTap: onSignOut,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
