import 'package:flutter/foundation.dart';

// ── Elevation levels ─────────────────────────────────────────────────────────

enum GlassElevation { flat, low, medium, high }

extension GlassElevationValues on GlassElevation {
  double get blurRadius => switch (this) {
    GlassElevation.flat => 0,
    GlassElevation.low => 24,
    GlassElevation.medium => 40,
    GlassElevation.high => 64,
  };

  double get yOffset => switch (this) {
    GlassElevation.flat => 0,
    GlassElevation.low => 6,
    GlassElevation.medium => 12,
    GlassElevation.high => 18,
  };

  double get spreadRadius => switch (this) {
    GlassElevation.flat => 0,
    GlassElevation.low => -3,
    GlassElevation.medium => -5,
    GlassElevation.high => -8,
  };

  double get opacity => switch (this) {
    GlassElevation.flat => 0,
    GlassElevation.low => 0.06,
    GlassElevation.medium => 0.09,
    GlassElevation.high => 0.13,
  };
}

// ── Glass thickness variants ─────────────────────────────────────────────────

enum GlassVariant { thin, medium, thick }

extension GlassVariantValues on GlassVariant {
  double get fillBoost => switch (this) {
    GlassVariant.thin => -0.05,
    GlassVariant.medium => 0.0,
    GlassVariant.thick => 0.08,
  };

  double get borderBoost => switch (this) {
    GlassVariant.thin => -0.06,
    GlassVariant.medium => 0.0,
    GlassVariant.thick => 0.08,
  };

  /// Multiplier applied to the platform blur sigma.
  double get blurMultiplier => switch (this) {
    GlassVariant.thin => 0.7,
    GlassVariant.medium => 1.0,
    GlassVariant.thick => 1.25,
  };

  /// Extra white alpha added at the top-left of the highlight gradient.
  double get highlightAlpha => switch (this) {
    GlassVariant.thin => 0.15,
    GlassVariant.medium => 0.28,
    GlassVariant.thick => 0.42,
  };

  double get topEdgeAlpha => switch (this) {
    GlassVariant.thin => 0.12,
    GlassVariant.medium => 0.22,
    GlassVariant.thick => 0.38,
  };

  double get bottomEdgeAlpha => switch (this) {
    GlassVariant.thin => 0.02,
    GlassVariant.medium => 0.04,
    GlassVariant.thick => 0.07,
  };

  double get innerGlowAlpha => switch (this) {
    GlassVariant.thin => 0.0,
    GlassVariant.medium => 0.02,
    GlassVariant.thick => 0.05,
  };

  GlassElevation get defaultElevation => switch (this) {
    GlassVariant.thin => GlassElevation.low,
    GlassVariant.medium => GlassElevation.medium,
    GlassVariant.thick => GlassElevation.high,
  };
}

// ── Platform config ──────────────────────────────────────────────────────────

class GlassConfig {
  const GlassConfig._({
    required this.sigmaX,
    required this.sigmaY,
    required this.fillOpacity,
    required this.borderOpacity,
    required this.shadowOpacity,
    required this.useBlur,
  });

  final double sigmaX;
  final double sigmaY;
  final double fillOpacity;
  final double borderOpacity;
  final double shadowOpacity;
  final bool useBlur;

  static GlassConfig get platform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return ios;
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        return android;
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return desktop;
    }
  }

  static const GlassConfig ios = GlassConfig._(
    sigmaX: 34,
    sigmaY: 34,
    fillOpacity: 0.28,
    borderOpacity: 0.28,
    shadowOpacity: 0.10,
    useBlur: true,
  );

  static const GlassConfig android = GlassConfig._(
    sigmaX: 14,
    sigmaY: 14,
    fillOpacity: 0.34,
    borderOpacity: 0.20,
    shadowOpacity: 0.08,
    useBlur: true,
  );

  static const GlassConfig web = GlassConfig._(
    sigmaX: 8,
    sigmaY: 8,
    fillOpacity: 0.42,
    borderOpacity: 0.22,
    shadowOpacity: 0.06,
    useBlur: true,
  );

  static const GlassConfig desktop = GlassConfig._(
    sigmaX: 22,
    sigmaY: 22,
    fillOpacity: 0.30,
    borderOpacity: 0.24,
    shadowOpacity: 0.08,
    useBlur: true,
  );
}
