import 'package:flutter/material.dart';

import '../../../../ui/ui.dart';
import '../../../../ui/theme/app_icons.dart';
import '../../../../l10n/app_localizations.dart';

/// Page 3 of onboarding: pre-existing conditions, allergies, medications,
/// weight/height, smoker status (all optional).
class HealthProfilePage extends StatelessWidget {
  const HealthProfilePage({
    super.key,
    required this.conditions,
    required this.allergies,
    required this.medications,
    required this.weightCtrl,
    required this.heightCtrl,
    required this.smokerStatus,
    required this.onAddCondition,
    required this.onRemoveCondition,
    required this.onAddAllergy,
    required this.onRemoveAllergy,
    required this.onAddMedication,
    required this.onRemoveMedication,
    required this.onSmokerChanged,
  });

  final List<String> conditions;
  final List<String> allergies;
  final List<String> medications;
  final TextEditingController weightCtrl;
  final TextEditingController heightCtrl;
  final String? smokerStatus;
  final ValueChanged<String> onAddCondition;
  final ValueChanged<String> onRemoveCondition;
  final ValueChanged<String> onAddAllergy;
  final ValueChanged<String> onRemoveAllergy;
  final ValueChanged<String> onAddMedication;
  final ValueChanged<String> onRemoveMedication;
  final ValueChanged<String?> onSmokerChanged;

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
          icon: AppIcons.medication,
                    iconColor: AppIcons.medicationColor,
          title: l.deinGesundheitsprofil,
          subtitle:
              'Hilf uns, deine Gesundheit besser einzuschätzen. Alles optional.',
        ),
        const SizedBox(height: AppSpacing.xxxl),

        // ── Pre-existing conditions ──
        _TagInputSection(
          title: 'Vorerkrankungen',
          hint: 'z.B. Diabetes, Bluthochdruck',
          icon: Icons.medical_services_outlined,
          tags: conditions,
          onAdd: onAddCondition,
          onRemove: onRemoveCondition,
        ),
        const SizedBox(height: AppSpacing.xxl),

        // ── Allergies ──
        _TagInputSection(
          title: 'Allergien',
          hint: 'z.B. Penicillin, Latex',
          icon: Icons.warning_amber_rounded,
          tags: allergies,
          onAdd: onAddAllergy,
          onRemove: onRemoveAllergy,
        ),
        const SizedBox(height: AppSpacing.xxl),

        // ── Medications ──
        _TagInputSection(
          title: l.aktuelleMedikamente,
          hint: 'z.B. Ibuprofen, Metformin',
          icon: Icons.medication_outlined,
          tags: medications,
          onAdd: onAddMedication,
          onRemove: onRemoveMedication,
        ),
        const SizedBox(height: AppSpacing.xxl),

        // ── Weight & Height ──
        Text(l.bodyData, style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: GlassTextField(
                controller: weightCtrl,
                label: 'Gewicht',
                hint: 'kg',
                prefixIcon: Icons.monitor_weight_outlined,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: GlassTextField(
                controller: heightCtrl,
                label: 'Größe',
                hint: 'cm',
                prefixIcon: Icons.height_rounded,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),

        // ── Smoker status ──
        Text(l.smokerStatus, style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            for (final entry in [
              ('Nichtraucher', Icons.smoke_free_rounded),
              ('Raucher', Icons.smoking_rooms_rounded),
              ('Ex-Raucher', Icons.smoke_free_rounded),
            ]) ...[
              if (entry != ('Nichtraucher', Icons.smoke_free_rounded))
                const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _SmokerOption(
                  label: entry.$1,
                  icon: entry.$2,
                  selected: smokerStatus == entry.$1,
                  onTap: () => onSmokerChanged(
                    smokerStatus == entry.$1 ? null : entry.$1,
                  ),
                ),
              ),
            ],
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

class _TagInputSection extends StatefulWidget {
  const _TagInputSection({
    required this.title,
    required this.hint,
    required this.icon,
    required this.tags,
    required this.onAdd,
    required this.onRemove,
  });

  final String title;
  final String hint;
  final IconData icon;
  final List<String> tags;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;

  @override
  State<_TagInputSection> createState() => _TagInputSectionState();
}

class _TagInputSectionState extends State<_TagInputSection> {
  final _ctrl = TextEditingController();

  void _submit() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    widget.onAdd(text);
    _ctrl.clear();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: GlassTextField(
                controller: _ctrl,
                hint: widget.hint,
                prefixIcon: widget.icon,
                textInputAction: TextInputAction.done,
                onChanged: (_) {},
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            GestureDetector(
              onTap: _submit,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: AppRadius.borderRadiusMd,
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: AppColors.white,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
        if (widget.tags.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: widget.tags
                .map(
                  (tag) => _TagChip(
                    label: tag,
                    onRemove: () => widget.onRemove(tag),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label, required this.onRemove});
  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.xs,
        top: AppSpacing.xs,
        bottom: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: AppRadius.borderRadiusPill,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.xxs),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 14,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmokerOption extends StatelessWidget {
  const _SmokerOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
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
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.primaryGradient : null,
          color: selected ? null : AppColors.white.withValues(alpha: 0.7),
          borderRadius: AppRadius.borderRadiusMd,
          border: Border.all(
            color: selected ? Colors.transparent : AppColors.grey300,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: selected ? AppColors.white : AppColors.grey600,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.white : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
