import 'package:flutter/foundation.dart';

// ── Elevation levels ─────────────────────────────────────────────────────────

enum GlassElevation { flat, low, medium, high }

extension GlassElevationValues on GlassElevation {
  double get blurRadius => switch (this) {
        GlassElevation.flat => 0,
        GlassElevation.low => 16,
        GlassElevation.medium => 32,
        GlassElevation.high => 48,
      };

  double get yOffset => switch (this) {
        GlassElevation.flat => 0,
        GlassElevation.low => 4,
        GlassElevation.medium => 8,
        GlassElevation.high => 14,
      };

  double get spreadRadius => switch (this) {
        GlassElevation.flat => 0,
        GlassElevation.low => -2,
        GlassElevation.medium => -4,
        GlassElevation.high => -6,
      };

  double get opacity => switch (this) {
        GlassElevation.flat => 0,
        GlassElevation.low => 0.05,
        GlassElevation.medium => 0.08,
        GlassElevation.high => 0.12,
      };
}

// ── Glass thickness variants ─────────────────────────────────────────────────

enum GlassVariant { thin, medium, thick }

extension GlassVariantValues on GlassVariant {
  double get fillBoost => switch (this) {
        GlassVariant.thin => -0.04,
        GlassVariant.medium => 0.0,
        GlassVariant.thick => 0.06,
      };

  double get borderBoost => switch (this) {
        GlassVariant.thin => -0.04,
        GlassVariant.medium => 0.0,
        GlassVariant.thick => 0.06,
      };

  double get highlightAlpha => switch (this) {
        GlassVariant.thin => 0.20,
        GlassVariant.medium => 0.35,
        GlassVariant.thick => 0.50,
      };

  double get topEdgeAlpha => switch (this) {
        GlassVariant.thin => 0.15,
        GlassVariant.medium => 0.25,
        GlassVariant.thick => 0.40,
      };

  double get bottomEdgeAlpha => switch (this) {
        GlassVariant.thin => 0.03,
        GlassVariant.medium => 0.05,
        GlassVariant.thick => 0.08,
      };

  double get innerGlowAlpha => switch (this) {
        GlassVariant.thin => 0.0,
        GlassVariant.medium => 0.03,
        GlassVariant.thick => 0.06,
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
    sigmaX: 32,
    sigmaY: 32,
    fillOpacity: 0.18,
    borderOpacity: 0.22,
    shadowOpacity: 0.10,
    useBlur: true,
  );

  static const GlassConfig android = GlassConfig._(
    sigmaX: 12,
    sigmaY: 12,
    fillOpacity: 0.22,
    borderOpacity: 0.16,
    shadowOpacity: 0.08,
    useBlur: true,
  );

  static const GlassConfig web = GlassConfig._(
    sigmaX: 6,
    sigmaY: 6,
    fillOpacity: 0.32,
    borderOpacity: 0.18,
    shadowOpacity: 0.06,
    useBlur: true,
  );

  static const GlassConfig desktop = GlassConfig._(
    sigmaX: 20,
    sigmaY: 20,
    fillOpacity: 0.20,
    borderOpacity: 0.18,
    shadowOpacity: 0.08,
    useBlur: true,
  );
}
