import 'package:flutter/material.dart';

import '../../features/gamification/domain/recovery_event.dart';
import '../motion/motion.dart';
import '../theme/colors.dart';
import '../theme/radius.dart';
import '../theme/spacing.dart';
import 'glass_container.dart';
import 'glass_icon.dart';

// ── Single feed event card ───────────────────────────────────────────────────

class RecoveryFeedCard extends StatelessWidget {
  const RecoveryFeedCard({super.key, required this.event});

  final RecoveryEvent event;

  Color get _accentColor => switch (event.relevance) {
        EventRelevance.epic => const Color(0xFF5856D6),
        EventRelevance.high => const Color(0xFFFF9500),
        EventRelevance.normal => AppColors.primary,
        EventRelevance.low => AppColors.grey500,
      };

  @override
  Widget build(BuildContext context) {
    final isEpic = event.relevance == EventRelevance.epic;
    final accent = _accentColor;

    return FadeSlideIn(
      slideOffset: 4,
      duration: const Duration(milliseconds: 250),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        borderRadius: AppRadius.borderRadiusLg,
        color: isEpic ? accent.withValues(alpha: 0.06) : null,
        child: Row(
          children: [
            // ── Emoji ──
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.10),
                borderRadius: AppRadius.borderRadiusSm,
                border: Border.all(
                  color: accent.withValues(alpha: 0.15),
                  width: 0.5,
                ),
              ),
              child: Center(
                child: GlassIcon(
                  icon: event.icon,
                  color: event.iconColor,
                  size: 36,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // ── Title + subtitle ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isEpic ? FontWeight.w800 : FontWeight.w600,
                      color: isEpic ? accent : AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (event.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      event.subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // ── XP chip ──
            if (event.xpDelta > 0) ...[
              const SizedBox(width: AppSpacing.sm),
              _XpChip(xp: event.xpDelta, accent: accent),
            ],
          ],
        ),
      ),
    );
  }
}

// ── XP chip ──────────────────────────────────────────────────────────────────

class _XpChip extends StatelessWidget {
  const _XpChip({required this.xp, required this.accent});

  final int xp;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: AppSpacing.xxs + 2,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent, accent.withValues(alpha: 0.8)],
        ),
        borderRadius: AppRadius.borderRadiusPill,
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.25),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        '+$xp XP',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

// ── Inline XP reward (for task completion feedback) ──────────────────────────

class InlineXpReward extends StatefulWidget {
  const InlineXpReward({
    super.key,
    required this.xp,
    required this.show,
    this.comboCount = 0,
  });

  final int xp;
  final bool show;
  final int comboCount;

  @override
  State<InlineXpReward> createState() => _InlineXpRewardState();
}

class _InlineXpRewardState extends State<InlineXpReward>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.15), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _opacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(InlineXpReward old) {
    super.didUpdateWidget(old);
    if (widget.show && !old.show) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) {
        if (_opacity.value <= 0.01) return const SizedBox.shrink();
        return Opacity(
          opacity: _opacity.value,
          child: Transform.scale(
            scale: _scale.value,
            child: child,
          ),
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm + 2,
              vertical: AppSpacing.xxs + 2,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF34C759), Color(0xFF30D158)],
              ),
              borderRadius: AppRadius.borderRadiusPill,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF34C759).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              '+${widget.xp} XP',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          if (widget.comboCount > 1) ...[
            const SizedBox(width: AppSpacing.xs),
            Text(
              'x${widget.comboCount}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Color(0xFFFF9500),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
