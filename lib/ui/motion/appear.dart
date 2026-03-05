import 'package:flutter/material.dart';

import 'motion.dart';

/// A subtle fade + slide-up enter animation for list items and cards.
///
/// The widget fades from [beginOpacity] to 1.0 and slides up by
/// [slideOffset] pixels over [duration]. Plays once on first build.
///
/// Use [delay] to stagger multiple items appearing in sequence.
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.duration = MotionDuration.enter,
    this.delay = Duration.zero,
    this.slideOffset = 16.0,
    this.beginOpacity = 0.0,
    this.curve = MotionCurve.enter,
  });

  final Widget child;
  final Duration duration;
  final Duration delay;
  final double slideOffset;
  final double beginOpacity;
  final Curve curve;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    final curved = CurvedAnimation(parent: _controller, curve: widget.curve);

    _opacity = Tween<double>(
      begin: widget.beginOpacity,
      end: 1.0,
    ).animate(curved);

    _offset = Tween<Offset>(
      begin: Offset(0, widget.slideOffset),
      end: Offset.zero,
    ).animate(curved);

    _start();
  }

  Future<void> _start() async {
    if (widget.delay > Duration.zero) {
      await Future<void>.delayed(widget.delay);
      if (!mounted) return;
    }
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Opacity(
        opacity: _opacity.value,
        child: Transform.translate(offset: _offset.value, child: child),
      ),
      child: widget.child,
    );
  }
}
