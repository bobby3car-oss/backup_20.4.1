import 'package:flutter/material.dart';

import '../../../domain/timeline_engine.dart';
import '../../../ui/ui.dart';
import '../data/doctor_template_repository.dart';
import '../domain/care_plan_template.dart';

/// Screen where doctors can create/edit/delete care plan templates.
class TemplateManagementScreen extends StatefulWidget {
  const TemplateManagementScreen({super.key});

  @override
  State<TemplateManagementScreen> createState() =>
      _TemplateManagementScreenState();
}

class _TemplateManagementScreenState extends State<TemplateManagementScreen> {
  final _repo = DoctorTemplateRepository();

  @override
  Widget build(BuildContext context) {
    return GlassPage(
      title: 'Vorlagen',
      titleEmoji: '📋',
      titleColor: AppColors.primary,
      trailing: IconButton(
        onPressed: () => _showCreateTemplate(context),
        icon: const Icon(Icons.add_rounded, color: AppColors.primary),
      ),
      children: [
        StreamBuilder<List<CarePlanTemplate>>(
          stream: _repo.watchAll(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final templates = snap.data ?? [];
            if (templates.isEmpty) {
              return GlassContainer(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                borderRadius: AppRadius.borderRadiusXl,
                child: Column(
                  children: [
                    const Text(
                      '📋',
                      style: TextStyle(fontSize: 48),
                    ),
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
              );
            }

            return Column(
              children: [
                for (final t in templates) ...[
                  _TemplateCard(
                    template: t,
                    onEdit: () => _showEditTemplate(context, t),
                    onDelete: () => _confirmDelete(context, t),
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

  Future<void> _confirmDelete(
      BuildContext context, CarePlanTemplate template) async {
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
    if (confirmed == true) await _repo.delete(template.id);
  }
}

// ── Template card ────────────────────────────────────────────────────────────

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({
    required this.template,
    required this.onEdit,
    required this.onDelete,
  });

  final CarePlanTemplate template;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
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
                  template.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'edit') onEdit();
                  if (v == 'delete') onDelete();
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                      value: 'edit', child: Text('Bearbeiten')),
                  const PopupMenuItem(
                      value: 'delete',
                      child: Text('Löschen',
                          style: TextStyle(color: AppColors.error))),
                ],
              ),
            ],
          ),
          if (template.description.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              template.description,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Text(
            '${template.tasks.length} Aufgabe${template.tasks.length == 1 ? '' : 'n'}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
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
  late final List<TemplateTask> _tasks;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl =
        TextEditingController(text: widget.existing?.name ?? '');
    _descCtrl =
        TextEditingController(text: widget.existing?.description ?? '');
    _tasks = List<TemplateTask>.from(widget.existing?.tasks ?? []);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;

    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      final template = CarePlanTemplate(
        id: widget.existing?.id ??
            'tpl_${now.millisecondsSinceEpoch}',
        doctorUid: widget.existing?.doctorUid ?? '',
        name: name,
        description: _descCtrl.text.trim(),
        tasks: _tasks,
        createdAt: widget.existing?.createdAt ?? now,
        updatedAt: now,
      );
      await widget.onSave(template);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _addTask() {
    showModalBottomSheet<TemplateTask>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => const _TaskDefinitionSheet(),
    ).then((task) {
      if (task != null) {
        setState(() => _tasks.add(task));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;

    return GlassPage(
      title: isEditing ? 'Vorlage bearbeiten' : 'Neue Vorlage',
      titleEmoji: '📋',
      titleColor: AppColors.primary,
      children: [
        GlassContainer(
          borderRadius: AppRadius.borderRadiusXl,
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameCtrl,
                decoration:
                    const InputDecoration(labelText: 'Name der Vorlage'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                    labelText: 'Beschreibung (optional)'),
                maxLines: 2,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Tasks section
        Row(
          children: [
            Expanded(
              child: Text(
                'Aufgaben (${_tasks.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(
              onPressed: _addTask,
              icon: const Icon(Icons.add_circle_outline_rounded,
                  color: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        if (_tasks.isEmpty)
          GlassContainer(
            borderRadius: AppRadius.borderRadiusLg,
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: const Center(
              child: Text(
                'Noch keine Aufgaben hinzugefügt',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          )
        else
          for (var i = 0; i < _tasks.length; i++) ...[
            _TaskRow(
              task: _tasks[i],
              onRemove: () => setState(() => _tasks.removeAt(i)),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],

        const SizedBox(height: AppSpacing.xxl),

        GlassButton(
          onPressed: _saving ? null : _save,
          label: _saving
              ? 'Speichere...'
              : (isEditing ? 'Speichern' : 'Vorlage erstellen'),
          icon: Icons.check_rounded,
          expand: true,
        ),
      ],
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({required this.task, required this.onRemove});

  final TemplateTask task;
  final VoidCallback onRemove;

  String _typeLabel(TaskType t) => switch (t) {
        TaskType.checklist => 'Checkliste',
        TaskType.wound => 'Wunddoku',
        TaskType.meds => 'Medikament',
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

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: AppRadius.borderRadiusLg,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_typeLabel(task.type)} · ${_priorityLabel(task.priority)} · Tag +${task.relativeDayOffset}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon:
                const Icon(Icons.remove_circle_outline, color: AppColors.error),
            iconSize: 20,
          ),
        ],
      ),
    );
  }
}

// ── Task definition bottom sheet ────────────────────────────────────────────

class _TaskDefinitionSheet extends StatefulWidget {
  const _TaskDefinitionSheet();

  @override
  State<_TaskDefinitionSheet> createState() => _TaskDefinitionSheetState();
}

class _TaskDefinitionSheetState extends State<_TaskDefinitionSheet> {
  final _titleCtrl = TextEditingController();
  final _subtitleCtrl = TextEditingController();
  TaskType _type = TaskType.checklist;
  TaskPriority _priority = TaskPriority.normal;
  int _dayOffset = 0;
  int _dueHours = 24;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subtitleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              Text(
                'Aufgabe definieren',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.lg),

              TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Titel'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _subtitleCtrl,
                decoration:
                    const InputDecoration(labelText: 'Beschreibung (optional)'),
              ),
              const SizedBox(height: AppSpacing.md),

              DropdownButtonFormField<TaskType>(
                initialValue: _type,
                items: const [
                  DropdownMenuItem(
                      value: TaskType.checklist, child: Text('Checkliste')),
                  DropdownMenuItem(
                      value: TaskType.wound, child: Text('Wunddoku')),
                  DropdownMenuItem(
                      value: TaskType.meds, child: Text('Medikament')),
                  DropdownMenuItem(
                      value: TaskType.custom, child: Text('Sonstige')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _type = v);
                },
                decoration: const InputDecoration(labelText: 'Typ'),
              ),
              const SizedBox(height: AppSpacing.md),

              DropdownButtonFormField<TaskPriority>(
                initialValue: _priority,
                items: const [
                  DropdownMenuItem(
                      value: TaskPriority.low, child: Text('Niedrig')),
                  DropdownMenuItem(
                      value: TaskPriority.normal, child: Text('Normal')),
                  DropdownMenuItem(
                      value: TaskPriority.high, child: Text('Hoch')),
                  DropdownMenuItem(
                      value: TaskPriority.critical, child: Text('Kritisch')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _priority = v);
                },
                decoration: const InputDecoration(labelText: 'Priorität'),
              ),
              const SizedBox(height: AppSpacing.md),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Tag-Offset'),
                      onChanged: (v) =>
                          _dayOffset = int.tryParse(v) ?? 0,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Fällig nach (Std.)'),
                      onChanged: (v) =>
                          _dueHours = int.tryParse(v) ?? 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              FilledButton(
                onPressed: () {
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
                    ),
                  );
                },
                child: const Text('Hinzufügen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
