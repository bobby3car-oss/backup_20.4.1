import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../../doctor_patients/domain/linked_patient.dart';
import '../data/aftercare_template_service.dart';
import '../data/patient_aftercare_plan_service.dart';
import '../domain/patient_aftercare_plan.dart';
import '../domain/plan_status.dart';
import 'assign_plan_screen.dart';
import 'patient_plan_detail_screen.dart';

/// Tab content showing a patient's aftercare plans inside
/// [PatientDetailScreen].
///
/// Displays the active plan (if any), draft plans, and a link to
/// archived plans. Doctors can activate / archive; staff can only view.
class PatientAftercarePlanTab extends StatefulWidget {
  const PatientAftercarePlanTab({
    super.key,
    required this.patientId,
    this.doctorUid,
    this.organizationId,
    this.isDoctor = false,
    this.isStaff = false,
    this.patientDisplayName,
    this.patientAge,
  });

  final String patientId;
  final String? doctorUid;
  final String? organizationId;
  final bool isDoctor;
  final bool isStaff;
  final String? patientDisplayName;
  final int? patientAge;

  @override
  State<PatientAftercarePlanTab> createState() =>
      _PatientAftercarePlanTabState();
}

class _PatientAftercarePlanTabState extends State<PatientAftercarePlanTab> {
  late final PatientAftercarePlanService _service;

  @override
  void initState() {
    super.initState();
    _service = PatientAftercarePlanService(
      overrideDoctorUid: widget.doctorUid,
    );
  }

  void _openDetail(PatientAftercarePlan plan) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => PatientPlanDetailScreen(
          plan: plan,
          planService: _service,
          isDoctor: widget.isDoctor,
          isStaff: widget.isStaff,
          patientDisplayName: widget.patientDisplayName,
          patientAge: widget.patientAge,
          onChanged: () => setState(() {}),
        ),
      ),
    );
  }

  void _openArchive() {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => _ArchiveListScreen(
          patientId: widget.patientId,
          service: _service,
          isDoctor: widget.isDoctor,
          isStaff: widget.isStaff,
          patientDisplayName: widget.patientDisplayName,
          patientAge: widget.patientAge,
        ),
      ),
    );
  }

  void _openAssign() {
    final preselected = LinkedPatient(
      uid: widget.patientId,
      displayName: widget.patientDisplayName ?? 'Patient',
    );
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => AssignPlanScreen(
          templateService: AftercareTemplateService(
            overrideDoctorUid: widget.doctorUid,
          ),
          planService: _service,
          doctorUid: widget.doctorUid,
          organizationId: widget.organizationId,
          preselectedPatient: preselected,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PatientAftercarePlan>>(
      stream: _service.getAllPlans(widget.patientId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Pläne konnten nicht geladen werden.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.error),
            ),
          );
        }

        final plans = snapshot.data;
        if (plans == null) {
          return const Center(child: CupertinoActivityIndicator());
        }

        final active =
            plans.where((p) => p.status == PlanStatus.active).toList();
        final paused =
          plans.where((p) => p.status == PlanStatus.paused).toList();
        final drafts =
            plans.where((p) => p.status == PlanStatus.draft).toList();
        final scheduled =
            plans.where((p) => p.status == PlanStatus.scheduled).toList();
        final completed =
          plans.where((p) => p.status == PlanStatus.completed).toList();
        final cancelled =
          plans.where((p) => p.status == PlanStatus.cancelled).toList();
        final archivedCount =
            plans.where((p) => p.status == PlanStatus.archived).length;

        if (plans.isEmpty) {
          return _EmptyState(
            canAssign: widget.isDoctor || widget.isStaff,
            onAssign: _openAssign,
          );
        }

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              physics: adaptiveScrollPhysics,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
          children: [
            // ── Assign button ────────────────────────────────────
            if (widget.isDoctor || widget.isStaff) ...[
              FadeSlideIn(
                child: GlassButton(
                  label: 'Plan zuweisen',
                  icon: Icons.add_rounded,
                  onPressed: _openAssign,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            // ── Active plan ──────────────────────────────────────
            if (active.isNotEmpty) ...[
              _SectionHeader(
                icon: Icons.check_circle_rounded,
                label: 'Aktiver Plan',
                color: AppColors.success,
              ),
              for (final plan in active)
                FadeSlideIn(
                  child: _PlanCard(
                    plan: plan,
                    onTap: () => _openDetail(plan),
                  ),
                ),
            ],

            // ── Paused plans ─────────────────────────────────────
            if (paused.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              _SectionHeader(
                icon: Icons.pause_circle_rounded,
                label: 'Pausierte Plaene',
                color: AppColors.warning,
              ),
              for (var i = 0; i < paused.length; i++)
                FadeSlideIn(
                  delay: Duration(milliseconds: 30 * i),
                  child: _PlanCard(
                    plan: paused[i],
                    onTap: () => _openDetail(paused[i]),
                  ),
                ),
            ],

            // ── Scheduled plans ──────────────────────────────────
            if (scheduled.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              _SectionHeader(
                icon: Icons.schedule_rounded,
                label: 'Geplante Pläne',
                color: AppColors.accent,
              ),
              for (var i = 0; i < scheduled.length; i++)
                FadeSlideIn(
                  delay: Duration(milliseconds: 40 * i),
                  child: _PlanCard(
                    plan: scheduled[i],
                    onTap: () => _openDetail(scheduled[i]),
                  ),
                ),
            ],

            // ── Draft plans ──────────────────────────────────────
            if (drafts.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              _SectionHeader(
                icon: Icons.edit_rounded,
                label: 'Entwürfe',
                color: AppColors.warning,
              ),
              for (var i = 0; i < drafts.length; i++)
                FadeSlideIn(
                  delay: Duration(milliseconds: 40 * i),
                  child: _PlanCard(
                    plan: drafts[i],
                    onTap: () => _openDetail(drafts[i]),
                  ),
                ),
            ],

            // ── Completed plans ──────────────────────────────────
            if (completed.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              _SectionHeader(
                icon: Icons.task_alt_rounded,
                label: 'Abgeschlossene Plaene',
                color: AppColors.success,
              ),
              for (var i = 0; i < completed.length; i++)
                FadeSlideIn(
                  delay: Duration(milliseconds: 30 * i),
                  child: _PlanCard(
                    plan: completed[i],
                    onTap: () => _openDetail(completed[i]),
                  ),
                ),
            ],

            // ── Cancelled plans ──────────────────────────────────
            if (cancelled.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              _SectionHeader(
                icon: Icons.cancel_rounded,
                label: 'Abgebrochene Plaene',
                color: AppColors.error,
              ),
              for (var i = 0; i < cancelled.length; i++)
                FadeSlideIn(
                  delay: Duration(milliseconds: 30 * i),
                  child: _PlanCard(
                    plan: cancelled[i],
                    onTap: () => _openDetail(cancelled[i]),
                  ),
                ),
            ],

            // ── Archive link ─────────────────────────────────────
            if (archivedCount > 0) ...[
              const SizedBox(height: AppSpacing.lg),
              FadeSlideIn(
                delay: const Duration(milliseconds: 120),
                child: GlassCard(
                  onTap: _openArchive,
                  child: Row(
                    children: [
                      Icon(Icons.archive_rounded,
                          size: 20, color: AppColors.grey500),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          '$archivedCount archivierte ${archivedCount == 1 ? 'Plan' : 'Pläne'}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded,
                          color: AppColors.grey400),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
        ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Shared widgets
// ═══════════════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.xs,
        bottom: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan, required this.onTap});
  final PatientAftercarePlan plan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (statusLabel, statusColor) = switch (plan.status) {
      PlanStatus.draft => ('Entwurf', AppColors.warning),
      PlanStatus.scheduled => ('Geplant', AppColors.accent),
      PlanStatus.active => ('Aktiv', AppColors.success),
      PlanStatus.paused => ('Pausiert', AppColors.warning),
      PlanStatus.completed => ('Abgeschlossen', AppColors.success),
      PlanStatus.cancelled => ('Abgebrochen', AppColors.error),
      PlanStatus.archived => ('Archiviert', AppColors.grey500),
    };

    return GlassCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  plan.title,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: AppRadius.borderRadiusSm,
                ),
                child: Text(
                  statusLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.xxs,
            children: [
              _SmallMeta(
                icon: Icons.calendar_today_rounded,
                text:
                    'OP: ${plan.surgeryDate.day}.${plan.surgeryDate.month}.${plan.surgeryDate.year}',
              ),
              _SmallMeta(
                icon: Icons.layers_outlined,
                text: '${plan.phases.length} Phasen',
              ),
              _SmallMeta(
                icon: Icons.checklist_rounded,
                text:
                    '${plan.phases.fold<int>(0, (s, p) => s + p.items.length)} Punkte',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallMeta extends StatelessWidget {
  const _SmallMeta({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.grey500),
        const SizedBox(width: 3),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    this.canAssign = false,
    this.onAssign,
  });
  final bool canAssign;
  final VoidCallback? onAssign;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeSlideIn(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.huge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.assignment_outlined,
                  size: 48, color: AppColors.grey400),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Kein Nachbehandlungsplan',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Diesem Patienten wurde noch kein Plan zugewiesen.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.grey500),
                textAlign: TextAlign.center,
              ),
              if (canAssign && onAssign != null) ...[
                const SizedBox(height: AppSpacing.xl),
                GlassButton(
                  label: 'Plan zuweisen',
                  icon: Icons.add_rounded,
                  onPressed: onAssign!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Archive list (pushed as a separate screen)
// ═══════════════════════════════════════════════════════════════════════════

class _ArchiveListScreen extends StatelessWidget {
  const _ArchiveListScreen({
    required this.patientId,
    required this.service,
    this.isDoctor = false,
    this.isStaff = false,
    this.patientDisplayName,
    this.patientAge,
  });

  final String patientId;
  final PatientAftercarePlanService service;
  final bool isDoctor;
  final bool isStaff;
  final String? patientDisplayName;
  final int? patientAge;

  @override
  Widget build(BuildContext context) {
    return GlassPage(
      title: 'Archivierte Pläne',
      titleIcon: Icons.archive_rounded,
      scrollableBody: (headerHeight) =>
          StreamBuilder<List<PatientAftercarePlan>>(
        stream: service.getArchivedPlans(patientId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Padding(
              padding: EdgeInsets.only(top: headerHeight + AppSpacing.huge),
              child: Center(
                child: Text(
                  'Archiv konnte nicht geladen werden.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.error),
                ),
              ),
            );
          }

          final plans = snapshot.data;
          if (plans == null) {
            return Padding(
              padding: EdgeInsets.only(top: headerHeight + AppSpacing.huge),
              child: const Center(child: CupertinoActivityIndicator()),
            );
          }

          if (plans.isEmpty) {
            return Padding(
              padding: EdgeInsets.only(top: headerHeight + AppSpacing.huge),
              child: Center(
                child: Text(
                  'Keine archivierten Pläne.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.textSecondary),
                ),
              ),
            );
          }

          return ListView.builder(
            physics: adaptiveScrollPhysics,
            padding: EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              top: headerHeight + AppSpacing.md,
              bottom: 120,
            ),
            itemCount: plans.length,
            itemBuilder: (context, i) {
              final plan = plans[i];
              return FadeSlideIn(
                delay: Duration(milliseconds: 40 * i),
                child: _PlanCard(
                  plan: plan,
                  onTap: () => Navigator.of(context).push(
                    CupertinoPageRoute<void>(
                      builder: (_) => PatientPlanDetailScreen(
                        plan: plan,
                        planService: service,
                        isDoctor: isDoctor,
                        isStaff: isStaff,
                        patientDisplayName: patientDisplayName,
                        patientAge: patientAge,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
