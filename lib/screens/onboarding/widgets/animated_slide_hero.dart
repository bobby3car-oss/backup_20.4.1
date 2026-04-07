import 'package:flutter/material.dart';

import '../../../ui/ui.dart';

/// Animated icon hero for onboarding slides.
///
/// Shows a large accent-colored icon that scales + fades in when
/// [isActive] becomes true, with a gentle continuous bounce animation.
class AnimatedSlideHero extends StatefulWidget {
  const AnimatedSlideHero({
    super.key,
    required this.icon,
    required this.accentColor,
    required this.isActive,
  });

  final IconData icon;
  final Color accentColor;
  final bool isActive;

  @override
  State<AnimatedSlideHero> createState() => _AnimatedSlideHeroState();
}

class _AnimatedSlideHeroState extends State<AnimatedSlideHero>
    with TickerProviderStateMixin {
  late final AnimationController _entranceCtrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _opacityAnim;

  late final AnimationController _bounceCtrl;
  late final Animation<double> _bounceAnim;

  bool _wasActive = false;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: MotionDuration.hero,
    );

    final curved = CurvedAnimation(
      parent: _entranceCtrl,
      curve: MotionCurve.heroEnter,
    );
    _scaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(curved);
    _opacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(curved);

    // Gentle continuous float
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _bounceAnim = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut),
    );

    if (widget.isActive) {
      _wasActive = true;
      _entranceCtrl.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedSlideHero oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_wasActive) {
      _wasActive = true;
      _entranceCtrl.forward(from: 0.0);
    } else if (!widget.isActive && _wasActive) {
      _wasActive = false;
      _entranceCtrl.reverse();
    }
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _bounceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_entranceCtrl, _bounceCtrl]),
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnim.value,
          child: Transform.translate(
            offset: Offset(0, _bounceAnim.value * _opacityAnim.value),
            child: Transform.scale(
              scale: _scaleAnim.value,
              child: child,
            ),
          ),
        );
      },
      child: Icon(
        widget.icon,
        size: 120,
        color: widget.accentColor,
      ),
    );
  }
}
