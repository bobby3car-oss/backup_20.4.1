import 'package:flutter/material.dart';

import '../../../../ui/ui.dart';

/// Friendly error state with icon, message, and retry button.
///
/// Used when a stream or future fails in the aftercare plan screens.
class AftercareErrorRetry extends StatelessWidget {
  const AftercareErrorRetry({
    super.key,
    this.message = 'Die Daten konnten gerade nicht geladen werden.',
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: AppColors.grey400,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Bitte pruefe deine Internetverbindung und versuche es erneut.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.grey500,
                  ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              GlassButton(
                onPressed: onRetry!,
                label: 'Erneut versuchen',
                icon: Icons.refresh_rounded,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
