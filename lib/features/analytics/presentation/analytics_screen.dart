import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../ui/ui.dart';
import '../../pain/data/pain_repository_local.dart';
import '../../pain/domain/pain_entry.dart';
import '../../vitals/data/vital_repository_local.dart';
import '../../vitals/domain/vital_entry.dart';
import '../../wound/data/wound_repository_local.dart';
import '../../wound/domain/wound_entry.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Analytics Screen — PRO Feature
// ─────────────────────────────────────────────────────────────────────────────

enum _TimeRange { days7, days14, days30, all }

extension on _TimeRange {
  String get label => switch (this) {
        _TimeRange.days7 => '7 T',
        _TimeRange.days14 => '14 T',
        _TimeRange.days30 => '30 T',
        _TimeRange.all => 'Alles',
      };

  Duration? get duration => switch (this) {
        _TimeRange.days7 => const Duration(days: 7),
        _TimeRange.days14 => const Duration(days: 14),
        _TimeRange.days30 => const Duration(days: 30),
        _TimeRange.all => null,
      };
}

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  _TimeRange _range = _TimeRange.days7;

  List<PainEntry> _painEntries = const [];
  List<VitalEntry> _vitalEntries = const [];
  List<WoundEntry> _woundEntries = const [];

  StreamSubscription<List<PainEntry>>? _painSub;
  StreamSubscription<List<VitalEntry>>? _vitalSub;
  StreamSubscription<List<WoundEntry>>? _woundSub;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _subscribe();
  }

  void _subscribe() {
    final painRepo = PainRepositoryLocal.instance;
    final vitalRepo = VitalRepositoryLocal.instance;
    final woundRepo = WoundRepositoryLocal.instance;

    _painSub = painRepo.watchAll().listen((data) {
      if (mounted) setState(() => _painEntries = data);
    });
    _vitalSub = vitalRepo.watchAll().listen((data) {
      if (mounted) setState(() => _vitalEntries = data);
    });
    _woundSub = woundRepo.watchAll().listen((data) {
      if (mounted) setState(() => _woundEntries = data);
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _painSub?.cancel();
    _vitalSub?.cancel();
    _woundSub?.cancel();
    super.dispose();
  }

  // ── Filtering ──────────────────────────────────────────────────────────────

  DateTime? get _cutoff {
    final dur = _range.duration;
    return dur != null ? DateTime.now().subtract(dur) : null;
  }

  List<PainEntry> get _filteredPain {
    final c = _cutoff;
    final list = c != null
        ? _painEntries.where((e) => e.occurredAt.isAfter(c)).toList()
        : List<PainEntry>.of(_painEntries);
    list.sort((a, b) => a.occurredAt.compareTo(b.occurredAt));
    return list;
  }

  List<VitalEntry> get _filteredVitals {
    final c = _cutoff;
    final list = c != null
        ? _vitalEntries.where((e) => e.createdAt.isAfter(c)).toList()
        : List<VitalEntry>.of(_vitalEntries);
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  List<WoundEntry> get _filteredWounds {
    final c = _cutoff;
    final list = c != null
        ? _woundEntries.where((e) => e.createdAt.isAfter(c)).toList()
        : List<WoundEntry>.of(_woundEntries);
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ── Top bar ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    PressableScale(
                      onTap: () {
                        Haptic.light();
                        Navigator.of(context).pop();
                      },
                      scaleFactor: 0.90,
                      child: GlassContainer(
                        padding: const EdgeInsets.all(AppSpacing.sm + 2),
                        borderRadius: AppRadius.borderRadiusMd,
                        variant: GlassVariant.thin,
                        elevation: GlassElevation.low,
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: AppColors.grey700,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text('Analytics', style: tt.titleLarge),
                    ),
                  ],
                ),
              ),

              // ── Time range chips ─────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  children: _TimeRange.values.map((r) {
                    final selected = r == _range;
                    return Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: ChoiceChip(
                        label: Text(r.label),
                        selected: selected,
                        onSelected: (_) => setState(() => _range = r),
                        selectedColor: AppColors.primary.withValues(alpha: 0.15),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                          color:
                              selected ? AppColors.primary : AppColors.grey600,
                        ),
                        side: BorderSide(
                          color: selected
                              ? AppColors.primary.withValues(alpha: 0.3)
                              : AppColors.grey300,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.borderRadiusPill,
                        ),
                        backgroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // ── Tabs ─────────────────────────────────────────
              TabBar(
                controller: _tabCtrl,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.grey500,
                indicatorColor: AppColors.primary,
                indicatorSize: TabBarIndicatorSize.label,
                labelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                tabs: const [
                  Tab(text: 'Schmerz'),
                  Tab(text: 'Vitals'),
                  Tab(text: 'Wunden'),
                ],
              ),

              // ── Tab content ──────────────────────────────────
              Expanded(
                child: TabBarView(
                  controller: _tabCtrl,
                  children: [
                    _PainTab(entries: _filteredPain),
                    _VitalsTab(entries: _filteredVitals),
                    _WoundsTab(entries: _filteredWounds),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Pain Tab
// =============================================================================

class _PainTab extends StatelessWidget {
  const _PainTab({required this.entries});
  final List<PainEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return _emptyState('Noch keine Schmerzeinträge');

    final spots = <FlSpot>[];
    for (var i = 0; i < entries.length; i++) {
      spots.add(FlSpot(i.toDouble(), entries[i].painLevel.toDouble()));
    }

    // Summary stats
    final levels = entries.map((e) => e.painLevel);
    final avg = levels.reduce((a, b) => a + b) / levels.length;
    final max = levels.reduce((a, b) => a > b ? a : b);
    final min = levels.reduce((a, b) => a < b ? a : b);

    return ListView(
      physics: adaptiveScrollPhysics,
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // Stats row
        Row(
          children: [
            _StatCard(
              label: 'Ø Schmerz',
              value: avg.toStringAsFixed(1),
              color: _painColor(avg),
            ),
            const SizedBox(width: AppSpacing.sm),
            _StatCard(
              label: 'Min',
              value: '$min',
              color: AppColors.success,
            ),
            const SizedBox(width: AppSpacing.sm),
            _StatCard(
              label: 'Max',
              value: '$max',
              color: AppColors.error,
            ),
            const SizedBox(width: AppSpacing.sm),
            _StatCard(
              label: 'Einträge',
              value: '${entries.length}',
              color: AppColors.primary,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),

        // Chart
        GlassContainer(
          variant: GlassVariant.medium,
          elevation: GlassElevation.low,
          padding: const EdgeInsets.fromLTRB(12, 20, 20, 12),
          borderRadius: AppRadius.borderRadiusLg,
          child: AspectRatio(
            aspectRatio: 1.6,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 10,
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.grey200,
                    strokeWidth: 0.5,
                  ),
                  drawVerticalLine: false,
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 2,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.grey500,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: _bottomInterval(entries.length),
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= entries.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            DateFormat('dd.MM').format(
                              entries[idx].occurredAt,
                            ),
                            style: const TextStyle(
                              fontSize: 9,
                              color: AppColors.grey500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                rangeAnnotations: RangeAnnotations(
                  horizontalRangeAnnotations: [
                    HorizontalRangeAnnotation(
                      y1: 0,
                      y2: 3,
                      color: AppColors.success.withValues(alpha: 0.06),
                    ),
                    HorizontalRangeAnnotation(
                      y1: 3,
                      y2: 7,
                      color: AppColors.warning.withValues(alpha: 0.06),
                    ),
                    HorizontalRangeAnnotation(
                      y1: 7,
                      y2: 10,
                      color: AppColors.error.withValues(alpha: 0.06),
                    ),
                  ],
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    preventCurveOverShooting: true,
                    color: AppColors.primary,
                    barWidth: 2.5,
                    dotData: FlDotData(
                      show: entries.length <= 30,
                      getDotPainter: (spot, xPct, bar, idx) =>
                          FlDotCirclePainter(
                        radius: 3,
                        color: _painColor(spot.y),
                        strokeWidth: 1.5,
                        strokeColor: AppColors.white,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary.withValues(alpha: 0.20),
                          AppColors.primary.withValues(alpha: 0.02),
                        ],
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (spots) => spots.map((s) {
                      final idx = s.spotIndex;
                      final entry = entries[idx];
                      return LineTooltipItem(
                        '${entry.painLevel}/10\n'
                        '${DateFormat('dd.MM HH:mm').format(entry.occurredAt)}',
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static Color _painColor(double level) {
    if (level < 4) return AppColors.success;
    if (level < 7) return AppColors.warning;
    return AppColors.error;
  }
}

// =============================================================================
// Vitals Tab
// =============================================================================

class _VitalsTab extends StatelessWidget {
  const _VitalsTab({required this.entries});
  final List<VitalEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return _emptyState('Noch keine Vitalwerte');

    final sysSpots = <FlSpot>[];
    final diaSpots = <FlSpot>[];
    final pulseSpots = <FlSpot>[];
    for (var i = 0; i < entries.length; i++) {
      sysSpots.add(FlSpot(i.toDouble(), entries[i].systolic.toDouble()));
      diaSpots.add(FlSpot(i.toDouble(), entries[i].diastolic.toDouble()));
      pulseSpots.add(FlSpot(i.toDouble(), entries[i].pulse.toDouble()));
    }

    return ListView(
      physics: adaptiveScrollPhysics,
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // Blood pressure chart
        _chartLabel(context, '🩸 Blutdruck (mmHg)'),
        const SizedBox(height: AppSpacing.sm),
        GlassContainer(
          variant: GlassVariant.medium,
          elevation: GlassElevation.low,
          padding: const EdgeInsets.fromLTRB(12, 20, 20, 12),
          borderRadius: AppRadius.borderRadiusLg,
          child: AspectRatio(
            aspectRatio: 1.6,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.grey200,
                    strokeWidth: 0.5,
                  ),
                  drawVerticalLine: false,
                ),
                titlesData: _vitalTitles(entries),
                borderData: FlBorderData(show: false),
                rangeAnnotations: RangeAnnotations(
                  horizontalRangeAnnotations: [
                    HorizontalRangeAnnotation(
                      y1: 90,
                      y2: 140,
                      color: AppColors.success.withValues(alpha: 0.06),
                    ),
                  ],
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: sysSpots,
                    isCurved: true,
                    preventCurveOverShooting: true,
                    color: AppColors.error,
                    barWidth: 2,
                    dotData: FlDotData(show: entries.length <= 20),
                  ),
                  LineChartBarData(
                    spots: diaSpots,
                    isCurved: true,
                    preventCurveOverShooting: true,
                    color: AppColors.primary,
                    barWidth: 2,
                    dotData: FlDotData(show: entries.length <= 20),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (spots) => spots.map((s) {
                      final idx = s.spotIndex;
                      final e = entries[idx];
                      final label = s.barIndex == 0
                          ? 'Sys: ${e.systolic}'
                          : 'Dia: ${e.diastolic}';
                      return LineTooltipItem(
                        '$label\n'
                        '${DateFormat('dd.MM HH:mm').format(e.createdAt)}',
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _legendRow(context),

        const SizedBox(height: AppSpacing.xxl),

        // Pulse chart
        _chartLabel(context, '💓 Puls (bpm)'),
        const SizedBox(height: AppSpacing.sm),
        GlassContainer(
          variant: GlassVariant.medium,
          elevation: GlassElevation.low,
          padding: const EdgeInsets.fromLTRB(12, 20, 20, 12),
          borderRadius: AppRadius.borderRadiusLg,
          child: AspectRatio(
            aspectRatio: 1.6,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.grey200,
                    strokeWidth: 0.5,
                  ),
                  drawVerticalLine: false,
                ),
                titlesData: _vitalTitles(entries),
                borderData: FlBorderData(show: false),
                rangeAnnotations: RangeAnnotations(
                  horizontalRangeAnnotations: [
                    HorizontalRangeAnnotation(
                      y1: 60,
                      y2: 100,
                      color: AppColors.success.withValues(alpha: 0.06),
                    ),
                  ],
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: pulseSpots,
                    isCurved: true,
                    preventCurveOverShooting: true,
                    color: const Color(0xFFFF6B6B),
                    barWidth: 2.5,
                    dotData: FlDotData(show: entries.length <= 20),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFFFF6B6B).withValues(alpha: 0.15),
                          const Color(0xFFFF6B6B).withValues(alpha: 0.02),
                        ],
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (spots) => spots.map((s) {
                      final idx = s.spotIndex;
                      final e = entries[idx];
                      return LineTooltipItem(
                        '${e.pulse} bpm\n'
                        '${DateFormat('dd.MM HH:mm').format(e.createdAt)}',
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  FlTitlesData _vitalTitles(List<VitalEntry> entries) => FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 36,
            getTitlesWidget: (value, meta) => Text(
              value.toInt().toString(),
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.grey500,
              ),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            interval: _bottomInterval(entries.length),
            getTitlesWidget: (value, meta) {
              final idx = value.toInt();
              if (idx < 0 || idx >= entries.length) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  DateFormat('dd.MM').format(entries[idx].createdAt),
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppColors.grey500,
                  ),
                ),
              );
            },
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      );

  Widget _legendRow(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _legendDot(AppColors.error, 'Systolisch'),
          const SizedBox(width: AppSpacing.lg),
          _legendDot(AppColors.primary, 'Diastolisch'),
        ],
      );

  Widget _legendDot(Color color, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.grey600,
            ),
          ),
        ],
      );

  Widget _chartLabel(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.only(left: AppSpacing.xs),
        child: Text(
          text,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
}

// =============================================================================
// Wounds Tab
// =============================================================================

class _WoundsTab extends StatelessWidget {
  const _WoundsTab({required this.entries});
  final List<WoundEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return _emptyState('Noch keine Wundeinträge');

    final spots = <FlSpot>[];
    for (var i = 0; i < entries.length; i++) {
      spots.add(FlSpot(i.toDouble(), entries[i].pain.toDouble()));
    }

    final levels = entries.map((e) => e.pain);
    final avg = levels.reduce((a, b) => a + b) / levels.length;

    return ListView(
      physics: adaptiveScrollPhysics,
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // Stats
        Row(
          children: [
            _StatCard(
              label: 'Ø Wundschmerz',
              value: avg.toStringAsFixed(1),
              color: AppColors.warning,
            ),
            const SizedBox(width: AppSpacing.sm),
            _StatCard(
              label: 'Einträge',
              value: '${entries.length}',
              color: AppColors.primary,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),

        // Chart
        GlassContainer(
          variant: GlassVariant.medium,
          elevation: GlassElevation.low,
          padding: const EdgeInsets.fromLTRB(12, 20, 20, 12),
          borderRadius: AppRadius.borderRadiusLg,
          child: AspectRatio(
            aspectRatio: 1.6,
            child: BarChart(
              BarChartData(
                maxY: 10,
                barGroups: List.generate(entries.length, (i) {
                  final pain = entries[i].pain.toDouble();
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: pain,
                        width: entries.length > 20 ? 6 : 14,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            AppColors.primary.withValues(alpha: 0.6),
                            pain >= 7
                                ? AppColors.error
                                : pain >= 4
                                    ? AppColors.warning
                                    : AppColors.success,
                          ],
                        ),
                      ),
                    ],
                  );
                }),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.grey200,
                    strokeWidth: 0.5,
                  ),
                  drawVerticalLine: false,
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 2,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.grey500,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: _bottomInterval(entries.length),
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= entries.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            DateFormat('dd.MM').format(
                              entries[idx].createdAt,
                            ),
                            style: const TextStyle(
                              fontSize: 9,
                              color: AppColors.grey500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, gIdx, rod, rIdx) {
                      final e = entries[group.x];
                      return BarTooltipItem(
                        'Schmerz: ${e.pain}/10\n'
                        '${DateFormat('dd.MM.yy').format(e.createdAt)}'
                        '${e.bodyLocation != null ? '\n${e.bodyLocation}' : ''}',
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Shared helpers
// =============================================================================

double _bottomInterval(int count) {
  if (count <= 7) return 1;
  if (count <= 14) return 2;
  if (count <= 30) return 5;
  return (count / 6).ceilToDouble();
}

Widget _emptyState(String message) => Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.bar_chart_rounded,
              size: 56,
              color: AppColors.grey300,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassContainer(
        variant: GlassVariant.thin,
        elevation: GlassElevation.flat,
        borderRadius: AppRadius.borderRadiusMd,
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.sm,
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.grey600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
