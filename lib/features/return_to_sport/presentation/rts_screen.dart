import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../../../ui/theme/app_icons.dart';
import '../data/rts_repository_sync.dart';
import '../domain/rts_assessment.dart';
import 'rts_assessment_screen.dart';
import 'rts_result_screen.dart';

class RtsScreen extends StatefulWidget {
  const RtsScreen({super.key});

  @override
  State<RtsScreen> createState() => _RtsScreenState();
}

class _RtsScreenState extends State<RtsScreen> {
  static final RtsRepositorySync _repository = RtsRepositorySync.instance;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _repository.loadFromDisk();
    try {
      await _repository.pullLatest();
    } catch (e) {
      debugPrint('[RtsScreen] pullLatest failed (offline?): $e');
    }
  }

  void _startAssessment() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const RtsAssessmentScreen(),
      ),
    );
  }

  void _openResult(RtsAssessment assessment) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RtsResultScreen(assessment: assessment),
      ),
    );
  }

  Future<void> _deleteAssessment(RtsAssessment assessment) async {
    final l = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.rtsDeleteTitle),
        content: Text(l.rtsDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              l.delete,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _repository.delete(assessment.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: StreamBuilder<List<RtsAssessment>>(
            stream: _repository.watchAll(),
            builder: (context, snapshot) {
              final assessments = snapshot.data ?? const [];

              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    floating: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    title: Text(l.rtsTitle),
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                  if (assessments.isEmpty)
                    SliverFillRemaining(
                      child: _EmptyState(onStart: _startAssessment),
                    )
                  else ...[
                    SliverToBoxAdapter(
                      child: _LatestResultCard(
                        assessment: assessments.first,
                        onTap: () => _openResult(assessments.first),
                        onNewTest: _startAssessment,
                      ),
                    ),
                    if (assessments.length >= 2)
                      SliverToBoxAdapter(
                        child: _ScoreTrendChart(assessments: assessments),
                      ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
                        child: Text(
                          l.rtsHistory,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final assessment = assessments[index];
                          return _HistoryTile(
                            assessment: assessment,
                            onTap: () => _openResult(assessment),
                            onDelete: () => _deleteAssessment(assessment),
                          );
                        },
                        childCount: assessments.length,
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 80),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _startAssessment,
        icon: const Icon(Icons.play_arrow_rounded),
        label: Text(AppLocalizations.of(context)!.rtsNewAssessment),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
    );
  }
}

// ── Score trend chart ─────────────────────────────────────────────────────────

class _ScoreTrendChart extends StatelessWidget {
  const _ScoreTrendChart({required this.assessments});

  final List<RtsAssessment> assessments;

  static const Color _kLine = Color(0xFF0A74FF);
  static const Color _kGray = Color(0xFF8E8E93);

  @override
  Widget build(BuildContext context) {
    // Show up to last 8, oldest first for the chart
    final data = assessments.reversed
        .take(8)
        .toList()
        .reversed
        .toList();

    final spots = data.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.overallScore);
    }).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.rtsScoreTrend,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 140,
                child: LineChart(
                  LineChartData(
                    minY: 0,
                    maxY: 100,
                    clipData: const FlClipData.all(),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 25,
                      getDrawingHorizontalLine: (_) => const FlLine(
                        color: Color(0xFFE5E5EA),
                        strokeWidth: 0.8,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: 25,
                          getTitlesWidget: (v, _) => Text(
                            '${v.toInt()}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: _kGray,
                            ),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 24,
                          getTitlesWidget: (v, _) {
                            final i = v.toInt();
                            if (i < 0 || i >= data.length) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                DateFormat('d.M').format(data[i].performedAt),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: _kGray,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    extraLinesData: ExtraLinesData(
                      horizontalLines: [
                        HorizontalLine(
                          y: 80,
                          color: AppColors.success.withOpacity(0.4),
                          strokeWidth: 1,
                          dashArray: [6, 4],
                          label: HorizontalLineLabel(
                            show: true,
                            alignment: Alignment.topRight,
                            style: TextStyle(
                              fontSize: 9,
                              color: AppColors.success.withOpacity(0.7),
                            ),
                            labelResolver: (_) => '80',
                          ),
                        ),
                      ],
                    ),
                    lineTouchData: LineTouchData(
                      handleBuiltInTouches: true,
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (_) => const Color(0xFF1C1C1E),
                        tooltipRoundedRadius: 8,
                        getTooltipItems: (spots) => spots
                            .map(
                              (s) => LineTooltipItem(
                                '${s.y.round()} pts',
                                const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        preventCurveOverShooting: true,
                        color: _kLine,
                        barWidth: 2.5,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (_, _, _, _) =>
                              FlDotCirclePainter(
                            radius: 4,
                            color: _kLine,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          ),
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: _kLine.withOpacity(0.08),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              AppIcons.rts,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l.rtsEmptyTitle,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            l.rtsEmptySubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.grey600,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: onStart,
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(l.rtsNewAssessment),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Latest result hero card ───────────────────────────────────────────────────

class _LatestResultCard extends StatelessWidget {
  const _LatestResultCard({
    required this.assessment,
    required this.onTap,
    required this.onNewTest,
  });

  final RtsAssessment assessment;
  final VoidCallback onTap;
  final VoidCallback onNewTest;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final color = _colorForLevel(assessment.clearanceLevel);
    final date = DateFormat('dd.MM.yyyy').format(assessment.performedAt);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: GlassCard(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    l.rtsLatestResult,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.grey600,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    date,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.grey500,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Score circle
                  _ScoreCircle(
                    score: assessment.overallScore,
                    color: color,
                    size: 80,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ClearanceBadge(
                          level: assessment.clearanceLevel,
                          l: l,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l.rtsScore,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.grey600,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: assessment.overallScore / 100,
                          color: color,
                          backgroundColor: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                          minHeight: 8,
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: onNewTest,
                          icon: const Icon(Icons.refresh_rounded, size: 16),
                          label: Text(l.rtsNewAssessment),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            textStyle: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── History tile ──────────────────────────────────────────────────────────────

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.assessment,
    required this.onTap,
    required this.onDelete,
  });

  final RtsAssessment assessment;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final color = _colorForLevel(assessment.clearanceLevel);
    final date =
        DateFormat('dd.MM.yyyy').format(assessment.performedAt);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: GlassCard(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _ScoreCircle(
                score: assessment.overallScore,
                color: color,
                size: 48,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ClearanceBadge(level: assessment.clearanceLevel, l: l),
                    const SizedBox(height: 2),
                    Text(
                      date,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.grey500,
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.grey500,
                  size: 20,
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.grey400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

Color _colorForLevel(RtsClearanceLevel level) {
  switch (level) {
    case RtsClearanceLevel.cleared:
      return AppColors.success;
    case RtsClearanceLevel.almostReady:
      return AppColors.warning;
    case RtsClearanceLevel.notReady:
      return AppColors.error;
  }
}

class _ScoreCircle extends StatelessWidget {
  const _ScoreCircle({
    required this.score,
    required this.color,
    required this.size,
  });

  final double score;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isSmall = size <= 56;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: score / 100,
            strokeWidth: isSmall ? 4 : 6,
            color: color,
            backgroundColor: color.withOpacity(0.18),
          ),
          Text(
            '${score.round()}',
            style: TextStyle(
              fontSize: isSmall ? 14 : 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClearanceBadge extends StatelessWidget {
  const _ClearanceBadge({required this.level, required this.l});

  final RtsClearanceLevel level;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final color = _colorForLevel(level);
    final label = switch (level) {
      RtsClearanceLevel.cleared => l.rtsCleared,
      RtsClearanceLevel.almostReady => l.rtsAlmostReady,
      RtsClearanceLevel.notReady => l.rtsNotReady,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
