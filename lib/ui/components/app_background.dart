import 'package:flutter/material.dart';

/// A clean, clinical background with a subtle neutral gradient.
/// Wrap screen content in this widget on main screens.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF5F6FA),
            Color(0xFFEFF0F6),
          ],
        ),
      ),
      child: child,
    );
  }
}
