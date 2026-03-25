import 'package:flutter/material.dart';

import '../../domain/timeline_engine.dart';
import '../../features/doctor_templates/data/system_template_repository.dart';
import '../../features/doctor_templates/domain/care_plan_template.dart';

/// Admin tab for managing system-wide templates that doctors can use.
class SystemTemplatesTab extends StatefulWidget {
  const SystemTemplatesTab({super.key});

  @override
  State<SystemTemplatesTab> createState() => _SystemTemplatesTabState();
}

class _SystemTemplatesTabState extends State<SystemTemplatesTab> {
  final _repo = AdminSystemTemplateRepository();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Systemvorlagen'),
        automaticallyImplyLeading: true,
        actions: [
          FilledButton.icon(
            onPressed: () => _showEditor(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Neue Vorlage'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: StreamBuilder<List<CarePlanTemplate>>(
        stream: _repo.watchAll(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final templates = snap.data ?? [];
          if (templates.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.library_books_outlined,
                      size: 48, color: cs.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text('Noch keine Systemvorlagen',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  const Text(
                    'Erstellen Sie Vorlagen, die alle Ärzte\nverwenden können.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => _showEditor(context),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Erste Systemvorlage'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: templates.length,
            separatorBuilder: (_, index) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final t = templates[i];
              return Card(
                child: ListTile(
                  leading: Icon(Icons.library_books_rounded,
                      color: cs.primary),
                  title: Text(t.name,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    t.description.isEmpty
                        ? '${t.tasks.length} Aufgabe${t.tasks.length == 1 ? '' : 'n'}'
                        : '${t.description}\n${t.tasks.length} Aufgabe${t.tasks.length == 1 ? '' : 'n'}',
                  ),
                  isThreeLine: t.description.isNotEmpty,
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'edit') _showEditor(context, existing: t);
                      if (v == 'delete') _confirmDelete(t);
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                          value: 'edit', child: Text('Bearbeiten')),
                      PopupMenuItem(
                          value: 'delete',
                          child: Text('Löschen',
                              style: TextStyle(color: cs.error))),
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

  void _showEditor(BuildContext context, {CarePlanTemplate? existing}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _SystemTemplateEditorScreen(
          existing: existing,
          onSave: (template) => _repo.upsert(template),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(CarePlanTemplate template) async {
    final cs = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Systemvorlage löschen?'),
        content: Text(
            'Möchten Sie "${template.name}" wirklich löschen?\nDiese Vorlage wird für alle Ärzte entfernt.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: cs.error),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await _repo.delete(template.id);
      } catch (e) {
        debugPrint('Error deleting system template: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fehler beim Löschen')),
          );
        }
      }
    }
  }
}

// ── System template editor ──────────────────────────────────────────────────

class _SystemTemplateEditorScreen extends StatefulWidget {
  const _SystemTemplateEditorScreen({
    this.existing,
    required this.onSave,
  });

  final CarePlanTemplate? existing;
  final Future<void> Function(CarePlanTemplate) onSave;

  @override
  State<_SystemTemplateEditorScreen> createState() =>
      _SystemTemplateEditorScreenState();
}

class _SystemTemplateEditorScreenState
    extends State<_SystemTemplateEditorScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final List<TemplateTask> _tasks;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
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
        id: widget.existing?.id ?? 'sys_${now.millisecondsSinceEpoch}',
        doctorUid: 'system',
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
      builder: (_) => _AdminTaskSheet(),
    ).then((task) {
      if (task != null) setState(() => _tasks.add(task));
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Vorlage bearbeiten' : 'Neue Systemvorlage'),
        actions: [
          FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? 'Speichere...' : 'Speichern'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Name der Vorlage',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Beschreibung (optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Tasks header
          Row(
            children: [
              Text('Aufgaben (${_tasks.length})',
                  style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              FilledButton.tonalIcon(
                onPressed: _addTask,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Aufgabe'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (_tasks.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text('Noch keine Aufgaben',
                      style: TextStyle(color: cs.onSurfaceVariant)),
                ),
              ),
            )
          else
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: _tasks.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final item = _tasks.removeAt(oldIndex);
                  _tasks.insert(newIndex, item);
                });
              },
              itemBuilder: (context, i) {
                final task = _tasks[i];
                return Card(
                  key: ValueKey('task_$i'),
                  child: ListTile(
                    leading: ReorderableDragStartListener(
                      index: i,
                      child: const Icon(Icons.drag_handle_rounded),
                    ),
                    title: Text(task.title,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      '${_typeLabel(task.type)} · Tag +${task.relativeDayOffset} · ${task.dueHours}h fällig',
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.remove_circle_outline,
                          color: cs.error),
                      onPressed: () => setState(() => _tasks.removeAt(i)),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  String _typeLabel(TaskType t) => switch (t) {
        TaskType.checklist => 'Checkliste',
        TaskType.wound => 'Wunddoku',
        TaskType.meds => 'Medikament',
        TaskType.message => 'Nachricht',
        TaskType.custom => 'Sonstige',
        _ => t.name,
      };
}

// ── Task definition sheet (admin version) ───────────────────────────────────

class _AdminTaskSheet extends StatefulWidget {
  @override
  State<_AdminTaskSheet> createState() => _AdminTaskSheetState();
}

class _AdminTaskSheetState extends State<_AdminTaskSheet> {
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
          left: 24,
          right: 24,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Aufgabe definieren',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),

              TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Titel',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _subtitleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Beschreibung (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

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
                decoration: const InputDecoration(
                  labelText: 'Typ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

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
                decoration: const InputDecoration(
                  labelText: 'Priorität',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Tag-Offset',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) => _dayOffset = int.tryParse(v) ?? 0,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Fällig nach (Std.)',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) => _dueHours = int.tryParse(v) ?? 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

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
