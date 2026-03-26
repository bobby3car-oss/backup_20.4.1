import 'package:flutter/material.dart';

import '../../../../ui/ui.dart';
import '../../../../ui/theme/app_icons.dart';
import '../../../../l10n/app_localizations.dart';

/// Page 2 of onboarding: Hospital name and treating doctor (both optional).
class ClinicPage extends StatelessWidget {
  const ClinicPage({
    super.key,
    required this.hospitalCtrl,
    required this.doctorCtrl,
  });

  final TextEditingController hospitalCtrl;
  final TextEditingController doctorCtrl;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      children: [
        const SizedBox(height: AppSpacing.xxl),

        // ── Hero ──
        _PageHeader(
          icon: AppIcons.vitals,
                    iconColor: AppIcons.vitalsColor,
          title: 'Wo wirst du behandelt?',
          subtitle:
              'Diese Angaben helfen uns, deine Vorbereitung zu personalisieren.',
        ),
        const SizedBox(height: AppSpacing.xxxl),

        // ── Hospital ──
        Text(l.hospitalClinic, style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.md),
        GlassTextField(
          controller: hospitalCtrl,
          hint: 'z.B. Charité Berlin',
          prefixIcon: Icons.local_hospital_outlined,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppSpacing.xxl),

        // ── Doctor ──
        Text(l.treatingDoctor, style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.md),
        GlassTextField(
          controller: doctorCtrl,
          hint: 'z.B. Dr. Müller',
          prefixIcon: Icons.person_outline_rounded,
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: AppSpacing.xxl),

        // ── Optional hint ──
        GlassContainer(
          padding: const EdgeInsets.all(AppSpacing.lg),
          borderRadius: AppRadius.borderRadiusMd,
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 20,
                color: AppColors.primary.withValues(alpha: 0.7),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Diese Felder sind optional. Du kannst sie auch später in den Einstellungen ergänzen.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.huge),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;

  final Color iconColor;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: GlassIcon(icon: icon, color: iconColor, size: 32),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
