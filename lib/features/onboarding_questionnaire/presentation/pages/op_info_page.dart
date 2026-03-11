import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../ui/ui.dart';
import '../../domain/questionnaire_data.dart';
import '../../../../ui/theme/app_icons.dart';

/// Page 1 of onboarding: OP type, date, and mode (all mandatory).
class OpInfoPage extends StatelessWidget {
  const OpInfoPage({
    super.key,
    required this.selectedOpType,
    required this.customOpType,
    required this.opDate,
    required this.opModus,
    required this.onOpTypeSelected,
    required this.onCustomOpTypeChanged,
    required this.onPickDate,
    required this.onModusChanged,
  });

  final String? selectedOpType;
  final TextEditingController customOpType;
  final DateTime? opDate;
  final String? opModus;
  final ValueChanged<String?> onOpTypeSelected;
  final ValueChanged<String> onCustomOpTypeChanged;
  final VoidCallback onPickDate;
  final ValueChanged<String> onModusChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      children: [
        const SizedBox(height: AppSpacing.xxl),

        // ── Hero ──
        _PageHeader(
          icon: AppIcons.hospital,
                    iconColor: AppIcons.hospitalColor,
          title: 'Erzähl uns von deiner OP',
          subtitle:
              'Diese Informationen helfen uns, deinen persönlichen Care Plan zu erstellen.',
        ),
        const SizedBox(height: AppSpacing.xxxl),

        // ── OP-Typ ──
        Text(
          'Art der Operation *',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final type in kSurgeryTypes)
              _SelectableChip(
                label: type,
                selected: selectedOpType == type,
                onTap: () => onOpTypeSelected(type),
              ),
            _SelectableChip(
              label: 'Sonstiges',
              selected: selectedOpType == 'Sonstiges',
              onTap: () => onOpTypeSelected('Sonstiges'),
            ),
          ],
        ),
        if (selectedOpType == 'Sonstiges') ...[
          const SizedBox(height: AppSpacing.md),
          GlassTextField(
            controller: customOpType,
            label: 'OP-Typ eingeben',
            hint: 'z.B. Blinddarm-OP',
            prefixIcon: Icons.edit_outlined,
            onChanged: onCustomOpTypeChanged,
          ),
        ],
        const SizedBox(height: AppSpacing.xxl),

        // ── OP-Datum ──
        Text('OP-Datum *', style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.md),
        GestureDetector(
          onTap: onPickDate,
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
                  color: opDate != null
                      ? AppColors.primary
                      : AppColors.grey500,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    opDate != null
                        ? DateFormat('dd. MMMM yyyy', 'de').format(opDate!)
                        : 'Datum auswählen',
                    style: TextStyle(
                      fontSize: 16,
                      color: opDate != null
                          ? AppColors.textPrimary
                          : AppColors.grey500,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.grey400,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),

        // ── OP-Modus ──
        Text('Behandlungsart *', style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _ModusCard(
                icon: Icons.wb_sunny_outlined,
                label: 'Ambulant',
                subtitle: 'Gleichtägige Entlassung',
                selected: opModus == 'ambulant',
                onTap: () => onModusChanged('ambulant'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _ModusCard(
                icon: Icons.hotel_outlined,
                label: 'Stationär',
                subtitle: 'Mit Krankenhausaufenthalt',
                selected: opModus == 'stationär',
                onTap: () => onModusChanged('stationär'),
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

class _SelectableChip extends StatelessWidget {
  const _SelectableChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: MotionDuration.medium,
        curve: MotionCurve.standard,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.primaryGradient : null,
          color: selected ? null : AppColors.white.withValues(alpha: 0.7),
          borderRadius: AppRadius.borderRadiusPill,
          border: Border.all(
            color: selected
                ? Colors.transparent
                : AppColors.grey300,
            width: 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.white : AppColors.textPrimary,
          ),
        ),
      ),
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
