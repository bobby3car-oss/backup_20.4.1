import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../data/plan_change_log_service.dart';
import '../data/patient_aftercare_plan_service.dart';
import '../domain/aftercare_phase.dart';
import '../domain/patient_aftercare_plan.dart';
import '../domain/plan_change_log.dart';
import '../domain/plan_status.dart';
import '../export/aftercare_pdf_export_service.dart';
import 'patient_plan_edit_screen.dart';

/// Detail view for a patient's aftercare plan.
///
/// Shows plan metadata, status, phases with items, and lifecycle actions
/// (activate, archive, approve) based on the viewer's role.
class PatientPlanDetailScreen extends StatefulWidget {
  const PatientPlanDetailScreen({
    super.key,
    required this.plan,
    required this.planService,
    this.isDoctor = false,
    this.isStaff = false,
    this.onChanged,
    this.patientDisplayName,
    this.patientAge,
  });

  final PatientAftercarePlan plan;
  final PatientAftercarePlanService planService;

  /// Whether the viewer is the linked doctor.
  final bool isDoctor;

  /// Whether the viewer is a staff member.
  final bool isStaff;

  /// Called after a lifecycle transition (activate / archive / approve).
  final VoidCallback? onChanged;

  /// Patient display name shown in the detail view.
  final String? patientDisplayName;

  /// Patient age in years shown in the detail view.
  final int? patientAge;

  @override
  State<PatientPlanDetailScreen> createState() =>
      _PatientPlanDetailScreenState();
}

class _PatientPlanDetailScreenState extends State<PatientPlanDetailScreen> {
  bool _isBusy = false;
  int _changeLogReloadTick = 0;
  final AftercarePdfExportService _pdfExportService = AftercarePdfExportService();
  final PlanChangeLogService _changeLogService = PlanChangeLogService();

  bool get _canActivate =>
      widget.isDoctor &&
      (widget.plan.status == PlanStatus.draft ||
          widget.plan.status == PlanStatus.scheduled);

  bool get _canArchive =>
      widget.isDoctor && widget.plan.status == PlanStatus.active;

    bool get _canPause =>
      widget.isDoctor && widget.plan.status == PlanStatus.active;

    bool get _canResume =>
      widget.isDoctor && widget.plan.status == PlanStatus.paused;

    bool get _canComplete =>
      widget.isDoctor &&
      (widget.plan.status == PlanStatus.active ||
        widget.plan.status == PlanStatus.paused);

    bool get _canCancel =>
      widget.isDoctor &&
      (widget.plan.status == PlanStatus.active ||
        widget.plan.status == PlanStatus.paused);

  bool get _canApprove =>
      widget.isDoctor &&
      widget.plan.status == PlanStatus.draft &&
      widget.plan.preparedBy != null &&
      widget.plan.approvedBy == null;

  bool get _canDelete =>
      (widget.isDoctor || widget.isStaff) &&
      widget.plan.status == PlanStatus.draft;

  bool get _canEdit =>
      (widget.isDoctor || widget.isStaff) &&
      widget.plan.status != PlanStatus.archived &&
      widget.plan.status != PlanStatus.completed &&
      widget.plan.status != PlanStatus.cancelled;

  Future<void> _activatePlan() async {
    final confirm = await _confirmDialog(
      'Plan aktivieren?',
      'Der Plan wird für den Patienten aktiviert. '
          'Ein eventuell bestehender aktiver Plan wird automatisch archiviert.',
    );
    if (confirm != true) return;
    await _run(() => widget.planService.activatePlan(widget.plan.id));
  }

  Future<void> _archivePlan() async {
    final confirm = await _confirmDialog(
      'Plan archivieren?',
      'Der Plan wird archiviert und ist nicht mehr aktiv.',
    );
    if (confirm != true) return;
    await _run(
      () => widget.planService.archivePlan(
        widget.plan.id,
        reason: 'Manuell archiviert',
      ),
    );
  }

  Future<void> _approvePlan() async {
    await _run(() => widget.planService.approvePreparedPlan(widget.plan.id));
  }

  Future<void> _pausePlan() async {
    final confirm = await _confirmDialog(
      'Plan pausieren?',
      'Der Plan bleibt sichtbar, aber Aufgaben werden voruebergehend ausgesetzt.',
    );
    if (confirm != true) return;
    await _run(() => widget.planService.pausePlan(widget.plan.id));
  }

  Future<void> _resumePlan() async {
    final confirm = await _confirmDialog(
      'Plan fortsetzen?',
      'Der pausierte Plan wird wieder als aktiv gefuehrt.',
    );
    if (confirm != true) return;
    await _run(() => widget.planService.resumePlan(widget.plan.id));
  }

  Future<void> _completePlan() async {
    final confirm = await _confirmDialog(
      'Plan abschliessen?',
      'Der Plan wird als abgeschlossen markiert und kann nicht mehr bearbeitet werden.',
    );
    if (confirm != true) return;
    await _run(() => widget.planService.completePlan(widget.plan.id));
  }

  Future<void> _cancelPlan() async {
    final confirm = await _confirmDialog(
      'Plan abbrechen?',
      'Der Plan wird abgebrochen und ist danach nicht mehr aktiv.',
    );
    if (confirm != true) return;
    await _run(() => widget.planService.cancelPlan(widget.plan.id));
  }

  Future<void> _deleteDraft() async {
    final confirm = await _confirmDialog(
      'Entwurf löschen?',
      'Der Entwurf wird unwiderruflich gelöscht.',
    );
    if (confirm != true) return;
    await _run(() => widget.planService.deleteDraft(widget.plan.id));
    if (mounted) Navigator.of(context).pop();
  }

  void _editPlan() {
    Navigator.of(context).push<bool>(
      CupertinoPageRoute<bool>(
        builder: (_) => PatientPlanEditScreen(
          plan: widget.plan,
          planService: widget.planService,
          patientDisplayName: widget.patientDisplayName,
          patientAge: widget.patientAge,
        ),
      ),
    ).then((changed) {
      if (changed == true) {
        widget.onChanged?.call();
        if (mounted) Navigator.of(context).pop();
      }
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _isBusy = true);
    try {
      await action();
      widget.onChanged?.call();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userFacingError(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _exportPdf() async {
    setState(() => _isBusy = true);
    try {
      await _pdfExportService.exportPlanPdf(widget.plan);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF-Export fehlgeschlagen: ${userFacingError(e)}')),
      );
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<bool?> _confirmDialog(String title, String content) {
    return showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Abbrechen'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Bestätigen'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;

    return GlassPage(
      title: widget.patientDisplayName != null
          ? (widget.patientAge != null
              ? '${widget.patientDisplayName} · ${widget.patientAge} J.'
              : widget.patientDisplayName!)
          : plan.title,
      titleIcon: widget.patientDisplayName != null
          ? Icons.person_rounded
          : Icons.assignment_rounded,
      trailing: _buildMenu(),
      scrollableBody: (headerHeight) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            physics: adaptiveScrollPhysics,
            padding: EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              top: headerHeight + AppSpacing.md,
              bottom: 120,
            ),
        children: [
          // ── Plan title (shown when patient name is in header) ─────
          if (widget.patientDisplayName != null) ...[
            FadeSlideIn(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.xs,
                  bottom: AppSpacing.sm,
                ),
                child: Text(
                  plan.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                ),
              ),
            ),
          ],

          // ── Status card ──────────────────────────────────────────
          FadeSlideIn(
            child: _StatusCard(plan: plan),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Meta info ────────────────────────────────────────────
          FadeSlideIn(
            delay: const Duration(milliseconds: 60),
            child: GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MetaRow(
                      label: 'OP-Datum', value: _fmt(plan.surgeryDate)),
                  const SizedBox(height: AppSpacing.xs),
                  _MetaRow(
                      label: 'Wirksam ab', value: _fmt(plan.effectiveFrom)),
                  const SizedBox(height: AppSpacing.xs),
                  _MetaRow(
                    label: 'Modus',
                    value: plan.activationMode == ActivationMode.opDate
                        ? 'Ab OP-Datum'
                        : 'Eigenes Datum',
                  ),
                  if (plan.scheduledActivationDate != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    _MetaRow(
                      label: 'Geplant',
                      value: _fmt(plan.scheduledActivationDate!),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xs),
                  _MetaRow(
                      label: 'Version', value: 'v${plan.version}'),
                  const SizedBox(height: AppSpacing.xs),
                  _MetaRow(
                      label: 'Erstellt', value: _fmt(plan.createdAt)),
                ],
              ),
            ),
          ),

          // ── Audit trail ──────────────────────────────────────────
          if (_hasAuditInfo(plan)) ...[
            const SizedBox(height: AppSpacing.md),
            FadeSlideIn(
              delay: const Duration(milliseconds: 120),
              child: GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Verlauf',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (plan.preparedBy != null)
                      _AuditRow(icon: Icons.edit_note_rounded,
                          label: 'Vorbereitet von', value: plan.preparedBy!),
                    if (plan.approvedBy != null)
                      _AuditRow(icon: Icons.verified_rounded,
                          label: 'Freigegeben von', value: plan.approvedBy!),
                    if (plan.activatedBy != null)
                      _AuditRow(icon: Icons.play_circle_rounded,
                          label: 'Aktiviert von', value: plan.activatedBy!),
                    if (plan.archivedBy != null) ...[
                      _AuditRow(icon: Icons.archive_rounded,
                          label: 'Archiviert von', value: plan.archivedBy!),
                      if (plan.archivedReason != null)
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 28, top: AppSpacing.xxs),
                          child: Text(
                            'Grund: ${plan.archivedReason}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.grey500),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.md),
          FadeSlideIn(
            delay: const Duration(milliseconds: 150),
            child: _ChangeLogSection(
              key: ValueKey(_changeLogReloadTick),
              planId: plan.id,
              service: _changeLogService,
              onRetry: () => setState(() => _changeLogReloadTick++),
            ),
          ),

          // ── Action buttons ───────────────────────────────────────
            if (_canActivate ||
              _canArchive ||
              _canApprove ||
              _canPause ||
              _canResume ||
              _canComplete ||
              _canCancel) ...[
            const SizedBox(height: AppSpacing.lg),
            FadeSlideIn(
              delay: const Duration(milliseconds: 180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_canApprove)
                    Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: GlassButton(
                        onPressed: _isBusy ? null : _approvePlan,
                        label: 'Freigeben',
                        icon: Icons.verified_rounded,
                      ),
                    ),
                  if (_canActivate)
                    Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: GlassButton(
                        onPressed: _isBusy ? null : _activatePlan,
                        label: 'Plan aktivieren',
                        icon: Icons.play_circle_rounded,
                      ),
                    ),
                  if (_canArchive)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: GlassButton(
                        onPressed: _isBusy ? null : _archivePlan,
                        label: 'Plan archivieren',
                        icon: Icons.archive_rounded,
                        variant: GlassButtonVariant.secondary,
                      ),
                    ),
                  if (_canPause)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: GlassButton(
                        onPressed: _isBusy ? null : _pausePlan,
                        label: 'Plan pausieren',
                        icon: Icons.pause_circle_rounded,
                        variant: GlassButtonVariant.secondary,
                      ),
                    ),
                  if (_canResume)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: GlassButton(
                        onPressed: _isBusy ? null : _resumePlan,
                        label: 'Plan fortsetzen',
                        icon: Icons.play_circle_rounded,
                      ),
                    ),
                  if (_canComplete)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: GlassButton(
                        onPressed: _isBusy ? null : _completePlan,
                        label: 'Plan abschliessen',
                        icon: Icons.task_alt_rounded,
                      ),
                    ),
                  if (_canCancel)
                    GlassButton(
                      onPressed: _isBusy ? null : _cancelPlan,
                      label: 'Plan abbrechen',
                      icon: Icons.cancel_rounded,
                      variant: GlassButtonVariant.secondary,
                    ),
                ],
              ),
            ),
          ],

          // ── Edit button ──────────────────────────────────────────
          if (_canEdit) ...[            const SizedBox(height: AppSpacing.lg),
            FadeSlideIn(
              delay: const Duration(milliseconds: 190),
              child: GlassButton(
                onPressed: _editPlan,
                label: 'Plan individualisieren',
                icon: Icons.tune_rounded,
              ),
            ),
          ],

          // ── Phases ───────────────────────────────────────────────
          const SizedBox(height: AppSpacing.lg),
          FadeSlideIn(
            delay: const Duration(milliseconds: 200),
            child: Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.xs,
                bottom: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Icon(Icons.layers_outlined,
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Phasen (${plan.phases.length})',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ),
          for (var i = 0; i < plan.phases.length; i++)
            FadeSlideIn(
              delay: Duration(milliseconds: 240 + i * 40),
              child: _PhaseCard(
                phase: plan.phases[i],
                index: i,
              ),
            ),
        ],
      ),
      ),
      ),
    );
  }

  Widget? _buildMenu() {
    return IconButton(
      icon: const Icon(Icons.more_horiz_rounded, color: AppColors.primary),
      onPressed: () {
        showCupertinoModalPopup<void>(
          context: context,
          builder: (ctx) => CupertinoActionSheet(
            actions: [
              if (_canEdit)
                CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _editPlan();
                  },
                  child: const Text('Plan bearbeiten'),
                ),
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(ctx);
                  _exportPdf();
                },
                child: const Text('PDF exportieren'),
              ),
              if (_canDelete)
                CupertinoActionSheetAction(
                  isDestructiveAction: true,
                  onPressed: () {
                    Navigator.pop(ctx);
                    _deleteDraft();
                  },
                  child: const Text('Entwurf löschen'),
                ),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Abbrechen'),
            ),
          ),
        );
      },
    );
  }

  bool _hasAuditInfo(PatientAftercarePlan plan) =>
      plan.preparedBy != null ||
      plan.approvedBy != null ||
      plan.activatedBy != null ||
      plan.archivedBy != null;

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
}

// ═══════════════════════════════════════════════════════════════════════════
// Private widgets
// ═══════════════════════════════════════════════════════════════════════════

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.plan});
  final PatientAftercarePlan plan;

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (plan.status) {
      PlanStatus.draft => ('Entwurf', AppColors.warning, Icons.edit_rounded),
      PlanStatus.scheduled => (
          'Geplant',
          AppColors.accent,
          Icons.schedule_rounded
        ),
      PlanStatus.active => (
          'Aktiv',
          AppColors.success,
          Icons.check_circle_rounded
        ),
      PlanStatus.paused => (
          'Pausiert',
          AppColors.warning,
          Icons.pause_circle_rounded
        ),
      PlanStatus.completed => (
          'Abgeschlossen',
          AppColors.success,
          Icons.task_alt_rounded
        ),
      PlanStatus.cancelled => (
          'Abgebrochen',
          AppColors.error,
          Icons.cancel_rounded
        ),
      PlanStatus.archived => (
          'Archiviert',
          AppColors.grey500,
          Icons.archive_rounded
        ),
    };

    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: AppRadius.borderRadiusMd,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Text(
                  plan.title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: AppRadius.borderRadiusSm,
            ),
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        Expanded(
          child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}

class _AuditRow extends StatelessWidget {
  const _AuditRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.grey500),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _PhaseCard extends StatelessWidget {
  const _PhaseCard({required this.phase, required this.index});

  final AftercarePhase phase;
  final int index;

  @override
  Widget build(BuildContext context) {
    final items = phase.items;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: AppRadius.borderRadiusSm,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${index + 1}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  phase.title,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                '${items.length} Punkte',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.grey500,
                      fontSize: 12,
                    ),
              ),
            ],
          ),
          if (items.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.sm),
            for (final item in items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
                child: Row(
                  children: [
                    Icon(
                      item.category.icon,
                      size: 14,
                      color: AppColors.grey500,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        item.title.isNotEmpty ? item.title : item.description,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _ChangeLogSection extends StatelessWidget {
  const _ChangeLogSection({
    super.key,
    required this.planId,
    required this.service,
    required this.onRetry,
  });

  final String planId;
  final PlanChangeLogService service;
  final VoidCallback onRetry;

  String _fmt(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history_rounded,
                  size: 18, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Aenderungsprotokoll',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          StreamBuilder<List<PlanChangeLog>>(
            stream: service.watchLogs(planId),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Das Protokoll konnte nicht geladen werden.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    GlassButton(
                      onPressed: onRetry,
                      label: 'Erneut versuchen',
                      icon: Icons.refresh_rounded,
                      variant: GlassButtonVariant.ghost,
                    ),
                  ],
                );
              }

              final entries = snapshot.data;
              if (entries == null) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Center(child: CupertinoActivityIndicator()),
                );
              }

              if (entries.isEmpty) {
                return Text(
                  'Noch keine Aenderungen protokolliert.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                );
              }

              return Column(
                children: [
                  for (var i = 0; i < entries.length; i++)
                    Padding(
                      padding: EdgeInsets.only(
                        top: i == 0 ? 0 : AppSpacing.sm,
                        bottom: AppSpacing.xxs,
                      ),
                      child: _ChangeLogRow(
                        entry: entries[i],
                        timestampText: _fmt(entries[i].changedAt),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ChangeLogRow extends StatelessWidget {
  const _ChangeLogRow({
    required this.entry,
    required this.timestampText,
  });

  final PlanChangeLog entry;
  final String timestampText;

  @override
  Widget build(BuildContext context) {
    final (icon, color, label) = _styleForType(entry.changeType);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: AppRadius.borderRadiusSm,
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 15, color: color),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                entry.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                timestampText,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.grey500,
                      fontSize: 10,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  (IconData, Color, String) _styleForType(PlanChangeType type) {
    return switch (type) {
      PlanChangeType.statusChange => (
          Icons.sync_alt_rounded,
          AppColors.accent,
          'Status geaendert',
        ),
      PlanChangeType.itemModified => (
          Icons.tune_rounded,
          AppColors.warning,
          'Aufgabe geaendert',
        ),
      PlanChangeType.itemAdded => (
          Icons.add_task_rounded,
          AppColors.success,
          'Aufgabe hinzugefuegt',
        ),
      PlanChangeType.itemRemoved => (
          Icons.remove_circle_outline_rounded,
          AppColors.error,
          'Aufgabe entfernt',
        ),
      PlanChangeType.phaseModified => (
          Icons.layers_rounded,
          AppColors.primary,
          'Phase geaendert',
        ),
      PlanChangeType.planEdited => (
          Icons.edit_note_rounded,
          AppColors.textSecondary,
          'Plan bearbeitet',
        ),
    };
  }
}
