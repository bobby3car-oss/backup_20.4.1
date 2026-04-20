import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'admin_functions.dart';

import '../../ui/theme/admin_theme.dart';
import 'widgets/admin_confirmation_dialog.dart';
import '../../l10n/app_localizations.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key, this.onNavigate});

  /// Called when the user taps a quick-action that should navigate to a tab.
  final ValueChanged<int>? onNavigate;

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  bool _refreshing = false;

  Future<void> _refreshStats() async {
    setState(() => _refreshing = true);
    try {
      await adminFunctions().httpsCallable('getAdminStats').call<void>({});
    } catch (e) {
      if (kDebugMode) debugPrint('[DashboardTab] refreshStats error: $e');
      if (mounted) {
        final l = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l.statsNichtAktualisiert} ($e)'),
            duration: const Duration(seconds: 8),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _refreshStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshStats,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildMaintenanceCard(context),
            const SizedBox(height: 16),
            _buildStatsSection(),
            const SizedBox(height: 24),
            _buildMiniCharts(context),
            const SizedBox(height: 24),
            _buildQuickActions(context),
            const SizedBox(height: 24),
            _buildRecentActivity(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMaintenanceCard(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream:
          FirebaseFirestore.instance.doc('appConfig/global').snapshots(),
      builder: (context, snapshot) {
        final l = AppLocalizations.of(context)!;
        final data = snapshot.data?.data();
        final enabled = data?['maintenanceMode'] == true;
        final message = data?['maintenanceMessage'] as String?;

        return Card(
          color: enabled
              ? Colors.orange.shade900.withValues(alpha: 0.35)
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  enabled ? Icons.construction : Icons.check_circle_outline,
                  color: enabled ? Colors.orange : Colors.green,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        enabled ? 'Wartungsmodus aktiv' : 'App online',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      if (enabled && message != null && message.isNotEmpty)
                        Text(message,
                            style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                FilledButton.tonal(
                  onPressed: () => _toggleMaintenance(context, enabled),
                  child: Text(enabled ? l.deactivate : l.activate),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _toggleMaintenance(
      BuildContext context, bool currentlyEnabled) async {
    if (!currentlyEnabled) {
      // Enabling → ask for optional message.
      final controller = TextEditingController();
      try {
        final l = AppLocalizations.of(context)!;
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l.adminMaintenanceMode),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: l.hinweistextOptional,
                hintText: l.zbUpdateWirdEingespielt,
              ),
              maxLines: 2,
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(l.cancel)),
              FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(l.activate)),
            ],
          ),
        );
        if (confirmed != true || !mounted) return;
        await _callSetMaintenance(true, controller.text.trim());
      } finally {
        controller.dispose();
      }
    } else {
      final l = AppLocalizations.of(context)!;
      final confirmed = await AdminConfirmationDialog.show(
        context,
        title: l.wartungsmodusDeaktivieren,
        message: l.dieAppWirdWiederFuerAlleNutzerZugaenglich,
        confirmLabel: l.deactivate,
      );
      if (confirmed != true || !mounted) return;
      await _callSetMaintenance(false, null);
    }
  }

  Future<void> _callSetMaintenance(bool enabled, String? message) async {
    try {
      await adminFunctions().httpsCallable('setMaintenanceMode').call<void>({
        'enabled': enabled,
        if (message != null && message.isNotEmpty) 'message': message,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(enabled
                ? 'Wartungsmodus aktiviert'
                : 'Wartungsmodus deaktiviert'),
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[DashboardTab] setMaintenance error: $e');
      if (mounted) {
        final l = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.adminMaintenanceError)),
        );
      }
    }
  }

  Widget _buildStatsSection() {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.doc('adminStats/global').snapshots(),
      builder: (context, snapshot) {
        final l = AppLocalizations.of(context)!;
        final data = snapshot.data?.data();
        final loading = snapshot.connectionState == ConnectionState.waiting;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  l.uebersicht,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                if (_refreshing)
                  const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    tooltip: l.statistikenAktualisieren,
                    onPressed: _refreshStats,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (loading && data == null)
              const Center(child: CircularProgressIndicator())
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossCount = constraints.maxWidth > 700 ? 4 : 2;
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: crossCount,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.6,
                    children: [
                      _StatCard(
                        icon: Icons.people,
                        iconColor: Colors.blue,
                        label: 'Nutzer',
                        value: '${data?['totalUsers'] ?? 0}',
                      ),
                      _StatCard(
                        icon: Icons.person,
                        iconColor: Colors.blue.shade300,
                        label: 'Patienten',
                        value: '${data?['totalPatients'] ?? 0}',
                      ),
                      _StatCard(
                        icon: Icons.medical_services,
                        iconColor: Colors.teal,
                        label: l.aerzte,
                        value: '${data?['totalDoctors'] ?? 0}',
                      ),
                      _StatCard(
                        icon: Icons.star,
                        iconColor: Colors.amber.shade600,
                        label: 'Pro aktiv',
                        value: '${data?['proActive'] ?? 0}',
                      ),
                    ],
                  );
                },
              ),
            if (data?['updatedAt'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Aktualisiert: ${_formatTimestamp(data!['updatedAt'] as Timestamp)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildMiniCharts(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.doc('adminStats/global').snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        if (data == null) return const SizedBox.shrink();

        final patients = (data['totalPatients'] ?? 0) as int;
        final doctors = (data['totalDoctors'] ?? 0) as int;
        final regHistory =
            (data['registrationHistory'] as List<dynamic>?) ?? [];

        if (patients + doctors == 0 && regHistory.isEmpty) {
          return const SizedBox.shrink();
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            final children = <Widget>[
              // Donut chart
              if (patients + doctors > 0)
                _MiniDonutCard(
                  patients: patients,
                  doctors: doctors,
                ),
              if (isWide) const SizedBox(width: 12),
              if (!isWide) const SizedBox(height: 12),
              // Sparkline
              if (regHistory.isNotEmpty)
                _MiniSparkCard(data: regHistory),
            ];

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (patients + doctors > 0)
                    Expanded(child: children[0]),
                  if (patients + doctors > 0)
                    const SizedBox(width: 12),
                  if (regHistory.isNotEmpty) Expanded(child: children.last),
                ],
              );
            }
            return Column(children: children);
          },
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Schnellaktionen',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _QuickActionChip(
              icon: Icons.search,
              label: l.userSuchen,
              onTap: () => widget.onNavigate?.call(2), // Users tab
            ),
            _QuickActionChip(
              icon: Icons.vpn_key,
              label: l.proKeyErstellen,
              onTap: () => widget.onNavigate?.call(5), // Mehr tab (Pro-Keys)
            ),
            _QuickActionChip(
              icon: Icons.send,
              label: l.dashboardPushSenden,
              onTap: () => widget.onNavigate?.call(5), // Mehr tab (Push)
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l.letzteAktivitaeten,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const Spacer(),
            TextButton(
              onPressed: () => widget.onNavigate?.call(5), // Mehr tab (Audit-Log)
              child: Text(l.alleMarkieren),
            ),
          ],
        ),
        const SizedBox(height: 8),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('auditLog')
              .orderBy('timestamp', descending: true)
              .limit(5)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Keine Aktivitäten.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            }
            return Card(
              child: Column(
                children: [
                  for (var i = 0; i < docs.length; i++) ...[
                    _AuditRow(data: docs[i].data()),
                    if (i < docs.length - 1)
                      Divider(height: 1, indent: 12, endIndent: 12,
                        color: AdminTheme.border.withValues(alpha: 0.3)),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  String _formatTimestamp(Timestamp ts) {
    final d = ts.toDate();
    return '${d.day.toString().padLeft(2, '0')}.'
        '${d.month.toString().padLeft(2, '0')}.'
        '${d.year} '
        '${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 22),
                const Spacer(),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
    );
  }
}

class _AuditRow extends StatelessWidget {
  const _AuditRow({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final action = data['action'] as String? ?? '–';
    final detail = data['detail'] as String?;
    final ts = data['timestamp'] as Timestamp?;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Icon(_iconForAction(action), size: 18,
            color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(action, style: Theme.of(context).textTheme.titleSmall),
                if (detail != null)
                  Text(detail, style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          if (ts != null)
            Text(
              _shortTime(ts),
              style: Theme.of(context).textTheme.labelSmall,
            ),
        ],
      ),
    );
  }

  String _shortTime(Timestamp ts) {
    final d = ts.toDate();
    return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}. '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  IconData _iconForAction(String action) {
    final upper = action.toUpperCase();
    if (upper.contains('KEY')) return Icons.vpn_key;
    if (upper.contains('ROLE')) return Icons.manage_accounts;
    if (upper.contains('OBSERVATION')) return Icons.visibility;
    if (upper.contains('WOUND') || upper.contains('WARNING')) {
      return Icons.warning_amber;
    }
    if (upper.contains('PRO')) return Icons.star;
    if (upper.contains('DELETE')) return Icons.delete;
    if (upper.contains('PUSH')) return Icons.notifications;
    if (upper.contains('DISABLE')) return Icons.block;
    if (upper.contains('MAINTENANCE')) return Icons.build;
    return Icons.receipt_long;
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Mini Donut Card (Dashboard compact)
// ═══════════════════════════════════════════════════════════════════════════════

class _MiniDonutCard extends StatelessWidget {
  const _MiniDonutCard({
    required this.patients,
    required this.doctors,
  });
  final int patients;
  final int doctors;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.roleDistribution,
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 24,
                        sections: [
                          PieChartSectionData(
                            value: patients.toDouble(),
                            color: Colors.blue,
                            title: '',
                            radius: 28,
                          ),
                          PieChartSectionData(
                            value: doctors.toDouble(),
                            color: Colors.teal,
                            title: '',
                            radius: 28,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DotLabel(Colors.blue, 'Patienten: $patients'),
                      const SizedBox(height: 4),
                      _DotLabel(Colors.teal, 'Ärzte: $doctors'),
                    ],
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DotLabel extends StatelessWidget {
  const _DotLabel(this.color, this.label);
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Mini Spark Line Card (Dashboard compact — last 30 days registrations)
// ═══════════════════════════════════════════════════════════════════════════════

class _MiniSparkCard extends StatelessWidget {
  const _MiniSparkCard({required this.data});
  final List<dynamic> data;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final total =
        data.fold<int>(0, (s, e) => s + ((e['count'] as int?) ?? 0));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(l.adminRegistrations,
                    style: Theme.of(context).textTheme.titleSmall),
                const Spacer(),
                Text('$total (30d)',
                    style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        for (var i = 0; i < data.length; i++)
                          FlSpot(i.toDouble(),
                              ((data[i]['count'] as int?) ?? 0).toDouble()),
                      ],
                      isCurved: true,
                      preventCurveOverShooting: true,
                      color: cs.primary,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: cs.primary.withValues(alpha: 0.12),
                      ),
                    ),
                  ],
                  lineTouchData: const LineTouchData(enabled: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
