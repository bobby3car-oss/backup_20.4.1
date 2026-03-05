import 'package:flutter/material.dart';

import '../../../ui/theme/colors.dart';
import '../data/entitlement_service.dart';

/// A small badge that shows the current Pro status.
/// Taps can be wired to open the paywall.
class ProBadge extends StatelessWidget {
  const ProBadge({
    super.key,
    required this.entitlementService,
    this.onTap,
  });

  final EntitlementService entitlementService;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: entitlementService.entitlement,
      builder: (context, entitlement, _) {
        if (entitlement.isPro) {
          return GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'PRO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          );
        }

        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.grey200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'FREE',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        );
      },
    );
  }
}
