import 'package:flutter/material.dart';

import '../onboarding_data.dart';

/// Clean animated background for the onboarding carousel.
///
/// Uses the app's light palette with a very subtle accent-color tint
/// that smoothly transitions between slide colors as the user swipes.
class ParallaxSlideBackground extends StatelessWidget {
  const ParallaxSlideBackground({
    super.key,
    required this.pageCtrl,
    required this.totalPages,
  });

  final PageController pageCtrl;
  final int totalPages;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pageCtrl,
      builder: (context, _) {
        final page = pageCtrl.hasClients && pageCtrl.page != null
            ? pageCtrl.page!
            : 0.0;
        final accent = _computeAccent(page);

        return SizedBox.expand(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.lerp(const Color(0xFFF5F6FA), accent, 0.04)!,
                  const Color(0xFFF0F1F7),
                  Color.lerp(const Color(0xFFECEDF4), accent, 0.03)!,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _computeAccent(double page) {
    final featurePage =
        (page - 1).clamp(0.0, onboardingSlidesCount.toDouble());
    final idx = featurePage.floor().clamp(0, onboardingSlidesCount - 1);
    final nextIdx = (idx + 1).clamp(0, onboardingSlidesCount - 1);
    final t = featurePage - featurePage.floor();

    if (idx < onboardingSlidesCount && nextIdx < onboardingSlidesCount) {
      return Color.lerp(
        onboardingSlideColors[idx],
        onboardingSlideColors[nextIdx],
        t,
      )!;
    }
    return const Color(0xFF007AFF);
  }
}
