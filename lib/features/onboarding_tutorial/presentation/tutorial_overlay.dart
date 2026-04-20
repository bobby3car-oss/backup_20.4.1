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
// Bella chat-bubble coach-mark content widget – animated
// ─────────────────────────────────────────────────────────────────────────────

class _BellaCoachMarkContent extends StatefulWidget {
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
  State<_BellaCoachMarkContent> createState() => _BellaCoachMarkContentState();
}

class _BellaCoachMarkContentState extends State<_BellaCoachMarkContent>
    with TickerProviderStateMixin {
  // ── Controllers ────────────────────────────────────────────────────────────
  late final AnimationController _entrance; // 680ms – avatar + bubble entry
  late final AnimationController _pulse;    // 1900ms loop – avatar glow halo
  late final AnimationController _typing;   // dynamic – typewriter text reveal
  late final AnimationController _btnPop;   // 450ms – button bounce after typing

  // ── Entrance-derived animations ────────────────────────────────────────────
  late final Animation<double> _avatarScale;
  late final Animation<Offset> _avatarSlide;
  late final Animation<double> _bubbleOpacity;
  late final Animation<Offset> _bubbleSlide;
  late final Animation<double> _contentFade; // title + actions

  // ── Halo pulse ─────────────────────────────────────────────────────────────
  late final Animation<double> _haloScale;
  late final Animation<double> _haloOpacity;

  // ── Typewriter ─────────────────────────────────────────────────────────────
  late final Animation<int> _charCount;

  // ── Button pop (1.0 → 1.10 → 1.0) after typing ───────────────────────────
  late final Animation<double> _btnPopScale;

  bool _typingDone = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _initAnimations();
    _entrance.forward().then((_) {
      if (!mounted) return;
      _typing.forward().then((_) {
        if (!mounted) return;
        setState(() => _typingDone = true);
        _btnPop.forward();
      });
    });
  }

  void _initControllers() {
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 680),
    );
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    )..repeat(reverse: true);
    _typing = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: (widget.description.length * 22).clamp(450, 1900),
      ),
    );
    _btnPop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
  }

  void _initAnimations() {
    // Avatar: elastic spring bounce from below
    _avatarScale = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.0, 0.55, curve: Curves.elasticOut),
    );
    _avatarSlide = Tween<Offset>(
      begin: const Offset(0, 0.9),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.0, 0.40, curve: Curves.easeOutCubic),
    ));

    // Bubble: slides up + fades in after avatar
    _bubbleOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.22, 0.65, curve: Curves.easeOut),
      ),
    );
    _bubbleSlide = Tween<Offset>(
      begin: const Offset(0, 0.40),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.22, 0.62, curve: Curves.easeOutCubic),
    ));

    // Title + actions fade in after bubble is visible
    _contentFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.50, 0.88, curve: Curves.easeOut),
      ),
    );

    // Breathing halo around avatar
    _haloScale = Tween<double>(begin: 1.0, end: 1.22).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
    _haloOpacity = Tween<double>(begin: 0.18, end: 0.48).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );

    // Typewriter: reveal characters linearly
    _charCount = IntTween(
      begin: 0,
      end: widget.description.length,
    ).animate(CurvedAnimation(parent: _typing, curve: Curves.linear));

    // Button pop: subtle scale burst when typing finishes
    _btnPopScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.10), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.10, end: 1.0), weight: 60),
    ]).animate(CurvedAnimation(parent: _btnPop, curve: Curves.easeInOut));
  }

  /// Tapping the bubble skips to full text immediately.
  void _skipTyping() {
    if (_typingDone) return;
    _typing.animateTo(1.0, duration: Duration.zero);
  }

  @override
  void dispose() {
    _entrance.dispose();
    _pulse.dispose();
    _typing.dispose();
    _btnPop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isLast = widget.stepIndex == widget.totalSteps - 1;

    return GestureDetector(
      onTap: _skipTyping,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // ── Bella Avatar ──────────────────────────────────────────────
            SlideTransition(
              position: _avatarSlide,
              child: ScaleTransition(
                scale: _avatarScale,
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Breathing glow halo
                      AnimatedBuilder(
                        animation: _pulse,
                        builder: (context, _) => Transform.scale(
                          scale: _haloScale.value,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _kBellaPink.withValues(
                                alpha: _haloOpacity.value,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Avatar image
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _kBellaPink.withValues(alpha: 0.45),
                              blurRadius: 18,
                              offset: const Offset(0, 4),
                              spreadRadius: -2,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/bella_avatar.png',
                            width: 36,
                            height: 36,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // ── Chat bubble ──────────────────────────────────────────────
            Flexible(
              child: FadeTransition(
                opacity: _bubbleOpacity,
                child: SlideTransition(
                  position: _bubbleSlide,
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
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm + 2,
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
                        child: FadeTransition(
                          opacity: _contentFade,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Step progress dots ──────────────────────
                              Row(
                                children: [
                                  for (int i = 0;
                                      i < widget.totalSteps;
                                      i++) ...[
                                    if (i > 0) const SizedBox(width: 4),
                                    AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                      width: i == widget.stepIndex ? 28 : 8,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: i == widget.stepIndex
                                            ? _kBellaPink
                                            : AppColors.grey300,
                                        borderRadius:
                                            BorderRadius.circular(2),
                                      ),
                                    ),
                                  ],
                                  const Spacer(),
                                  Text(
                                    '${widget.stepIndex + 1}/'
                                    '${widget.totalSteps}',
                                    style: TextStyle(
                                      color:
                                          _kBellaPink.withValues(alpha: 0.70),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.sm),

                              // ── Title ────────────────────────────────────
                              Text(
                                widget.title,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _kBellaPink,
                                  letterSpacing: -0.1,
                                ),
                              ),
                              const SizedBox(height: 2),

                              // ── Typewriter text ──────────────────────────
                              AnimatedBuilder(
                                animation: _charCount,
                                builder: (context, _) => Text(
                                  widget.description.substring(
                                    0,
                                    _charCount.value.clamp(
                                        0, widget.description.length),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textPrimary,
                                    height: 1.35,
                                    letterSpacing: -0.1,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),

                              // ── Actions row ──────────────────────────────
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: widget.onNeverShow,
                                    child: Text(
                                      l.tutorialNeverShow,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                        decoration: TextDecoration.underline,
                                        decorationColor:
                                            AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  ScaleTransition(
                                    scale: _btnPopScale,
                                    child: FilledButton(
                                      onPressed: () {
                                        HapticFeedback.lightImpact();
                                        widget.onNext();
                                      },
                                      style: FilledButton.styleFrom(
                                        backgroundColor: _kBellaPink,
                                        foregroundColor: AppColors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.md,
                                          vertical: 6,
                                        ),
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: Text(
                                        isLast
                                            ? l.tutorialFinish
                                            : l.tutorialNext,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
