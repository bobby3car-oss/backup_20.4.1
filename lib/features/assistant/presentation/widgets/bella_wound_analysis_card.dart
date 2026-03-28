import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../ui/ui.dart';
import '../../domain/wound_analysis_result.dart';

/// Structured card shown in the Bella chat when a wound analysis completes.
class BellaWoundAnalysisCard extends StatelessWidget {
  const BellaWoundAnalysisCard({
    super.key,
    required this.result,
  });

  final WoundAnalysisResult result;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(
        right: 52,
        top: AppSpacing.xs,
        bottom: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _statusBorderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Status header ──
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm + 2,
            ),
            decoration: BoxDecoration(
              color: _statusBgColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                Text(
                  result.statusEmoji,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.bellaWoundAnalysisTitle,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _statusTextColor.withValues(alpha: 0.7),
                          letterSpacing: 0.3,
                        ),
                      ),
                      Text(
                        result.statusLabel,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _statusTextColor,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.healing_rounded,
                  size: 20,
                  color: _statusTextColor.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),

          // ── Observations ──
          if (result.observations.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.xs,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.bellaWoundObservations,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  ...result.observations.map(
                    (obs) => Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppSpacing.xs - 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: _statusAccentColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              obs,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textPrimary,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ── Comparison note ──
          if (result.comparisonNote != null &&
              result.comparisonNote!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xs,
                AppSpacing.md,
                AppSpacing.xs,
              ),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.sm + 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFD0DCFF),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📊', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.bellaWoundProgressComparison,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF4A6FA5),
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            result.comparisonNote!,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF3A5A8E),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Recommendation ──
          if (result.recommendation.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xs,
                AppSpacing.md,
                AppSpacing.xs,
              ),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.sm + 2),
                decoration: BoxDecoration(
                  color: _recommendationBgColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _recommendationBorderColor,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        result.recommendation,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: _recommendationTextColor,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Disclaimer ──
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.xs,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 12,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    l.bellaWoundDisclaimer,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade500,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Color helpers ──

  Color get _statusBorderColor => switch (result.status) {
        'green' => const Color(0xFFB2DFDB),
        'yellow' => const Color(0xFFFFE0B2),
        'red' => const Color(0xFFFFCDD2),
        _ => Colors.grey.shade200,
      };

  Color get _statusBgColor => switch (result.status) {
        'green' => const Color(0xFFE8F5E9),
        'yellow' => const Color(0xFFFFF8E1),
        'red' => const Color(0xFFFCE4EC),
        _ => Colors.grey.shade50,
      };

  Color get _statusTextColor => switch (result.status) {
        'green' => const Color(0xFF2E7D32),
        'yellow' => const Color(0xFFE65100),
        'red' => const Color(0xFFC62828),
        _ => AppColors.textPrimary,
      };

  Color get _statusAccentColor => switch (result.status) {
        'green' => const Color(0xFF4CAF50),
        'yellow' => const Color(0xFFFF9800),
        'red' => const Color(0xFFE53935),
        _ => Colors.grey,
      };

  Color get _recommendationBgColor => switch (result.status) {
        'red' => const Color(0xFFFFF3E0),
        _ => const Color(0xFFF1F8E9),
      };

  Color get _recommendationBorderColor => switch (result.status) {
        'red' => const Color(0xFFFFCC80),
        _ => const Color(0xFFC5E1A5),
      };

  Color get _recommendationTextColor => switch (result.status) {
        'red' => const Color(0xFFBF360C),
        _ => const Color(0xFF33691E),
      };
}
