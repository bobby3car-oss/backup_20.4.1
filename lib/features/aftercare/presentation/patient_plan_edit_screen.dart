import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../data/patient_aftercare_plan_service.dart';
import '../domain/aftercare_item.dart';
import '../domain/aftercare_item_category.dart';
import '../domain/aftercare_phase.dart';
import '../domain/patient_aftercare_plan.dart';

/// Lightweight editor for an assigned patient aftercare plan.
///
/// Unlike the full 10-step [AftercareBuilderScreen], this screen shows all
/// phases and items on a single scrollable page. Doctors can:
///
///  - Edit the plan title
///  - Edit phase titles and day offsets
///  - Edit / delete / add items per phase
///  - Save all changes at once
class PatientPlanEditScreen extends StatefulWidget {
  const PatientPlanEditScreen({
    super.key,
    required this.plan,
    required this.planService,
    this.patientDisplayName,
    this.patientAge,
  });

  final PatientAftercarePlan plan;
  final PatientAftercarePlanService planService;

  /// Patient name displayed at the top for context.
  final String? patientDisplayName;

  /// Patient age in years displayed at the top for context.
  final int? patientAge;

  @override
  State<PatientPlanEditScreen> createState() => _PatientPlanEditScreenState();
}

class _PatientPlanEditScreenState extends State<PatientPlanEditScreen> {
  late final TextEditingController _titleCtrl;
  late List<_EditablePhase> _phases;
  bool _isSaving = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.plan.title);
    _titleCtrl.addListener(_markChanged);
    _phases = widget.plan.phases.asMap().entries.map((e) {
      return _EditablePhase.fromPhase(e.value);
    }).toList();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    for (final p in _phases) {
      p.dispose();
    }
    super.dispose();
  }

  void _markChanged() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  // ── Save ────────────────────────────────────────────────────────────

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte geben Sie einen Titel ein.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final updatedPhases = _phases.map((ep) => ep.toPhase()).toList();
      final updated = widget.plan.copyWith(
        title: title,
        phases: updatedPhases,
      );
      await widget.planService.updatePlan(updated);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: ${userFacingError(e)}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Phase operations ────────────────────────────────────────────────

  void _addItemToPhase(int phaseIndex) {
    _markChanged();
    setState(() {
      _phases[phaseIndex].items.add(_EditableItem.blank(
        order: _phases[phaseIndex].items.length,
      ));
    });
  }

  void _removeItem(int phaseIndex, int itemIndex) {
    _markChanged();
    final item = _phases[phaseIndex].items.removeAt(itemIndex);
    item.dispose();
    setState(() {});
  }

  void _editItem(int phaseIndex, int itemIndex) {
    final item = _phases[phaseIndex].items[itemIndex];
    _showItemEditor(item);
  }

  Future<void> _showItemEditor(_EditableItem item) async {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => _ItemEditorSheet(
        item: item,
        onChanged: () {
          _markChanged();
          setState(() {});
        },
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GlassPage(
      title: 'Plan anpassen',
      titleIcon: Icons.tune_rounded,
      trailing: _isSaving
          ? const CupertinoActivityIndicator()
          : IconButton(
              icon: const Icon(Icons.check_rounded, color: AppColors.primary),
              onPressed: _hasChanges ? _save : null,
            ),
      scrollableBody: (headerHeight) => ListView(
        physics: adaptiveScrollPhysics,
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: headerHeight + AppSpacing.md,
          bottom: 120,
        ),
        children: [
          // ── Patient info banner ──────────────────────────────
          if (widget.patientDisplayName != null)
            FadeSlideIn(
              child: GlassCard(
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: AppRadius.borderRadiusMd,
                      ),
                      child: const Icon(Icons.person_rounded,
                          size: 20, color: AppColors.primary),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.patientDisplayName!,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        if (widget.patientAge != null)
                          Text(
                            '${widget.patientAge} Jahre',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          if (widget.patientDisplayName != null)
            const SizedBox(height: AppSpacing.md),

          // ── Plan Title ───────────────────────────────────────
          FadeSlideIn(
            child: GlassTextField(
              controller: _titleCtrl,
              label: 'Plantitel',
              prefixIcon: Icons.assignment_rounded,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── Phases ───────────────────────────────────────────
          for (var pi = 0; pi < _phases.length; pi++) ...[
            FadeSlideIn(
              delay: Duration(milliseconds: 60 * pi),
              child: _PhaseSection(
                phase: _phases[pi],
                index: pi,
                onAddItem: () => _addItemToPhase(pi),
                onRemoveItem: (ii) => _removeItem(pi, ii),
                onEditItem: (ii) => _editItem(pi, ii),
                onChanged: _markChanged,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // ── Save button ──────────────────────────────────────
          const SizedBox(height: AppSpacing.lg),
          FadeSlideIn(
            delay: Duration(milliseconds: 60 * _phases.length + 60),
            child: GlassButton(
              label: 'Änderungen speichern',
              icon: Icons.save_rounded,
              onPressed: (_hasChanges && !_isSaving) ? _save : null,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Editable data holders
// ═══════════════════════════════════════════════════════════════════════════

class _EditablePhase {
  _EditablePhase({
    required this.id,
    required this.titleCtrl,
    required this.startDay,
    this.endDay,
    required this.order,
    required this.items,
  });

  final String id;
  final TextEditingController titleCtrl;
  int startDay;
  int? endDay;
  int order;
  final List<_EditableItem> items;

  factory _EditablePhase.fromPhase(AftercarePhase phase) {
    return _EditablePhase(
      id: phase.id,
      titleCtrl: TextEditingController(text: phase.title),
      startDay: phase.startDayOffset,
      endDay: phase.endDayOffset,
      order: phase.order,
      items: phase.items
          .map((i) => _EditableItem.fromItem(i))
          .toList(),
    );
  }

  AftercarePhase toPhase() {
    return AftercarePhase(
      id: id,
      title: titleCtrl.text.trim(),
      startDayOffset: startDay,
      endDayOffset: endDay,
      order: order,
      items: items.map((ei) => ei.toItem()).toList(),
    );
  }

  void dispose() {
    titleCtrl.dispose();
    for (final i in items) {
      i.dispose();
    }
  }
}

class _EditableItem {
  _EditableItem({
    required this.id,
    required this.category,
    required this.titleCtrl,
    required this.descCtrl,
    required this.notesCtrl,
    this.startDayOffset,
    this.endDayOffset,
    this.showInTimeline = true,
    this.isTimeBound = false,
    this.value = const {},
    required this.order,
  });

  final String id;
  AftercareItemCategory category;
  final TextEditingController titleCtrl;
  final TextEditingController descCtrl;
  final TextEditingController notesCtrl;
  int? startDayOffset;
  int? endDayOffset;
  bool showInTimeline;
  bool isTimeBound;
  Map<String, dynamic> value;
  int order;

  factory _EditableItem.fromItem(AftercareItem item) {
    return _EditableItem(
      id: item.id,
      category: item.category,
      titleCtrl: TextEditingController(text: item.title),
      descCtrl: TextEditingController(text: item.description),
      notesCtrl: TextEditingController(text: item.notes),
      startDayOffset: item.startDayOffset,
      endDayOffset: item.endDayOffset,
      showInTimeline: item.showInTimeline,
      isTimeBound: item.isTimeBound,
      value: Map<String, dynamic>.from(item.value),
      order: item.order,
    );
  }

  factory _EditableItem.blank({required int order}) {
    return _EditableItem(
      id: 'item_${DateTime.now().millisecondsSinceEpoch}',
      category: AftercareItemCategory.custom,
      titleCtrl: TextEditingController(),
      descCtrl: TextEditingController(),
      notesCtrl: TextEditingController(),
      order: order,
    );
  }

  AftercareItem toItem() {
    return AftercareItem(
      id: id,
      category: category,
      title: titleCtrl.text.trim(),
      description: descCtrl.text.trim(),
      notes: notesCtrl.text.trim(),
      startDayOffset: startDayOffset,
      endDayOffset: endDayOffset,
      showInTimeline: showInTimeline,
      isTimeBound: isTimeBound,
      value: value,
      order: order,
    );
  }

  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    notesCtrl.dispose();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Phase section widget
// ═══════════════════════════════════════════════════════════════════════════

class _PhaseSection extends StatelessWidget {
  const _PhaseSection({
    required this.phase,
    required this.index,
    required this.onAddItem,
    required this.onRemoveItem,
    required this.onEditItem,
    required this.onChanged,
  });

  final _EditablePhase phase;
  final int index;
  final VoidCallback onAddItem;
  final ValueChanged<int> onRemoveItem;
  final ValueChanged<int> onEditItem;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Phase header ─────────────────────────────────────
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
                child: TextField(
                  controller: phase.titleCtrl,
                  onChanged: (_) => onChanged(),
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: 'Phasenname',
                  ),
                ),
              ),
            ],
          ),

          // ── Day range ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(
              left: 40,
              top: AppSpacing.xs,
              bottom: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded,
                    size: 13, color: AppColors.grey500),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Tag ${phase.startDay}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                ),
                if (phase.endDay != null) ...[
                  Text(
                    ' – ${phase.endDay}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                  ),
                ],
              ],
            ),
          ),

          if (phase.items.isNotEmpty) const Divider(height: 1),

          // ── Items ────────────────────────────────────────────
          for (var i = 0; i < phase.items.length; i++)
            Dismissible(
              key: ValueKey(phase.items[i].id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: AppSpacing.lg),
                color: AppColors.error.withValues(alpha: 0.12),
                child: const Icon(Icons.delete_rounded,
                    color: AppColors.error, size: 20),
              ),
              onDismissed: (_) => onRemoveItem(i),
              child: InkWell(
                onTap: () => onEditItem(i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        phase.items[i].category.icon,
                        size: 16,
                        color: AppColors.grey500,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              phase.items[i].titleCtrl.text.isNotEmpty
                                  ? phase.items[i].titleCtrl.text
                                  : phase.items[i].descCtrl.text.isNotEmpty
                                      ? phase.items[i].descCtrl.text
                                      : 'Neuer Punkt',
                              style: Theme.of(context).textTheme.bodyMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (phase.items[i].descCtrl.text.isNotEmpty &&
                                phase.items[i].titleCtrl.text.isNotEmpty)
                              Text(
                                phase.items[i].descCtrl.text,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: AppColors.textSecondary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      if (!phase.items[i].showInTimeline)
                        Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.xs),
                          child: Icon(Icons.visibility_off_rounded,
                              size: 14, color: AppColors.grey400),
                        ),
                      Icon(Icons.chevron_right_rounded,
                          size: 18, color: AppColors.grey400),
                    ],
                  ),
                ),
              ),
            ),

          // ── Add item ─────────────────────────────────────────
          const SizedBox(height: AppSpacing.xs),
          Center(
            child: TextButton.icon(
              onPressed: onAddItem,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Punkt hinzufügen'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                textStyle: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Item editor bottom sheet
// ═══════════════════════════════════════════════════════════════════════════

class _ItemEditorSheet extends StatefulWidget {
  const _ItemEditorSheet({
    required this.item,
    required this.onChanged,
  });

  final _EditableItem item;
  final VoidCallback onChanged;

  @override
  State<_ItemEditorSheet> createState() => _ItemEditorSheetState();
}

class _ItemEditorSheetState extends State<_ItemEditorSheet> {
  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: AppSpacing.lg,
        bottom: bottom + AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Header
              Text(
                'Punkt bearbeiten',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Category picker
              Row(
                children: [
                  Text('Kategorie: ',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          )),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: CupertinoSlidingSegmentedControl<AftercareItemCategory>(
                      groupValue: item.category,
                      children: {
                        for (final cat in [
                          AftercareItemCategory.custom,
                          AftercareItemCategory.wound,
                          AftercareItemCategory.weightBearing,
                          AftercareItemCategory.physio,
                          AftercareItemCategory.medication,
                        ])
                          cat: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            child: Icon(cat.icon, size: 16),
                          ),
                      },
                      onValueChanged: (cat) {
                        if (cat != null) {
                          setState(() => item.category = cat);
                          widget.onChanged();
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Title
              GlassTextField(
                controller: item.titleCtrl,
                label: 'Titel',
                prefixIcon: Icons.title_rounded,
                onChanged: (_) => widget.onChanged(),
              ),
              const SizedBox(height: AppSpacing.md),

              // Description
              GlassTextField(
                controller: item.descCtrl,
                label: 'Beschreibung',
                prefixIcon: Icons.notes_rounded,
                maxLines: 3,
                onChanged: (_) => widget.onChanged(),
              ),
              const SizedBox(height: AppSpacing.md),

              // Notes
              GlassTextField(
                controller: item.notesCtrl,
                label: 'Hinweise',
                prefixIcon: Icons.info_outline_rounded,
                maxLines: 2,
                onChanged: (_) => widget.onChanged(),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Timeline toggle
              Row(
                children: [
                  const Icon(Icons.timeline_rounded,
                      size: 18, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'In Timeline anzeigen',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  CupertinoSwitch(
                    value: item.showInTimeline,
                    activeTrackColor: AppColors.primary,
                    onChanged: (v) {
                      setState(() => item.showInTimeline = v);
                      widget.onChanged();
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Done button
              GlassButton(
                label: 'Fertig',
                icon: Icons.check_rounded,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
