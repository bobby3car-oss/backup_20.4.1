import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../data/patient_aftercare_plan_service.dart';
import '../data/patient_aftercare_progress_service.dart';
import '../domain/aftercare_item.dart';
import '../domain/aftercare_item_category.dart';
import '../domain/aftercare_item_progress.dart';
import '../domain/aftercare_phase.dart';
import '../domain/patient_aftercare_plan.dart';
import '../domain/plan_status.dart';
import '../export/aftercare_pdf_export_service.dart';
import 'widgets/confetti_burst.dart';
import 'widgets/error_retry_widget.dart';
import 'widgets/medical_disclaimer.dart';
import 'widgets/plan_status_banner.dart';
import 'widgets/today_hero_section.dart';

/// Patient-side read-only view of their aftercare plan.
///
/// Shows the active plan (if any) plus a link to archived plans.
/// No edit or lifecycle actions — purely informational.
class PatientPlanViewScreen extends StatefulWidget {
  const PatientPlanViewScreen({
    super.key,
    required this.patientId,
  });

  final String patientId;

  @override
  State<PatientPlanViewScreen> createState() => _PatientPlanViewScreenState();
}

class _PatientPlanViewScreenState extends State<PatientPlanViewScreen>
  with WidgetsBindingObserver {
  late final PatientAftercarePlanService _service;
  late final PatientAftercareProgressService _progressService;
  late final AftercarePdfExportService _exportService;
  late final Connectivity _connectivity;
  final _confettiKey = GlobalKey<ConfettiBurstState>();
  StreamSubscription<List<ConnectivityResult>>? _connectionSub;
  String? _currentPlanId;
  String? _lastSyncedPlanId;
  DateTime? _lastSyncAttemptAt;

  @override
  void initState() {
    super.initState();
    _service = PatientAftercarePlanService();
    _progressService = PatientAftercareProgressService();
    _exportService = AftercarePdfExportService();
    _connectivity = Connectivity();
    WidgetsBinding.instance.addObserver(this);

    _connectionSub = _connectivity.onConnectivityChanged.listen((results) {
      if (results.contains(ConnectivityResult.none)) return;
      _triggerSyncForCurrentPlan();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectionSub?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    _triggerSyncForCurrentPlan();
  }

  void _triggerSyncForCurrentPlan() {
    final planId = _currentPlanId;
    if (planId == null) return;
    final now = DateTime.now();
    final tooSoon = _lastSyncAttemptAt != null &&
        now.difference(_lastSyncAttemptAt!) < const Duration(seconds: 12) &&
        _lastSyncedPlanId == planId;
    if (tooSoon) return;

    _lastSyncAttemptAt = now;
    _lastSyncedPlanId = planId;
    unawaited(_progressService.syncPendingActions(planId: planId));
  }

  @override
  Widget build(BuildContext context) {
    return GlassPage(
      title: 'Mein Nachbehandlungsplan',
      titleIcon: Icons.assignment_rounded,
      scrollableBody: (headerHeight) =>
          StreamBuilder<PatientAftercarePlan?>(
        stream: _service.getCurrentPatientPlan(widget.patientId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Padding(
              padding: EdgeInsets.only(top: headerHeight + AppSpacing.huge),
              child: AftercareErrorRetry(
                message: 'Plan konnte nicht geladen werden.',
                onRetry: () => setState(() {}),
              ),
            );
          }

          final plan = snapshot.data;

          if (!snapshot.hasData && snapshot.connectionState == ConnectionState.waiting) {
            return Padding(
              padding: EdgeInsets.only(top: headerHeight + AppSpacing.huge),
              child: const Center(child: CupertinoActivityIndicator()),
            );
          }

          if (plan == null) {
            _currentPlanId = null;
            return Padding(
              padding: EdgeInsets.only(top: headerHeight + AppSpacing.huge),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.assignment_outlined,
                        size: 48, color: AppColors.grey400),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Kein aktueller Plan',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Es liegt aktuell kein Nachbehandlungsplan vor.\nBitte kontaktiere bei Fragen deine Praxis.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.grey500),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Opacity(
                      opacity: 0.7,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.info_outline_rounded,
                              size: 13, color: AppColors.grey500),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            'Bei Fragen wende dich an deinen Arzt.',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: AppColors.grey500,
                                  fontSize: 11,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          _currentPlanId = plan.id;
          _triggerSyncForCurrentPlan();

          return _ActivePlanBody(
            plan: plan,
            headerHeight: headerHeight,
            service: _service,
            progressService: _progressService,
            patientId: widget.patientId,
            exportService: _exportService,
            confettiKey: _confettiKey,
          );
        },
      ),
    );
  }
}

class _ActivePlanBody extends StatelessWidget {
  const _ActivePlanBody({
    required this.plan,
    required this.headerHeight,
    required this.service,
    required this.progressService,
    required this.patientId,
    required this.exportService,
    required this.confettiKey,
  });

  final PatientAftercarePlan plan;
  final double headerHeight;
  final PatientAftercarePlanService service;
  final PatientAftercareProgressService progressService;
  final String patientId;
  final AftercarePdfExportService exportService;
  final GlobalKey<ConfettiBurstState> confettiKey;

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  @override
  Widget build(BuildContext context) {
    final isPaused = plan.status == PlanStatus.paused;
    final isCancelled = plan.status == PlanStatus.cancelled;
    final isCompleted = plan.status == PlanStatus.completed;
    final isInactive = isPaused || isCancelled || isCompleted;

    return StreamBuilder<AftercareItemProgress>(
      stream: progressService.watchProgress(plan.id),
      builder: (context, progressSnap) {
        final progress = progressSnap.data ??
            AftercareItemProgress.empty(
              patientId: patientId,
              planId: plan.id,
            );

        final totalItems =
            plan.phases.fold<int>(0, (s, p) => s + p.items.length);
        final completedItems = progress.completedCount;
        final progressFraction =
            totalItems > 0 ? completedItems / totalItems : 0.0;

        // Status badge color + label
        final (Color badgeColor, String badgeLabel) = switch (plan.status) {
          PlanStatus.active => (AppColors.success, 'Aktiv'),
          PlanStatus.scheduled => (AppColors.accent, 'Geplant'),
          PlanStatus.paused => (AppColors.warning, 'Pausiert'),
          PlanStatus.completed => (AppColors.success, 'Abgeschlossen'),
          PlanStatus.cancelled => (AppColors.error, 'Abgebrochen'),
          PlanStatus.archived => (AppColors.grey500, 'Archiviert'),
          PlanStatus.draft => (AppColors.grey500, 'Entwurf'),
        };

        return Opacity(
          opacity: isCancelled ? 0.6 : 1.0,
          child: ListView(
            physics: adaptiveScrollPhysics,
            padding: EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              top: headerHeight + AppSpacing.md,
              bottom: 120,
            ),
            children: [
              // ── Status banner (paused / completed / cancelled) ────
              if (isInactive) ...[
                FadeSlideIn(child: PlanStatusBanner(plan: plan)),
                const SizedBox(height: AppSpacing.md),
              ],

              // ── Today hero (active plans only) ───────────────────
              if (plan.status == PlanStatus.active) ...[
                FadeSlideIn(
                  child: TodayHeroSection(
                    plan: plan,
                    progress: progress,
                    onToggleItem: (item, wasCompleted) async {
                      final result = await progressService.toggleItemCompleted(
                        planId: plan.id,
                        itemId: item.id,
                      );

                      if (!context.mounted) return;
                      final snackBar = SnackBar(
                        duration: const Duration(seconds: 8),
                        content: Text(
                          result.queuedOffline
                              ? 'Offline gespeichert. Wird bei Verbindung synchronisiert.'
                              : (result.isCompleted
                                  ? 'Aufgabe als erledigt markiert.'
                                  : 'Aufgabe als offen markiert.'),
                        ),
                        action: SnackBarAction(
                          label: 'Rueckgaengig',
                          onPressed: () {
                            unawaited(progressService
                                .setItemCompleted(
                                  planId: plan.id,
                                  itemId: item.id,
                                  completed: wasCompleted,
                                )
                                .then((_) => progressService
                                    .syncPendingActions(planId: plan.id)));
                          },
                        ),
                      );

                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(snackBar);
                    },
                    confettiKey: confettiKey,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              // ── Title + status ───────────────────────────────────
              FadeSlideIn(
                delay: const Duration(milliseconds: 40),
                child: GlassCard(
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
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xxs,
                            ),
                            decoration: BoxDecoration(
                              color: badgeColor.withValues(alpha: 0.12),
                              borderRadius: AppRadius.borderRadiusSm,
                            ),
                            child: Text(
                              badgeLabel,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: badgeColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      // ── Progress bar ─────────────────────────────
                      if (totalItems > 0) ...[
                        const SizedBox(height: AppSpacing.sm),
                        GlassProgressBar(
                          value: progressFraction,
                          height: 4,
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          '$completedItems / $totalItems erledigt',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.md,
                        runSpacing: AppSpacing.xs,
                        children: [
                          _InfoChip(
                            icon: Icons.calendar_today_rounded,
                            label: 'OP: ${_fmt(plan.surgeryDate)}',
                          ),
                          _InfoChip(
                            icon: Icons.layers_outlined,
                            label: '${plan.phases.length} Phasen',
                          ),
                          _InfoChip(
                            icon: Icons.checklist_rounded,
                            label: '$totalItems Punkte',
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      GlassButton(
                        onPressed: () async {
                          try {
                            await exportService.exportPlanPdf(plan);
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'PDF-Export fehlgeschlagen: ${userFacingError(e)}',
                                ),
                              ),
                            );
                          }
                        },
                        label: 'PDF exportieren',
                        icon: Icons.picture_as_pdf_rounded,
                      ),
                    ],
                  ),
                ),
              ),

              if (isCompleted) ...[
                const SizedBox(height: AppSpacing.md),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 60),
                  child: _CompletedSummaryCard(
                    plan: plan,
                    completedItems: completedItems,
                    totalItems: totalItems,
                  ),
                ),
              ],

              // ── Phases (hidden for cancelled plans) ──────────────
              if (!isCancelled && !isCompleted) ...[
                const SizedBox(height: AppSpacing.lg),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 80),
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
                          'Phasen',
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
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
                    delay: Duration(milliseconds: 120 + i * 40),
                    child: _PatientPhaseCard(
                      phase: plan.phases[i],
                      index: i,
                      progress: progress,
                      isPlanPaused: isPaused,
                    ),
                  ),
              ],

              // ── Medical disclaimer ───────────────────────────────
              const SizedBox(height: AppSpacing.lg),
              FadeSlideIn(
                delay: Duration(
                    milliseconds: 160 + plan.phases.length * 40),
                child: const MedicalDisclaimerFooter(),
              ),

              // ── Archive link ─────────────────────────────────────
              const SizedBox(height: AppSpacing.md),
              FadeSlideIn(
                delay: Duration(
                    milliseconds: 200 + plan.phases.length * 40),
                child: StreamBuilder<List<PatientAftercarePlan>>(
                  stream: service.getArchivedPlans(patientId),
                  builder: (context, snap) {
                    final count = snap.data?.length ?? 0;
                    if (count == 0) return const SizedBox.shrink();
                    return GlassCard(
                      onTap: () => Navigator.of(context).push(
                        CupertinoPageRoute<void>(
                          builder: (_) => _PatientArchiveScreen(
                            patientId: patientId,
                            service: service,
                            exportService: exportService,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.archive_rounded,
                              size: 20, color: AppColors.grey500),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              '$count frühere ${count == 1 ? 'Plan' : 'Pläne'}',
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
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PatientPhaseCard extends StatelessWidget {
  const _PatientPhaseCard({
    required this.phase,
    required this.index,
    required this.progress,
    this.isPlanPaused = false,
  });

  final AftercarePhase phase;
  final int index;
  final AftercareItemProgress progress;
  final bool isPlanPaused;

  static const _criticalCategories = {
    AftercareItemCategory.wound,
    AftercareItemCategory.dressing,
    AftercareItemCategory.sutureRemoval,
    AftercareItemCategory.medication,
  };

  @override
  Widget build(BuildContext context) {
    final items = phase.items;
    final completedInPhase =
        items.where((item) => progress.isCompleted(item.id)).length;
    final hasCritical =
        items.any((item) => _criticalCategories.contains(item.category));

    return Opacity(
      opacity: isPlanPaused ? 0.6 : 1.0,
      child: GlassCard(
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
                if (items.isNotEmpty)
                  Text(
                    '$completedInPhase / ${items.length}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                  ),
              ],
            ),
            if (items.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              const Divider(height: 1),
              const SizedBox(height: AppSpacing.sm),
              for (final item in items)
                _buildItemTile(context, item),
            ],
            if (hasCritical) ...[
              const SizedBox(height: AppSpacing.sm),
              const MedicalInlineWarning(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildItemTile(BuildContext context, AftercareItem item) {
    final isCompleted = progress.isCompleted(item.id);
    final isCritical = _criticalCategories.contains(item.category);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Container(
        decoration: isCritical
            ? BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: AppColors.warning.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
              )
            : null,
        padding: isCritical
            ? const EdgeInsets.only(left: AppSpacing.sm)
            : EdgeInsets.zero,
        child: Opacity(
          opacity: isCompleted ? 0.5 : 1.0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isCompleted
                    ? Icons.check_circle_rounded
                    : item.category.icon,
                size: 14,
                color: isCompleted
                    ? AppColors.success
                    : isCritical
                        ? AppColors.warning
                        : AppColors.grey500,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  item.title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
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

class _CompletedSummaryCard extends StatelessWidget {
  const _CompletedSummaryCard({
    required this.plan,
    required this.completedItems,
    required this.totalItems,
  });

  final PatientAftercarePlan plan;
  final int completedItems;
  final int totalItems;

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  @override
  Widget build(BuildContext context) {
    final completionRate =
        totalItems > 0 ? ((completedItems / totalItems) * 100).round() : 0;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.task_alt_rounded,
                  size: 18, color: AppColors.success),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Abschlussuebersicht',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.xs,
            children: [
              _InfoChip(
                icon: Icons.percent_rounded,
                label: '$completionRate% erledigt',
              ),
              _InfoChip(
                icon: Icons.checklist_rounded,
                label: '$completedItems / $totalItems Aufgaben',
              ),
              if (plan.completedAt != null)
                _InfoChip(
                  icon: Icons.calendar_today_rounded,
                  label: 'Abgeschlossen: ${_fmt(plan.completedAt!)}',
                ),
            ],
          ),
          if ((plan.completionSummary ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              plan.completionSummary!.trim(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Patient archive view (read-only)
// ═══════════════════════════════════════════════════════════════════════════

class _PatientArchiveScreen extends StatefulWidget {
  const _PatientArchiveScreen({
    required this.patientId,
    required this.service,
    required this.exportService,
  });

  final String patientId;
  final PatientAftercarePlanService service;
  final AftercarePdfExportService exportService;

  @override
  State<_PatientArchiveScreen> createState() => _PatientArchiveScreenState();
}

class _PatientArchiveScreenState extends State<_PatientArchiveScreen> {
  int _reloadTick = 0;

  @override
  Widget build(BuildContext context) {
    return GlassPage(
      title: 'Frühere Pläne',
      titleIcon: Icons.archive_rounded,
      scrollableBody: (headerHeight) =>
          StreamBuilder<List<PatientAftercarePlan>>(
        key: ValueKey(_reloadTick),
        stream: widget.service.getArchivedPlans(widget.patientId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Padding(
              padding: EdgeInsets.only(top: headerHeight + AppSpacing.huge),
              child: AftercareErrorRetry(
                message: 'Frühere Pläne konnten nicht geladen werden.',
                onRetry: () => setState(() => _reloadTick++),
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
                  'Keine früheren Pläne.',
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
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.title,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      if (plan.archivedReason != null)
                        Text(
                          plan.archivedReason!,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      const SizedBox(height: AppSpacing.xs),
                      Wrap(
                        spacing: AppSpacing.md,
                        children: [
                          _InfoChip(
                            icon: Icons.calendar_today_rounded,
                            label:
                                'OP: ${plan.surgeryDate.day}.${plan.surgeryDate.month}.${plan.surgeryDate.year}',
                          ),
                          _InfoChip(
                            icon: Icons.layers_outlined,
                            label: '${plan.phases.length} Phasen',
                          ),
                          if (plan.archivedAt != null)
                            _InfoChip(
                              icon: Icons.archive_rounded,
                              label:
                                  'Archiviert: ${plan.archivedAt!.day}.${plan.archivedAt!.month}.${plan.archivedAt!.year}',
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GlassButton(
                          onPressed: () async {
                            try {
                              await widget.exportService.exportPlanPdf(plan);
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'PDF-Export fehlgeschlagen: ${userFacingError(e)}',
                                  ),
                                ),
                              );
                            }
                          },
                          label: 'PDF',
                          icon: Icons.picture_as_pdf_rounded,
                          variant: GlassButtonVariant.ghost,
                        ),
                      ),
                    ],
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
