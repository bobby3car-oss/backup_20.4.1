import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/theme.dart';

/// Prominent but non-intrusive medical disclaimer banner.
///
/// Shown on all health-related screens to remind users
/// that the app does not replace medical advice.
class MedicalDisclaimerBanner extends StatelessWidget {
  const MedicalDisclaimerBanner({super.key, this.inverted = false});

  /// When `true`, renders white-on-dark for dark backgrounds
  /// (e.g. the emergency screen).
  final bool inverted;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final bg = inverted
        ? Colors.white.withValues(alpha: 0.15)
        : AppColors.primary.withValues(alpha: 0.07);
    final iconColor = inverted
        ? Colors.white70
        : AppColors.primary.withValues(alpha: 0.7);
    final textColor = inverted
        ? Colors.white.withValues(alpha: 0.85)
        : AppColors.primary.withValues(alpha: 0.8);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: iconColor,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                l.medicalDisclaimer,
                style: TextStyle(
                  fontSize: 13,
                  color: textColor,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
