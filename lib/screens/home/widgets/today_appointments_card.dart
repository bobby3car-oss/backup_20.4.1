import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../home_view_model.dart';
import '../../../l10n/app_localizations.dart';

/// Shows today's appointments, or a friendly "no appointments" message.
class TodayAppointmentsCard extends StatelessWidget {
  const TodayAppointmentsCard({
    super.key,
    required this.appointments,
    required this.onNavigate,
  });

  final List<TimelineTask> appointments;
  final void Function(String? routeKey, String id) onNavigate;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final tt = Theme.of(context).textTheme;

    if (appointments.isEmpty) {
      return GlassContainer(
        padding: const EdgeInsets.all(18),
        borderRadius: BorderRadius.circular(20),
        variant: GlassVariant.thin,
        elevation: GlassElevation.low,
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.calendar_today_rounded,
                size: 18,
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l.apptTodayNone,
                style: tt.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return GlassContainer(
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(20),
      variant: GlassVariant.thin,
      elevation: GlassElevation.low,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  l.apptTodayTitle,
                  style: tt.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          for (var i = 0; i < appointments.length; i++) ...[
            _AppointmentRow(
              task: appointments[i],
              onTap: () => onNavigate(
                appointments[i].routeKey,
                appointments[i].id,
              ),
            ),
            if (i < appointments.length - 1)
              Padding(
                padding: const EdgeInsets.only(left: 54, right: 16),
                child: Divider(
                  height: 1,
                  color: AppColors.grey200.withValues(alpha: 0.5),
                ),
              ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _AppointmentRow extends StatelessWidget {
  const _AppointmentRow({required this.task, required this.onTap});

  final TimelineTask task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      scaleFactor: 0.988,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: task.iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(task.icon, size: 18, color: task.iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: task.isDone
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                      decoration:
                          task.isDone ? TextDecoration.lineThrough : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (task.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      task.subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.grey400,
            ),
          ],
        ),
      ),
    );
  }
}
