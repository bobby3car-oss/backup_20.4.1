import 'package:flutter/widgets.dart';

import '../theme/radius.dart';

/// An Apple-style solid gradient icon bubble.
///
/// Renders [icon] in white on a coloured gradient background with a subtle
/// shadow – similar to iOS Home Screen app icons.
///
/// ```dart
/// GlassIcon(icon: CupertinoIcons.heart_fill, color: AppColors.error)
/// ```
class GlassIcon extends StatelessWidget {
  const GlassIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 34,
    this.iconSize,
    this.borderRadius,
  });

  /// The icon to display.
  final IconData icon;

  /// Accent colour used for the gradient background and shadow tint.
  final Color color;

  /// Overall size of the bubble (width & height). Default 34.
  final double size;

  /// Size of the icon glyph. Defaults to `size * 0.50`.
  final double? iconSize;

  /// Custom border radius. Defaults to [AppRadius.sm] (10) scaled by size.
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final effectiveIconSize = iconSize ?? size * 0.50;
    final radius = borderRadius ??
        BorderRadius.all(Radius.circular(size * 0.26));

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            color.withValues(alpha: 0.72),
          ],
        ),
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          icon,
          size: effectiveIconSize,
          color: const Color(0xFFFFFFFF),
        ),
      ),
    );
  }
}
