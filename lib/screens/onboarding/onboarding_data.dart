import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Data model for a single onboarding slide.
class OnboardingSlideData {
  const OnboardingSlideData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.features,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final List<OnboardingFeature> features;
}

/// A single bullet-point feature shown on an onboarding slide.
class OnboardingFeature {
  const OnboardingFeature({required this.icon, required this.text});

  final IconData icon;
  final String text;
}

/// Accent colors for each onboarding slide (used by background animation).
const onboardingSlideColors = <Color>[
  Color(0xFF007AFF),
  Color(0xFF34C759),
  Color(0xFF5856D6),
  Color(0xFFFF9500),
  Color(0xFF00C7BE),
];

/// Number of onboarding feature slides.
const onboardingSlidesCount = 5;

/// Returns localized onboarding slides.
List<OnboardingSlideData> getOnboardingSlides(AppLocalizations l) => [
  OnboardingSlideData(
    icon: Icons.monitor_heart_outlined,
    title: l.onboardingSlide1Title,
    subtitle: l.onboardingSlide1Subtitle,
    accentColor: onboardingSlideColors[0],
    features: [
      OnboardingFeature(icon: Icons.route_rounded, text: l.onboardingSlide1Feature1),
      OnboardingFeature(icon: Icons.verified_user_outlined, text: l.onboardingSlide1Feature2),
      OnboardingFeature(icon: Icons.hub_outlined, text: l.onboardingSlide1Feature3),
    ],
  ),
  OnboardingSlideData(
    icon: Icons.calendar_month_rounded,
    title: l.onboardingSlide2Title,
    subtitle: l.onboardingSlide2Subtitle,
    accentColor: onboardingSlideColors[1],
    features: [
      OnboardingFeature(icon: Icons.checklist_rounded, text: l.onboardingSlide2Feature1),
      OnboardingFeature(icon: Icons.luggage_rounded, text: l.onboardingSlide2Feature2),
      OnboardingFeature(icon: Icons.event_available_rounded, text: l.onboardingSlide2Feature3),
    ],
  ),
  OnboardingSlideData(
    icon: Icons.favorite_rounded,
    title: l.onboardingSlide3Title,
    subtitle: l.onboardingSlide3Subtitle,
    accentColor: onboardingSlideColors[2],
    features: [
      OnboardingFeature(icon: Icons.monitor_heart_outlined, text: l.onboardingSlide3Feature1),
      OnboardingFeature(icon: Icons.analytics_outlined, text: l.onboardingSlide3Feature2),
      OnboardingFeature(icon: Icons.medical_information_outlined, text: l.onboardingSlide3Feature3),
    ],
  ),
  OnboardingSlideData(
    icon: Icons.healing_rounded,
    title: l.onboardingSlide4Title,
    subtitle: l.onboardingSlide4Subtitle,
    accentColor: onboardingSlideColors[3],
    features: [
      OnboardingFeature(icon: Icons.camera_alt_outlined, text: l.onboardingSlide4Feature1),
      OnboardingFeature(icon: Icons.compare_rounded, text: l.onboardingSlide4Feature2),
      OnboardingFeature(icon: Icons.auto_awesome_rounded, text: l.onboardingSlide4Feature3),
    ],
  ),
  OnboardingSlideData(
    icon: Icons.group_rounded,
    title: l.onboardingSlide5Title,
    subtitle: l.onboardingSlide5Subtitle,
    accentColor: onboardingSlideColors[4],
    features: [
      OnboardingFeature(icon: Icons.person_add_alt_1_rounded, text: l.onboardingSlide5Feature1),
      OnboardingFeature(icon: Icons.share_rounded, text: l.onboardingSlide5Feature2),
      OnboardingFeature(icon: Icons.forum_outlined, text: l.onboardingSlide5Feature3),
    ],
  ),
];
