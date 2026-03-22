import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/theme/colors.dart';
import '../../../ui/theme/spacing.dart';
import '../data/tutorial_preferences.dart';

/// Coach-mark tutorial overlay shown on first launch.
///
/// Requires [GlobalKey]s for the four highlighted UI elements:
/// 1. Timeline/Today tasks area
/// 2. Pain documentation button
/// 3. Bella AI assistant
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
      colorShadow: AppColors.black,
      opacityShadow: 0.75,
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

    // Step 2: Pain documentation
    if (painKey.currentContext != null) {
      targets.add(_target(
        key: painKey,
        identify: 'pain',
        title: l.tutorialStep2Title,
        description: l.tutorialStep2Desc,
        contentAlign: ContentAlign.bottom,
        shape: ShapeLightFocus.Circle,
      ));
    }

    // Step 3: Bella AI
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
        shape: ShapeLightFocus.Circle,
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
          builder: (context, controller) => _CoachMarkContent(
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
// Coach-mark content widget
// ─────────────────────────────────────────────────────────────────────────────

class _CoachMarkContent extends StatelessWidget {
  const _CoachMarkContent({
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

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step indicator
          Row(
            children: [
              for (int i = 0; i < totalSteps; i++) ...[
                if (i > 0) const SizedBox(width: 4),
                Container(
                  width: i == stepIndex ? 24 : 8,
                  height: 4,
                  decoration: BoxDecoration(
                    color: i == stepIndex
                        ? AppColors.primary
                        : AppColors.grey300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
              const Spacer(),
              Text(
                '${stepIndex + 1}/$totalSteps',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              // "Nicht mehr anzeigen" link
              GestureDetector(
                onTap: onNeverShow,
                child: Text(
                  l.tutorialNeverShow,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const Spacer(),
              // Next / Finish button
              FilledButton(
                onPressed: onNext,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isLast ? l.tutorialFinish : l.tutorialNext,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
