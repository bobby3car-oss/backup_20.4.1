import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../gamification_service.dart';

/// A dialog shown when a streak is about to break,
/// offering the user a one-time-per-week rescue (Pro feature).
class StreakRescueDialog extends StatefulWidget {
  const StreakRescueDialog({
    super.key,
    required this.service,
    required this.lostStreak,
    required this.isPro,
  });

  final GamificationService service;
  final int lostStreak;
  final bool isPro;

  /// Show the dialog and return true if streak was rescued.
  static Future<bool> show(
    BuildContext context, {
    required GamificationService service,
    required int lostStreak,
    required bool isPro,
  }) async {
    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'StreakRescueDialog',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, anim, _, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: anim,
              curve: Curves.easeOutBack,
            ),
            child: child,
          ),
        );
      },
      pageBuilder: (context, _, _) {
        return StreakRescueDialog(
          service: service,
          lostStreak: lostStreak,
          isPro: isPro,
        );
      },
    );
    return result ?? false;
  }

  @override
  State<StreakRescueDialog> createState() => _StreakRescueDialogState();
}

class _StreakRescueDialogState extends State<StreakRescueDialog> {
  bool _rescuing = false;

  Future<void> _rescue() async {
    if (_rescuing) return;
    setState(() => _rescuing = true);
    await widget.service.rescueStreak();
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: GlassContainer(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            borderRadius: AppRadius.borderRadiusXl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Broken streak icon
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.error.withValues(alpha: 0.2),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.local_fire_department_rounded,
                    size: 36,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                const Text(
                  'Streak verloren!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                Text(
                  'Deine Serie von ${widget.lostStreak} Tagen wurde unterbrochen.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),

                if (widget.isPro) ...[
                  // Rescue button (Pro)
                  GestureDetector(
                    onTap: _rescuing ? null : _rescue,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF9500), Color(0xFFFF3B30)],
                        ),
                        borderRadius: AppRadius.borderRadiusMd,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.warning.withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _rescuing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.white,
                                ),
                              )
                            : const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.shield_rounded, size: 18, color: AppColors.white),
                                  SizedBox(width: AppSpacing.sm),
                                  Text(
                                    'Streak retten',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    '1× pro Woche verfügbar (Pro)',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ] else ...[
                  // Pro upsell
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.08),
                      borderRadius: AppRadius.borderRadiusMd,
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.2),
                        width: 0.5,
                      ),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.workspace_premium_rounded, size: 28, color: AppColors.accent),
                        SizedBox(height: AppSpacing.sm),
                        Text(
                          'Streak retten mit Pro',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xxs),
                        Text(
                          'Rette deine Serie 1× pro Woche – nur mit Pro.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.lg),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'Schließen',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
