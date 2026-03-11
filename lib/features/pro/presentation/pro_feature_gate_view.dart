import 'package:flutter/material.dart';

import '../../../ui/ui.dart';

class ProFeatureGateView extends StatelessWidget {
  const ProFeatureGateView({
    super.key,
    required this.pageTitle,
    required this.pageIcon,
    required this.pageColor,
    required this.heroIcon,
    required this.heroTitle,
    required this.heroSubtitle,
    required this.primaryCta,
    required this.onPrimaryTap,
    required this.benefits,
    this.preview,
    this.secondaryLabel,
    this.onSecondaryTap,
  });

  final String pageTitle;
  final IconData pageIcon;
  final Color pageColor;
  final IconData heroIcon;
  final String heroTitle;
  final String heroSubtitle;
  final String primaryCta;
  final VoidCallback onPrimaryTap;
  final List<(String, String)> benefits;
  final Widget? preview;
  final String? secondaryLabel;
  final VoidCallback? onSecondaryTap;

  @override
  Widget build(BuildContext context) {
    return GlassPage(
      title: pageTitle,
      titleIcon: pageIcon,
      titleColor: pageColor,
      horizontalPadding: AppSpacing.lg,
      children: [
        GlassContainer(
          variant: GlassVariant.thick,
          elevation: GlassElevation.high,
          borderRadius: AppRadius.borderRadiusXl,
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GlassIcon(
                    icon: heroIcon,
                    color: pageColor,
                    size: 56,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.14),
                      borderRadius: AppRadius.borderRadiusPill,
                    ),
                    child: Text(
                      'PRO',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                heroTitle,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.45,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                heroSubtitle,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.55,
                    ),
              ),
              if (preview != null) ...[
                const SizedBox(height: AppSpacing.xl),
                preview!,
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        GlassContainer(
          variant: GlassVariant.medium,
          borderRadius: AppRadius.borderRadiusXl,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: benefits
                .map(
                  (benefit) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: pageColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: pageColor,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                benefit.$1,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                benefit.$2,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppColors.textSecondary,
                                      height: 1.4,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        GlassButton(
          onPressed: onPrimaryTap,
          label: primaryCta,
          icon: Icons.workspace_premium_rounded,
          variant: GlassButtonVariant.primary,
        ),
        if (secondaryLabel != null && onSecondaryTap != null) ...[
          const SizedBox(height: AppSpacing.md),
          GlassButton(
            onPressed: onSecondaryTap,
            label: secondaryLabel!,
            icon: Icons.visibility_rounded,
            variant: GlassButtonVariant.secondary,
          ),
        ],
        const SizedBox(height: AppSpacing.massive),
      ],
    );
  }
}