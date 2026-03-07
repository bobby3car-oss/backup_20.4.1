import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'colors.dart';
import 'radius.dart';
import 'spacing.dart';

/// Dark theme exclusively used for the Admin Dashboard.
abstract final class AdminTheme {
  // ── Admin-specific dark colors ────────────────────────────────
  static const Color background = Color(0xFF111113);
  static const Color surface = Color(0xFF1C1C1E);
  static const Color surfaceContainer = Color(0xFF2C2C2E);
  static const Color surfaceHigh = Color(0xFF3A3A3C);
  static const Color border = Color(0xFF48484A);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF98989F);
  static const Color textTertiary = Color(0xFF636366);

  static ThemeData get dark {
    const colorScheme = ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.accent,
      onSecondary: Colors.white,
      surface: surface,
      onSurface: textPrimary,
      onSurfaceVariant: textSecondary,
      error: AppColors.error,
      onError: Colors.white,
      outline: border,
      outlineVariant: Color(0xFF3A3A3C),
      surfaceContainerHighest: surfaceHigh,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      fontFamily: '.SF Pro Text',

      // ── AppBar ──────────────────────────────────────────────
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: surface,
        foregroundColor: textPrimary,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: AppColors.primary),
      ),

      // ── Text ────────────────────────────────────────────────
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          fontSize: 34, fontWeight: FontWeight.w700, letterSpacing: -0.7,
          height: 1.1, color: textPrimary,
        ),
        headlineLarge: TextStyle(
          fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.5,
          height: 1.15, color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.4,
          height: 1.2, color: textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.35,
          height: 1.25, color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: -0.25,
          height: 1.3, color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.15,
          height: 1.35, color: textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: -0.05,
          height: 1.35, color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: -0.1,
          height: 1.45, color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: -0.05,
          height: 1.45, color: textPrimary,
        ),
        bodySmall: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.05,
          height: 1.4, color: textSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.1,
          color: Colors.white,
        ),
        labelMedium: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.1,
          color: textSecondary,
        ),
        labelSmall: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.15,
          color: textSecondary,
        ),
      ),

      // ── Divider ─────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 0.5,
        space: 0,
      ),

      // ── Card ────────────────────────────────────────────────
      cardTheme: CardThemeData(
        elevation: 0,
        color: surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderRadiusMd,
          side: BorderSide(color: border.withValues(alpha: 0.5), width: 0.5),
        ),
        margin: AppSpacing.paddingSm,
      ),

      // ── NavigationRail ──────────────────────────────────────
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: surface,
        selectedIconTheme: const IconThemeData(color: AppColors.primary),
        unselectedIconTheme: IconThemeData(color: textSecondary),
        selectedLabelTextStyle: const TextStyle(
          color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: textSecondary, fontSize: 11, fontWeight: FontWeight.w500,
        ),
        indicatorColor: AppColors.primary.withValues(alpha: 0.15),
      ),

      // ── NavigationBar (mobile fallback) ─────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.15),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary);
          }
          return IconThemeData(color: textSecondary);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600,
            );
          }
          return TextStyle(
            color: textSecondary, fontSize: 11, fontWeight: FontWeight.w500,
          );
        }),
      ),

      // ── Drawer ──────────────────────────────────────────────
      drawerTheme: const DrawerThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
      ),

      // ── Floating Action Button ──────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusXl),
      ),

      // ── Input / TextField ───────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceHigh,
        contentPadding: AppSpacing.cardPadding,
        hintStyle: TextStyle(color: textTertiary),
        border: OutlineInputBorder(
          borderRadius: AppRadius.borderRadiusMd,
          borderSide: BorderSide(color: border, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderRadiusMd,
          borderSide: BorderSide(color: border, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderRadiusMd,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),

      // ── Chips ───────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: surfaceHigh,
        selectedColor: AppColors.primary.withValues(alpha: 0.2),
        labelStyle: const TextStyle(color: textPrimary, fontSize: 13),
        secondaryLabelStyle: const TextStyle(color: textPrimary, fontSize: 13),
        side: BorderSide(color: border, width: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderRadiusSm,
        ),
      ),

      // ── SnackBar ────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceHigh,
        contentTextStyle: const TextStyle(color: textPrimary),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusMd),
        behavior: SnackBarBehavior.floating,
      ),

      // ── Dialog ──────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceContainer,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusLg),
        titleTextStyle: const TextStyle(
          fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 14, color: textSecondary,
        ),
      ),

      // ── FilledButton ────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusMd),
        ),
      ),

      // ── OutlinedButton ──────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusMd),
        ),
      ),

      // ── TextButton ─────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
        ),
      ),

      // ── ListTile ───────────────────────────────────────────
      listTileTheme: const ListTileThemeData(
        textColor: textPrimary,
        iconColor: textSecondary,
      ),
    );
  }
}
