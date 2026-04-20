import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../ui/theme/app_icons.dart';
import '../../../../ui/ui.dart';

/// Page 2 of onboarding: OP date and OP mode (ambulant / stationär).
///
/// Split from [OpInfoPage] so the (potentially very long) OP-type list
/// doesn't require scrolling past the date/mode controls.
class OpDateModusPage extends StatelessWidget {
  const OpDateModusPage({
    super.key,
    required this.opDate,
    required this.opDateUnknown,
    required this.opModus,
    required this.onPickDate,
    required this.onDateUnknownChanged,
    required this.onModusChanged,
  });

  final DateTime? opDate;
  final bool opDateUnknown;
  final String? opModus;
  final VoidCallback onPickDate;
  final ValueChanged<bool> onDateUnknownChanged;
  final ValueChanged<String> onModusChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      children: [
        const SizedBox(height: AppSpacing.xxl),
        _PageHeader(
          icon: AppIcons.appointments,
          iconColor: AppIcons.appointmentsColor,
          title: l.opDate,
          subtitle: l.treatmentType,
        ),
        const SizedBox(height: AppSpacing.xxxl),

        // ── OP-Datum ──
        Text(l.opDate, style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.md),
        GestureDetector(
          onTap: opDateUnknown ? null : onPickDate,
          child: GlassContainer(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
            borderRadius: AppRadius.borderRadiusMd,
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 20,
                  color: opDateUnknown
                      ? AppColors.grey400
                      : opDate != null
                          ? AppColors.primary
                          : AppColors.grey500,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    opDateUnknown
                        ? 'Datum noch unbekannt'
                        : opDate != null
                            ? DateFormat('dd. MMMM yyyy', 'de').format(opDate!)
                            : l.datumAuswaehlen,
                    style: TextStyle(
                      fontSize: 16,
                      color: opDateUnknown
                          ? AppColors.grey400
                          : opDate != null
                              ? AppColors.textPrimary
                              : AppColors.grey500,
                    ),
                  ),
                ),
                if (!opDateUnknown)
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.grey400,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: opDateUnknown,
                onChanged: (v) => onDateUnknownChanged(v ?? false),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            GestureDetector(
              onTap: () => onDateUnknownChanged(!opDateUnknown),
              child: Text(
                'Datum noch unbekannt',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),

        // ── OP-Modus ──
        Text(l.treatmentType, style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _ModusCard(
                icon: Icons.wb_sunny_outlined,
                label: 'Ambulant',
                subtitle: l.gleichtaegigeEntlassung,
                selected: opModus == 'ambulant',
                onTap: () => onModusChanged('ambulant'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _ModusCard(
                icon: Icons.hotel_outlined,
                label: 'Stationär',
                subtitle: l.mitKrankenhausaufenthalt,
                selected: opModus == l.stationaer2,
                onTap: () => onModusChanged(l.stationaer2),
              ),
            ),
          ],
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

class _ModusCard extends StatelessWidget {
  const _ModusCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: MotionDuration.medium,
        curve: MotionCurve.standard,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.primaryGradient : null,
          color: selected ? null : AppColors.white.withValues(alpha: 0.7),
          borderRadius: AppRadius.borderRadiusLg,
          border: Border.all(
            color: selected ? Colors.transparent : AppColors.grey300,
            width: 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: selected ? AppColors.white : AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: selected
                    ? AppColors.white.withValues(alpha: 0.8)
                    : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
