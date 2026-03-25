import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../data/rehab_session_repository_sync.dart';
import '../domain/rehab_exercise.dart';
import '../domain/rehab_session.dart';
import 'widgets/exercise_category_chip.dart';
import 'widgets/rehab_timer_widget.dart';
import '../../../ui/theme/app_icons.dart';

class RehabExerciseDetailScreen extends StatefulWidget {
  const RehabExerciseDetailScreen({super.key, required this.exercise});

  final RehabExercise exercise;

  @override
  State<RehabExerciseDetailScreen> createState() =>
      _RehabExerciseDetailScreenState();
}

class _RehabExerciseDetailScreenState extends State<RehabExerciseDetailScreen> {
  static final RehabSessionRepositorySync _repository =
      RehabSessionRepositorySync.instance;

  bool _tipsExpanded = false;

  Future<void> _onTimerComplete(int completedSets, int totalDurationSeconds) async {
    await _saveSession(completedSets, totalDurationSeconds);
    _showCompletionDialog(completedSets);
  }

  Future<void> _saveSession(int completedSets, int durationSec) async {
    final now = DateTime.now();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final session = RehabSession(
      id: 'rehab_${now.millisecondsSinceEpoch}',
      ownerId: uid,
      exerciseId: widget.exercise.id,
      exerciseTitle: widget.exercise.title,
      completedSets: completedSets,
      totalSets: widget.exercise.sets,
      totalDurationSeconds: durationSec,
      completedAt: now,
      createdAt: now,
      updatedAt: now,
      metadata: const <String, dynamic>{'source': 'rehab_timer'},
    );
    try {
      await _repository.upsert(session);
    } catch (e) {
      debugPrint('[RehabExerciseDetailScreen] Failed to save session: $e');
    }
  }

  void _showCompletionDialog(int completedSets) {
    final allDone = completedSets >= widget.exercise.sets;

    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GlassIcon(
                  icon: allDone
                      ? CupertinoIcons.checkmark_circle_fill
                      : CupertinoIcons.hand_thumbsup_fill,
                  color: allDone
                      ? AppColors.success
                      : AppColors.primary,
                  size: 48,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  allDone ? 'Geschafft!' : 'Gut gemacht!',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  allDone
                      ? 'Alle $completedSets Sätze abgeschlossen.\nWeiter so!'
                      : '$completedSets von ${widget.exercise.sets} Sätzen geschafft.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                SizedBox(
                  width: double.infinity,
                  child: GlassButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    label: 'Fertig',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercise;
    final diffLabel = switch (ex.difficulty) {
      RehabDifficulty.easy => 'Leicht',
      RehabDifficulty.medium => 'Mittel',
      RehabDifficulty.hard => 'Schwer',
    };
    final targetLabel = switch (ex.targetArea) {
      RehabTargetArea.general => 'Allgemein',
      RehabTargetArea.knee => 'Knie',
      RehabTargetArea.hip => 'Hüfte',
      RehabTargetArea.shoulder => 'Schulter',
      RehabTargetArea.back => 'Rücken',
      RehabTargetArea.ankle => 'Sprunggelenk',
    };

    return GlassPage(
      title: ex.title,
      titleIcon: ex.exerciseIcon,
      titleColor: AppColors.success,
      horizontalPadding: AppSpacing.lg,
      children: [
        // ── Meta Tags ──
        Row(
          children: [
            ExerciseCategoryChip(category: ex.category),
            const SizedBox(width: AppSpacing.sm),
            _Tag(label: diffLabel, color: AppColors.warning),
            const SizedBox(width: AppSpacing.sm),
            _Tag(label: targetLabel, color: AppColors.primary),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),

        // ── Timer ──
        Center(
          child: RehabTimerWidget(
            durationSeconds: ex.durationSeconds,
            sets: ex.sets,
            restSeconds: ex.restSeconds,
            onComplete: _onTimerComplete,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),

        // ── Description ──
        GlassCard(
          child: Padding(
            padding: AppSpacing.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Anleitung',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  ex.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary.withValues(alpha: 0.85),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Exercise Info ──
        GlassCard(
          child: Padding(
            padding: AppSpacing.cardPadding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _InfoPill(
                  icon: AppIcons.timer,
                  iconColor: AppIcons.timerColor,
                  label: '${ex.durationSeconds}s',
                  subtitle: 'pro Satz',
                ),
                _InfoPill(
                  icon: CupertinoIcons.repeat,
                  iconColor: AppColors.primary,
                  label: '${ex.sets}',
                  subtitle: 'Sätze',
                ),
                if (ex.reps != null)
                  _InfoPill(
                    icon: AppIcons.done,
                    iconColor: AppIcons.doneColor,
                    label: '${ex.reps}',
                    subtitle: 'Wdh.',
                  ),
                _InfoPill(
                  icon: AppIcons.done,
                  iconColor: AppIcons.doneColor,
                  label: '${ex.restSeconds}s',
                  subtitle: 'Pause',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Tips ──
        if (ex.tips.isNotEmpty) ...[
          PressableScale(
            onTap: () {
              Haptic.selection();
              setState(() => _tipsExpanded = !_tipsExpanded);
            },
            child: GlassCard(
              child: Padding(
                padding: AppSpacing.cardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GlassIcon(icon: AppIcons.info, color: AppIcons.infoColor, size: 14),
                        const SizedBox(width: AppSpacing.sm),
                        const Expanded(
                          child: Text(
                            'Tipps',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        AnimatedRotation(
                          turns: _tipsExpanded ? 0.5 : 0,
                          duration: MotionDuration.fast,
                          child: const Icon(
                            Icons.expand_more_rounded,
                            color: AppColors.textSecondary,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                    AnimatedCrossFade(
                      firstChild: const SizedBox.shrink(),
                      secondChild: Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: ex.tips
                              .map((tip) => Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: AppSpacing.sm),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '•  ',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppColors.success
                                                .withValues(alpha: 0.8),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            tip,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: AppColors.textPrimary
                                                  .withValues(alpha: 0.8),
                                              height: 1.4,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                      crossFadeState: _tipsExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: MotionDuration.medium,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],

        const SizedBox(height: AppSpacing.massive),
      ],
    );
  }
}

// ============================================================================
// _Tag
// ============================================================================

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.borderRadiusPill,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

// ============================================================================
// _InfoPill
// ============================================================================

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.subtitle,
  });

  final IconData icon;


  final Color iconColor;
  final String label;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GlassIcon(icon: icon, color: iconColor, size: 18),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
