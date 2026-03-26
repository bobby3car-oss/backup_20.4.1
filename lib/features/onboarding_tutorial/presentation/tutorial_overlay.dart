import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/theme/colors.dart';
import '../../../ui/theme/spacing.dart';
import '../data/tutorial_preferences.dart';

// Bella's signature pink color – matches BellaFab shadow and accent.
const _kBellaPink = Color(0xFFFF6B9D);

/// Coach-mark tutorial overlay shown on first launch.
///
/// Requires [GlobalKey]s for the four highlighted UI elements:
/// 1. Timeline/Today tasks area
/// 2. Appointments tab
/// 3. Bella AI assistant FAB
/// 4. "Mehr" (More) tab
class TutorialOverlay {
  TutorialOverlay({
    required this.context,
    required this.timelineKey,
    required this.painKey,
    required this.bellaKey,
    required this.mehrTabKey,
  });

  final BuildContext context;
  final GlobalKey timelineKey;
  final GlobalKey painKey;
  final GlobalKey bellaKey;
  final GlobalKey mehrTabKey;

  TutorialCoachMark? _tutorialCoachMark;

  /// Shows the tutorial if it hasn't been completed / dismissed before.
  Future<void> showIfNeeded() async {
    final prefs = TutorialPreferences.instance;
    if (await prefs.isTutorialNeverShow()) return;
    if (await prefs.isTutorialCompleted()) return;

    if (!context.mounted) return;
    _show();
  }

  /// Force-show the tutorial (e.g. from settings "Replay tutorial").
  void show() => _show();

  void _show() {
    final l = AppLocalizations.of(context)!;
    final targets = _buildTargets(l);
    if (targets.isEmpty) return;

    _tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: _kBellaPink,
      opacityShadow: 0.55,
      textSkip: l.tutorialSkip,
      paddingFocus: 10,
      onFinish: () => _onComplete(),
      onSkip: () {
        _onSkip();
        return true;
      },
      onClickTarget: (_) {},
      alignSkip: Alignment.topRight,
      textStyleSkip: const TextStyle(
        color: AppColors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    )..show(context: context);
  }

  List<TargetFocus> _buildTargets(AppLocalizations l) {
    final targets = <TargetFocus>[];

    // Step 1: Timeline
    if (timelineKey.currentContext != null) {
      targets.add(_target(
        key: timelineKey,
        identify: 'timeline',
        title: l.tutorialStep1Title,
        description: l.tutorialStep1Desc,
        contentAlign: ContentAlign.bottom,
        shape: ShapeLightFocus.RRect,
      ));
    }

    // Step 2: Appointments tab
    if (painKey.currentContext != null) {
      targets.add(_target(
        key: painKey,
        identify: 'pain',
        title: l.tutorialStep2Title,
        description: l.tutorialStep2Desc,
        contentAlign: ContentAlign.top,
        shape: ShapeLightFocus.RRect,
      ));
    }

    // Step 3: Bella AI FAB
    if (bellaKey.currentContext != null) {
      targets.add(_target(
        key: bellaKey,
        identify: 'bella',
        title: l.tutorialStep3Title,
        description: l.tutorialStep3Desc,
        contentAlign: ContentAlign.top,
        shape: ShapeLightFocus.Circle,
      ));
    }

    // Step 4: "Mehr" tab
    if (mehrTabKey.currentContext != null) {
      targets.add(_target(
        key: mehrTabKey,
        identify: 'mehr',
        title: l.tutorialStep4Title,
        description: l.tutorialStep4Desc,
        contentAlign: ContentAlign.top,
        shape: ShapeLightFocus.RRect,
      ));
    }

    return targets;
  }

  TargetFocus _target({
    required GlobalKey key,
    required String identify,
    required String title,
    required String description,
    required ContentAlign contentAlign,
    required ShapeLightFocus shape,
  }) {
    return TargetFocus(
      identify: identify,
      keyTarget: key,
      shape: shape,
      radius: 12,
      enableOverlayTab: true,
      enableTargetTab: true,
      contents: [
        TargetContent(
          align: contentAlign,
          builder: (context, controller) => _BellaCoachMarkContent(
            title: title,
            description: description,
            stepIndex: _stepIndexFor(identify),
            totalSteps: 4,
            onNext: controller.next,
            onNeverShow: () {
              _onNeverShow();
              _tutorialCoachMark?.skip();
            },
          ),
        ),
      ],
    );
  }

  int _stepIndexFor(String identify) {
    switch (identify) {
      case 'timeline':
        return 0;
      case 'pain':
        return 1;
      case 'bella':
        return 2;
      case 'mehr':
        return 3;
      default:
        return 0;
    }
  }

  void _onComplete() {
    TutorialPreferences.instance.setTutorialCompleted();
  }

  void _onSkip() {
    TutorialPreferences.instance.setTutorialCompleted();
  }

  void _onNeverShow() {
    TutorialPreferences.instance.setTutorialNeverShow();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bella chat-bubble coach-mark content widget
// ─────────────────────────────────────────────────────────────────────────────

class _BellaCoachMarkContent extends StatelessWidget {
  const _BellaCoachMarkContent({
    required this.title,
    required this.description,
    required this.stepIndex,
    required this.totalSteps,
    required this.onNext,
    required this.onNeverShow,
  });

  final String title;
  final String description;
  final int stepIndex;
  final int totalSteps;
  final VoidCallback onNext;
  final VoidCallback onNeverShow;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isLast = stepIndex == totalSteps - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // ── Bella Avatar ─────────────────────────────────────────────
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Small spacer so the avatar aligns with the bubble tail.
              const SizedBox(height: 6),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _kBellaPink.withValues(alpha: 0.40),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/bella_avatar.png',
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),

          // ── Chat bubble ───────────────────────────────────────────────
          Flexible(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
                bottomLeft: Radius.circular(6),
                bottomRight: Radius.circular(22),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.88),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(22),
                      topRight: Radius.circular(22),
                      bottomLeft: Radius.circular(6),
                      bottomRight: Radius.circular(22),
                    ),
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.70),
                      width: 0.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _kBellaPink.withValues(alpha: 0.12),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                        spreadRadius: -4,
                      ),
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Step progress dots + counter ──────────────────
                      Row(
                        children: [
                          for (int i = 0; i < totalSteps; i++) ...[
                            if (i > 0) const SizedBox(width: 4),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              width: i == stepIndex ? 28 : 8,
                              height: 4,
                              decoration: BoxDecoration(
                                color: i == stepIndex
                                    ? _kBellaPink
                                    : AppColors.grey300,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                          const Spacer(),
                          Text(
                            '${stepIndex + 1}/$totalSteps',
                            style: TextStyle(
                              color: _kBellaPink.withValues(alpha: 0.70),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // ── Title ─────────────────────────────────────────
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _kBellaPink,
                          letterSpacing: -0.1,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // ── Message text ─────────────────────────────────
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.textPrimary,
                          height: 1.45,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // ── Actions row ───────────────────────────────────
                      Row(
                        children: [
                          GestureDetector(
                            onTap: onNeverShow,
                            child: Text(
                              l.tutorialNeverShow,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const Spacer(),
                          FilledButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              onNext();
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: _kBellaPink,
                              foregroundColor: AppColors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                                vertical: AppSpacing.sm,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              isLast ? l.tutorialFinish : l.tutorialNext,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
