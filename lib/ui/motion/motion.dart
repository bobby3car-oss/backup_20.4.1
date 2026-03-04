import 'package:flutter/animation.dart';

export 'appear.dart';
export 'haptic.dart';
export 'pressable.dart';

/// Canonical duration tokens for all micro-animations.
abstract final class MotionDuration {
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration medium = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration enter = Duration(milliseconds: 350);
}

/// iOS-like spring and ease curves for natural, premium motion.
abstract final class MotionCurve {
  /// Gentle spring-like deceleration — ideal for scale, position, opacity.
  static const Curve standard = Curves.easeOutCubic;

  /// Slightly bouncier — useful for selection indicators and bubbles.
  static const Curve emphasized = Cubic(0.2, 0.9, 0.3, 1.05);

  /// Quick settle for interactive feedback (tap-down / release).
  static const Curve interactive = Curves.easeInOutCubicEmphasized;

  /// Slow fade-in for staggered enter animations.
  static const Curve enter = Cubic(0.0, 0.0, 0.2, 1.0);
}
