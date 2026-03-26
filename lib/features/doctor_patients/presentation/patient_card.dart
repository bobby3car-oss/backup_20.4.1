import 'package:flutter/material.dart';

import '../../doctor_report/doctor_report_builder.dart';
import '../domain/linked_patient.dart';
import '../../../ui/ui.dart';
import '../../../l10n/app_localizations.dart';

/// A card displaying a linked patient's summary for the doctor dashboard.
class PatientCard extends StatelessWidget {
  const PatientCard({
    super.key,
    required this.patient,
    required this.onTap,
  });

  final LinkedPatient patient;
  final VoidCallback onTap;

  Color _ampelColor(ReportLight status) => switch (status) {
        ReportLight.green => AppColors.success,
        ReportLight.yellow => AppColors.warning,
        ReportLight.red => AppColors.error,
        ReportLight.unknown => AppColors.grey400,
      };

  IconData _ampelIcon(ReportLight status) => switch (status) {
        ReportLight.green => Icons.check_circle_rounded,
        ReportLight.yellow => Icons.warning_rounded,
        ReportLight.red => Icons.error_rounded,
        ReportLight.unknown => Icons.help_outline_rounded,
      };

  String _phaseLabel(PatientPhase phase) => switch (phase) {
        PatientPhase.preOp => 'Prä-OP',
        PatientPhase.opDay => 'OP-Tag',
        PatientPhase.postOp => 'Post-OP',
        PatientPhase.discharged => 'Entlassen',
      };

  String _timeAgo(DateTime? dt) {
    if (dt == null) return '–';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return 'vor ${diff.inMinutes} Min';
    if (diff.inHours < 24) return 'vor ${diff.inHours} Std';
    return 'vor ${diff.inDays} Tagen';
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '–';
    return '${dt.day}.${dt.month}.${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final ampel = _ampelColor(patient.warnStatus);

    return GlassCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: Name + Ampel ─────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Text(
                  patient.displayName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                _ampelIcon(patient.warnStatus),
                color: ampel,
                size: 22,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xs),

          // ── OP-Datum + Phase ──────────────────────────────────────
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: AppColors.grey600),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'OP: ${_formatDate(patient.opDate)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: AppRadius.borderRadiusPill,
                ),
                child: Text(
                  _phaseLabel(patient.phase),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // ── Fortschrittsbalken ────────────────────────────────────
          GlassProgressBar(
            value: patient.progressPercent,
            height: 6,
            showPercentage: false,
          ),

          const SizedBox(height: AppSpacing.sm),

          // ── Letzter Eintrag + nächster Termin ────────────────────
          Row(
            children: [
              Expanded(
                child: _InfoChip(
                  icon: Icons.edit_note_rounded,
                  label: patient.lastEntryLabel ?? '–',
                  value: _timeAgo(patient.lastEntryAt),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _InfoChip(
                  icon: Icons.event_rounded,
                  label: patient.nextAppointmentTitle ?? l.appointment,
                  value: _formatDate(patient.nextAppointmentAt),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.grey600),
        const SizedBox(width: 4),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: style.labelSmall?.copyWith(color: AppColors.grey600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                value,
                style: style.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
