import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── Primary palette ──────────────────────────────────────────────
  static const Color primary = Color(0xFF007AFF);
  static const Color primaryLight = Color(0xFF5AC8FA);
  static const Color primaryDark = Color(0xFF0055D4);

  // ── Accent / secondary ──────────────────────────────────────────
  static const Color accent = Color(0xFF5856D6);
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9500);
  static const Color error = Color(0xFFFF3B30);

  // ── Neutrals ────────────────────────────────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFF9F9F9);
  static const Color grey100 = Color(0xFFF2F2F7);
  static const Color grey200 = Color(0xFFE5E5EA);
  static const Color grey300 = Color(0xFFD1D1D6);
  static const Color grey400 = Color(0xFFC7C7CC);
  static const Color grey500 = Color(0xFFAEAEB2);
  static const Color grey600 = Color(0xFF8E8E93);
  static const Color grey700 = Color(0xFF636366);
  static const Color grey800 = Color(0xFF48484A);
  static const Color grey900 = Color(0xFF1C1C1E);

  // ── Glass surface ───────────────────────────────────────────────
  static const Color glassFill = Color(0x33FFFFFF);
  static const Color glassFillLight = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassShadow = Color(0x14000000);

  // ── Gradients ───────────────────────────────────────────────────
  static const LinearGradient glassHighlight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x40FFFFFF),
      Color(0x0DFFFFFF),
    ],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  // ── Text ────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1C1C1E);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textOnGlass = Color(0xE6000000);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
}
