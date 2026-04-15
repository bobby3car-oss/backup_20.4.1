import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../../doctor_patients/data/doctor_patient_repository.dart';
import '../../doctor_patients/domain/linked_patient.dart';
import '../data/aftercare_template_service.dart';
import '../data/patient_aftercare_plan_service.dart';
import '../domain/aftercare_item_category.dart';
import '../domain/aftercare_template.dart';
import '../domain/plan_status.dart';

/// Step-by-step wizard to assign an aftercare template to a patient.
///
/// Steps:
///  0 – Select template
///  1 – Select patient  (skipped when [preselectedPatient] is set)
///  2 – Configuration   (surgery date, activation mode)
///  3 – Summary + confirm
class AssignPlanScreen extends StatefulWidget {
  const AssignPlanScreen({
    super.key,
    required this.templateService,
    required this.planService,
    this.doctorUid,
    this.organizationId,
    this.preselectedPatient,
    this.preselectedTemplate,
  });

  final AftercareTemplateService templateService;
  final PatientAftercarePlanService planService;

  /// Doctor UID override for staff mode.
  final String? doctorUid;
  final String? organizationId;

  /// When navigating from patient context, skip patient selection.
  final LinkedPatient? preselectedPatient;

  /// When navigating from template detail, skip template selection.
  final AftercareTemplate? preselectedTemplate;

  @override
  State<AssignPlanScreen> createState() => _AssignPlanScreenState();
}

class _AssignPlanScreenState extends State<AssignPlanScreen> {
  late final PageController _pageCtrl;
  late final DoctorPatientRepository _patientRepo;

  int _currentStep = 0;
  bool _isSaving = false;

  // ── Selections ────────────────────────────────────────────────────────
  AftercareTemplate? _selectedTemplate;
  LinkedPatient? _selectedPatient;
  DateTime _surgeryDate = DateTime.now();
  ActivationMode _activationMode = ActivationMode.opDate;
  DateTime? _scheduledDate;
  String _patientQuery = '';

  /// true = create as draft, false = activate immediately.
  bool _asDraft = false;

  int get _totalSteps {
    // Skip patient step when preselected.
    if (widget.preselectedPatient != null) return 3;
    return 4;
  }

  int get _templateStep => 0;
  int get _patientStep => widget.preselectedPatient != null ? -1 : 1;
  int get _configStep => widget.preselectedPatient != null ? 1 : 2;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
    _patientRepo = DoctorPatientRepository(
      overrideDoctorUid: widget.doctorUid,
    );
    _selectedPatient = widget.preselectedPatient;
    _selectedTemplate = widget.preselectedTemplate;
    if (_selectedTemplate != null && widget.preselectedPatient == null) {
      // Template pre-selected, jump to patient step.
      _currentStep = 1;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pageCtrl.jumpToPage(1);
      });
    }
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  bool get _canProceed {
    if (_currentStep == _templateStep) return _selectedTemplate != null;
    if (_currentStep == _patientStep) return _selectedPatient != null;
    if (_currentStep == _configStep) return true;
    return true;
  }

  void _next() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageCtrl.animateToPage(
        _currentStep,
        duration: MotionDuration.medium,
        curve: MotionCurve.standard,
      );
    }
  }

  void _back() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageCtrl.animateToPage(
        _currentStep,
        duration: MotionDuration.medium,
        curve: MotionCurve.standard,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _confirm() async {
    final template = _selectedTemplate;
    final patient = _selectedPatient;
    if (template == null || patient == null) return;

    if (kDebugMode) {
      debugPrint('[AssignPlan] _confirm: templateId=${template.id}, '
          'asDraft=$_asDraft');
    }

    setState(() => _isSaving = true);

    try {
      if (_asDraft) {
        await widget.planService.createDraftFromTemplate(
          template: template,
          patientId: patient.uid,
          surgeryDate: _surgeryDate,
          activationMode: _activationMode,
          scheduledActivationDate: _scheduledDate,
          doctorId: widget.doctorUid,
          organizationId: widget.organizationId,
        );
      } else {
        await widget.planService.assignTemplateToPatient(
          template: template,
          patientId: patient.uid,
          surgeryDate: _surgeryDate,
          activationMode: _activationMode,
          doctorId: widget.doctorUid,
          organizationId: widget.organizationId,
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      debugPrint('[AssignPlan] ERROR: ${e.runtimeType}: $e');
      if (!mounted) return;
      // Show raw error details for debugging:
      final rawMsg = e is FirebaseException
          ? 'Firebase ${e.plugin}/${e.code}: ${e.message}'
          : '${e.runtimeType}: $e';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(rawMsg),
          duration: const Duration(seconds: 10),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // Build
  // ══════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _buildTemplateStep(),
      if (widget.preselectedPatient == null) _buildPatientStep(),
      _buildConfigStep(),
      _buildSummaryStep(),
    ];

    return GlassPage(
      title: 'Plan zuweisen',
      titleIcon: Icons.assignment_turned_in_rounded,
      scrollableBody: (headerHeight) => Column(
        children: [
          SizedBox(height: headerHeight + AppSpacing.sm),

          // ── Step indicator ──────────────────────────────────────
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: FadeSlideIn(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.md,
                  ),
                  child: _StepIndicator(
                    current: _currentStep,
                    total: _totalSteps,
                  ),
                ),
              ),
            ),
          ),

          // ── Page content ───────────────────────────────────────
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: PageView(
                  controller: _pageCtrl,
                  physics: const NeverScrollableScrollPhysics(),
                  children: pages,
                ),
              ),
            ),
          ),

          // ── Bottom bar ─────────────────────────────────────────
          SafeArea(
            top: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.md,
                  ),
                  child: Row(
                children: [
                  GlassButton(
                    onPressed: _back,
                    label: _currentStep == 0 ? 'Abbrechen' : 'Zurück',
                    variant: GlassButtonVariant.ghost,
                  ),
                  const Spacer(),
                  if (_currentStep < _totalSteps - 1)
                    GlassButton(
                      onPressed: _canProceed ? _next : null,
                      label: 'Weiter',
                      icon: Icons.arrow_forward_rounded,
                    )
                  else
                    GlassButton(
                      onPressed: _isSaving ? null : _confirm,
                      label: _isSaving
                          ? 'Speichern …'
                          : _asDraft
                              ? 'Als Entwurf speichern'
                              : 'Plan zuweisen',
                      icon: _isSaving ? null : Icons.check_rounded,
                    ),
                ],
              ),
            ),
            ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // Step 0: Template selection
  // ══════════════════════════════════════════════════════════════════════

  Widget _buildTemplateStep() {
    return StreamBuilder<List<AftercareTemplate>>(
      stream: widget.templateService.getTemplatesForUser(
        organizationId: widget.organizationId,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Vorlagen konnten nicht geladen werden.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.error),
            ),
          );
        }
        final templates = snapshot.data;
        if (templates == null) {
          return const Center(child: CupertinoActivityIndicator());
        }
        if (templates.isEmpty) {
          return _emptyHint(
            icon: Icons.medical_information_outlined,
            text: 'Keine Vorlagen verfügbar.',
          );
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Icon(Icons.medical_information_rounded,
                      size: 18, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Vorlage auswählen',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
          physics: adaptiveScrollPhysics,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          itemCount: templates.length,
          itemBuilder: (context, i) {
            final t = templates[i];
            final isSelected = _selectedTemplate?.id == t.id;
            return FadeSlideIn(
              delay: Duration(milliseconds: 40 * i),
              child: GlassCard(
                onTap: () => setState(() => _selectedTemplate = t),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded,
                      color:
                          isSelected ? AppColors.primary : AppColors.grey600,
                      size: 22,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                          ),
                          if (t.surgeryType.isNotEmpty ||
                              t.bodyRegion.isNotEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: AppSpacing.xxs),
                              child: Text(
                                [t.surgeryType, t.bodyRegion]
                                    .where((s) => s.isNotEmpty)
                                    .join(' · '),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: AppColors.grey800),
                              ),
                            ),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: AppSpacing.xxs),
                            child: Text(
                              '${t.phases.length} Phasen · ${t.phases.fold<int>(0, (s, p) => s + p.items.length)} Punkte',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.grey800,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _TemplateScopeBadge(type: t.templateType),
                  ],
                ),
              ),
            );
          },
        ),
            ),
          ],
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // Step 1: Patient selection
  // ══════════════════════════════════════════════════════════════════════

  Widget _buildPatientStep() {
    return StreamBuilder<List<LinkedPatient>>(
      stream: _patientRepo.watchLinkedPatients(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Patienten konnten nicht geladen werden.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.error),
            ),
          );
        }
        final patients = snapshot.data;
        if (patients == null) {
          return const Center(child: CupertinoActivityIndicator());
        }
        if (patients.isEmpty) {
          return _emptyHint(
            icon: Icons.people_outline_rounded,
            text: 'Keine verknüpften Patienten.',
          );
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Icon(Icons.person_rounded,
                      size: 18, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Patient auswählen',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
              ),
              child: GlassTextField(
                hint: 'Patient suchen …',
                prefixIcon: Icons.search_rounded,
                onChanged: (v) => setState(() => _patientQuery = v),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: Builder(
                builder: (context) {
                  final q = _patientQuery.toLowerCase();
                  final filtered = q.isEmpty
                      ? patients
                      : patients.where((p) {
                          if (p.displayName.toLowerCase().contains(q)) {
                            return true;
                          }
                          if (p.diagnosis != null &&
                              p.diagnosis!.toLowerCase().contains(q)) {
                            return true;
                          }
                          return false;
                        }).toList();
                  if (filtered.isEmpty) {
                    return _emptyHint(
                      icon: Icons.search_off_rounded,
                      text: 'Kein Patient gefunden.',
                    );
                  }
                  return ListView.builder(
          physics: adaptiveScrollPhysics,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          itemCount: filtered.length,
          itemBuilder: (context, i) {
            final p = filtered[i];
            final isSelected = _selectedPatient?.uid == p.uid;
            return FadeSlideIn(
              delay: Duration(milliseconds: 40 * i),
              child: GlassCard(
                onTap: () => setState(() {
                  _selectedPatient = p;
                  if (p.opDate != null) _surgeryDate = p.opDate!;
                }),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded,
                      color:
                          isSelected ? AppColors.primary : AppColors.grey600,
                      size: 22,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.displayName,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                          ),
                          if (p.diagnosis != null && p.diagnosis!.isNotEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: AppSpacing.xxs),
                              child: Text(
                                p.diagnosis!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: AppColors.grey800),
                              ),
                            ),
                          if (p.opDate != null)
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: AppSpacing.xxs),
                              child: Text(
                                'OP: ${_fmt(p.opDate!)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColors.grey800,
                                    ),
                              ),
                            ),
                        ],
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
            ),
          ],
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // Step 2: Configuration
  // ══════════════════════════════════════════════════════════════════════

  Widget _buildConfigStep() {
    return ListView(
      physics: adaptiveScrollPhysics,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Row(
            children: [
              Icon(Icons.settings_rounded,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Konfiguration',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
              ),
            ],
          ),
        ),
        FadeSlideIn(
          child: GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'OP-Datum',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                GestureDetector(
                  onTap: _pickSurgeryDate,
                  child: GlassContainer(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            size: 18, color: AppColors.primary),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          _fmt(_surgeryDate),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textPrimary,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Activation mode ────────────────────────────────────────
        FadeSlideIn(
          delay: const Duration(milliseconds: 60),
          child: GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aktivierungs-Modus',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _RadioTile(
                  title: 'Ab OP-Datum',
                  subtitle: 'Plan startet am OP-Tag',
                  selected: _activationMode == ActivationMode.opDate,
                  onTap: () => setState(
                      () => _activationMode = ActivationMode.opDate),
                ),
                _RadioTile(
                  title: 'Eigenes Datum',
                  subtitle: 'Plan startet an einem gewählten Datum',
                  selected: _activationMode == ActivationMode.customDate,
                  onTap: () => setState(
                      () => _activationMode = ActivationMode.customDate),
                ),
                if (_activationMode == ActivationMode.customDate) ...[
                  const SizedBox(height: AppSpacing.sm),
                  GestureDetector(
                    onTap: _pickScheduledDate,
                    child: GlassContainer(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.event_rounded,
                              size: 18, color: AppColors.accent),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            _scheduledDate != null
                                ? _fmt(_scheduledDate!)
                                : 'Datum wählen …',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Draft toggle ───────────────────────────────────────────
        FadeSlideIn(
          delay: const Duration(milliseconds: 120),
          child: GlassCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Als Entwurf anlegen',
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        'Entwurf muss später vom Arzt aktiviert werden.',
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.grey800,
                                ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: _asDraft,
                  activeTrackColor: AppColors.primary,
                  onChanged: (v) => setState(() => _asDraft = v),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // Step 3: Summary
  // ══════════════════════════════════════════════════════════════════════

  Widget _buildSummaryStep() {
    final template = _selectedTemplate;
    final patient = _selectedPatient;

    return ListView(
      physics: adaptiveScrollPhysics,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Row(
            children: [
              Icon(Icons.checklist_rounded,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Zusammenfassung',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
              ),
            ],
          ),
        ),
        FadeSlideIn(
          child: GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SummaryRow(label: 'Vorlage', value: template?.title ?? '–'),
                const SizedBox(height: AppSpacing.sm),
                _SummaryRow(
                    label: 'Patient', value: patient?.displayName ?? '–'),
                const SizedBox(height: AppSpacing.sm),
                _SummaryRow(label: 'OP-Datum', value: _fmt(_surgeryDate)),
                const SizedBox(height: AppSpacing.sm),
                _SummaryRow(
                  label: 'Modus',
                  value: _activationMode == ActivationMode.opDate
                      ? 'Ab OP-Datum'
                      : 'Eigenes Datum (${_scheduledDate != null ? _fmt(_scheduledDate!) : '–'})',
                ),
                const SizedBox(height: AppSpacing.sm),
                _SummaryRow(
                  label: 'Status',
                  value: _asDraft ? 'Entwurf' : 'Sofort aktiv',
                ),
              ],
            ),
          ),
        ),

        if (template != null) ...[
          const SizedBox(height: AppSpacing.lg),
          FadeSlideIn(
            delay: const Duration(milliseconds: 60),
            child: Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.xs,
                bottom: AppSpacing.sm,
              ),
              child: Text(
                'Phasen-Übersicht',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ),
          for (var i = 0; i < template.phases.length; i++)
            FadeSlideIn(
              delay: Duration(milliseconds: 100 + i * 40),
              child: GlassCard(
                child: Row(
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
                        '${i + 1}',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            template.phases[i].title,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                          ),
                          Text(
                            '${template.phases[i].items.length} Punkte',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.grey800),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // Helpers
  // ══════════════════════════════════════════════════════════════════════

  Widget _emptyHint({required IconData icon, required String text}) {
    return Center(
      child: FadeSlideIn(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.grey600),
            const SizedBox(height: AppSpacing.lg),
            Text(
              text,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: AppColors.grey700),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickSurgeryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _surgeryDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _surgeryDate = picked);
  }

  Future<void> _pickScheduledDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate ?? _surgeryDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _scheduledDate = picked);
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
}

// ═══════════════════════════════════════════════════════════════════════════
// Private widgets
// ═══════════════════════════════════════════════════════════════════════════

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.current, required this.total});
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final isActive = i <= current;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: i < total - 1 ? AppSpacing.xs : 0),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary
                  : AppColors.grey500,
              borderRadius: AppRadius.borderRadiusSm,
            ),
          ),
        );
      }),
    );
  }
}

class _RadioTile extends StatelessWidget {
  const _RadioTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? AppColors.primary : AppColors.grey600,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          )),
                  Text(subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.grey800,
                          )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.grey700,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                ),
          ),
        ),
      ],
    );
  }
}

class _TemplateScopeBadge extends StatelessWidget {
  const _TemplateScopeBadge({required this.type});
  final AftercareTemplateType type;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (type) {
      AftercareTemplateType.doctor => ('Eigene', AppColors.primary),
      AftercareTemplateType.organization => ('Org', AppColors.accent),
      AftercareTemplateType.system => ('System', AppColors.success),
    };

    return Container(
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
    );
  }
}
