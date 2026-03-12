import 'package:flutter/material.dart';

import '../../../domain/timeline_engine.dart';
import '../../../ui/ui.dart';
import '../home_view_model.dart';

/// The single dominant card showing the user's next important step.
class HeuteFocusCard extends StatelessWidget {
  const HeuteFocusCard({
    super.key,
    required this.focus,
    required this.dayLabel,
    required this.encouragement,
    this.onAction,
    this.onTap,
  });

  final TodayFocus focus;
  final String dayLabel;
  final String encouragement;
  final VoidCallback? onAction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return GlassContainer(
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(24),
      variant: GlassVariant.medium,
      elevation: GlassElevation.medium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top: day label + encouragement ──────────────────
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dayLabel,
                  style: tt.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  encouragement,
                  style: tt.bodyMedium?.copyWith(
                    color: AppColors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom: focus task ─────────────────────────────
          PressableScale(
            onTap: focus.isAllDone ? null : onTap,
            scaleFactor: 0.98,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: focus.iconColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      focus.icon,
                      size: 22,
                      color: focus.iconColor,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Title + subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          focus.title,
                          style: tt.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          focus.subtitle,
                          style: tt.bodySmall?.copyWith(
                            color: focus.state == TaskState.due
                                ? AppColors.error
                                : AppColors.textSecondary,
                            fontWeight: focus.state == TaskState.due
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),

                  // CTA
                  if (!focus.isAllDone)
                    _FocusCTA(
                      isDue: focus.state == TaskState.due,
                      onTap: onAction,
                    ),

                  if (focus.isAllDone)
                    Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.success,
                      size: 32,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FocusCTA extends StatelessWidget {
  const _FocusCTA({required this.isDue, this.onTap});

  final bool isDue;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: () {
        Haptic.light();
        onTap?.call();
      },
      scaleFactor: 0.92,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: isDue ? null : AppColors.primaryGradient,
          color: isDue ? AppColors.error : null,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: (isDue ? AppColors.error : AppColors.primary)
                  .withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          isDue ? 'Jetzt' : 'Öffnen',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}
