import 'package:flutter/material.dart';

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

/// All onboarding slides in order.
const List<OnboardingSlideData> onboardingSlides = [
  // ── Slide 1: Welcome ───────────────────────────────────────────────
  OnboardingSlideData(
    icon: Icons.monitor_heart_outlined,
    title: 'Dein digitaler\nOP-Begleiter',
    subtitle: 'Alle Informationen rund um deinen Eingriff –\nsicher und übersichtlich an einem Ort.',
    accentColor: Color(0xFF007AFF),
    features: [
      OnboardingFeature(icon: Icons.route_rounded, text: 'Schritt-für-Schritt Begleitung'),
      OnboardingFeature(icon: Icons.verified_user_outlined, text: 'Für Patienten entwickelt'),
      OnboardingFeature(icon: Icons.hub_outlined, text: 'Alles an einem Ort'),
    ],
  ),

  // ── Slide 2: Planning ──────────────────────────────────────────────
  OnboardingSlideData(
    icon: Icons.calendar_month_rounded,
    title: 'Deine OP\nim Überblick',
    subtitle: 'Von der Vorbereitung bis zur Nachsorge –\nalles übersichtlich geplant.',
    accentColor: Color(0xFF34C759),
    features: [
      OnboardingFeature(icon: Icons.checklist_rounded, text: 'Vorbereitungs-Checkliste'),
      OnboardingFeature(icon: Icons.luggage_rounded, text: 'Packliste für die Klinik'),
      OnboardingFeature(icon: Icons.event_available_rounded, text: 'Alle Termine im Blick'),
    ],
  ),

  // ── Slide 3: Health tracking ───────────────────────────────────────
  OnboardingSlideData(
    icon: Icons.favorite_rounded,
    title: 'Gesundheit\ntracken',
    subtitle: 'Behalte deine Vitalwerte und Symptome\njederzeit im Auge.',
    accentColor: Color(0xFF5856D6),
    features: [
      OnboardingFeature(icon: Icons.monitor_heart_outlined, text: 'Vitalwerte & Puls'),
      OnboardingFeature(icon: Icons.analytics_outlined, text: 'Schmerztagebuch'),
      OnboardingFeature(icon: Icons.medical_information_outlined, text: 'Symptom-Check'),
    ],
  ),

  // ── Slide 4: Wound care ────────────────────────────────────────────
  OnboardingSlideData(
    icon: Icons.healing_rounded,
    title: 'Deine\nWundheilung',
    subtitle: 'Dokumentiere deinen Heilungsverlauf\nmit Fotos und Vergleichen.',
    accentColor: Color(0xFFFF9500),
    features: [
      OnboardingFeature(icon: Icons.camera_alt_outlined, text: 'Foto-Dokumentation'),
      OnboardingFeature(icon: Icons.compare_rounded, text: 'Vergleichs-Funktion'),
      OnboardingFeature(icon: Icons.auto_awesome_rounded, text: 'Intelligente Hinweise'),
    ],
  ),

  // ── Slide 5: Team ──────────────────────────────────────────────────
  OnboardingSlideData(
    icon: Icons.group_rounded,
    title: 'Vernetzt mit\ndeinem Team',
    subtitle: 'Binde Angehörige ein und teile\nwichtige Informationen mit deinem Arzt.',
    accentColor: Color(0xFF00C7BE),
    features: [
      OnboardingFeature(icon: Icons.person_add_alt_1_rounded, text: 'Angehörige einladen'),
      OnboardingFeature(icon: Icons.share_rounded, text: 'Arztberichte teilen'),
      OnboardingFeature(icon: Icons.forum_outlined, text: 'Direkte Kommunikation'),
    ],
  ),
];
