import 'package:flutter/material.dart';

import '../../locale/locale_provider.dart';
import '../../ui/ui.dart';

/// First onboarding slide – lets the user pick their preferred language
/// before seeing the feature tour.
class LanguageSlide extends StatelessWidget {
  const LanguageSlide({super.key, required this.onLanguageSelected});

  /// Called after the user taps a language tile.
  final VoidCallback onLanguageSelected;

  @override
  Widget build(BuildContext context) {
    final localeProvider = LocaleProvider.of(context);
    final currentLocale = localeProvider.locale;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + AppSpacing.huge,
            bottom: MediaQuery.of(context).padding.bottom + 120,
            left: AppSpacing.xxl,
            right: AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // -- Globe icon
              FadeSlideIn(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.15),
                        AppColors.primary.withValues(alpha: 0.0),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.translate_rounded,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // -- Title
              FadeSlideIn(
                delay: const Duration(milliseconds: 80),
                child: const Text(
                  'Sprache wählen',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.15,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              FadeSlideIn(
                delay: const Duration(milliseconds: 120),
                child: Text(
                  'Choose your language',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),

              // -- Language tiles
              ...LocaleProvider.supportedLocales.asMap().entries.map((entry) {
                final index = entry.key;
                final locale = entry.value;
                final info = LocaleProvider.localeLabels[locale.languageCode]!;
                final isSelected = locale == currentLocale;

                return FadeSlideIn(
                  delay: Duration(milliseconds: 160 + index * 60),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: PressableScale(
                      onTap: () {
                        localeProvider.setLocale(locale);
                        onLanguageSelected();
                      },
                      child: AnimatedContainer(
                        duration: MotionDuration.medium,
                        curve: MotionCurve.standard,
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                          vertical: AppSpacing.lg,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.10)
                              : Colors.white.withValues(alpha: 0.7),
                          borderRadius: AppRadius.borderRadiusLg,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.4)
                                : Colors.black.withValues(alpha: 0.06),
                            width: isSelected ? 1.5 : 0.5,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color:
                                        AppColors.primary.withValues(alpha: 0.15),
                                    blurRadius: 20,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          children: [
                            Text(
                              info.flag,
                              style: const TextStyle(fontSize: 28),
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            Expanded(
                              child: Text(
                                info.name,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight:
                                      isSelected ? FontWeight.w600 : FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textPrimary,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.primary,
                                size: 22,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
