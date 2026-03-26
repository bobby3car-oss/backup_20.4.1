import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../features/gamification/domain/badge_progress.dart';
import '../features/gamification/domain/badge_rules.dart';
import '../features/gamification/domain/daily_challenge.dart';
import '../features/gamification/domain/daily_log.dart';
import '../features/gamification/domain/gamification_state.dart';
import '../features/gamification/domain/milestone.dart';
import '../features/gamification/domain/recovery_event.dart';
import '../features/gamification/domain/xp_config.dart';
import '../features/gamification/gamification_service.dart';
import '../features/gamification/presentation/streak_rescue_dialog.dart';
import '../features/gamification/presentation/xp_toast.dart';
import '../features/pro/domain/trigger_context.dart';
import '../features/pro/presentation/pro_feature_gate_view.dart';
import '../features/pro/presentation/smart_paywall.dart';
import '../main.dart';
import '../ui/ui.dart';
import '../ui/theme/app_icons.dart';
import '../l10n/app_localizations.dart';

// ─────────────────────────────────────────────────────────────────────────────

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  late final GamificationService _service;

  GamificationState _state = const GamificationState();
  List<DailyLog> _recentLogs7 = [];
  List<DailyLog> _recentLogs35 = [];

  StreamSubscription<GamificationState>? _stateSub;
  StreamSubscription<List<DailyLog>>? _recentLogs7Sub;
  StreamSubscription<List<DailyLog>>? _recentLogs35Sub;

  @override
  void initState() {
    super.initState();
    _service = GamificationService();
    _stateSub = _service.watchState().listen((s) {
      if (mounted) setState(() => _state = s);
    });
    _recentLogs7Sub = _service.watchRecentLogs(days: 7).listen((logs) {
      if (mounted) setState(() => _recentLogs7 = logs);
    });
    _recentLogs35Sub = _service.watchRecentLogs(days: 35).listen((logs) {
      if (mounted) setState(() => _recentLogs35 = logs);
    });
    _checkStreakRescue();
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _recentLogs7Sub?.cancel();
    _recentLogs35Sub?.cancel();
    super.dispose();
  }

  Future<void> _checkStreakRescue() async {
    final broken = await _service.isStreakBroken();
    if (!broken || !mounted) return;

    final isPro = _isPro(context);
    final canRescue = await _service.canRescueStreak();
    if (!canRescue && isPro) return; // already used this week
    if (!mounted) return;

    final state = await _service.getState();
    if (!mounted) return;

    await StreakRescueDialog.show(
      context,
      service: _service,
      lostStreak: state.currentStreak,
      isPro: isPro,
    );
  }

  bool _isPro(BuildContext context) {
    final pro = ProServices.maybeOf(context);
    return pro?.entitlementService.isPro ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isPro = _isPro(context);

    if (!isPro) {
      final l = AppLocalizations.of(context)!;
      return ProFeatureGateView(
        pageTitle: 'Fortschritt',
        pageIcon: AppIcons.progress,
        pageColor: AppColors.success,
        heroIcon: AppIcons.trophy,
        heroTitle: 'Mach deine Genesung sichtbar',
        heroSubtitle:
            'Streaks, Level und Abzeichen – verfolge deinen Fortschritt '
            'Tag für Tag und feiere jeden Meilenstein auf dem Weg zur Genesung.',
        primaryCta: 'Jetzt Pro freischalten',
        onPrimaryTap: () {
          SmartPaywall.trigger(
            context: context,
            triggerContext: TriggerContext.progressFeature,
          );
        },
        benefits: <(String, String)>[
          (
            'Streaks & Motivation',
            'Sieh auf einen Blick, wie viele Tage in Folge du aktiv warst – das hält dich dran.',
          ),
          (
            'Level & XP-System',
            l.sammleErfahrungspunkteFuerJedeAktionUndSteigeImLevel,
          ),
          (
            'Meilensteine & Abzeichen',
            'Schalte Abzeichen frei und erreiche Meilensteine – dein Recovery-Erfolg wird belohnt.',
          ),
        ],
        preview: const _ProgressLockedPreview(),
      );
    }

    final state = _state;

    return GlassPage(
      title: 'Fortschritt',
      titleIcon: AppIcons.progress,
      titleColor: AppColors.success,
      children: [
        // ── Streak ──
        _StreakCard(
          currentStreak: state.currentStreak,
          longestStreak: state.longestStreak,
          recentLogs: _recentLogs7,
        ),

            // ── Combo indicator (Pro) ──
            if (isPro && state.comboCount > 1) ...[
              const SizedBox(height: AppSpacing.lg),
              _ComboIndicator(comboCount: state.comboCount),
            ],

            // ── Level / XP (Pro) ──
            const SizedBox(height: AppSpacing.xxl),
            if (isPro) ...[
              _LevelCard(state: state),
            ] else ...[
              _ProTeaser(
                title: 'XP & Level-System',
                subtitle: 'Schalte Level, XP-Tracking und mehr frei',
                icon: Icons.workspace_premium_rounded,
              ),
            ],

            // ── Milestones (Pro) ──
            const SizedBox(height: AppSpacing.xxl),
            _sectionTitle(context, 'Meilensteine'),
            const SizedBox(height: AppSpacing.md),
            if (isPro) ...[
              _MilestoneList(milestones: state.milestones),
            ] else ...[
              _ProTeaser(
                title: 'Meilensteine & Ziele',
                subtitle: 'Verfolge deine Recovery-Meilensteine',
                icon: Icons.emoji_events_rounded,
              ),
            ],

            // ── Daily Challenges (Pro) ──
            const SizedBox(height: AppSpacing.xxl),
            _sectionTitle(context, 'Heutige Aufgaben'),
            const SizedBox(height: AppSpacing.md),
            if (isPro) ...[
              _DailyChallengesCard(service: _service),
            ] else ...[
              _ProTeaser(
                title: 'Tägliche Challenges',
                subtitle: l.n3NeueAufgabenJedenTagNurFuerPro,
                icon: Icons.bolt_rounded,
              ),
            ],

            // ── Recovery Score ──
            const SizedBox(height: AppSpacing.xxl),
            _sectionTitle(context, 'Recovery Score'),
            const SizedBox(height: AppSpacing.md),
            _RecoveryScoreCard(state: state),

            // ── Recovery Feed Highlights (Pro) ──
            const SizedBox(height: AppSpacing.xxl),
            _sectionTitle(context, 'Recovery Feed'),
            const SizedBox(height: AppSpacing.md),
            if (isPro) ...[
              _RecentEventsCard(service: _service),
            ] else ...[
              _ProTeaser(
                title: 'Recovery Feed',
                subtitle: l.alleDeineAktivitaetenAufEinenBlick,
                icon: Icons.dynamic_feed_rounded,
              ),
            ],

            // ── Heatmap (Pro) ──
            const SizedBox(height: AppSpacing.xxl),
            _sectionTitle(context, 'Aktivität'),
            const SizedBox(height: AppSpacing.md),
            if (isPro) ...[
              _HeatmapCard(logs: _recentLogs35),
            ] else ...[
              _ProTeaser(
                title: 'Aktivitäts-Heatmap',
                subtitle: l.visualisiereDeineTaeglicheAktivitaet,
                icon: Icons.grid_on_rounded,
              ),
            ],

            // ── Badges with progress ──
            const SizedBox(height: AppSpacing.xxl),
            _sectionTitle(context, 'Abzeichen'),
            const SizedBox(height: AppSpacing.md),
            _BadgeProgressGrid(
              state: state,
              isPro: isPro,
            ),
          ],
        );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}

// ── Streak card ──────────────────────────────────────────────────────────────

class _StreakCard extends StatelessWidget {
  const _StreakCard({
    required this.currentStreak,
    required this.longestStreak,
    required this.recentLogs,
  });

  final int currentStreak;
  final int longestStreak;
  final List<DailyLog> recentLogs;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.xl),
      borderRadius: AppRadius.borderRadiusXl,
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFF9500), Color(0xFFFF3B30)],
              ),
              borderRadius: AppRadius.borderRadiusLg,
              boxShadow: [
                BoxShadow(
                  color: AppColors.warning.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              size: 34,
              color: AppColors.white,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$currentStreak',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Text(
                        'Tage',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'Aktuelle Serie',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const Icon(
                      Icons.emoji_events_outlined,
                      size: 14,
                      color: AppColors.grey500,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Längste Serie: $longestStreak Tage',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Builder(
            builder: (context) {
              final logDates = {for (final l in recentLogs) l.date};
              final now = DateTime.now();
              return Column(
                children: [
                  const Text(
                    'Letzte 7 Tage',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: List.generate(7, (i) {
                      final day = now.subtract(Duration(days: 6 - i));
                      final key =
                          '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
                      final active = logDates.contains(key);
                      return Padding(
                        padding:
                            EdgeInsets.only(left: i > 0 ? AppSpacing.xxs : 0),
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color:
                                active ? AppColors.success : AppColors.grey300,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Combo indicator (Pro) ────────────────────────────────────────────────────

class _ComboIndicator extends StatelessWidget {
  const _ComboIndicator({required this.comboCount});

  final int comboCount;
  static const int _comboMax = 5;

  @override
  Widget build(BuildContext context) {
    final progress = (comboCount / _comboMax).clamp(0.0, 1.0);
    final isMaxed = comboCount >= _comboMax;

    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppRadius.borderRadiusXl,
      child: Row(
        children: [
          // Flame icon with animated glow
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + 0.2 * value,
                child: child,
              );
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isMaxed
                      ? [const Color(0xFFFF3B30), const Color(0xFFFF9500)]
                      : [AppColors.warning.withValues(alpha: 0.8), AppColors.warning],
                ),
                borderRadius: AppRadius.borderRadiusMd,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.warning.withValues(alpha: isMaxed ? 0.5 : 0.3),
                    blurRadius: isMaxed ? 20 : 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.local_fire_department_rounded,
                size: 26,
                color: AppColors.white,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Opacity(opacity: value, child: child);
                  },
                  child: Text(
                    isMaxed ? '${comboCount}x Combo! MAX' : '${comboCount}x Combo!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isMaxed ? AppColors.error : AppColors.warning,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  isMaxed
                      ? 'Maximaler Combo-Bonus aktiv!'
                      : 'Noch ${_comboMax - comboCount} für Max-Combo',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: progress),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) {
                    return ClipRRect(
                      borderRadius: AppRadius.borderRadiusPill,
                      child: LinearProgressIndicator(
                        value: value,
                        minHeight: 6,
                        backgroundColor: AppColors.grey200,
                        valueColor: AlwaysStoppedAnimation(
                          isMaxed ? AppColors.error : AppColors.warning,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Level card (Pro) ─────────────────────────────────────────────────────────

class _LevelCard extends StatelessWidget {
  const _LevelCard({required this.state});

  final GamificationState state;

  @override
  Widget build(BuildContext context) {
    final levelName = LevelNames.forLevel(state.level);

    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.xl),
      borderRadius: AppRadius.borderRadiusXl,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.accent, AppColors.primary],
                  ),
                  borderRadius: AppRadius.borderRadiusLg,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.30),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${state.level}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      levelName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      '${state.xp} XP gesamt',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${state.xpInCurrentLevel} / ${state.xpForNextLevel} XP',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    'Level ${state.level + 1}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: state.levelProgress,
                  minHeight: 8,
                  backgroundColor: AppColors.grey200,
                  valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Daily challenges card (Pro) ──────────────────────────────────────────────

class _DailyChallengesCard extends StatefulWidget {
  const _DailyChallengesCard({required this.service});

  final GamificationService service;

  @override
  State<_DailyChallengesCard> createState() => _DailyChallengesCardState();
}

class _DailyChallengesCardState extends State<_DailyChallengesCard> {
  late Future<DailyChallengeSet> _challengesFuture;
  DailyChallengeSet? _liveSet;
  StreamSubscription<DailyChallengeSet?>? _challengesSub;

  @override
  void initState() {
    super.initState();
    _challengesFuture = widget.service.getOrGenerateDailyChallenges();
    _challengesSub = widget.service.watchDailyChallenges().listen((set) {
      if (mounted) setState(() => _liveSet = set);
    });
  }

  @override
  void dispose() {
    _challengesSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DailyChallengeSet>(
      future: _challengesFuture,
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting &&
            _liveSet == null) {
          return GlassContainer(
            padding: const EdgeInsets.all(AppSpacing.xl),
            borderRadius: AppRadius.borderRadiusXl,
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        final set = _liveSet ?? snap.data;
        if (set == null || set.challenges.isEmpty) {
          return const SizedBox.shrink();
        }

        final liveSet = set;

            return GlassContainer(
              padding: const EdgeInsets.all(AppSpacing.xl),
              borderRadius: AppRadius.borderRadiusXl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.bolt_rounded,
                          size: 20, color: AppColors.warning),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '${liveSet.completedCount} / ${liveSet.challenges.length} erledigt',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (liveSet.allCompleted) ...[
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.10),
                            borderRadius: AppRadius.borderRadiusPill,
                          ),
                          child: const Text(
                            'Alle geschafft!',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  for (var i = 0; i < liveSet.challenges.length; i++) ...[
                    _ChallengeRow(
                      challenge: liveSet.challenges[i],
                      onComplete: () async {
                        final challenge = liveSet.challenges[i];
                        final xpContext = context;
                        final result = await widget.service
                            .completeChallenge(challenge.id);
                        if (!mounted || result.xpAwarded <= 0) return;
                        XpToast.show(
                          // ignore: use_build_context_synchronously
                          xpContext,
                          xp: result.xpAwarded,
                          label: challenge.title,
                        );
                      },
                    ),
                    if (i < liveSet.challenges.length - 1)
                      const SizedBox(height: AppSpacing.md),
                  ],
                ],
              ),
            );
      },
    );
  }
}

class _ChallengeRow extends StatelessWidget {
  const _ChallengeRow({required this.challenge, required this.onComplete});

  final DailyChallenge challenge;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: challenge.completed ? null : onComplete,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color:
                  challenge.completed ? AppColors.success : AppColors.grey200,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: challenge.completed
                    ? AppColors.success
                    : AppColors.grey400,
                width: 1.5,
              ),
            ),
            child: challenge.completed
                ? const Icon(Icons.check_rounded,
                    size: 18, color: AppColors.white)
                : null,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                challenge.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: challenge.completed
                      ? AppColors.textSecondary
                      : AppColors.textPrimary,
                  decoration:
                      challenge.completed ? TextDecoration.lineThrough : null,
                ),
              ),
              Text(
                challenge.description,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xxs,
          ),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.10),
            borderRadius: AppRadius.borderRadiusPill,
          ),
          child: Text(
            '+${challenge.xpReward} XP',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Recovery score card ──────────────────────────────────────────────────────

class _RecoveryScoreCard extends StatelessWidget {
  const _RecoveryScoreCard({required this.state});

  final GamificationState state;

  int _computeScore() {
    final streakScore = (state.currentStreak / 30.0 * 30).clamp(0, 30).toInt();
    final taskScore = (state.totalTasksDone / 50.0 * 30).clamp(0, 30).toInt();
    final daysScore = (state.totalDaysActive / 30.0 * 20).clamp(0, 20).toInt();
    final levelScore = (state.level / 10.0 * 20).clamp(0, 20).toInt();
    return (streakScore + taskScore + daysScore + levelScore).clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    final score = _computeScore();

    final metrics = <_RecoveryMetric>[
      _RecoveryMetric(
        label: 'Aufgaben',
        value: state.totalTasksDone.toDouble(),
        maxValue: 50,
        unit: 'erledigt',
        icon: Icons.checklist_rounded,
        color: AppColors.success,
      ),
      _RecoveryMetric(
        label: 'Streak',
        value: state.currentStreak.toDouble(),
        maxValue: 30,
        unit: 'Tage',
        icon: Icons.local_fire_department_rounded,
        color: AppColors.warning,
      ),
      _RecoveryMetric(
        label: 'Aktive Tage',
        value: state.totalDaysActive.toDouble(),
        maxValue: 30,
        unit: 'Tage',
        icon: Icons.calendar_today_rounded,
        color: AppColors.primary,
      ),
      _RecoveryMetric(
        label: 'Level',
        value: state.level.toDouble(),
        maxValue: 10,
        unit: '/ 10',
        icon: Icons.trending_up_rounded,
        color: AppColors.accent,
      ),
    ];

    final label = score >= 80
        ? 'Sehr gute Erholung – weiter so!'
        : score >= 50
            ? 'Gute Erholung – weiter so!'
            : 'Du bist auf dem Weg – bleib dran!';

    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.xl),
      borderRadius: AppRadius.borderRadiusXl,
      child: Column(
        children: [
          SizedBox(
            height: 140,
            child: Center(
              child: SizedBox(
                width: 130,
                height: 130,
                child: CustomPaint(
                  painter: _ScoreRingPainter(score: score / 100),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$score',
                          style: const TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            height: 1,
                          ),
                        ),
                        const Text(
                          'von 100',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.10),
              borderRadius: AppRadius.borderRadiusPill,
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.success,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(height: 1, color: AppColors.grey200),
          const SizedBox(height: AppSpacing.lg),
          for (var i = 0; i < metrics.length; i++) ...[
            _MetricRow(metric: metrics[i]),
            if (i < metrics.length - 1) const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

class _RecoveryMetric {
  const _RecoveryMetric({
    required this.label,
    required this.value,
    required this.maxValue,
    required this.unit,
    required this.icon,
    required this.color,
  });
  final String label;
  final double value;
  final double maxValue;
  final String unit;
  final IconData icon;
  final Color color;
}

class _ScoreRingPainter extends CustomPainter {
  _ScoreRingPainter({required this.score});
  final double score;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 14) / 2;
    const strokeWidth = 10.0;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.grey200
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    final sweepAngle = 2 * math.pi * score;
    final gradient = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: -math.pi / 2 + sweepAngle,
      colors: const [AppColors.primaryLight, AppColors.primary],
    );

    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweepAngle,
      false,
      Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreRingPainter old) => old.score != score;
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.metric});

  final _RecoveryMetric metric;

  @override
  Widget build(BuildContext context) {
    final progress = (metric.value / metric.maxValue).clamp(0.0, 1.0);

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: metric.color.withValues(alpha: 0.10),
            borderRadius: AppRadius.borderRadiusSm,
          ),
          child: Icon(metric.icon, size: 18, color: metric.color),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    metric.label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${metric.value.toInt()} ${metric.unit}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: metric.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: AppColors.grey200,
                  valueColor: AlwaysStoppedAnimation(metric.color),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Heatmap card (Pro) ───────────────────────────────────────────────────────

class _HeatmapCard extends StatelessWidget {
  const _HeatmapCard({required this.logs});

  final List<DailyLog> logs;
  static const _weekdays = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];

  @override
  Widget build(BuildContext context) {
        final l = AppLocalizations.of(context)!;
        final now = DateTime.now();
        final activityData = List<int>.filled(35, 0);
        final logMap = <String, int>{};
        for (final l in logs) {
          logMap[l.date] = l.activityCount;
        }
        for (var i = 0; i < 35; i++) {
          final day = now.subtract(Duration(days: 34 - i));
          final key =
              '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
          activityData[i] = logMap[key] ?? 0;
        }

        final activeDays = activityData.where((v) => v > 0).length;

        return GlassContainer(
          padding: const EdgeInsets.all(AppSpacing.xl),
          borderRadius: AppRadius.borderRadiusXl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Letzte 5 Wochen',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.10),
                      borderRadius: AppRadius.borderRadiusPill,
                    ),
                    child: Text(
                      '$activeDays / 35 aktiv',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: List.generate(7, (row) {
                      return Container(
                        height: 22,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: Text(
                          _weekdays[row],
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    }),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(5, (col) {
                        return Column(
                          children: List.generate(7, (row) {
                            final index = col * 7 + row;
                            final level = index < activityData.length
                                ? activityData[index]
                                : 0;
                            return Padding(
                              padding: const EdgeInsets.all(1.5),
                              child: Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: _colorForLevel(level),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            );
                          }),
                        );
                      }),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Weniger',
                    style:
                        TextStyle(fontSize: 10, color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  for (var i = 0; i <= 4; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1.5),
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: _colorForLevel(i),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    l.tabMore,
                    style:
                        TextStyle(fontSize: 10, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        );
  }

  static Color _colorForLevel(int level) => switch (level) {
        0 => AppColors.grey200,
        1 => AppColors.success.withValues(alpha: 0.20),
        2 => AppColors.success.withValues(alpha: 0.40),
        3 => AppColors.success.withValues(alpha: 0.65),
        _ => AppColors.success,
      };
}

// ── Badge grid with progress ─────────────────────────────────────────────────

class _BadgeProgressGrid extends StatelessWidget {
  const _BadgeProgressGrid({
    required this.state,
    required this.isPro,
  });

  final GamificationState state;
  final bool isPro;

  @override
  Widget build(BuildContext context) {
    final badges = BadgeProgressCalculator.computeAll(
      state,
      const ActivityCounts(),
    );

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 0.85,
      children: badges.map((bp) {
        return _BadgeProgressCard(
          badgeProgress: bp,
          showProgress: isPro,
        );
      }).toList(),
    );
  }
}

class _BadgeProgressCard extends StatelessWidget {
  const _BadgeProgressCard({
    required this.badgeProgress,
    required this.showProgress,
  });

  final BadgeProgress badgeProgress;
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    final badge = badgeProgress.badge;
    final earned = badgeProgress.earned;

    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppRadius.borderRadiusXl,
      child: Opacity(
        opacity: earned ? 1.0 : 0.55,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: earned
                    ? badge.color.withValues(alpha: 0.12)
                    : AppColors.grey200,
                shape: BoxShape.circle,
                border: Border.all(
                  color: earned
                      ? badge.color.withValues(alpha: 0.30)
                      : AppColors.grey300,
                  width: 1.5,
                ),
                boxShadow: earned
                    ? [
                        BoxShadow(
                          color: badge.color.withValues(alpha: 0.20),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                badge.icon,
                size: 26,
                color: earned ? badge.color : AppColors.grey400,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              badge.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              badge.description,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                height: 1.3,
              ),
            ),
            if (earned) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.10),
                  borderRadius: AppRadius.borderRadiusPill,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_rounded, size: 10, color: AppColors.success),
                    SizedBox(width: 2),
                    Text(
                      'Verdient',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (showProgress) ...[
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: AppRadius.borderRadiusPill,
                child: LinearProgressIndicator(
                  value: badgeProgress.progress,
                  minHeight: 4,
                  backgroundColor: AppColors.grey200,
                  valueColor: AlwaysStoppedAnimation(badge.color.withValues(alpha: 0.6)),
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                '${badgeProgress.currentValue}/${badgeProgress.targetValue}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: badge.color.withValues(alpha: 0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Milestone list (Pro) ─────────────────────────────────────────────────────

class _MilestoneList extends StatelessWidget {
  const _MilestoneList({required this.milestones});

  final List<MilestoneProgress> milestones;

  @override
  Widget build(BuildContext context) {
    final allDefs = MilestoneCatalog.all;

    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppRadius.borderRadiusXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < allDefs.length; i++) ...[
            _MilestoneRow(
              definition: allDefs[i],
              progress: milestones
                  .where((m) => m.milestoneId == allDefs[i].id)
                  .firstOrNull,
            ),
            if (i < allDefs.length - 1) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(height: 0.5, color: AppColors.grey200),
              const SizedBox(height: AppSpacing.sm),
            ],
          ],
        ],
      ),
    );
  }
}

class _MilestoneRow extends StatelessWidget {
  const _MilestoneRow({required this.definition, this.progress});

  final MilestoneDefinition definition;
  final MilestoneProgress? progress;

  @override
  Widget build(BuildContext context) {
    final isComplete = progress?.status == MilestoneStatus.completed;
    final progressValue = progress?.progressFor(definition) ?? 0.0;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isComplete
                ? definition.color.withValues(alpha: 0.12)
                : AppColors.grey200,
            borderRadius: AppRadius.borderRadiusSm,
            border: Border.all(
              color: isComplete
                  ? definition.color.withValues(alpha: 0.25)
                  : AppColors.grey300,
              width: 0.5,
            ),
          ),
          child: Center(
            child: Icon(
              isComplete ? Icons.check_circle_rounded : definition.icon,
              size: 20,
              color: isComplete ? definition.color : AppColors.grey500,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                definition.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isComplete
                      ? AppColors.textSecondary
                      : AppColors.textPrimary,
                  decoration: isComplete ? TextDecoration.lineThrough : null,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                definition.description,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (!isComplete) ...[
                const SizedBox(height: AppSpacing.xs),
                ClipRRect(
                  borderRadius: AppRadius.borderRadiusPill,
                  child: LinearProgressIndicator(
                    value: progressValue.clamp(0.0, 1.0),
                    minHeight: 4,
                    backgroundColor: AppColors.grey200,
                    valueColor:
                        AlwaysStoppedAnimation(definition.color.withValues(alpha: 0.7)),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        if (isComplete)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.10),
              borderRadius: AppRadius.borderRadiusPill,
            ),
            child: const Text(
              '✓',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.success,
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: definition.color.withValues(alpha: 0.08),
              borderRadius: AppRadius.borderRadiusPill,
            ),
            child: Text(
              '+${definition.xpReward} XP',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: definition.color,
              ),
            ),
          ),
      ],
    );
  }
}

// ── Recent recovery events card (Pro) ────────────────────────────────────────

class _RecentEventsCard extends StatefulWidget {
  const _RecentEventsCard({required this.service});

  final GamificationService service;

  @override
  State<_RecentEventsCard> createState() => _RecentEventsCardState();
}

class _RecentEventsCardState extends State<_RecentEventsCard> {
  List<RecoveryEvent> _events = [];
  StreamSubscription<List<RecoveryEvent>>? _eventsSub;

  @override
  void initState() {
    super.initState();
    _eventsSub = widget.service.watchRecentEvents(days: 3).listen((events) {
      if (mounted) setState(() => _events = events);
    });
  }

  @override
  void dispose() {
    _eventsSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
        final events = _events;
        if (events.isEmpty) {
          return GlassContainer(
            padding: const EdgeInsets.all(AppSpacing.xl),
            borderRadius: AppRadius.borderRadiusXl,
            child: const Center(
              child: Text(
                'Noch keine Aktivitäten',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          );
        }

        final shown = events.take(8).toList();
        return GlassContainer(
          padding: const EdgeInsets.all(AppSpacing.lg),
          borderRadius: AppRadius.borderRadiusXl,
          child: Column(
            children: [
              for (var i = 0; i < shown.length; i++) ...[
                _EventRow(event: shown[i]),
                if (i < shown.length - 1) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Container(height: 0.5, color: AppColors.grey200),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ],
            ],
          ),
        );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.event});

  final RecoveryEvent event;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GlassIcon(icon: event.icon, color: event.iconColor, size: 18),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (event.subtitle != null)
                Text(
                  event.subtitle!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        if (event.xpDelta > 0)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: AppRadius.borderRadiusPill,
            ),
            child: Text(
              '+${event.xpDelta}',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }
}

// ── Pro teaser card ──────────────────────────────────────────────────────────

class _ProTeaser extends StatelessWidget {
  const _ProTeaser({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(
        '/paywall',
        arguments: {'source': 'progress_teaser'},
      ),
      child: GlassContainer(
        padding: const EdgeInsets.all(AppSpacing.xl),
        borderRadius: AppRadius.borderRadiusXl,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.accent, AppColors.primary],
                ),
                borderRadius: AppRadius.borderRadiusMd,
              ),
              child: Icon(icon, size: 22, color: AppColors.white),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.10),
                borderRadius: AppRadius.borderRadiusPill,
              ),
              child: const Text(
                'PRO',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.accent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Pro locked preview ───────────────────────────────────────────────────────

class _ProgressLockedPreview extends StatelessWidget {
  const _ProgressLockedPreview();

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      variant: GlassVariant.medium,
      borderRadius: AppRadius.borderRadiusLg,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Row(
            children: [
              _ProgressPreviewChip(
                icon: Icons.local_fire_department_rounded,
                label: 'Streaks',
                color: AppColors.warning,
              ),
              const SizedBox(width: AppSpacing.sm),
              _ProgressPreviewChip(
                icon: Icons.emoji_events_rounded,
                label: 'Abzeichen',
                color: AppColors.accent,
              ),
              const SizedBox(width: AppSpacing.sm),
              _ProgressPreviewChip(
                icon: Icons.trending_up_rounded,
                label: 'Level',
                color: AppColors.success,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.grey100.withValues(alpha: 0.55),
              borderRadius: AppRadius.borderRadiusLg,
            ),
            child: Text(
              'Vorschau: Tägliche Streaks, XP-System mit Level-Aufstieg, '
              'Meilensteine, Aktivitäts-Heatmap und sammelbare Abzeichen.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressPreviewChip extends StatelessWidget {
  const _ProgressPreviewChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: AppRadius.borderRadiusLg,
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
