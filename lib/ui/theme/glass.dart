import 'package:flutter/foundation.dart';

/// Platform‑aware glass configuration.
///
/// iOS  → full backdrop blur with rich frosted glass.
/// Android → lighter blur to stay performant on mid-range devices.
/// Web / desktop → no blur, translucent fill as fallback.
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
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return ios;
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        return android;
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return kIsWeb ? web : desktop;
    }
  }

  static const GlassConfig ios = GlassConfig._(
    sigmaX: 28,
    sigmaY: 28,
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
    sigmaX: 0,
    sigmaY: 0,
    fillOpacity: 0.28,
    borderOpacity: 0.14,
    shadowOpacity: 0.06,
    useBlur: false,
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
