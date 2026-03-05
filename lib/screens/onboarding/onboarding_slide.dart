import 'dart:ui';

import 'package:flutter/material.dart';

import '../../ui/ui.dart';
import 'onboarding_data.dart';

/// A single onboarding slide with a glowing icon, headline, subtitle
/// and three feature bullets – all on a dark background.
class OnboardingSlide extends StatelessWidget {
  const OnboardingSlide({
    super.key,
    required this.data,
    required this.isActive,
  });

  final OnboardingSlideData data;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.xxl,
        right: AppSpacing.xxl,
        top: mq.padding.top + 80, // space for skip button
        bottom: 120, // space for indicator + button
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Glowing icon circle ──────────────────────────────────
          _GlowingIcon(
            icon: data.icon,
            color: data.accentColor,
            isActive: isActive,
          ),
          const SizedBox(height: AppSpacing.xxxl),

          // ── Title ────────────────────────────────────────────────
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.12,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Subtitle ─────────────────────────────────────────────
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.7),
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppSpacing.huge),

          // ── Feature bullets ──────────────────────────────────────
          ...List.generate(data.features.length, (i) {
            return FadeSlideIn(
              delay: Duration(milliseconds: 200 + i * 120),
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _FeatureRow(
                  feature: data.features[i],
                  accentColor: data.accentColor,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _GlowingIcon extends StatelessWidget {
  const _GlowingIcon({
    required this.icon,
    required this.color,
    required this.isActive,
  });

  final IconData icon;
  final Color color;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: isActive ? 1.0 : 0.5,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 48,
              spreadRadius: -4,
            ),
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 96,
              spreadRadius: 8,
            ),
          ],
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Icon(icon, size: 52, color: color),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.feature,
    required this.accentColor,
  });

  final OnboardingFeature feature;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: AppRadius.borderRadiusSm,
            ),
            child: Icon(feature.icon, size: 18, color: accentColor),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              feature.text,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
