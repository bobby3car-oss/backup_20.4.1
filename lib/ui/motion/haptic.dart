import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Lightweight haptic feedback helper that is safe to call on all platforms.
/// On web and platforms without haptic support, calls are silently ignored.
abstract final class Haptic {
  static void light() {
    if (!kIsWeb) HapticFeedback.lightImpact();
  }

  static void medium() {
    if (!kIsWeb) HapticFeedback.mediumImpact();
  }

  static void selection() {
    if (!kIsWeb) HapticFeedback.selectionClick();
  }
}
