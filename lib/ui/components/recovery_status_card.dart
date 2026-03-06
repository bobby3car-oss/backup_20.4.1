import 'package:flutter/material.dart';

import '../motion/motion.dart';
import '../theme/colors.dart';
import '../theme/radius.dart';
import '../theme/spacing.dart';
import 'glass_container.dart';

// ── Model ────────────────────────────────────────────────────────────────────

class RecoveryStatusData {
  const RecoveryStatusData({
    required this.currentStreak,
    required this.todayXp,
    required this.level,
    required this.levelProgress,
    required this.comboCount,
    required this.streakMultiplier,
    this.nextMilestoneTitle,
    this.nextMilestoneProgress,
    this.isPro = false,
  });

  final int currentStreak;
  final int todayXp;
  final int level;
  final double levelProgress;
  final int comboCount;
  final double streakMultiplier;
  final String? nextMilestoneTitle;
  final double? nextMilestoneProgress;
  final bool isPro;
}

// ── Widget ───────────────────────────────────────────────────────────────────

class RecoveryStatusCard extends StatelessWidget {
  const RecoveryStatusCard({
    super.key,
    required this.data,
    this.onTap,
  });

  final RecoveryStatusData data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: () {
        Haptic.light();
        onTap?.call();
      },
      scaleFactor: 0.98,
      child: GlassContainer(
        padding: const EdgeInsets.all(AppSpacing.lg),
        borderRadius: AppRadius.borderRadiusXl,
        child: Column(
          children: [
            // ── Top metrics row ──
            Row(
              children: [
                _MetricPill(
                  emoji: '🔥',
                  value: '${data.currentStreak}',
                  label: 'Streak',
                  accent: const Color(0xFFFF9500),
                ),
                const SizedBox(width: AppSpacing.sm),
                if (data.isPro) ...[
                  _MetricPill(
                    emoji: '⚡',
                    value: '+${data.todayXp}',
                    label: 'Heute',
                    accent: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _MetricPill(
                    emoji: '🎯',
                    value: 'Lv.${data.level}',
                    label: '${(data.levelProgress * 100).round()}%',
                    accent: const Color(0xFF5856D6),
                  ),
                ] else ...[
                  const Spacer(),
                  _ProHint(),
                ],
              ],
            ),

            // ── Combo indicator (Pro only, when active) ──
            if (data.isPro && data.comboCount > 1) ...[
              const SizedBox(height: AppSpacing.md),
              _ComboBar(comboCount: data.comboCount),
            ],

            // ── Streak multiplier (Pro only, when active) ──
            if (data.isPro && data.streakMultiplier > 1.0) ...[
              const SizedBox(height: AppSpacing.sm),
              _StreakMultiplierChip(multiplier: data.streakMultiplier),
            ],

            // ── Next milestone (Pro only) ──
            if (data.isPro &&
                data.nextMilestoneTitle != null &&
                data.nextMilestoneProgress != null) ...[
              const SizedBox(height: AppSpacing.md),
              _NextMilestoneBar(
                title: data.nextMilestoneTitle!,
                progress: data.nextMilestoneProgress!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Metric pill ──────────────────────────────────────────────────────────────

class _MetricPill extends StatelessWidget {
  const _MetricPill({
    required this.emoji,
    required this.value,
    required this.label,
    required this.accent,
  });

  final String emoji;
  final String value;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: AppRadius.borderRadiusLg,
        border: Border.all(
          color: accent.withValues(alpha: 0.15),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: AppSpacing.xs),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: accent,
                  height: 1.1,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: accent.withValues(alpha: 0.7),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Pro hint for free users ──────────────────────────────────────────────────

class _ProHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5856D6), Color(0xFF7C3AED)],
        ),
        borderRadius: AppRadius.borderRadiusPill,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5856D6).withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.workspace_premium_rounded, size: 14, color: Colors.white),
          SizedBox(width: AppSpacing.xs),
          Text(
            'XP & Level freischalten',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Combo bar ────────────────────────────────────────────────────────────────

class _ComboBar extends StatelessWidget {
  const _ComboBar({required this.comboCount});

  final int comboCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF9500).withValues(alpha: 0.08),
            const Color(0xFFFF3B30).withValues(alpha: 0.08),
          ],
        ),
        borderRadius: AppRadius.borderRadiusLg,
        border: Border.all(
          color: const Color(0xFFFF9500).withValues(alpha: 0.15),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          const Text('⚡', style: TextStyle(fontSize: 14)),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Combo x$comboCount',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFFFF9500),
            ),
          ),
          const Spacer(),
          // Combo pips
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (i) {
              final active = i < comboCount;
              return Padding(
                padding: const EdgeInsets.only(left: 3),
                child: AnimatedContainer(
                  duration: MotionDuration.medium,
                  width: active ? 18 : 10,
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: active
                        ? const LinearGradient(
                            colors: [Color(0xFFFF9500), Color(0xFFFF3B30)],
                          )
                        : null,
                    color: active
                        ? null
                        : const Color(0xFFFF9500).withValues(alpha: 0.15),
                    borderRadius: AppRadius.borderRadiusPill,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Streak multiplier chip ───────────────────────────────────────────────────

class _StreakMultiplierChip extends StatelessWidget {
  const _StreakMultiplierChip({required this.multiplier});

  final double multiplier;

  @override
  Widget build(BuildContext context) {
    final label = '${multiplier.toStringAsFixed(1)}x';
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs + 1,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF34C759).withValues(alpha: 0.10),
          borderRadius: AppRadius.borderRadiusPill,
          border: Border.all(
            color: const Color(0xFF34C759).withValues(alpha: 0.20),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔥', style: TextStyle(fontSize: 12)),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Streak-Bonus $label',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF34C759),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Next milestone bar ───────────────────────────────────────────────────────

class _NextMilestoneBar extends StatelessWidget {
  const _NextMilestoneBar({
    required this.title,
    required this.progress,
  });

  final String title;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFF5856D6).withValues(alpha: 0.06),
        borderRadius: AppRadius.borderRadiusLg,
        border: Border.all(
          color: const Color(0xFF5856D6).withValues(alpha: 0.12),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🏆', style: TextStyle(fontSize: 14)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF5856D6),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: AppRadius.borderRadiusPill,
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: const Color(0xFF5856D6).withValues(alpha: 0.10),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF5856D6)),
            ),
          ),
        ],
      ),
    );
  }
}
