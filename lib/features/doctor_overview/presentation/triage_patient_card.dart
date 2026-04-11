import 'package:flutter/material.dart';

import '../../doctor_patients/domain/linked_patient.dart';
import '../../doctor_report/doctor_report_builder.dart';
import '../../red_flags/domain/red_flag.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';

/// Rich triage card for the doctor dashboard showing clinical indicators
/// at a glance: severity, phase, days post-OP, healing progress, red flags.
class TriagePatientCard extends StatelessWidget {
  const TriagePatientCard({
    super.key,
    required this.patient,
    required this.onTap,
  });

  final LinkedPatient patient;
  final VoidCallback onTap;

  // ── Colors ──

  Color _severityColor() {
    if (patient.redFlagCount > 0) {
      return switch (patient.maxRedFlagSeverity) {
        RedFlagSeverity.red => AppColors.error,
        RedFlagSeverity.orange => AppColors.warning,
        RedFlagSeverity.yellow => const Color(0xFFFFCC00),
        RedFlagSeverity.green => AppColors.success,
      };
    }
    return switch (patient.warnStatus) {
      ReportLight.red => AppColors.error,
      ReportLight.yellow => AppColors.warning,
      ReportLight.green => AppColors.success,
      ReportLight.unknown => AppColors.grey400,
    };
  }

  IconData _severityIcon() {
    if (patient.redFlagCount > 0) {
      return switch (patient.maxRedFlagSeverity) {
        RedFlagSeverity.red => Icons.error_rounded,
        RedFlagSeverity.orange => Icons.warning_amber_rounded,
        RedFlagSeverity.yellow => Icons.info_rounded,
        RedFlagSeverity.green => Icons.check_circle_rounded,
      };
    }
    return switch (patient.warnStatus) {
      ReportLight.red => Icons.error_rounded,
      ReportLight.yellow => Icons.warning_rounded,
      ReportLight.green => Icons.check_circle_rounded,
      ReportLight.unknown => Icons.help_outline_rounded,
    };
  }

  String _phaseLabel(AppLocalizations l) => switch (patient.phase) {
        PatientPhase.preOp => l.phasePreOp,
        PatientPhase.opDay => l.phaseOpDay,
        PatientPhase.postOp => l.phasePostOp,
        PatientPhase.discharged => l.phaseDischarged,
      };

  /// Color-coded healing progress gradient.
  LinearGradient _progressGradient() {
    final p = patient.progressPercent;
    if (p < 0.25) {
      return const LinearGradient(
        colors: [Color(0xFF5AC8FA), Color(0xFF007AFF)],
      );
    } else if (p < 0.75) {
      return const LinearGradient(
        colors: [Color(0xFF34C759), Color(0xFF30D158)],
      );
    } else {
      return const LinearGradient(
        colors: [Color(0xFF30D158), Color(0xFF00C7BE)],
      );
    }
  }

  String? _daysPostOp() {
    final op = patient.opDate;
    if (op == null) return null;
    final days = DateTime.now().difference(op).inDays;
    if (days < 0) return 'OP in ${-days}d';
    if (days == 0) return 'OP heute';
    return 'Tag $days';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final color = _severityColor();
    final daysLabel = _daysPostOp();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: PressableScale(
        child: GlassCard(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Row 1: Status icon + name + phase badge + chevron ──
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_severityIcon(), color: color, size: 20),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient.displayName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            _PhaseBadge(label: _phaseLabel(l)),
                            if (daysLabel != null) ...[
                              const SizedBox(width: 6),
                              Text(
                                daysLabel,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (patient.redFlagCount > 0) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.10),
                        borderRadius: AppRadius.borderRadiusPill,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.flag_rounded, size: 12, color: color),
                          const SizedBox(width: 2),
                          Text(
                            '${patient.redFlagCount}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                  Icon(Icons.chevron_right_rounded,
                      color: AppColors.grey400, size: 20),
                ],
              ),

              // ── Row 2: Healing progress bar (post-OP / op-day only) ──
              if (patient.phase == PatientPhase.postOp ||
                  patient.phase == PatientPhase.opDay) ...[
                const SizedBox(height: AppSpacing.sm),
                GlassProgressBar(
                  value: patient.progressPercent,
                  height: 6,
                  gradient: _progressGradient(),
                  showPercentage: false,
                ),
              ],

              // ── Row 3: Meta info chips ──
              if (patient.lastEntryLabel != null ||
                  patient.nextAppointmentTitle != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    if (patient.lastEntryLabel != null) ...[
                      Icon(Icons.edit_note_rounded,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 3),
                      Text(
                        patient.lastEntryLabel!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (patient.lastEntryAt != null) ...[
                        const SizedBox(width: 3),
                        Text(
                          _timeAgo(patient.lastEntryAt!),
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.grey400,
                          ),
                        ),
                      ],
                    ],
                    if (patient.lastEntryLabel != null &&
                        patient.nextAppointmentTitle != null)
                      const SizedBox(width: AppSpacing.md),
                    if (patient.nextAppointmentTitle != null) ...[
                      Icon(Icons.calendar_today_rounded,
                          size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          patient.nextAppointmentTitle!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return 'vor ${diff.inMinutes}m';
    if (diff.inHours < 24) return 'vor ${diff.inHours}h';
    if (diff.inDays == 1) return 'gestern';
    return 'vor ${diff.inDays}d';
  }
}

class _PhaseBadge extends StatelessWidget {
  const _PhaseBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
