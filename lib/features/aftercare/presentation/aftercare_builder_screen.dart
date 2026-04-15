import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../data/aftercare_template_service.dart';
import '../data/patient_aftercare_plan_service.dart';
import '../domain/aftercare_defaults.dart';
import '../domain/aftercare_item.dart';
import '../domain/aftercare_item_category.dart';
import '../domain/aftercare_phase.dart';
import '../domain/aftercare_template.dart';
import '../domain/patient_aftercare_plan.dart';

/// Builder modes.
enum _BuilderMode { create, edit, duplicate, editPlan }

/// 10-step guided builder for aftercare templates.
///
/// Steps:
/// 0. Basisdaten (title, description, surgeryType, bodyRegion)
/// 1. Phasen-Struktur (add/remove/reorder phases)
/// 2. Wunde & Verband
/// 3. Fäden / Klammern
/// 4. Belastung
/// 5. Bewegungsumfang (ROM)
/// 6. Therapie (Physio + CPM)
/// 7. Hilfsmittel
/// 8. Medikamente & Supplemente
/// 9. Zusammenfassung
class AftercareBuilderScreen extends StatefulWidget {
  const AftercareBuilderScreen({
    super.key,
    required this.service,
    this.organizationId,
    this.existingTemplate,
    this.isDuplicate = false,
    this.existingPlan,
    this.planService,
    this.defaultTemplateType,
  });

  final AftercareTemplateService service;
  final String? organizationId;
  final AftercareTemplate? existingTemplate;
  final bool isDuplicate;

  /// When editing an assigned plan (not a template), provide the plan
  /// and its service. The builder will call [planService.updatePlan] on save.
  final PatientAftercarePlan? existingPlan;
  final PatientAftercarePlanService? planService;

  /// Override the default template type for new templates.
  final AftercareTemplateType? defaultTemplateType;

  @override
  State<AftercareBuilderScreen> createState() => _AftercareBuilderScreenState();
}

class _AftercareBuilderScreenState extends State<AftercareBuilderScreen> {
  late final _BuilderMode _mode;
  late final PageController _pageCtrl;
  int _currentStep = 0;
  bool _isSaving = false;

  // ── Step 0: Basisdaten ───────────────────────────────────────────────
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _surgeryType = '';
  String _bodyRegion = '';
  AftercareTemplateType _templateType = AftercareTemplateType.doctor;

  // ── Step 1+: Phases & Items ──────────────────────────────────────────
  List<AftercarePhase> _phases = [];

  /// Categories explicitly deactivated by the user.
  final Set<AftercareItemCategory> _deactivatedCategories = {};

  static const _totalSteps = 10;

  /// Maps builder step index (2–8) to the categories it manages.
  static const _stepCategories = <int, List<AftercareItemCategory>>{
    2: [AftercareItemCategory.wound, AftercareItemCategory.dressing],
    3: [AftercareItemCategory.sutureRemoval],
    4: [AftercareItemCategory.weightBearing],
    5: [AftercareItemCategory.rom],
    6: [AftercareItemCategory.physio, AftercareItemCategory.cpm],
    7: [AftercareItemCategory.aid],
    8: [AftercareItemCategory.medication, AftercareItemCategory.supplement],
  };

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();

    final existing = widget.existingTemplate;
    final plan = widget.existingPlan;
    if (plan != null && widget.planService != null) {
      _mode = _BuilderMode.editPlan;
      _titleCtrl.text = plan.title;
      _descCtrl.text = '';
      _surgeryType = '';
      _bodyRegion = '';
      _templateType = plan.sourceTemplateType;
      _phases = plan.phases.map((p) => p.copyWith()).toList();
    } else if (existing != null && !widget.isDuplicate) {
      _mode = _BuilderMode.edit;
      _titleCtrl.text = existing.title;
      _descCtrl.text = existing.description;
      _surgeryType = existing.surgeryType;
      _bodyRegion = existing.bodyRegion;
      _templateType = existing.templateType;
      _phases = existing.phases.map((p) => p.copyWith()).toList();
    } else if (existing != null && widget.isDuplicate) {
      _mode = _BuilderMode.duplicate;
      _titleCtrl.text = '${existing.title} (Kopie)';
      _descCtrl.text = existing.description;
      _surgeryType = existing.surgeryType;
      _bodyRegion = existing.bodyRegion;
      _templateType = AftercareTemplateType.doctor;
      _phases = existing.phases.map((p) => p.copyWith()).toList();
    } else {
      _mode = _BuilderMode.create;
      if (widget.defaultTemplateType != null) {
        _templateType = widget.defaultTemplateType!;
      }
    }
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  // ── Navigation ──────────────────────────────────────────────────────

  void _goNext() {
    if (_currentStep < _totalSteps - 1) {
      _pageCtrl.nextPage(
        duration: MotionDuration.medium,
        curve: MotionCurve.standard,
      );
    }
  }

  void _goBack() {
    if (_currentStep > 0) {
      _pageCtrl.previousPage(
        duration: MotionDuration.medium,
        curve: MotionCurve.standard,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  // ── Save ────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte geben Sie einen Titel ein.')),
      );
      return;
    }
    setState(() => _isSaving = true);

    try {
      // Remove items from deactivated categories.
      final cleanedPhases = _phases.map((phase) {
        final kept = phase.items
            .where((item) => !_deactivatedCategories.contains(item.category))
            .toList();
        return phase.copyWith(items: kept);
      }).toList();

      if (_mode == _BuilderMode.editPlan) {
        final updated = widget.existingPlan!.copyWith(
          title: _titleCtrl.text.trim(),
          phases: cleanedPhases,
        );
        await widget.planService!.updatePlan(updated);
      } else if (_mode == _BuilderMode.edit) {
        final updated = widget.existingTemplate!.copyWith(
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          surgeryType: _surgeryType,
          bodyRegion: _bodyRegion,
          phases: cleanedPhases,
        );
        await widget.service.updateTemplate(updated);
      } else {
        final template = AftercareTemplate(
          id: '',
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          surgeryType: _surgeryType,
          bodyRegion: _bodyRegion,
          createdBy: '',
          organizationId: _templateType == AftercareTemplateType.organization
              ? widget.organizationId
              : null,
          templateType: _templateType,
          version: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          phases: cleanedPhases,
        );
        await widget.service.createTemplate(template);
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Phase helpers ───────────────────────────────────────────────────

  void _loadDefaults() {
    if (_phases.isNotEmpty) return;
    setState(() {
      _phases = AftercareDefaults.phasesForSurgeryType(_surgeryType);
    });
  }

  void _addPhase() {
    final newOrder = _phases.length;
    final startDay =
        _phases.isEmpty ? 0 : (_phases.last.endDayOffset ?? _phases.last.startDayOffset) + 1;
    setState(() {
      _phases.add(AftercarePhase(
        id: 'phase_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Phase ${newOrder + 1}',
        startDayOffset: startDay,
        order: newOrder,
      ));
    });
  }

  void _removePhase(int index) {
    setState(() => _phases.removeAt(index));
  }

  // ── Item helpers ────────────────────────────────────────────────────

  void _addItemToPhase(int phaseIndex, AftercareItem item) {
    setState(() {
      final phase = _phases[phaseIndex];
      final items = [...phase.items, item];
      _phases[phaseIndex] = phase.copyWith(items: items);
    });
  }

  void _removeItem(String itemId) {
    setState(() {
      for (var pi = 0; pi < _phases.length; pi++) {
        final phase = _phases[pi];
        final updated = phase.items.where((i) => i.id != itemId).toList();
        if (updated.length != phase.items.length) {
          _phases[pi] = phase.copyWith(items: updated);
          return;
        }
      }
    });
  }

  void _updateItem(String itemId, AftercareItem updated) {
    setState(() {
      for (var pi = 0; pi < _phases.length; pi++) {
        final phase = _phases[pi];
        final idx = phase.items.indexWhere((i) => i.id == itemId);
        if (idx >= 0) {
          final items = [...phase.items];
          items[idx] = updated;
          _phases[pi] = phase.copyWith(items: items);
          return;
        }
      }
    });
  }

  // ── Deactivation with safety confirmation ───────────────────────────

  Future<void> _toggleCategory(AftercareItemCategory category) async {
    // Find all categories in the same step group.
    final group = _stepCategories.values
        .firstWhere((cats) => cats.contains(category), orElse: () => [category]);
    final allDeactivated = group.every(_deactivatedCategories.contains);

    if (allDeactivated) {
      setState(() => _deactivatedCategories.removeAll(group));
      return;
    }

    // Safety-critical categories need confirmation.
    final hasSafety =
        group.any(AftercareDefaults.safetyCriticalCategories.contains);
    if (hasSafety) {
      final label = group.map((c) => c.displayName).join(' & ');
      final confirm = await showCupertinoDialog<bool>(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: Text('$label deaktivieren?'),
          content: Text(
            'Dieser Bereich ist sicherheitsrelevant. '
            'Alle $label-Einträge werden entfernt.',
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Abbrechen'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Deaktivieren'),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }

    setState(() => _deactivatedCategories.addAll(group));
  }

  // ── Build ───────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final screenTitle = switch (_mode) {
      _BuilderMode.create => 'Vorlage erstellen',
      _BuilderMode.edit => 'Vorlage bearbeiten',
      _BuilderMode.duplicate => 'Vorlage duplizieren',
      _BuilderMode.editPlan => 'Plan bearbeiten',
    };

    return GlassPage(
      title: screenTitle,
      titleIcon: Icons.construction_rounded,
      scrollableBody: (headerHeight) => Column(
        children: [
          SizedBox(height: headerHeight + AppSpacing.sm),

          // ── Step indicator ───────────────────────────────────
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: _StepIndicator(
                currentStep: _currentStep,
                totalSteps: _totalSteps,
                onStepTap: (step) => _pageCtrl.animateToPage(
                  step,
                  duration: MotionDuration.medium,
                  curve: MotionCurve.standard,
                ),
              ),
            ),
          ),

          // ── Page content ─────────────────────────────────────
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: PageView(
              controller: _pageCtrl,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => _currentStep = i),
              children: [
                _Step0Basisdaten(
                  titleCtrl: _titleCtrl,
                  descCtrl: _descCtrl,
                  surgeryType: _surgeryType,
                  bodyRegion: _bodyRegion,
                  templateType: _templateType,
                  hasOrganization: widget.organizationId != null,
                  onSurgeryTypeChanged: (v) =>
                      setState(() => _surgeryType = v),
                  onBodyRegionChanged: (v) =>
                      setState(() => _bodyRegion = v),
                  onTemplateTypeChanged: (v) =>
                      setState(() => _templateType = v),
                ),
                _Step1Phases(
                  phases: _phases,
                  onLoadDefaults: _loadDefaults,
                  onAddPhase: _addPhase,
                  onRemovePhase: _removePhase,
                  onPhaseRenamed: (index, title) {
                    setState(() {
                      _phases[index] = _phases[index].copyWith(title: title);
                    });
                  },
                  onPhaseDaysChanged: (index, start, end) {
                    setState(() {
                      _phases[index] = _phases[index].copyWith(
                        startDayOffset: start,
                        endDayOffset: end,
                        clearEndDayOffset: end == null,
                      );
                    });
                  },
                ),
                // Steps 2–8: category-specific item editors
                for (final entry in _stepCategories.entries)
                  _CategoryStepView(
                    stepIndex: entry.key,
                    categories: entry.value,
                    phases: _phases,
                    deactivatedCategories: _deactivatedCategories,
                    onToggleCategory: _toggleCategory,
                    onAddItem: _addItemToPhase,
                    onRemoveItem: _removeItem,
                    onUpdateItem: _updateItem,
                  ),
                // Step 9: Summary
                _Step9Summary(
                  title: _titleCtrl.text,
                  description: _descCtrl.text,
                  surgeryType: _surgeryType,
                  bodyRegion: _bodyRegion,
                  templateType: _templateType,
                  phases: _phases,
                  deactivatedCategories: _deactivatedCategories,
                  onJumpToStep: (step) => _pageCtrl.animateToPage(
                    step,
                    duration: MotionDuration.medium,
                    curve: MotionCurve.standard,
                  ),
                ),
              ],
              ),
              ),
            ),
          ),

          // ── Navigation bar ───────────────────────────────────
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
                    onPressed: _goBack,
                    label: _currentStep == 0 ? 'Abbrechen' : 'Zurück',
                    variant: GlassButtonVariant.ghost,
                  ),
                  const Spacer(),
                  if (_currentStep < _totalSteps - 1)
                    GlassButton(
                      onPressed: _currentStep == 0 &&
                              _titleCtrl.text.trim().isEmpty
                          ? null
                          : _goNext,
                      label: 'Weiter',
                    )
                  else
                    GlassButton(
                      onPressed: _isSaving ? null : _save,
                      label: 'Speichern',
                      icon: Icons.check_rounded,
                      isLoading: _isSaving,
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
}

// ═══════════════════════════════════════════════════════════════════════════
// Step metadata
// ═══════════════════════════════════════════════════════════════════════════

class _StepMeta {
  const _StepMeta._({
    required this.shortTitle,
    required this.title,
    required this.icon,
    required this.color,
    required this.instruction,
  });
  final String shortTitle;
  final String title;
  final IconData icon;
  final Color color;
  final String instruction;
}

const _kStepMeta = <_StepMeta>[
  _StepMeta._(
    shortTitle: 'Basis',
    title: 'Basisdaten',
    icon: Icons.info_outline_rounded,
    color: AppColors.primary,
    instruction:
        'Vergeben Sie einen aussagekräftigen Titel und wählen Sie OP-Typ sowie Körperregion. Diese Angaben ermöglichen das automatische Laden passender Standardphasen im nächsten Schritt.',
  ),
  _StepMeta._(
    shortTitle: 'Phasen',
    title: 'Phasen-Struktur',
    icon: Icons.view_timeline_rounded,
    color: Color(0xFF32ADE6),
    instruction:
        'Definieren Sie die Behandlungsphasen mit Zeiträumen in Tagen nach OP. Jede Phase bündelt zusammengehörige Maßnahmen. Nutzen Sie "Standardphasen laden" für einen schnellen Einstieg.',
  ),
  _StepMeta._(
    shortTitle: 'Wunde',
    title: 'Wunde & Verband',
    icon: Icons.healing_rounded,
    color: Color(0xFFFF6B6B),
    instruction:
        'Tragen Sie alle Wundkontrollen und Verbandswechsel-Termine ein. Diese Einträge sind sicherheitsrelevant und werden in der Patienten-Timeline besonders hervorgehoben.',
  ),
  _StepMeta._(
    shortTitle: 'Fäden',
    title: 'Fäden / Klammern',
    icon: Icons.content_cut_rounded,
    color: AppColors.warning,
    instruction:
        'Geben Sie den geplanten Termin für die Fadenentfernung oder das Entfernen von Klammern und Staples an. Dieser Termin erscheint als wichtiger Meilenstein im Patientenplan.',
  ),
  _StepMeta._(
    shortTitle: 'Belastung',
    title: 'Belastung',
    icon: Icons.fitness_center_rounded,
    color: Color(0xFFFF9F0A),
    instruction:
        'Definieren Sie die Belastungssteigerung schrittweise je Phase – z.B. „Teilbelastung 15 kg“ in Phase 1, dann „Vollbelastung“ ab Phase 3. Hilft dem Patienten beim täglichen Training.',
  ),
  _StepMeta._(
    shortTitle: 'ROM',
    title: 'Bewegungsumfang',
    icon: Icons.open_with_rounded,
    color: AppColors.accent,
    instruction:
        'Legen Sie erlaubte Bewegungswinkel je Phase fest, z.B. „Flexion bis 90°“ in Woche 2. Diese Grenzen unterstützen den Patienten bei der sicheren Rehabilitation zuhause.',
  ),
  _StepMeta._(
    shortTitle: 'Therapie',
    title: 'Therapie',
    icon: Icons.accessibility_new_rounded,
    color: AppColors.success,
    instruction:
        'Geben Sie Physiotherapie-Einheiten und CPM-Schienen-Zeiten (Continuous Passive Motion) an. Definieren Sie Startdatum und Dauer je Phase.',
  ),
  _StepMeta._(
    shortTitle: 'Hilfsmittel',
    title: 'Hilfsmittel',
    icon: Icons.support_rounded,
    color: Color(0xFF64D2FF),
    instruction:
        'Tragen Sie alle benötigten Hilfsmittel ein: Gehstützen, Orthesen, Kompressionsstrümpfe, Lagerungsschienen usw. Angabe: ab welchem Tag und für wie lange.',
  ),
  _StepMeta._(
    shortTitle: 'Medikamente',
    title: 'Medikamente & Supplemente',
    icon: Icons.medication_rounded,
    color: Color(0xFFFF453A),
    instruction:
        'Dokumentieren Sie alle verordneten Medikamente (z.B. Schmerztherapie, Thromboseprophylaxe) und Supplemente mit Einnahmedauer und wichtigen Hinweisen.',
  ),
  _StepMeta._(
    shortTitle: 'Übersicht',
    title: 'Zusammenfassung',
    icon: Icons.checklist_rounded,
    color: AppColors.success,
    instruction:
        'Prüfen Sie alle Eingaben. Tippen Sie auf „Bearbeiten" neben einem Abschnitt, um direkt dorthin zurückzuspringen und Änderungen vorzunehmen.',
  ),
];

// ═══════════════════════════════════════════════════════════════════════════
// Visual step indicator
// ═══════════════════════════════════════════════════════════════════════════

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.currentStep,
    required this.totalSteps,
    required this.onStepTap,
  });

  final int currentStep;
  final int totalSteps;
  final ValueChanged<int> onStepTap;

  @override
  Widget build(BuildContext context) {
    final meta = _kStepMeta[currentStep];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            itemCount: totalSteps,
            separatorBuilder: (_, x) => const SizedBox(width: 6),
            itemBuilder: (context, i) {
              final isCurrent = i == currentStep;
              final isPast = i < currentStep;
              final sm = _kStepMeta[i];
              return GestureDetector(
                onTap: () => onStepTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  width: isCurrent ? 36 : 28,
                  height: isCurrent ? 36 : 28,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? sm.color
                        : isPast
                            ? sm.color.withValues(alpha: 0.18)
                            : AppColors.grey200,
                    shape: BoxShape.circle,
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: sm.color.withValues(alpha: 0.40),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: isPast
                      ? Icon(Icons.check_rounded,
                          size: 13, color: sm.color)
                      : Text(
                          '${i + 1}',
                          style: TextStyle(
                            fontSize: isCurrent ? 14 : 11,
                            fontWeight: FontWeight.w700,
                            color: isCurrent ? Colors.white : AppColors.grey600,
                          ),
                        ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: meta.color,
                  borderRadius: AppRadius.borderRadiusPill,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  meta.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                ),
              ),
              Text(
                '${currentStep + 1} / $totalSteps',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.grey600,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Step instruction box
// ═══════════════════════════════════════════════════════════════════════════

class _StepInstruction extends StatelessWidget {
  const _StepInstruction({required this.stepIndex});
  final int stepIndex;

  @override
  Widget build(BuildContext context) {
    final meta = _kStepMeta[stepIndex];
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: meta.color.withValues(alpha: 0.09),
        borderRadius: AppRadius.borderRadiusMd,
        border: Border(left: BorderSide(color: meta.color, width: 3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(meta.icon, size: 16, color: meta.color),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              meta.instruction,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.grey800,
                    height: 1.45,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Chip selector (replaces _DropdownField)
// ═══════════════════════════════════════════════════════════════════════════

class _ChipSelector extends StatelessWidget {
  const _ChipSelector({
    required this.label,
    required this.icon,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 15, color: AppColors.grey600),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.grey700,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: adaptiveScrollPhysics,
          child: Row(
            children: [
              for (final option in options)
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.xs),
                  child: _SelectionChip(
                    label: option,
                    isSelected: option == value,
                    onTap: () => onChanged(option),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SelectionChip extends StatelessWidget {
  const _SelectionChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: AppRadius.borderRadiusPill,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.grey300,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.28),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(Icons.check_rounded,
                  size: 13, color: AppColors.white),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.white : AppColors.grey700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Step 0: Basisdaten
// ═══════════════════════════════════════════════════════════════════════════

class _Step0Basisdaten extends StatelessWidget {
  const _Step0Basisdaten({
    required this.titleCtrl,
    required this.descCtrl,
    required this.surgeryType,
    required this.bodyRegion,
    required this.templateType,
    required this.hasOrganization,
    required this.onSurgeryTypeChanged,
    required this.onBodyRegionChanged,
    required this.onTemplateTypeChanged,
  });

  final TextEditingController titleCtrl;
  final TextEditingController descCtrl;
  final String surgeryType;
  final String bodyRegion;
  final AftercareTemplateType templateType;
  final bool hasOrganization;
  final ValueChanged<String> onSurgeryTypeChanged;
  final ValueChanged<String> onBodyRegionChanged;
  final ValueChanged<AftercareTemplateType> onTemplateTypeChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: adaptiveScrollPhysics,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      children: [
        _StepInstruction(stepIndex: 0),

        GlassTextField(
          controller: titleCtrl,
          label: 'Titel *',
          hint: 'z.B. Knie-TEP Standard',
          prefixIcon: Icons.title_rounded,
        ),
        const SizedBox(height: AppSpacing.lg),

        GlassTextField(
          controller: descCtrl,
          label: 'Beschreibung',
          hint: 'Optionale Beschreibung …',
          prefixIcon: Icons.notes_rounded,
          maxLines: 3,
        ),
        const SizedBox(height: AppSpacing.xl),

        // Surgery type chip selector
        _ChipSelector(
          label: 'OP-Typ',
          icon: Icons.medical_services_outlined,
          value: surgeryType,
          options: AftercareDefaults.surgeryTypes,
          onChanged: onSurgeryTypeChanged,
        ),
        const SizedBox(height: AppSpacing.xl),

        // Body region chip selector
        _ChipSelector(
          label: 'Körperregion',
          icon: Icons.location_on_outlined,
          value: bodyRegion,
          options: AftercareDefaults.bodyRegions,
          onChanged: onBodyRegionChanged,
        ),
        const SizedBox(height: AppSpacing.xl),

        // Template type selector (only doctor allowed if no org)
        if (hasOrganization) ...[
          _SectionHeader(
            title: 'Vorlagentyp',
            icon: Icons.folder_outlined,
          ),
          const SizedBox(height: AppSpacing.sm),
          _SegmentedControl(
            selected: templateType,
            onChanged: onTemplateTypeChanged,
          ),
        ],
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Step 1: Phasen-Struktur
// ═══════════════════════════════════════════════════════════════════════════

class _Step1Phases extends StatelessWidget {
  const _Step1Phases({
    required this.phases,
    required this.onLoadDefaults,
    required this.onAddPhase,
    required this.onRemovePhase,
    required this.onPhaseRenamed,
    required this.onPhaseDaysChanged,
  });

  final List<AftercarePhase> phases;
  final VoidCallback onLoadDefaults;
  final VoidCallback onAddPhase;
  final ValueChanged<int> onRemovePhase;
  final void Function(int index, String title) onPhaseRenamed;
  final void Function(int index, int start, int? end) onPhaseDaysChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: adaptiveScrollPhysics,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      children: [
        _StepInstruction(stepIndex: 1),

        if (phases.isEmpty) ...[
          GlassCard(
            child: Column(
              children: [
                const Icon(Icons.auto_awesome_rounded,
                    size: 32, color: AppColors.primary),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Standardphasen laden?',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Basierend auf dem OP-Typ werden passende Phasen vorgeschlagen.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                GlassButton(
                  onPressed: onLoadDefaults,
                  label: 'Standardphasen laden',
                  icon: Icons.auto_awesome_rounded,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        for (var i = 0; i < phases.length; i++)
          _PhaseCard(
            phase: phases[i],
            index: i,
            onRenamed: (title) => onPhaseRenamed(i, title),
            onDaysChanged: (start, end) => onPhaseDaysChanged(i, start, end),
            onRemove: () => onRemovePhase(i),
          ),

        const SizedBox(height: AppSpacing.md),
        GlassButton(
          onPressed: onAddPhase,
          label: 'Phase hinzufügen',
          icon: Icons.add_rounded,
          variant: GlassButtonVariant.secondary,
        ),
      ],
    );
  }
}

class _PhaseCard extends StatefulWidget {
  const _PhaseCard({
    required this.phase,
    required this.index,
    required this.onRenamed,
    required this.onDaysChanged,
    required this.onRemove,
  });

  final AftercarePhase phase;
  final int index;
  final ValueChanged<String> onRenamed;
  final void Function(int start, int? end) onDaysChanged;
  final VoidCallback onRemove;

  @override
  State<_PhaseCard> createState() => _PhaseCardState();
}

class _PhaseCardState extends State<_PhaseCard> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _startCtrl;
  late final TextEditingController _endCtrl;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.phase.title);
    _startCtrl =
        TextEditingController(text: widget.phase.startDayOffset.toString());
    _endCtrl =
        TextEditingController(text: widget.phase.endDayOffset?.toString() ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
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
                    '${widget.index + 1}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: GlassTextField(
                    hint: 'Phasenname',
                    controller: _titleCtrl,
                    onChanged: widget.onRenamed,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  color: AppColors.error,
                  onPressed: widget.onRemove,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: GlassTextField(
                    label: 'Ab Tag',
                    hint: '0',
                    keyboardType: TextInputType.number,
                    controller: _startCtrl,
                    onChanged: (v) {
                      final start = int.tryParse(v);
                      if (start != null) {
                        widget.onDaysChanged(
                            start, widget.phase.endDayOffset);
                      }
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: GlassTextField(
                    label: 'Bis Tag',
                    hint: 'optional',
                    keyboardType: TextInputType.number,
                    controller: _endCtrl,
                    onChanged: (v) {
                      final end = v.isEmpty ? null : int.tryParse(v);
                      widget.onDaysChanged(
                          widget.phase.startDayOffset, end);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${widget.phase.items.length} Einträge',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.grey700,
                    fontSize: 11,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Steps 2–8: Category item editors
// ═══════════════════════════════════════════════════════════════════════════

class _CategoryStepView extends StatelessWidget {
  const _CategoryStepView({
    required this.stepIndex,
    required this.categories,
    required this.phases,
    required this.deactivatedCategories,
    required this.onToggleCategory,
    required this.onAddItem,
    required this.onRemoveItem,
    required this.onUpdateItem,
  });

  final int stepIndex;
  final List<AftercareItemCategory> categories;
  final List<AftercarePhase> phases;
  final Set<AftercareItemCategory> deactivatedCategories;
  final Future<void> Function(AftercareItemCategory) onToggleCategory;
  final void Function(int phaseIndex, AftercareItem item) onAddItem;
  final void Function(String itemId) onRemoveItem;
  final void Function(String itemId, AftercareItem updated) onUpdateItem;

  @override
  Widget build(BuildContext context) {
    final mainCategory = categories.first;
    final isDeactivated = categories.every(deactivatedCategories.contains);
    final stepColor = _kStepMeta[stepIndex].color;

    return ListView(
      physics: adaptiveScrollPhysics,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      children: [
        _StepInstruction(stepIndex: stepIndex),

        // Header with toggle
        Row(
          children: [
            Icon(mainCategory.icon, size: 22, color: stepColor),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                categories.map((c) => c.displayName).join(' & '),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            CupertinoSwitch(
              value: !isDeactivated,
              activeTrackColor: stepColor,
              onChanged: (_) => onToggleCategory(mainCategory),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        if (isDeactivated)
          GlassCard(
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 18, color: AppColors.grey600),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Dieser Bereich ist deaktiviert. '
                    'Aktivieren Sie ihn, um Einträge hinzuzufügen.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.grey700,
                        ),
                  ),
                ),
              ],
            ),
          )
        else ...[
          // Existing items per phase
          for (var pi = 0; pi < phases.length; pi++) ...[
            _PhaseItemsSection(
              phase: phases[pi],
              phaseIndex: pi,
              categories: categories,
              onAddItem: onAddItem,
              onRemoveItem: onRemoveItem,
              onUpdateItem: onUpdateItem,
            ),
          ],

          if (phases.isEmpty)
            GlassCard(
              child: Text(
                'Bitte definieren Sie zuerst Phasen in Schritt 2.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ),
        ],
      ],
    );
  }
}

class _PhaseItemsSection extends StatelessWidget {
  const _PhaseItemsSection({
    required this.phase,
    required this.phaseIndex,
    required this.categories,
    required this.onAddItem,
    required this.onRemoveItem,
    required this.onUpdateItem,
  });

  final AftercarePhase phase;
  final int phaseIndex;
  final List<AftercareItemCategory> categories;
  final void Function(int phaseIndex, AftercareItem item) onAddItem;
  final void Function(String itemId) onRemoveItem;
  final void Function(String itemId, AftercareItem updated) onUpdateItem;

  List<AftercareItem> get _relevantItems =>
      phase.items.where((i) => categories.contains(i.category)).toList();

  @override
  Widget build(BuildContext context) {
    final items = _relevantItems;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.layers_outlined,
                    size: 14, color: AppColors.grey600),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  phase.title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                ),
              ],
            ),
            if (items.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              for (final item in items)
                _ItemRow(
                  item: item,
                  onRemove: () => onRemoveItem(item.id),
                  onUpdate: (updated) => onUpdateItem(item.id, updated),
                ),
            ],
            const SizedBox(height: AppSpacing.sm),
            GlassButton(
              onPressed: () {
                final cat = categories.first;
                final newItem = AftercareItem(
                  id: '${cat.name}_${DateTime.now().millisecondsSinceEpoch}',
                  category: cat,
                  title: '',
                  startDayOffset: phase.startDayOffset,
                  endDayOffset: phase.endDayOffset,
                  order: items.length,
                );
                onAddItem(phaseIndex, newItem);
              },
              label: 'Eintrag hinzufügen',
              icon: Icons.add_rounded,
              variant: GlassButtonVariant.ghost,
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemRow extends StatefulWidget {
  const _ItemRow({
    required this.item,
    required this.onRemove,
    required this.onUpdate,
  });

  final AftercareItem item;
  final VoidCallback onRemove;
  final ValueChanged<AftercareItem> onUpdate;

  @override
  State<_ItemRow> createState() => _ItemRowState();
}

class _ItemRowState extends State<_ItemRow> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.item.title);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Icon(widget.item.category.icon, size: 14, color: AppColors.grey600),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: GlassTextField(
              hint: '${widget.item.category.displayName} …',
              controller: _ctrl,
              onChanged: (v) =>
                  widget.onUpdate(widget.item.copyWith(title: v)),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          // Day range display
          SizedBox(
            width: 56,
            child: Text(
              _dayRange(widget.item),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.grey700,
                    fontSize: 10,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 16),
            color: AppColors.error.withValues(alpha: 0.7),
            onPressed: widget.onRemove,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          ),
        ],
      ),
    );
  }

  String _dayRange(AftercareItem item) {
    final s = item.startDayOffset;
    final e = item.endDayOffset;
    if (s == null && e == null) return '';
    if (e == null) return 'Tag $s';
    return 'Tag $s–$e';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Step 9: Summary
// ═══════════════════════════════════════════════════════════════════════════

class _Step9Summary extends StatelessWidget {
  const _Step9Summary({
    required this.title,
    required this.description,
    required this.surgeryType,
    required this.bodyRegion,
    required this.templateType,
    required this.phases,
    required this.deactivatedCategories,
    required this.onJumpToStep,
  });

  final String title;
  final String description;
  final String surgeryType;
  final String bodyRegion;
  final AftercareTemplateType templateType;
  final List<AftercarePhase> phases;
  final Set<AftercareItemCategory> deactivatedCategories;
  final void Function(int step) onJumpToStep;

  @override
  Widget build(BuildContext context) {
    // Count items excluding deactivated categories.
    var totalItems = 0;
    for (final phase in phases) {
      totalItems += phase.items
          .where((i) => !deactivatedCategories.contains(i.category))
          .length;
    }

    final typeLabel = switch (templateType) {
      AftercareTemplateType.doctor => 'Eigene Vorlage',
      AftercareTemplateType.organization => 'Organisations-Vorlage',
      AftercareTemplateType.system => 'System-Vorlage',
    };

    return ListView(
      physics: adaptiveScrollPhysics,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      children: [
        _StepInstruction(stepIndex: 9),

        // ── Basisdaten overview card ─────────────────────────────────────
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title.isEmpty ? '(Kein Titel)' : title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  _JumpButton(
                    step: 0,
                    onJump: onJumpToStep,
                  ),
                ],
              ),
              if (description.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.grey700,
                      ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              _SummaryRow(label: 'Typ', value: typeLabel),
              if (surgeryType.isNotEmpty)
                _SummaryRow(label: 'OP-Typ', value: surgeryType),
              if (bodyRegion.isNotEmpty)
                _SummaryRow(label: 'Region', value: bodyRegion),
              _SummaryRow(label: 'Phasen', value: '${phases.length}'),
              _SummaryRow(label: 'Einträge gesamt', value: '$totalItems'),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Sections quick-jump row ──────────────────────────────────────
        _SectionJumpRow(onJumpToStep: onJumpToStep),
        const SizedBox(height: AppSpacing.lg),

        // ── Phase details with jump buttons ─────────────────────────────
        Row(
          children: [
            Text(
              'Phasen-Übersicht',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
            ),
            const Spacer(),
            _JumpButton(step: 1, onJump: onJumpToStep),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        for (var i = 0; i < phases.length; i++)
          _SummaryPhaseCard(
            phase: phases[i],
            index: i,
            deactivatedCategories: deactivatedCategories,
          ),

        if (phases.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: GlassCard(
              child: Text(
                'Keine Phasen definiert – gehen Sie zurück zu Schritt 2.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.grey700,
                    ),
              ),
            ),
          ),

        // ── Deactivated categories warning ───────────────────────────────
        if (deactivatedCategories.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          GlassCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded,
                    size: 18, color: AppColors.warning),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Deaktiviert: ${deactivatedCategories.map((c) => c.displayName).join(', ')}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.grey600,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small "Bearbeiten" button used in the summary to jump to a step.
class _JumpButton extends StatelessWidget {
  const _JumpButton({required this.step, required this.onJump});
  final int step;
  final void Function(int) onJump;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onJump(step),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.10),
          borderRadius: AppRadius.borderRadiusPill,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.edit_rounded, size: 11, color: AppColors.primary),
            const SizedBox(width: 3),
            Text(
              'Bearbeiten',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Horizontal scrollable row of section jump chips for the summary overview.
class _SectionJumpRow extends StatelessWidget {
  const _SectionJumpRow({required this.onJumpToStep});
  final void Function(int) onJumpToStep;

  // Steps 2–8 (categories): index matches _kStepMeta
  static const _sectionSteps = [2, 3, 4, 5, 6, 7, 8];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Schnellnavigation',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.grey600,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: adaptiveScrollPhysics,
          child: Row(
            children: [
              for (final step in _sectionSteps)
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.xs),
                  child: GestureDetector(
                    onTap: () => onJumpToStep(step),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: _kStepMeta[step].color.withValues(alpha: 0.10),
                        borderRadius: AppRadius.borderRadiusPill,
                        border: Border.all(
                          color: _kStepMeta[step].color.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _kStepMeta[step].icon,
                            size: 13,
                            color: _kStepMeta[step].color,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _kStepMeta[step].shortTitle,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _kStepMeta[step].color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryPhaseCard extends StatelessWidget {
  const _SummaryPhaseCard({
    required this.phase,
    required this.index,
    required this.deactivatedCategories,
  });

  final AftercarePhase phase;
  final int index;
  final Set<AftercareItemCategory> deactivatedCategories;

  @override
  Widget build(BuildContext context) {
    final activeItems = phase.items
        .where((i) => !deactivatedCategories.contains(i.category))
        .toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: AppRadius.borderRadiusXs,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${index + 1}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  phase.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                ),
                const Spacer(),
                Text(
                  _dayLabel(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.grey700,
                        fontSize: 11,
                      ),
                ),
              ],
            ),
            if (activeItems.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              for (final item in activeItems)
                Padding(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.xxxl,
                    bottom: 2,
                  ),
                  child: Row(
                    children: [
                      Icon(item.category.icon,
                          size: 12, color: AppColors.grey600),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          item.title.isEmpty
                              ? item.category.displayName
                              : item.title,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 12,
                                    color: AppColors.textPrimary,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  String _dayLabel() {
    final e = phase.endDayOffset;
    if (e == null) return 'Ab Tag ${phase.startDayOffset}';
    return 'Tag ${phase.startDayOffset}–$e';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Shared widgets
// ═══════════════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _SegmentedControl extends StatelessWidget {
  const _SegmentedControl({
    required this.selected,
    required this.onChanged,
  });

  final AftercareTemplateType selected;
  final ValueChanged<AftercareTemplateType> onChanged;

  @override
  Widget build(BuildContext context) {
    return CupertinoSlidingSegmentedControl<AftercareTemplateType>(
      groupValue: selected,
      children: const {
        AftercareTemplateType.doctor: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text('Eigene', style: TextStyle(fontSize: 13)),
        ),
        AftercareTemplateType.organization: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text('Organisation', style: TextStyle(fontSize: 13)),
        ),
      },
      onValueChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}
