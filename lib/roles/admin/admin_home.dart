import 'package:flutter/material.dart';

import '../../auth/auth_service.dart';
import '../../ui/ui.dart';
import 'admin_notifications_tab.dart';
import 'admin_pin_gate.dart';
import 'audit_log_tab.dart';
import 'dashboard_tab.dart';
import 'doctors_admin_tab.dart';
import 'invites_tab.dart';
import 'orgs_admin_tab.dart';
import 'pro_keys_tab.dart';
import 'push_tab.dart';
import 'stats_tab.dart';
import 'system_templates_tab.dart';
import 'tickets_tab.dart';
import 'users_tab.dart';
import '../../l10n/app_localizations.dart';

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
    _MehrTab(
      onNavigateToTickets: () => setState(() => _currentIndex = 3),
      onNavigateToDoctors: () => setState(() => _currentIndex = 1),
    ),
  ];

  static final _items = [
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
    GlassNavItem(
      icon: Icons.more_horiz_outlined,
      activeIcon: Icons.more_horiz_rounded,
      label: 'Mehr',
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
                  child: SafeArea(
                    bottom: false,
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

// ─────────────────────────────────────────────────────────────────────────────
// "Mehr" tab: pushes secondary admin tools as full-screen pages.
// ─────────────────────────────────────────────────────────────────────────────

class _MehrTab extends StatelessWidget {
  const _MehrTab({this.onNavigateToTickets, this.onNavigateToDoctors});

  final VoidCallback? onNavigateToTickets;
  final VoidCallback? onNavigateToDoctors;

  static Widget _screen(Widget child) => child;

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final items = <_MehrItem>[
      _MehrItem(
        icon: Icons.notifications_outlined,
        activeIcon: Icons.notifications_rounded,
        label: l.notifications,
        subtitle: l.adminBenachrichtigungenUndEreignisse,
        onTap: () => _push(
          context,
          AdminNotificationsTab(
            onNavigateToTickets: () {
              Navigator.of(context).pop();
              onNavigateToTickets?.call();
            },
            onNavigateToDoctors: () {
              Navigator.of(context).pop();
              onNavigateToDoctors?.call();
            },
            onNavigateToOrgs: () => _push(context, const OrgsAdminTab()),
          ),
        ),
      ),
      _MehrItem(
        icon: Icons.vpn_key_outlined,
        activeIcon: Icons.vpn_key_rounded,
        label: l.proKeys,
        subtitle: l.lizenzschluesselErstellenVerwalten,
        onTap: () => _push(context, _screen(const ProKeysTab())),
      ),
      _MehrItem(
        icon: Icons.history_outlined,
        activeIcon: Icons.history_rounded,
        label: l.adminAuditLog,
        subtitle: l.adminAktionenUndEreignisprotokoll,
        onTap: () => _push(context, _screen(const AuditLogTab())),
      ),
      _MehrItem(
        icon: Icons.mail_outline_rounded,
        activeIcon: Icons.mail_rounded,
        label: l.invitations,
        subtitle: l.arztUndPatienteneinladungen,
        onTap: () => _push(context, _screen(const InvitesTab())),
      ),
      _MehrItem(
        icon: Icons.business_outlined,
        activeIcon: Icons.business_rounded,
        label: 'Organisationen',
        subtitle: l.orgaRegistrierungenPruefen,
        onTap: () => _push(context, _screen(const OrgsAdminTab())),
      ),
      _MehrItem(
        icon: Icons.campaign_outlined,
        activeIcon: Icons.campaign_rounded,
        label: 'Push-Nachrichten',
        subtitle: l.pushBenachrichtigungenVersenden,
        onTap: () => _push(context, _screen(const PushTab())),
      ),
      _MehrItem(
        icon: Icons.description_outlined,
        activeIcon: Icons.description_rounded,
        label: 'System-Templates',
        subtitle: l.vordefinierteVorlagenVerwalten,
        onTap: () => _push(context, _screen(const SystemTemplatesTab())),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l.moreTools),
        actions: [
          IconButton(
            tooltip: l.logout,
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(l.abmelden),
                  content: Text(l.adminAbmeldenBestaetigung),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(l.cancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(l.abmelden),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await AuthService().signOut();
              }
            },
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final item = items[i];
          return Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: Icon(item.activeIcon),
              title: Text(item.label),
              subtitle: Text(item.subtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: item.onTap,
            ),
          );
        },
      ),
    );
  }
}

class _MehrItem {
  const _MehrItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
}
