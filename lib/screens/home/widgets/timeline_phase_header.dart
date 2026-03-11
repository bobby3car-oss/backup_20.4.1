import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../ui/theme/app_icons.dart';
import '../../../ui/ui.dart';
import '../home_view_model.dart';

class TimelinePhaseHeader extends StatelessWidget {
  const TimelinePhaseHeader({
    super.key,
    required this.data,
  });

  final PhaseHeaderData data;

  static IconData _phaseIcon(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('vor')) return CupertinoIcons.scissors;
    if (lower.contains('op-tag') || lower.contains('optag')) return AppIcons.hospital;
    if (lower.contains('woche 1') || lower.contains('week1')) return AppIcons.wound;
    if (lower.contains('woche 2') || lower.contains('week2')) return AppIcons.progress;
    if (lower.contains('nachsorge') || lower.contains('follow')) return AppIcons.done;
    return AppIcons.clipboard;
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl, bottom: AppSpacing.xs),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // ── Accent bar ──────────────────────────────────
            Container(
              width: 3,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
            const SizedBox(width: AppSpacing.sm + 2),
            // ── Icon ────────────────────────────────────────
            Icon(
              _phaseIcon(data.title),
              color: AppColors.primary,
              size: 16,
            ),
            const SizedBox(width: AppSpacing.sm),
            // ── Title ───────────────────────────────────────
            Expanded(
              child: Text(
                data.title,
                style: tt.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.1,
                ),
              ),
            ),
            // ── Progress count ──────────────────────────────
            Text(
              '${data.doneCount}/${data.totalCount}',
              style: tt.labelSmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
