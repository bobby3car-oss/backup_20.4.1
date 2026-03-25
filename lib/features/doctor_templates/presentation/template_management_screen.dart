import 'package:flutter/material.dart';

import '../../../domain/timeline_engine.dart';
import '../../../ui/ui.dart';
import '../data/doctor_template_repository.dart';
import '../data/system_template_repository.dart';
import '../domain/care_plan_template.dart';
import '../../../ui/theme/app_icons.dart';

/// Screen where doctors can create/edit/delete care plan templates.
class TemplateManagementScreen extends StatefulWidget {
  const TemplateManagementScreen({super.key});

  @override
  State<TemplateManagementScreen> createState() =>
      _TemplateManagementScreenState();
}

class _TemplateManagementScreenState extends State<TemplateManagementScreen> {
  final _repo = DoctorTemplateRepository();
  final _systemRepo = SystemTemplateRepository();
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  final Set<String> _selectedTags = {};

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Set<String> _collectTags(List<CarePlanTemplate> templates) {
    final tags = <String>{};
    for (final t in templates) {
      tags.addAll(t.tags);
    }
    return tags;
  }

  List<CarePlanTemplate> _filter(List<CarePlanTemplate> templates) {
    var result = templates;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where((t) =>
              t.name.toLowerCase().contains(q) ||
              t.description.toLowerCase().contains(q))
          .toList();
    }
    if (_selectedTags.isNotEmpty) {
      result = result
          .where((t) => _selectedTags.every((tag) => t.tags.contains(tag)))
          .toList();
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return GlassPage(
      title: 'Vorlagen',
      titleIcon: AppIcons.clipboard,
      titleColor: AppColors.primary,
      trailing: IconButton(
        onPressed: () => _showCreateTemplate(context),
        icon: const Icon(Icons.add_rounded, color: AppColors.primary),
      ),
      children: [
        // Search bar
        GlassContainer(
          borderRadius: AppRadius.borderRadiusXl,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xs,
          ),
          child: TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Vorlagen durchsuchen...',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              border: InputBorder.none,
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
            ),
            onChanged: (v) => setState(() => _searchQuery = v.trim()),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        StreamBuilder<List<CarePlanTemplate>>(
          stream: _repo.watchAll(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final allTemplates = snap.data ?? [];
            final allTags = _collectTags(allTemplates);
            // Remove stale tag filters that no longer exist
            _selectedTags.retainAll(allTags);
            final filtered = _filter(allTemplates);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tag filter chips
                if (allTags.isNotEmpty) ...[                  
                  SizedBox(
                    height: 36,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (final tag in allTags.toList()..sort())
                          Padding(
                            padding: const EdgeInsets.only(right: AppSpacing.sm),
                            child: FilterChip(
                              label: Text(tag, style: const TextStyle(fontSize: 12)),
                              selected: _selectedTags.contains(tag),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedTags.add(tag);
                                  } else {
                                    _selectedTags.remove(tag);
                                  }
                                });
                              },
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                              selectedColor: AppColors.primary.withValues(alpha: 0.2),
                              checkmarkColor: AppColors.primary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

            if (allTemplates.isEmpty)
              GlassContainer(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                borderRadius: AppRadius.borderRadiusXl,
                child: Column(
                  children: [
                    GlassIcon(icon: AppIcons.clipboard, color: AppIcons.clipboardColor, size: 34),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Noch keine Vorlagen',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      'Erstellen Sie Vorlagen mit Aufgaben, die Sie Ihren Patienten zuweisen können.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    GlassButton(
                      onPressed: () => _showCreateTemplate(context),
                      label: 'Erste Vorlage erstellen',
                      icon: Icons.add_rounded,
                    ),
                  ],
                ),
              )
            else if (filtered.isEmpty)
              GlassContainer(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                borderRadius: AppRadius.borderRadiusXl,
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.search_off_rounded, size: 40, color: AppColors.textSecondary),
                      const SizedBox(height: AppSpacing.md),
                      const Text('Keine Vorlagen gefunden',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _selectedTags.isNotEmpty
                            ? 'Versuchen Sie andere Filter'
                            : 'Versuchen Sie einen anderen Suchbegriff',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: [
                  for (final t in filtered) ...[
                    _TemplateCard(
                      template: t,
                      onEdit: () => _showEditTemplate(context, t),
                      onDelete: () => _confirmDelete(t),
                      onClone: () => _cloneTemplate(t),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ],
              ),
              ],
            );
          },
        ),

        // ── System templates section ──────────────────────────────
        const SizedBox(height: AppSpacing.xl),
        StreamBuilder<List<CarePlanTemplate>>(
          stream: _systemRepo.watchAll(),
          builder: (context, snap) {
            final systemTemplates = snap.data ?? [];
            if (systemTemplates.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Systemvorlagen',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'Vom Admin bereitgestellt – zum Übernehmen tippen.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                for (final t in systemTemplates) ...[
                  _SystemTemplateCard(
                    template: t,
                    onClone: () => _cloneSystemTemplate(t),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  void _showCreateTemplate(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _TemplateEditorScreen(
          onSave: (template) => _repo.upsert(template),
        ),
      ),
    );
  }

  void _showEditTemplate(BuildContext context, CarePlanTemplate template) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _TemplateEditorScreen(
          existing: template,
          onSave: (updated) => _repo.upsert(updated),
        ),
      ),
    );
  }

  Future<void> _cloneTemplate(CarePlanTemplate template) async {
    final now = DateTime.now();
    final clone = CarePlanTemplate(
      id: 'tpl_${now.millisecondsSinceEpoch}',
      doctorUid: template.doctorUid,
      name: 'Kopie von ${template.name}',
      description: template.description,
      tasks: template.tasks,
      tags: template.tags,
      phases: template.phases,
      createdAt: now,
      updatedAt: now,
    );
    try {
      await _repo.upsert(clone);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${clone.name}" erstellt')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fehler beim Duplizieren')),
        );
      }
    }
  }

  Future<void> _cloneSystemTemplate(CarePlanTemplate systemTemplate) async {
    final now = DateTime.now();
    final clone = CarePlanTemplate(
      id: 'tpl_${now.millisecondsSinceEpoch}',
      doctorUid: '',
      name: systemTemplate.name,
      description: systemTemplate.description,
      tasks: systemTemplate.tasks,
      tags: systemTemplate.tags,
      phases: systemTemplate.phases,
      createdAt: now,
      updatedAt: now,
    );
    try {
      await _repo.upsert(clone);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${clone.name}" in eigene Vorlagen übernommen')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fehler beim Übernehmen')),
        );
      }
    }
  }

  Future<void> _confirmDelete(CarePlanTemplate template) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Vorlage löschen?'),
        content: Text('Möchten Sie "${template.name}" wirklich löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.error),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await _repo.delete(template.id);
      } catch (e) {
        debugPrint('Error deleting template: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fehler beim Löschen der Vorlage')),
          );
        }
      }
    }
  }
}

// ── Template card ────────────────────────────────────────────────────────────

class _TemplateCard extends StatefulWidget {
  const _TemplateCard({
    required this.template,
    required this.onEdit,
    required this.onDelete,
    required this.onClone,
  });

  final CarePlanTemplate template;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onClone;

  @override
  State<_TemplateCard> createState() => _TemplateCardState();
}

class _TemplateCardState extends State<_TemplateCard> {
  bool _expanded = false;

  String _phaseInfo() {
    final t = widget.template;
    if (t.phases.isEmpty) {
      return '${t.tasks.length} Aufgabe${t.tasks.length == 1 ? '' : 'n'}';
    }
    final parts = <String>[];
    for (final phase in t.phases) {
      final count = t.tasks.where((task) => task.phaseId == phase.id).length;
      if (count > 0) parts.add('${phase.name}: $count');
    }
    final unphased = t.tasks
        .where((task) => task.phaseId == null || !t.phases.any((p) => p.id == task.phaseId))
        .length;
    if (unphased > 0) parts.add('Allgemein: $unphased');
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.template;
    return GlassContainer(
      borderRadius: AppRadius.borderRadiusXl,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  t.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'edit') widget.onEdit();
                  if (v == 'clone') widget.onClone();
                  if (v == 'delete') widget.onDelete();
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('Bearbeiten')),
                  const PopupMenuItem(value: 'clone', child: Text('Duplizieren')),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Löschen', style: TextStyle(color: AppColors.error)),
                  ),
                ],
              ),
            ],
          ),
          // Tags
          if (t.tags.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final tag in t.tags)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(tag,
                      style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
          ],
          if (t.description.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(t.description,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
          const SizedBox(height: AppSpacing.md),
          // Tasks summary + expand
          InkWell(
            onTap: t.tasks.isNotEmpty ? () => setState(() => _expanded = !_expanded) : null,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                children: [
                  Text(_phaseInfo(),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  if (t.tasks.isNotEmpty) ...[
                    const SizedBox(width: AppSpacing.xs),
                    Icon(_expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                        size: 18, color: AppColors.primary),
                  ],
                ],
              ),
            ),
          ),
          if (_expanded && t.tasks.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            for (final task in t.tasks)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Row(
                  children: [
                    Icon(_taskTypeIcon(task.type), size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: Text(task.title,
                      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary))),
                    if (task.timeOfDay != null)
                      Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: Text(task.timeOfDay!.label,
                          style: const TextStyle(fontSize: 11, color: AppColors.accent)),
                      ),
                    Text('Tag ${task.relativeDayOffset >= 0 ? '+' : ''}${task.relativeDayOffset}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

IconData _taskTypeIcon(TaskType type) => switch (type) {
      TaskType.checklist => Icons.check_circle_outline_rounded,
      TaskType.wound => Icons.healing_rounded,
      TaskType.meds => Icons.medication_rounded,
      TaskType.appointment => Icons.calendar_today_rounded,
      TaskType.message => Icons.chat_bubble_outline_rounded,
      TaskType.custom => Icons.widgets_outlined,
      _ => Icons.task_alt_rounded,
    };

String _taskTypeLabel(TaskType t) => switch (t) {
      TaskType.checklist => 'Checkliste',
      TaskType.wound => 'Wunddoku',
      TaskType.meds => 'Medikament',
      TaskType.appointment => 'Termin',
      TaskType.message => 'Nachricht',
      TaskType.custom => 'Sonstige',
      _ => t.name,
    };

String _priorityLabel(TaskPriority p) => switch (p) {
      TaskPriority.low => 'Niedrig',
      TaskPriority.normal => 'Normal',
      TaskPriority.high => 'Hoch',
      TaskPriority.critical => 'Kritisch',
    };

// ── System template card (read-only, clone only) ────────────────────────────

class _SystemTemplateCard extends StatefulWidget {
  const _SystemTemplateCard({
    required this.template,
    required this.onClone,
  });

  final CarePlanTemplate template;
  final VoidCallback onClone;

  @override
  State<_SystemTemplateCard> createState() => _SystemTemplateCardState();
}

class _SystemTemplateCardState extends State<_SystemTemplateCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.template;
    return GlassContainer(
      borderRadius: AppRadius.borderRadiusXl,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.library_books_rounded,
                  size: 18, color: AppColors.accent),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  t.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: widget.onClone,
                icon: const Icon(Icons.copy_rounded, size: 16),
                label: const Text('Übernehmen'),
              ),
            ],
          ),
          if (t.tags.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final tag in t.tags)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(tag,
                      style: const TextStyle(fontSize: 11, color: AppColors.accent, fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
          ],
          if (t.description.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(t.description,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
          const SizedBox(height: AppSpacing.md),
          InkWell(
            onTap: t.tasks.isNotEmpty ? () => setState(() => _expanded = !_expanded) : null,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                children: [
                  Text(
                    '${t.tasks.length} Aufgabe${t.tasks.length == 1 ? '' : 'n'}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accent),
                  ),
                  if (t.tasks.isNotEmpty) ...[
                    const SizedBox(width: AppSpacing.xs),
                    Icon(_expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                        size: 18, color: AppColors.accent),
                  ],
                ],
              ),
            ),
          ),
          if (_expanded && t.tasks.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            for (final task in t.tasks)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Row(
                  children: [
                    Icon(_taskTypeIcon(task.type), size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: Text(task.title,
                      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary))),
                    if (task.timeOfDay != null)
                      Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: Text(task.timeOfDay!.label,
                          style: const TextStyle(fontSize: 11, color: AppColors.accent)),
                      ),
                    Text('Tag ${task.relativeDayOffset >= 0 ? '+' : ''}${task.relativeDayOffset}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

// ── Template editor screen ──────────────────────────────────────────────────

class _TemplateEditorScreen extends StatefulWidget {
  const _TemplateEditorScreen({
    this.existing,
    required this.onSave,
  });

  final CarePlanTemplate? existing;
  final Future<void> Function(CarePlanTemplate) onSave;

  @override
  State<_TemplateEditorScreen> createState() => _TemplateEditorScreenState();
}

class _TemplateEditorScreenState extends State<_TemplateEditorScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _tagCtrl;
  late final List<TemplateTask> _tasks;
  late final List<String> _tags;
  late final List<TemplatePhase> _phases;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
    _descCtrl = TextEditingController(text: widget.existing?.description ?? '');
    _tagCtrl = TextEditingController();
    _tasks = List<TemplateTask>.from(widget.existing?.tasks ?? []);
    _tags = List<String>.from(widget.existing?.tags ?? []);
    _phases = List<TemplatePhase>.from(widget.existing?.phases ?? []);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _tagCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;

    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      final template = CarePlanTemplate(
        id: widget.existing?.id ?? 'tpl_${now.millisecondsSinceEpoch}',
        doctorUid: widget.existing?.doctorUid ?? '',
        name: name,
        description: _descCtrl.text.trim(),
        tasks: _tasks,
        tags: _tags,
        phases: _phases,
        createdAt: widget.existing?.createdAt ?? now,
        updatedAt: now,
      );
      await widget.onSave(template);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userFacingError(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _addTag() {
    final tag = _tagCtrl.text.trim();
    if (tag.isEmpty || _tags.contains(tag)) return;
    setState(() {
      _tags.add(tag);
      _tagCtrl.clear();
    });
  }

  void _addPhase() {
    final name = 'Phase ${_phases.length + 1}';
    setState(() {
      _phases.add(TemplatePhase(
        id: 'phase_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        order: _phases.length,
      ));
    });
  }

  void _renamePhase(int index) {
    final ctrl = TextEditingController(text: _phases[index].name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Phase umbenennen'),
        content: TextField(controller: ctrl, autofocus: true,
          decoration: const InputDecoration(labelText: 'Name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Abbrechen')),
          FilledButton(onPressed: () {
            final n = ctrl.text.trim();
            if (n.isNotEmpty) {
              setState(() => _phases[index] = TemplatePhase(
                id: _phases[index].id, name: n, order: _phases[index].order));
            }
            Navigator.pop(ctx);
          }, child: const Text('OK')),
        ],
      ),
    );
  }

  void _deletePhase(int index) {
    final phaseId = _phases[index].id;
    setState(() {
      _phases.removeAt(index);
      // Clear phaseId from tasks that had this phase
      for (var i = 0; i < _tasks.length; i++) {
        if (_tasks[i].phaseId == phaseId) {
          _tasks[i] = _tasks[i].copyWith(clearPhaseId: true);
        }
      }
    });
  }

  Future<void> _openTaskSheet({TemplateTask? existing, int? editIndex}) async {
    final result = await showModalBottomSheet<TemplateTask>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => _TaskDefinitionSheet(existing: existing, phases: _phases),
    );
    if (result != null) {
      setState(() {
        if (editIndex != null) {
          _tasks[editIndex] = result;
        } else {
          _tasks.add(result);
        }
      });
    }
  }

  List<TemplateTask> _tasksForPhase(String? phaseId) {
    if (phaseId == null) {
      return _tasks.where((t) =>
          t.phaseId == null || !_phases.any((p) => p.id == t.phaseId)).toList();
    }
    return _tasks.where((t) => t.phaseId == phaseId).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;

    return GlassPage(
      title: isEditing ? 'Vorlage bearbeiten' : 'Neue Vorlage',
      titleIcon: AppIcons.clipboard,
      titleColor: AppColors.primary,
      children: [
        // ─── Name & Description ─────────────────────
        GlassContainer(
          borderRadius: AppRadius.borderRadiusXl,
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Name der Vorlage'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Beschreibung (optional)'),
                maxLines: 2,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // ─── Tags ───────────────────────────────────
        GlassContainer(
          borderRadius: AppRadius.borderRadiusXl,
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tags', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tagCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Tag eingeben...',
                        isDense: true,
                      ),
                      onSubmitted: (_) => _addTag(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  IconButton(
                    onPressed: _addTag,
                    icon: const Icon(Icons.add_rounded, color: AppColors.primary),
                  ),
                ],
              ),
              if (_tags.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    for (var i = 0; i < _tags.length; i++)
                      InputChip(
                        label: Text(_tags[i]),
                        onDeleted: () => setState(() => _tags.removeAt(i)),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // ─── Phases ─────────────────────────────────
        GlassContainer(
          borderRadius: AppRadius.borderRadiusXl,
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text('Phasen', style: Theme.of(context).textTheme.titleSmall)),
                  TextButton.icon(
                    onPressed: _addPhase,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Hinzufügen'),
                  ),
                ],
              ),
              if (_phases.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: AppSpacing.sm),
                  child: Text('Keine Phasen – alle Aufgaben sind allgemein.',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                )
              else
                for (var i = 0; i < _phases.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Row(
                      children: [
                        Icon(Icons.label_outline_rounded, size: 16, color: AppColors.primary),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(child: Text(_phases[i].name,
                          style: const TextStyle(fontWeight: FontWeight.w600))),
                        IconButton(
                          onPressed: () => _renamePhase(i),
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          iconSize: 18,
                        ),
                        IconButton(
                          onPressed: () => _deletePhase(i),
                          icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.error),
                          iconSize: 18,
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // ─── Tasks ──────────────────────────────────
        Row(
          children: [
            Expanded(
              child: Text(
                'Aufgaben (${_tasks.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(
              onPressed: () => _openTaskSheet(),
              icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        if (_tasks.isEmpty)
          GlassContainer(
            borderRadius: AppRadius.borderRadiusLg,
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: const Center(
              child: Text('Noch keine Aufgaben hinzugefügt',
                style: TextStyle(color: AppColors.textSecondary)),
            ),
          )
        else if (_phases.isEmpty)
          // No phases → flat list
          _buildTaskList(_tasks)
        else ...[
          // Group by phases
          for (final phase in _phases) ...[
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.xs),
              child: Text(phase.name,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ),
            _buildTaskList(_tasksForPhase(phase.id)),
          ],
          // Unassigned tasks
          if (_tasksForPhase(null).isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.xs),
              child: Text('Allgemein',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
            ),
            _buildTaskList(_tasksForPhase(null)),
          ],
        ],

        const SizedBox(height: AppSpacing.xxl),

        GlassButton(
          onPressed: _saving ? null : _save,
          label: _saving ? 'Speichere...' : (isEditing ? 'Speichern' : 'Vorlage erstellen'),
          icon: Icons.check_rounded,
          expand: true,
        ),
      ],
    );
  }

  Widget _buildTaskList(List<TemplateTask> tasks) {
    if (tasks.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Text('Keine Aufgaben', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      );
    }
    return Column(
      children: [
        for (var i = 0; i < tasks.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _TaskRow(
              task: tasks[i],
              onTap: () {
                final globalIndex = _tasks.indexOf(tasks[i]);
                _openTaskSheet(existing: tasks[i], editIndex: globalIndex);
              },
              onRemove: () {
                final globalIndex = _tasks.indexOf(tasks[i]);
                setState(() => _tasks.removeAt(globalIndex));
              },
            ),
          ),
      ],
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({required this.task, required this.onRemove, this.onTap});

  final TemplateTask task;
  final VoidCallback onRemove;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        borderRadius: AppRadius.borderRadiusLg,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Icon(_taskTypeIcon(task.type), size: 18, color: AppColors.primary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title,
                    style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(_taskTypeLabel(task.type),
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      Text(' · ${_priorityLabel(task.priority)}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      Text(' · Tag ${task.relativeDayOffset >= 0 ? '+' : ''}${task.relativeDayOffset}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                  if (task.timeOfDay != null || task.recurrence != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        children: [
                          if (task.timeOfDay != null)
                            Text(task.timeOfDay!.label,
                              style: const TextStyle(fontSize: 11, color: AppColors.accent, fontWeight: FontWeight.w600)),
                          if (task.timeOfDay != null && task.recurrence != null)
                            const Text(' · ', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          if (task.recurrence != null)
                            Text(_recurrenceLabel(task.recurrence!),
                              style: const TextStyle(fontSize: 11, color: AppColors.accent, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.edit_outlined, size: 16, color: AppColors.textSecondary),
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.remove_circle_outline, color: AppColors.error),
              iconSize: 20,
            ),
          ],
        ),
      ),
    );
  }
}

String _recurrenceLabel(TaskRecurrence r) => switch (r.type) {
      RecurrenceType.daily => 'Täglich (${r.count}x)',
      RecurrenceType.weekdays => 'Werktags (${r.count}x)',
      RecurrenceType.everyNDays => 'Alle ${r.intervalDays} Tage (${r.count}x)',
    };

// ── Task definition bottom sheet ────────────────────────────────────────────

class _TaskDefinitionSheet extends StatefulWidget {
  const _TaskDefinitionSheet({this.existing, this.phases = const []});

  final TemplateTask? existing;
  final List<TemplatePhase> phases;

  @override
  State<_TaskDefinitionSheet> createState() => _TaskDefinitionSheetState();
}

class _TaskDefinitionSheetState extends State<_TaskDefinitionSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _subtitleCtrl;
  late TaskType _type;
  late TaskPriority _priority;
  late int _dayOffset;
  late int _dueHours;
  TaskTimeOfDay? _timeOfDay;
  String? _phaseId;
  bool _hasRecurrence = false;
  RecurrenceType _recType = RecurrenceType.daily;
  int _recInterval = 2;
  int _recCount = 7;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _subtitleCtrl = TextEditingController(text: e?.subtitle ?? '');
    _type = e?.type ?? TaskType.checklist;
    _priority = e?.priority ?? TaskPriority.normal;
    _dayOffset = e?.relativeDayOffset ?? 0;
    _dueHours = e?.dueHours ?? 24;
    _timeOfDay = e?.timeOfDay;
    _phaseId = e?.phaseId;
    if (e?.recurrence != null) {
      _hasRecurrence = true;
      _recType = e!.recurrence!.type;
      _recInterval = e.recurrence!.intervalDays;
      _recCount = e.recurrence!.count;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subtitleCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;
    Navigator.pop(
      context,
      TemplateTask(
        title: title,
        subtitle: _subtitleCtrl.text.trim(),
        type: _type,
        priority: _priority,
        relativeDayOffset: _dayOffset,
        dueHours: _dueHours,
        timeOfDay: _timeOfDay,
        phaseId: _phaseId,
        recurrence: _hasRecurrence
            ? TaskRecurrence(
                type: _recType,
                intervalDays: _recType == RecurrenceType.everyNDays ? _recInterval : 1,
                count: _recCount,
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.xl,
          right: AppSpacing.xl,
          top: AppSpacing.lg,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
        ),
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
                    color: AppColors.grey400,
                    borderRadius: AppRadius.borderRadiusPill,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(isEdit ? 'Aufgabe bearbeiten' : 'Aufgabe definieren',
                style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.lg),

              // Title + Subtitle
              TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Titel'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _subtitleCtrl,
                decoration: const InputDecoration(labelText: 'Beschreibung (optional)'),
              ),
              const SizedBox(height: AppSpacing.md),

              // Type + Priority row
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<TaskType>(
                      initialValue: _type,
                      items: const [
                        DropdownMenuItem(value: TaskType.checklist, child: Text('Checkliste')),
                        DropdownMenuItem(value: TaskType.wound, child: Text('Wunddoku')),
                        DropdownMenuItem(value: TaskType.meds, child: Text('Medikament')),
                        DropdownMenuItem(value: TaskType.appointment, child: Text('Termin')),
                        DropdownMenuItem(value: TaskType.message, child: Text('Nachricht')),
                        DropdownMenuItem(value: TaskType.custom, child: Text('Sonstige')),
                      ],
                      onChanged: (v) { if (v != null) setState(() => _type = v); },
                      decoration: const InputDecoration(labelText: 'Typ'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: DropdownButtonFormField<TaskPriority>(
                      initialValue: _priority,
                      items: const [
                        DropdownMenuItem(value: TaskPriority.low, child: Text('Niedrig')),
                        DropdownMenuItem(value: TaskPriority.normal, child: Text('Normal')),
                        DropdownMenuItem(value: TaskPriority.high, child: Text('Hoch')),
                        DropdownMenuItem(value: TaskPriority.critical, child: Text('Kritisch')),
                      ],
                      onChanged: (v) { if (v != null) setState(() => _priority = v); },
                      decoration: const InputDecoration(labelText: 'Priorität'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Time of day segmented button
              Text('Tageszeit (optional)', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: AppSpacing.sm),
              SegmentedButton<TaskTimeOfDay?>(
                segments: [
                  const ButtonSegment(value: null, label: Text('–')),
                  for (final tod in TaskTimeOfDay.values)
                    ButtonSegment(value: tod, label: Text(tod.label)),
                ],
                selected: {_timeOfDay},
                onSelectionChanged: (s) => setState(() => _timeOfDay = s.first),
                showSelectedIcon: false,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Day offset stepper
              Row(
                children: [
                  Expanded(
                    child: Text('Tag-Offset', style: Theme.of(context).textTheme.labelLarge),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _dayOffset--),
                    icon: const Icon(Icons.remove_circle_outline_rounded),
                  ),
                  SizedBox(
                    width: 40,
                    child: Text('$_dayOffset', textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _dayOffset++),
                    icon: const Icon(Icons.add_circle_outline_rounded),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              // Due hours stepper
              Row(
                children: [
                  Expanded(
                    child: Text('Fällig nach (Std.)', style: Theme.of(context).textTheme.labelLarge),
                  ),
                  IconButton(
                    onPressed: _dueHours > 1 ? () => setState(() => _dueHours--) : null,
                    icon: const Icon(Icons.remove_circle_outline_rounded),
                  ),
                  SizedBox(
                    width: 40,
                    child: Text('$_dueHours', textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _dueHours++),
                    icon: const Icon(Icons.add_circle_outline_rounded),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Phase dropdown
              if (widget.phases.isNotEmpty) ...[
                DropdownButtonFormField<String?>(
                  initialValue: _phaseId,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Keine Phase')),
                    for (final phase in widget.phases)
                      DropdownMenuItem(value: phase.id, child: Text(phase.name)),
                  ],
                  onChanged: (v) => setState(() => _phaseId = v),
                  decoration: const InputDecoration(labelText: 'Phase'),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              // Recurrence
              SwitchListTile(
                title: const Text('Wiederkehrend'),
                value: _hasRecurrence,
                onChanged: (v) => setState(() => _hasRecurrence = v),
                contentPadding: EdgeInsets.zero,
              ),
              if (_hasRecurrence) ...[
                SegmentedButton<RecurrenceType>(
                  segments: const [
                    ButtonSegment(value: RecurrenceType.daily, label: Text('Täglich')),
                    ButtonSegment(value: RecurrenceType.weekdays, label: Text('Werktags')),
                    ButtonSegment(value: RecurrenceType.everyNDays, label: Text('Alle N Tage')),
                  ],
                  selected: {_recType},
                  onSelectionChanged: (s) => setState(() => _recType = s.first),
                  showSelectedIcon: false,
                ),
                const SizedBox(height: AppSpacing.sm),
                if (_recType == RecurrenceType.everyNDays)
                  Row(
                    children: [
                      const Text('Alle '),
                      IconButton(
                        onPressed: _recInterval > 2 ? () => setState(() => _recInterval--) : null,
                        icon: const Icon(Icons.remove_circle_outline_rounded, size: 20),
                      ),
                      Text('$_recInterval', style: const TextStyle(fontWeight: FontWeight.w700)),
                      IconButton(
                        onPressed: () => setState(() => _recInterval++),
                        icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                      ),
                      const Text(' Tage'),
                    ],
                  ),
                Row(
                  children: [
                    const Expanded(child: Text('Anzahl Wiederholungen')),
                    IconButton(
                      onPressed: _recCount > 1
                          ? () => setState(() => _recCount--)
                          : null,
                      icon: const Icon(Icons.remove_circle_outline_rounded, size: 20),
                    ),
                    Text('$_recCount', style: const TextStyle(fontWeight: FontWeight.w700)),
                    IconButton(
                      onPressed: () => setState(() => _recCount++),
                      icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
              ],

              const SizedBox(height: AppSpacing.xl),

              FilledButton(
                onPressed: _submit,
                child: Text(isEdit ? 'Übernehmen' : 'Hinzufügen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
