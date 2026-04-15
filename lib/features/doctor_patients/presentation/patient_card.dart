import 'package:flutter/material.dart';

import '../domain/linked_patient.dart';
import '../../../ui/ui.dart';

/// A card displaying a linked patient's summary for the doctor dashboard.
class PatientCard extends StatelessWidget {
  const PatientCard({
    super.key,
    required this.patient,
    required this.onTap,
  });

  final LinkedPatient patient;
  final VoidCallback onTap;

  String _phaseLabel(PatientPhase phase) => switch (phase) {
        PatientPhase.preOp => 'Prä-OP',
        PatientPhase.opDay => 'OP-Tag',
        PatientPhase.postOp => 'Post-OP',
        PatientPhase.discharged => 'Entlassen',
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: Name ─────────────────────────────────────────
          Text(
            patient.displayName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: AppSpacing.xs),

          // ── Alter + Phase ──────────────────────────────────────
          Row(
            children: [
              if (patient.age != null) ...[
                Icon(Icons.person_outline, size: 14, color: AppColors.grey600),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '${patient.age} Jahre',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
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

          // ── Nachbehandlungsplan ───────────────────────────────────
          Row(
            children: [
              Icon(Icons.assignment_rounded, size: 14, color: AppColors.grey600),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  patient.activeAftercarePlanTitle ?? 'Kein Plan',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: patient.activeAftercarePlanTitle != null
                        ? AppColors.textSecondary
                        : AppColors.grey400,
                    fontStyle: patient.activeAftercarePlanTitle == null
                        ? FontStyle.italic
                        : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
