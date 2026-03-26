import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../ui/ui.dart';
import '../../../../ui/theme/app_icons.dart';
import '../../../../l10n/app_localizations.dart';

/// Page 4 of onboarding: Emergency contact (optional) and a review summary
/// of everything entered.
class EmergencySummaryPage extends StatelessWidget {
  const EmergencySummaryPage({
    super.key,
    required this.emergencyNameCtrl,
    required this.emergencyPhoneCtrl,
    // Summary data:
    required this.opType,
    required this.opDate,
    required this.opModus,
    required this.hospitalName,
    required this.doctorName,
    required this.conditions,
    required this.allergies,
    required this.medications,
    required this.weight,
    required this.height,
    required this.smokerStatus,
  });

  final TextEditingController emergencyNameCtrl;
  final TextEditingController emergencyPhoneCtrl;

  final String opType;
  final DateTime? opDate;
  final String opModus;
  final String? hospitalName;
  final String? doctorName;
  final List<String> conditions;
  final List<String> allergies;
  final List<String> medications;
  final String? weight;
  final String? height;
  final String? smokerStatus;

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
          icon: AppIcons.achievement, iconColor: AppIcons.achievementColor,
          title: 'Fast geschafft!',
          subtitle:
              'Hinterlege optional einen Notfallkontakt und überprüfe deine Angaben.',
        ),
        const SizedBox(height: AppSpacing.xxxl),

        // ── Emergency contact ──
        Text(l.emergencyContact, style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.md),
        GlassTextField(
          controller: emergencyNameCtrl,
          label: 'Name',
          hint: 'z.B. Max Mustermann',
          prefixIcon: Icons.person_outline_rounded,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppSpacing.md),
        GlassTextField(
          controller: emergencyPhoneCtrl,
          label: 'Telefonnummer',
          hint: 'z.B. +49 170 1234567',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: AppSpacing.xxxl),

        // ── Summary card ──
        Text(l.yourDetails, style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.md),
        GlassContainer(
          padding: const EdgeInsets.all(AppSpacing.lg),
          borderRadius: AppRadius.borderRadiusLg,
          child: Column(
            children: [
              _SummaryRow(
                icon: Icons.event_rounded,
                label: 'OP-Datum',
                value: opDate != null
                    ? DateFormat('dd. MMMM yyyy', 'de').format(opDate!)
                    : 'Noch unbekannt',
              ),
              _SummaryRow(
                icon: Icons.medical_services_outlined,
                label: 'OP-Typ',
                value: opType,
              ),
              _SummaryRow(
                icon: opModus == 'ambulant'
                    ? Icons.wb_sunny_outlined
                    : Icons.hotel_outlined,
                label: 'Behandlung',
                value: opModus == 'ambulant' ? 'Ambulant' : 'Stationär',
              ),
              if (_hasValue(hospitalName))
                _SummaryRow(
                  icon: Icons.local_hospital_outlined,
                  label: 'Klinik',
                  value: hospitalName!,
                ),
              if (_hasValue(doctorName))
                _SummaryRow(
                  icon: Icons.person_outline_rounded,
                  label: l.doctor,
                  value: doctorName!,
                ),
              if (conditions.isNotEmpty)
                _SummaryRow(
                  icon: Icons.medical_services_outlined,
                  label: 'Vorerkrankungen',
                  value: conditions.join(', '),
                ),
              if (allergies.isNotEmpty)
                _SummaryRow(
                  icon: Icons.warning_amber_rounded,
                  label: 'Allergien',
                  value: allergies.join(', '),
                ),
              if (medications.isNotEmpty)
                _SummaryRow(
                  icon: Icons.medication_outlined,
                  label: 'Medikamente',
                  value: medications.join(', '),
                ),
              if (_hasValue(weight) || _hasValue(height))
                _SummaryRow(
                  icon: Icons.monitor_weight_outlined,
                  label: l.bodyData,
                  value: [
                    if (_hasValue(weight)) '$weight kg',
                    if (_hasValue(height)) '$height cm',
                  ].join(' · '),
                ),
              if (_hasValue(smokerStatus))
                _SummaryRow(
                  icon: Icons.smoke_free_rounded,
                  label: l.smokerStatus,
                  value: smokerStatus!,
                  isLast: true,
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.huge),
      ],
    );
  }

  bool _hasValue(String? value) => value != null && value.isNotEmpty;
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

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: AppRadius.borderRadiusSm,
                ),
                child: Icon(icon, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            color: AppColors.grey200.withValues(alpha: 0.6),
          ),
      ],
    );
  }
}
