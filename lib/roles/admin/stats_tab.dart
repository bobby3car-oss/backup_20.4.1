import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'admin_functions.dart';
import '../../l10n/app_localizations.dart';

class StatsTab extends StatefulWidget {
  const StatsTab({super.key});

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab> {
  bool _refreshing = false;
  bool _didInitialLoad = false;

  @override
  void initState() {
    super.initState();
    // Auto-refresh stats on first open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_didInitialLoad) {
        _didInitialLoad = true;
        _refreshStats();
      }
    });
  }

  Future<void> _refreshStats() async {
    setState(() => _refreshing = true);
    try {
      await adminFunctions().httpsCallable('getAdminStats').call<void>({});
    } catch (e) {
      if (kDebugMode) debugPrint('[StatsTab] refreshStats error: $e');
      if (mounted) {
        final l = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.statisticsLoadError)),
        );
      }
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.statistics),
        actions: [
          IconButton(
            onPressed: _refreshing ? null : _refreshStats,
            tooltip: l.update,
            icon: _refreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream:
            FirebaseFirestore.instance.doc('adminStats/global').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(l.dataLoadError));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data?.data();
          if (data == null || data.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    size: 64,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(l.statisticsLoading),
                  const SizedBox(height: 12),
                  if (_refreshing)
                    const CircularProgressIndicator()
                  else
                    FilledButton.icon(
                      onPressed: _refreshStats,
                      icon: const Icon(Icons.refresh),
                      label: Text(l.bellaGenerate),
                    ),
                ],
              ),
            );
          }

          final totalUsers = data['totalUsers'] ?? 0;
          final totalPatients = data['totalPatients'] ?? 0;
          final totalDoctors = data['totalDoctors'] ?? 0;
          final totalStaff = data['totalStaff'] ?? 0;
          final totalOrganisation = data['totalOrganisation'] ?? 0;
          final proActive = data['proActive'] ?? 0;
          final updatedAt = data['updatedAt'] as Timestamp?;
          final registrationHistory =
              (data['registrationHistory'] as List<dynamic>?) ?? [];
          final activityHistory =
              (data['activityHistory'] as List<dynamic>?) ?? [];
          final actionCounts =
              (data['actionCounts'] as Map<String, dynamic>?) ?? {};

          return RefreshIndicator(
            onRefresh: _refreshStats,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _StatCard(
                  icon: Icons.people,
                  iconColor: cs.primary,
                  label: l.nutzerGesamt,
                  value: '$totalUsers',
                ),
                _StatCard(
                  icon: Icons.person,
                  iconColor: Colors.blue,
                  label: 'Patienten',
                  value: '$totalPatients',
                ),
                _StatCard(
                  icon: Icons.medical_services,
                  iconColor: Colors.teal,
                  label: l.aerzte,
                  value: '$totalDoctors',
                ),
                _StatCard(
                  icon: Icons.badge_outlined,
                  iconColor: Colors.brown,
                  label: 'Personal',
                  value: '$totalStaff',
                ),
                _StatCard(
                  icon: Icons.business_rounded,
                  iconColor: Colors.indigo,
                  label: 'Organisationen',
                  value: '$totalOrganisation',
                ),
                _StatCard(
                  icon: Icons.star,
                  iconColor: Colors.amber.shade700,
                  label: l.aktiveProLizenzen,
                  value: '$proActive',
                ),

                // ── Role Distribution Donut Chart ────────────────
                if (totalUsers > 0) ...[
                  const SizedBox(height: 24),
                  Text(l.roleDistribution,
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 200,
                    child: _RoleDonutChart(
                      patients: totalPatients as int,
                      doctors: totalDoctors as int,
                      staff: totalStaff as int,
                      organisation: totalOrganisation as int,
                    ),
                  ),
                ],

                // ── Registration Growth Line Chart ───────────────
                if (registrationHistory.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(l.adminNewRegistrations30d,
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 200,
                    child: _GrowthLineChart(
                      data: registrationHistory,
                      barColor: cs.primary,
                    ),
                  ),
                ],

                // ── Admin Activity Bar Chart (7 days) ────────────
                if (activityHistory.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(l.adminActivities7d,
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 200,
                    child: _ActivityBarChart(data: activityHistory),
                  ),
                ],

                // ── Action Type Distribution ─────────────────────
                if (actionCounts.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(l.adminActionDistribution7d,
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          for (final entry in (actionCounts.entries.toList()
                            ..sort((a, b) =>
                                (b.value as int).compareTo(a.value as int))))
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(entry.key,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall),
                                  ),
                                  Expanded(
                                    flex: 5,
                                    child: LinearProgressIndicator(
                                      value: (entry.value as int) /
                                          (actionCounts.values
                                              .fold<int>(
                                                  0,
                                                  (s, v) =>
                                                      s + (v as int))),
                                      borderRadius:
                                          BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 32,
                                    child: Text('${entry.value}',
                                        textAlign: TextAlign.end,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],

                if (updatedAt != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Text(
                      'Zuletzt aktualisiert: ${_formatTimestamp(updatedAt)}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
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
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child:
                  Text(label, style: Theme.of(context).textTheme.titleMedium),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Role Distribution Donut Chart
// ═══════════════════════════════════════════════════════════════════════════════

class _RoleDonutChart extends StatelessWidget {
  const _RoleDonutChart({
    required this.patients,
    required this.doctors,
    required this.staff,
    required this.organisation,
  });

  final int patients;
  final int doctors;
  final int staff;
  final int organisation;

  @override
  Widget build(BuildContext context) {
    final total = patients + doctors + staff + organisation;
    if (total == 0) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 36,
              sections: [
                PieChartSectionData(
                  value: patients.toDouble(),
                  color: Colors.blue,
                  title: '$patients',
                  titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  radius: 50,
                ),
                PieChartSectionData(
                  value: doctors.toDouble(),
                  color: Colors.teal,
                  title: '$doctors',
                  titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  radius: 50,
                ),
                if (staff > 0)
                  PieChartSectionData(
                    value: staff.toDouble(),
                    color: Colors.brown,
                    title: '$staff',
                    titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    radius: 50,
                  ),
                if (organisation > 0)
                  PieChartSectionData(
                    value: organisation.toDouble(),
                    color: Colors.indigo,
                    title: '$organisation',
                    titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    radius: 50,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LegendItem(color: Colors.blue, label: 'Patienten'),
            const SizedBox(height: 8),
            _LegendItem(color: Colors.teal, label: 'Ärzte'),
            if (staff > 0) ...[
              const SizedBox(height: 8),
              _LegendItem(color: Colors.brown, label: 'Personal'),
            ],
            if (organisation > 0) ...[
              const SizedBox(height: 8),
              _LegendItem(color: Colors.indigo, label: 'Organisationen'),
            ],
          ],
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Registration Growth Line Chart (30 days)
// ═══════════════════════════════════════════════════════════════════════════════

class _GrowthLineChart extends StatelessWidget {
  const _GrowthLineChart({required this.data, required this.barColor});
  final List<dynamic> data;
  final Color barColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final maxY = data.fold<int>(
            0, (max, e) => (e['count'] as int) > max ? e['count'] as int : max)
        .toDouble();

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY < 1 ? 1 : maxY + 1,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY / 4).clamp(1, double.infinity),
          getDrawingHorizontalLine: (value) => FlLine(
            color: cs.onSurface.withValues(alpha: 0.1),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: (maxY / 4).clamp(1, double.infinity),
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: TextStyle(
                    fontSize: 10, color: cs.onSurfaceVariant),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 7,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= data.length) return const SizedBox.shrink();
                final date = data[i]['date'] as String;
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '${date.substring(8, 10)}.${date.substring(5, 7)}.',
                    style: TextStyle(
                        fontSize: 9, color: cs.onSurfaceVariant),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < data.length; i++)
                FlSpot(i.toDouble(), (data[i]['count'] as int).toDouble()),
            ],
            isCurved: true,
            preventCurveOverShooting: true,
            color: barColor,
            barWidth: 2.5,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: barColor.withValues(alpha: 0.15),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => spots.map((s) {
              final i = s.x.toInt();
              final date = (i >= 0 && i < data.length)
                  ? data[i]['date'] as String
                  : '';
              return LineTooltipItem(
                '${date.substring(8, 10)}.${date.substring(5, 7)}.: ${s.y.toInt()}',
                TextStyle(
                    color: cs.onPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Admin Activity Bar Chart (7 days)
// ═══════════════════════════════════════════════════════════════════════════════

class _ActivityBarChart extends StatelessWidget {
  const _ActivityBarChart({required this.data});
  final List<dynamic> data;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final maxY = data.fold<int>(
            0, (max, e) => (e['count'] as int) > max ? e['count'] as int : max)
        .toDouble();

    return BarChart(
      BarChartData(
        maxY: maxY < 1 ? 1 : maxY + 2,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY / 4).clamp(1, double.infinity),
          getDrawingHorizontalLine: (value) => FlLine(
            color: cs.onSurface.withValues(alpha: 0.1),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: (maxY / 4).clamp(1, double.infinity),
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: TextStyle(
                    fontSize: 10, color: cs.onSurfaceVariant),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= data.length) return const SizedBox.shrink();
                final date = data[i]['date'] as String;
                final weekday = _weekdayLabel(date);
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(weekday,
                      style: TextStyle(
                          fontSize: 10, color: cs.onSurfaceVariant)),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          for (var i = 0; i < data.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: (data[i]['count'] as int).toDouble(),
                  color: cs.primary,
                  width: 20,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4)),
                ),
              ],
            ),
        ],
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final i = group.x;
              final date = (i >= 0 && i < data.length)
                  ? data[i]['date'] as String
                  : '';
              return BarTooltipItem(
                '${date.substring(8, 10)}.${date.substring(5, 7)}.: ${rod.toY.toInt()}',
                TextStyle(
                    color: cs.onPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              );
            },
          ),
        ),
      ),
    );
  }

  String _weekdayLabel(String isoDate) {
    final d = DateTime.tryParse(isoDate);
    if (d == null) return '?';
    const days = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
    return days[d.weekday - 1];
  }
}
