import 'package:flutter/material.dart';

import '../../../../ui/ui.dart';
import '../../domain/patient_aftercare_plan.dart';
import '../../domain/plan_status.dart';

/// Status-aware banner for paused, completed, and cancelled plans.
///
/// Returns [SizedBox.shrink] for active/draft/scheduled/archived plans.
class PlanStatusBanner extends StatelessWidget {
  const PlanStatusBanner({super.key, required this.plan});

  final PatientAftercarePlan plan;

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  @override
  Widget build(BuildContext context) {
    return switch (plan.status) {
      PlanStatus.paused => _buildPausedBanner(context),
      PlanStatus.completed => _buildCompletedBanner(context),
      PlanStatus.cancelled => _buildCancelledBanner(context),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildPausedBanner(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: AppRadius.borderRadiusMd,
        border: Border(
          left: BorderSide(color: AppColors.warning, width: 3),
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pause_circle_rounded,
                  size: 20, color: AppColors.warning),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Plan pausiert',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.warning,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Dein Arzt hat den Plan vorübergehend pausiert. '
            'Du wirst benachrichtigt, sobald es weitergeht.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
          ),
          if (plan.pauseReason != null && plan.pauseReason!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Grund: ${plan.pauseReason}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompletedBanner(BuildContext context) {
    final totalItems = plan.phases.fold<int>(0, (s, p) => s + p.items.length);
    final duration = plan.completedAt?.difference(plan.surgeryDate).inDays;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        borderRadius: AppRadius.borderRadiusMd,
        border: Border(
          left: BorderSide(color: AppColors.success, width: 3),
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.task_alt_rounded,
                  size: 20, color: AppColors.success),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Plan abgeschlossen',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.xs,
            children: [
              if (plan.completedAt != null)
                _BannerChip(
                  icon: Icons.calendar_today_rounded,
                  label: 'Abgeschlossen: ${_fmt(plan.completedAt!)}',
                ),
              if (duration != null)
                _BannerChip(
                  icon: Icons.timer_outlined,
                  label: '$duration Tage',
                ),
              _BannerChip(
                icon: Icons.checklist_rounded,
                label: '$totalItems Aufgaben',
              ),
            ],
          ),
          if (plan.completionSummary?.isNotEmpty == true) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.06),
                borderRadius: AppRadius.borderRadiusSm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Arzt-Kommentar:',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    plan.completionSummary!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Bei Unsicherheit kontaktiere bitte deinen behandelnden Arzt.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelledBanner(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: AppRadius.borderRadiusMd,
        border: Border(
          left: BorderSide(color: AppColors.error, width: 3),
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.cancel_rounded, size: 20, color: AppColors.error),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Plan abgebrochen',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (plan.cancelledAt != null) ...[
            Text(
              'Abgebrochen am: ${_fmt(plan.cancelledAt!)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
          if (plan.cancelReason != null && plan.cancelReason!.isNotEmpty) ...[
            Text(
              'Grund: ${plan.cancelReason}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          Text(
            'Bei Fragen kontaktiere bitte deinen behandelnden Arzt.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }
}

class _BannerChip extends StatelessWidget {
  const _BannerChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.grey500),
        const SizedBox(width: 3),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
        ),
      ],
    );
  }
}
