import 'package:flutter/cupertino.dart';

import '../../../../auth/user_profile_service.dart';
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

  static const _patientSuggestions = [
    (AppIcons.hospital, AppIcons.hospitalColor, 'Wie bereite ich mich auf die OP vor?'),
    (AppIcons.clipboard, AppIcons.clipboardColor, 'Was passiert am OP-Tag?'),
    (CupertinoIcons.device_phone_portrait, AppColors.primary, 'Wie funktioniert die Timeline?'),
    (AppIcons.redFlags, AppIcons.redFlagsColor, 'Wann sollte ich den Arzt rufen?'),
    (AppIcons.medication, AppIcons.medicationColor, 'Wie erfasse ich meine Medikamente?'),
    (AppIcons.rehab, AppIcons.rehabColor, 'Infos zur Knie-TEP'),
  ];

  static const _doctorSuggestions = [
    (AppIcons.family, AppIcons.familyColor, 'Wie verknüpfe ich einen Patienten?'),
    (AppIcons.doctor, AppIcons.doctorColor, 'Wie funktioniert das Arzt-Dashboard?'),
    (AppIcons.analytics, AppIcons.analyticsColor, 'Wie sehe ich Patientendaten ein?'),
    (AppIcons.done, AppIcons.doneColor, 'Wie verifiziere ich mein Arztkonto?'),
    (CupertinoIcons.device_phone_portrait, AppColors.primary, 'Welche App-Funktionen gibt es?'),
    (AppIcons.clipboard, AppIcons.clipboardColor, 'Wie erstelle ich einen Arztbericht?'),
  ];

  static const _staffSuggestions = [
    (AppIcons.clipboard, AppIcons.clipboardColor, 'Was sind meine Aufgaben?'),
    (AppIcons.family, AppIcons.familyColor, 'Wie sehe ich Patientendaten?'),
    (AppIcons.doctor, AppIcons.doctorColor, 'Wie funktioniert das Dashboard?'),
    (CupertinoIcons.device_phone_portrait, AppColors.primary, 'Welche App-Funktionen gibt es?'),
  ];

  /// Pro-exclusive action suggestions for patients.
  static const _proActionSuggestions = [
    (AppIcons.appointments, AppIcons.appointmentsColor, 'Erstelle einen Termin morgen um 10 Uhr'),
    (AppIcons.clipboard, AppIcons.clipboardColor, 'Füge eine Aufgabe hinzu: Wunde kontrollieren'),
    (AppIcons.vitals, AppIcons.vitalsColor, 'Trage Blutdruck 120/80 ein'),
    (AppIcons.medication, AppIcons.medicationColor, 'Ich habe gerade Ibuprofen genommen'),
    (AppIcons.pain, AppIcons.painColor, 'Logge Schmerz: Knie, Stärke 4'),
  ];

  /// Sentinel value used to identify the symptom-check chip tap.
  static const _symptomCheckChip = (
    CupertinoIcons.waveform_path_ecg,
    AppColors.error,
    'Symptom-Check starten',
  );

  List<(IconData, Color, String)> get _suggestions {
    final base = switch (role) {
      AppUserRole.doctor => _doctorSuggestions,
      AppUserRole.staff => _staffSuggestions,
      _ => _patientSuggestions,
    };

    // Dynamic server suggestions shown first (with a lightbulb icon).
    final dynamic = dynamicSuggestions
        .map<(IconData, Color, String)>(
          (s) => (CupertinoIcons.lightbulb_fill, AppColors.warning, s),
        )
        .toList();

    if (isPro && role == AppUserRole.patient) {
      return [_symptomCheckChip, ...dynamic, ..._proActionSuggestions, ...base];
    }
    return [...dynamic, ...base];
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: adaptiveScrollPhysics,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        itemCount: _suggestions.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final (icon, iconColor, text) = _suggestions[index];
          final isSymptomCheck = identical(
            _suggestions[index],
            _symptomCheckChip,
          );
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
