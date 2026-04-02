import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../../../ui/theme/app_icons.dart';
import '../domain/rts_assessment.dart';
import '../domain/rts_calculator.dart';
import 'rts_assessment_screen.dart';

class RtsResultScreen extends StatelessWidget {
  const RtsResultScreen({
    super.key,
    required this.assessment,
    this.isNew = false,
  });

  final RtsAssessment assessment;

  /// Whether this result was just created (shows a congratulations hint).
  final bool isNew;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final color = _colorForLevel(assessment.clearanceLevel);
    final date = DateFormat('dd.MM.yyyy – HH:mm').format(assessment.performedAt);
    final sport = assessment.sportType;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                title: Text(l.rtsResultTitle),
                actions: [
                  if (!isNew)
                    IconButton(
                      icon: const Icon(Icons.add_rounded),
                      tooltip: l.rtsNewAssessment,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const RtsAssessmentScreen(),
                          ),
                        );
                      },
                    ),
                ],
              ),

              // ── Hero score ────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                  child: GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Text(
                            date,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.grey500,
                                    ),
                          ),
                          if (sport != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.25),
                                ),
                              ),
                              child: Text(
                                '${sport.emoji}  ${_sportLabel(sport, l)}',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          // Big score circle
                          SizedBox(
                            width: 140,
                            height: 140,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: assessment.overallScore / 100,
                                  strokeWidth: 10,
                                  color: color,
                                  backgroundColor: color.withOpacity(0.15),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${assessment.overallScore.round()}',
                                      style: TextStyle(
                                        fontSize: 42,
                                        fontWeight: FontWeight.bold,
                                        color: color,
                                      ),
                                    ),
                                    Text(
                                      '/ 100',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: color.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Clearance badge
                          _ClearanceBadgeLarge(
                            level: assessment.clearanceLevel,
                            l: l,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _clearanceMessage(assessment.clearanceLevel, l),
                            style:
                                Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.grey600,
                                      height: 1.5,
                                    ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Test breakdown ────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
                  child: Text(
                    l.rtsBreakdown,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: Column(
                    children: [
                      if (assessment.hopScore != null)
                        _TestResultTile(
                          icon: Icons.directions_run_rounded,
                          iconColor: const Color(0xFF34C759),
                          title: l.rtsTestHopTitle,
                          score: assessment.hopScore!,
                          weight: RtsCalculator.hopWeight,
                          detail: assessment.hopAffectedCm != null &&
                                  assessment.hopHealthyCm != null
                              ? l.rtsHopDetailValue(
                                  _fmt(assessment.hopAffectedCm!),
                                  _fmt(assessment.hopHealthyCm!),
                                  _lsiPercent(
                                    assessment.hopAffectedCm!,
                                    assessment.hopHealthyCm!,
                                  ),
                                )
                              : null,
                        ),
                      if (assessment.lsiScore != null)
                        _TestResultTile(
                          icon: Icons.compare_arrows_rounded,
                          iconColor: AppColors.primary,
                          title: l.rtsTestLsiTitle,
                          score: assessment.lsiScore!,
                          weight: RtsCalculator.lsiWeight,
                          detail: assessment.lsiAffected != null &&
                                  assessment.lsiHealthy != null
                              ? l.rtsLsiDetailValue(
                                  _fmt(assessment.lsiAffected!),
                                  _fmt(assessment.lsiHealthy!),
                                  assessment.lsiUnit.shortLabel,
                                  _lsiPercent(
                                    assessment.lsiAffected!,
                                    assessment.lsiHealthy!,
                                  ),
                                )
                              : null,
                        ),
                      if (assessment.tugScore != null)
                        _TestResultTile(
                          icon: Icons.directions_walk_rounded,
                          iconColor: const Color(0xFF5856D6),
                          title: l.rtsTestTugTitle,
                          score: assessment.tugScore!,
                          weight: RtsCalculator.tugWeight,
                          detail: assessment.tugSeconds != null
                              ? l.rtsTugDetailValue(
                                  _fmt(assessment.tugSeconds!),
                                )
                              : null,
                        ),
                      if (assessment.balanceScore != null)
                        _TestResultTile(
                          icon: Icons.accessibility_new_rounded,
                          iconColor: AppColors.accent,
                          title: l.rtsTestBalanceTitle,
                          score: assessment.balanceScore!,
                          weight: RtsCalculator.balanceWeight,
                          detail: assessment.balanceSeconds != null
                              ? l.rtsBalanceDetailValue(
                                  _fmt(assessment.balanceSeconds!),
                                )
                              : null,
                        ),
                      if (assessment.stabilityScore != null)
                        _TestResultTile(
                          icon: Icons.sports_gymnastics_rounded,
                          iconColor: AppColors.warning,
                          title: l.rtsTestStabilityTitle,
                          score: assessment.stabilityScore!,
                          weight: RtsCalculator.stabilityWeight,
                          detail: assessment.stabilityRating != null
                              ? l.rtsStabilityDetailValue(
                                  assessment.stabilityRating.toString(),
                                )
                              : null,
                        ),
                      if (assessment.painScore != null)
                        _TestResultTile(
                          icon: Icons.fitness_center_rounded,
                          iconColor: AppColors.error,
                          title: l.rtsTestPainTitle,
                          score: assessment.painScore!,
                          weight: RtsCalculator.painWeight,
                          detail: assessment.painLevel != null
                              ? l.rtsPainDetailValue(
                                  assessment.painLevel.toString(),
                                )
                              : null,
                        ),
                    ],
                  ),
                ),
              ),

              // ── Notes ──────────────────────────────────────────────────
              if (assessment.notes != null && assessment.notes!.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: GlassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.notes_rounded,
                                color: AppColors.grey500, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                assessment.notes!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: AppColors.grey700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // ── CTA: new test ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const RtsAssessmentScreen(),
                        ),
                      );
                    },
                    icon: const Icon(AppIcons.rts),
                    label: Text(l.rtsNewAssessment),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      minimumSize: const Size(double.infinity, 0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _sportLabel(SportType sport, AppLocalizations l) {
    switch (sport) {
      case SportType.running:    return l.rtsSportRunning;
      case SportType.soccer:     return l.rtsSportSoccer;
      case SportType.strength:   return l.rtsSportStrength;
      case SportType.cycling:    return l.rtsSportCycling;
      case SportType.swimming:   return l.rtsSportSwimming;
      case SportType.martialArts: return l.rtsSportMartialArts;
      case SportType.other:      return l.rtsSportOther;
    }
  }

  String _clearanceMessage(
    RtsClearanceLevel level,
    AppLocalizations l,
  ) {
    switch (level) {
      case RtsClearanceLevel.cleared:
        return l.rtsClearedMessage;
      case RtsClearanceLevel.almostReady:
        return l.rtsAlmostReadyMessage;
      case RtsClearanceLevel.notReady:
        return l.rtsNotReadyMessage;
    }
  }

  String _lsiPercent(double affected, double healthy) {
    if (healthy <= 0) return '–';
    return '${(affected / healthy * 100).round()}%';
  }

  String _fmt(double v) {
    if (v == v.floorToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }
}

// ── Test result tile ──────────────────────────────────────────────────────────

class _TestResultTile extends StatelessWidget {
  const _TestResultTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.score,
    required this.weight,
    this.detail,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final double score;
  final double weight;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final scoreColor = score >= 80
        ? AppColors.success
        : score >= 60
            ? AppColors.warning
            : AppColors.error;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (detail != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        detail!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.grey500,
                            ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: score / 100,
                      color: scoreColor,
                      backgroundColor: scoreColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                      minHeight: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${score.round()}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: scoreColor,
                    ),
                  ),
                  Text(
                    '${(weight * 100).round()}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.grey400,
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

// ── Clearance badge (large) ───────────────────────────────────────────────────

class _ClearanceBadgeLarge extends StatelessWidget {
  const _ClearanceBadgeLarge({required this.level, required this.l});

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
    final icon = switch (level) {
      RtsClearanceLevel.cleared => Icons.check_circle_rounded,
      RtsClearanceLevel.almostReady => Icons.watch_later_rounded,
      RtsClearanceLevel.notReady => Icons.cancel_rounded,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

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
