import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

export 'appear.dart';
export 'haptic.dart';
export 'pressable.dart';

/// Canonical duration tokens for all micro-animations.
abstract final class MotionDuration {
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration medium = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration enter = Duration(milliseconds: 350);

  /// Hero element transitions (Lottie entrance, large slide reveals).
  static const Duration hero = Duration(milliseconds: 600);

  /// Tighter stagger interval for onboarding slide content.
  static const Duration stagger = Duration(milliseconds: 80);
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

  /// Very slow deceleration for hero / Lottie entrance animations.
  static const Curve heroEnter = Cubic(0.0, 0.0, 0.1, 1.0);
}

/// Platform-adaptive scroll physics: bouncing on iOS/macOS, clamping elsewhere.
ScrollPhysics get adaptiveScrollPhysics {
  if (kIsWeb) return const ClampingScrollPhysics();
  switch (defaultTargetPlatform) {
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
      return const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      );
    case TargetPlatform.android:
    case TargetPlatform.fuchsia:
    case TargetPlatform.windows:
    case TargetPlatform.linux:
      return const ClampingScrollPhysics();
  }
}
