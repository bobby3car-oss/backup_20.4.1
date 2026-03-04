import 'package:flutter/material.dart';

import '../motion/motion.dart';
import '../theme/colors.dart';

/// A checkbox with animated fill, border color, and checkmark scale transitions.
///
/// Supports both circular and rounded-rect shapes via [borderRadius].
/// Defaults to a circle when [borderRadius] is null.
///
/// All transitions use implicit animations — no controllers needed by the
/// consumer. Just flip [value] and the widget handles the rest.
class AnimatedCheckbox extends StatelessWidget {
  const AnimatedCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.activeColor = AppColors.success,
    this.inactiveColor = AppColors.grey300,
    this.size = 24.0,
    this.borderRadius,
    this.iconSize,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color activeColor;
  final Color inactiveColor;
  final double size;

  /// When null the checkbox renders as a circle; provide a [BorderRadius]
  /// for a rounded-rectangle shape (e.g. timeline tasks).
  final BorderRadius? borderRadius;

  /// Icon size for the checkmark. Defaults to `size * 0.58`.
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final effectiveIconSize = iconSize ?? size * 0.58;
    final isCircle = borderRadius == null;

    return GestureDetector(
      onTap: onChanged != null ? () => onChanged!(!value) : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: MotionDuration.medium,
        curve: MotionCurve.standard,
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: value
              ? activeColor.withValues(alpha: 0.10)
              : Colors.transparent,
          shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isCircle ? null : borderRadius,
          border: Border.all(
            color: value
                ? activeColor.withValues(alpha: 0.50)
                : inactiveColor.withValues(alpha: 0.30),
            width: value ? 1.5 : 0.8,
          ),
        ),
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value ? 1.0 : 0.0),
            duration: value ? MotionDuration.medium : MotionDuration.fast,
            curve: value ? MotionCurve.emphasized : MotionCurve.standard,
            builder: (context, t, _) {
              if (t < 0.01) return const SizedBox.shrink();
              return Opacity(
                opacity: t.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: (0.3 + t * 0.7).clamp(0.0, 1.0),
                  child: Icon(
                    Icons.check_rounded,
                    size: effectiveIconSize,
                    color: activeColor,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
