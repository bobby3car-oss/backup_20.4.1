import 'package:flutter/cupertino.dart';

import '../../../../auth/user_profile_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../ui/theme/app_icons.dart';
import '../../../../ui/ui.dart';

/// Horizontally scrollable chips with suggested starter questions.
class SuggestionChips extends StatelessWidget {
  const SuggestionChips({
    super.key,
    required this.onSelected,
    this.role = AppUserRole.patient,
    this.isPro = false,
    this.dynamicSuggestions = const [],
    this.onSymptomCheck,
  });

  final ValueChanged<String> onSelected;
  final AppUserRole role;
  final bool isPro;

  /// Server-generated contextual suggestions (shown first when available).
  final List<String> dynamicSuggestions;

  /// Callback when the "Symptom-Check starten" chip is tapped (Pro-only).
  final VoidCallback? onSymptomCheck;

  static List<(IconData, Color, String)> _patientSuggestions(AppLocalizations l) => [
    (AppIcons.hospital, AppIcons.hospitalColor, l.bellaChipPrepareOp),
    (AppIcons.clipboard, AppIcons.clipboardColor, l.bellaChipOpDay),
    (CupertinoIcons.device_phone_portrait, AppColors.primary, l.bellaChipTimeline),
    (AppIcons.redFlags, AppIcons.redFlagsColor, l.bellaChipCallDoctor),
    (AppIcons.medication, AppIcons.medicationColor, l.bellaChipMedications),
    (AppIcons.rehab, AppIcons.rehabColor, l.bellaChipKneeTep),
  ];

  static List<(IconData, Color, String)> _doctorSuggestions(AppLocalizations l) => [
    (AppIcons.family, AppIcons.familyColor, l.bellaChipLinkPatient),
    (AppIcons.doctor, AppIcons.doctorColor, l.bellaChipDoctorDashboard),
    (AppIcons.analytics, AppIcons.analyticsColor, l.bellaChipViewPatientData),
    (AppIcons.done, AppIcons.doneColor, l.bellaChipVerifyAccount),
    (CupertinoIcons.device_phone_portrait, AppColors.primary, l.bellaChipAppFunctions),
    (AppIcons.clipboard, AppIcons.clipboardColor, l.bellaChipDoctorReport),
  ];

  static List<(IconData, Color, String)> _staffSuggestions(AppLocalizations l) => [
    (AppIcons.clipboard, AppIcons.clipboardColor, l.bellaChipMyTasks),
    (AppIcons.family, AppIcons.familyColor, l.bellaChipViewPatientDataStaff),
    (AppIcons.doctor, AppIcons.doctorColor, l.bellaChipGeneralDashboard),
    (CupertinoIcons.device_phone_portrait, AppColors.primary, l.bellaChipAppFunctions),
  ];

  static List<(IconData, Color, String)> _organisationSuggestions(AppLocalizations l) => [
    (AppIcons.analytics, AppIcons.analyticsColor, l.bellaChipOrgDashboard),
    (AppIcons.doctor, AppIcons.doctorColor, l.bellaChipManageDoctors),
    (AppIcons.analytics, AppIcons.analyticsColor, l.bellaChipOrgStats),
    (CupertinoIcons.device_phone_portrait, AppColors.primary, l.bellaChipAppFunctions),
  ];

  static List<(IconData, Color, String)> _doctorProActionSuggestions(AppLocalizations l) => [
    (AppIcons.appointments, AppIcons.appointmentsColor, l.bellaChipDoctorCreateAppointment),
    (AppIcons.clipboard, AppIcons.clipboardColor, l.bellaChipDoctorCreateTask),
    (AppIcons.redFlags, AppIcons.redFlagsColor, l.bellaChipDoctorCreateRedFlag),
    (AppIcons.family, AppIcons.familyColor, l.bellaChipDoctorInvitePatient),
    (CupertinoIcons.mail_solid, AppColors.primary, l.bellaChipDoctorBroadcast),
  ];

  static List<(IconData, Color, String)> _staffProActionSuggestions(AppLocalizations l) => [
    (AppIcons.appointments, AppIcons.appointmentsColor, l.bellaChipStaffCreateAppointment),
    (AppIcons.clipboard, AppIcons.clipboardColor, l.bellaChipStaffCreateTask),
    (AppIcons.vitals, AppIcons.vitalsColor, l.bellaChipStaffLogVital),
  ];

  static List<(IconData, Color, String)> _orgProActionSuggestions(AppLocalizations l) => [
    (AppIcons.analytics, AppIcons.analyticsColor, l.bellaChipOrgStats),
    (AppIcons.doctor, AppIcons.doctorColor, l.bellaChipOrgInviteDoctor),
    (CupertinoIcons.mail_solid, AppColors.primary, l.bellaChipOrgBroadcast),
    (AppIcons.analytics, AppIcons.analyticsColor, l.bellaChipOrgBillingInfo),
  ];

  static List<(IconData, Color, String)> _proActionSuggestions(AppLocalizations l) => [
    (AppIcons.appointments, AppIcons.appointmentsColor, l.bellaChipCreateAppointment),
    (AppIcons.clipboard, AppIcons.clipboardColor, l.bellaChipAddTask),
    (AppIcons.vitals, AppIcons.vitalsColor, l.bellaChipLogBloodPressure),
    (AppIcons.medication, AppIcons.medicationColor, l.bellaChipLogMedication),
    (AppIcons.pain, AppIcons.painColor, l.bellaChipLogPain),
  ];

  List<(IconData, Color, String)> _buildSuggestions(AppLocalizations l) {
    final base = switch (role) {
      AppUserRole.doctor => _doctorSuggestions(l),
      AppUserRole.staff => _staffSuggestions(l),
      AppUserRole.organisation => _organisationSuggestions(l),
      _ => _patientSuggestions(l),
    };

    // Dynamic server suggestions shown first (with a lightbulb icon).
    final dynamic = dynamicSuggestions
        .map<(IconData, Color, String)>(
          (s) => (CupertinoIcons.lightbulb_fill, AppColors.warning, s),
        )
        .toList();

    if (isPro && role == AppUserRole.patient) {
      return [
        (CupertinoIcons.waveform_path_ecg, AppColors.error, l.bellaChipSymptomCheck),
        ...dynamic,
        ..._proActionSuggestions(l),
        ...base,
      ];
    }
    if (isPro && role == AppUserRole.doctor) {
      return [...dynamic, ..._doctorProActionSuggestions(l), ...base];
    }
    if (isPro && role == AppUserRole.staff) {
      return [...dynamic, ..._staffProActionSuggestions(l), ...base];
    }
    if (isPro && role == AppUserRole.organisation) {
      return [...dynamic, ..._orgProActionSuggestions(l), ...base];
    }
    return [...dynamic, ...base];
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final suggestions = _buildSuggestions(l);
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: adaptiveScrollPhysics,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        itemCount: suggestions.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final (icon, iconColor, text) = suggestions[index];
          final isSymptomCheck =
              isPro && role == AppUserRole.patient && index == 0;
          return PressableScale(
            onTap: () {
              Haptic.selection();
              if (isSymptomCheck && onSymptomCheck != null) {
                onSymptomCheck!();
              } else {
                onSelected(text);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.55),
                borderRadius: AppRadius.borderRadiusPill,
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GlassIcon(icon: icon, color: iconColor, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
