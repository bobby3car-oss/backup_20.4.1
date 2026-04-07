import 'package:flutter/material.dart';

import '../../ui/ui.dart';
import 'onboarding_data.dart';
import 'widgets/animated_slide_hero.dart';

/// A single onboarding slide with a gradient hero card, benefit headline,
/// subtitle, and staggered feature items.
class OnboardingSlide extends StatefulWidget {
  const OnboardingSlide({
    super.key,
    required this.data,
    required this.isActive,
  });

  final OnboardingSlideData data;
  final bool isActive;

  @override
  State<OnboardingSlide> createState() => _OnboardingSlideState();
}

class _OnboardingSlideState extends State<OnboardingSlide>
    with SingleTickerProviderStateMixin {
  late final AnimationController _staggerCtrl;

  late final Animation<double> _headlineOpacity;
  late final Animation<Offset> _headlineSlide;
  late final Animation<double> _subtitleOpacity;
  late final Animation<Offset> _subtitleSlide;

  bool _hasPlayed = false;

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _headlineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _staggerCtrl,
        curve: const Interval(0.20, 0.48, curve: MotionCurve.enter),
      ),
    );
    _headlineSlide = Tween<Offset>(
      begin: const Offset(0, 16),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _staggerCtrl,
        curve: const Interval(0.20, 0.48, curve: MotionCurve.enter),
      ),
    );
    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _staggerCtrl,
        curve: const Interval(0.32, 0.58, curve: MotionCurve.enter),
      ),
    );
    _subtitleSlide = Tween<Offset>(
      begin: const Offset(0, 12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _staggerCtrl,
        curve: const Interval(0.32, 0.58, curve: MotionCurve.enter),
      ),
    );

    if (widget.isActive) {
      _hasPlayed = true;
      _staggerCtrl.forward();
    }
  }

  @override
  void didUpdateWidget(OnboardingSlide oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_hasPlayed) {
      _hasPlayed = true;
      _staggerCtrl.forward(from: 0.0);
    } else if (!widget.isActive && _hasPlayed) {
      _hasPlayed = false;
      _staggerCtrl.reverse();
    }
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final data = widget.data;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(
            left: AppSpacing.xxl,
            right: AppSpacing.xxl,
            top: mq.padding.top + 56,
            bottom: 140,
          ),
          child: Column(
            children: [
              // ── Gradient Hero Card ───────────────────────────
              AnimatedSlideHero(
                icon: data.icon,
                accentColor: data.accentColor,
                isActive: widget.isActive,
              ),
              const SizedBox(height: AppSpacing.xxxl),

              // ── Headline ─────────────────────────────────────
              AnimatedBuilder(
                animation: _staggerCtrl,
                builder: (context, child) => Opacity(
                  opacity: _headlineOpacity.value,
                  child: Transform.translate(
                    offset: _headlineSlide.value,
                    child: child,
                  ),
                ),
                child: Text(
                  data.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.15,
                    letterSpacing: -0.6,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // ── Subtitle ─────────────────────────────────────
              AnimatedBuilder(
                animation: _staggerCtrl,
                builder: (context, child) => Opacity(
                  opacity: _subtitleOpacity.value,
                  child: Transform.translate(
                    offset: _subtitleSlide.value,
                    child: child,
                  ),
                ),
                child: Text(
                  data.subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // ── Feature Items (staggered) ────────────────────
              ...List.generate(data.features.length, (i) {
                final startFraction = 0.50 + i * 0.10;
                final endFraction =
                    (startFraction + 0.22).clamp(0.0, 1.0);

                return _StaggeredItem(
                  animation: _staggerCtrl,
                  startFraction: startFraction,
                  endFraction: endFraction,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _FeatureRow(
                      feature: data.features[i],
                      accentColor: data.accentColor,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// Drives a single child's staggered entrance using parent [animation].
class _StaggeredItem extends StatelessWidget {
  const _StaggeredItem({
    required this.animation,
    required this.startFraction,
    required this.endFraction,
    required this.child,
  });

  final Animation<double> animation;
  final double startFraction;
  final double endFraction;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animation,
        curve: Interval(startFraction, endFraction, curve: MotionCurve.enter),
      ),
    );
    final slideY = Tween<double>(begin: 16.0, end: 0.0).animate(
      CurvedAnimation(
        parent: animation,
        curve: Interval(startFraction, endFraction, curve: MotionCurve.enter),
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Opacity(
        opacity: opacity.value,
        child: Transform.translate(
          offset: Offset(0, slideY.value),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// Feature item — rounded-square icon container + text.
class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.feature,
    required this.accentColor,
  });

  final OnboardingFeature feature;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(feature.icon, size: 20, color: accentColor),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Text(
            feature.text,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
              letterSpacing: -0.1,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
