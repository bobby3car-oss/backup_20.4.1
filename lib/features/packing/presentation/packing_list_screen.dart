import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../data/packing_repository_sync.dart';
import '../domain/packing_item.dart';

class PackingListScreen extends StatefulWidget {
  const PackingListScreen({super.key});

  @override
  State<PackingListScreen> createState() => _PackingListScreenState();
}

class _PackingListScreenState extends State<PackingListScreen> {
  static final PackingRepositorySync _repository =
      PackingRepositorySync.instance;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _repository.loadFromDisk();
    await _repository.seedDefaultsIfEmpty();
    await _repository.pullLatest();
  }

  @override
  Widget build(BuildContext context) {
    return GlassPage(
      title: 'Packliste',
      titleEmoji: '🧳',
      titleColor: AppColors.warning,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('Item hinzufügen'),
      ),
      scrollableBody: (headerHeight) => StreamBuilder<List<PackingItem>>(
        stream: _repository.watchAll(),
        builder: (context, snapshot) {
          final items = snapshot.data ?? const <PackingItem>[];
          if (items.isEmpty) {
            return const Center(
              child: Text('Keine Packlisten-Einträge vorhanden.'),
            );
          }
          final grouped = _groupByCategory(items);
          return ListView(
            padding: EdgeInsets.only(top: headerHeight + 8, bottom: 100),
            children: [
              for (final category in PackingCategory.values)
                if ((grouped[category] ?? const <PackingItem>[])
                    .isNotEmpty) ...[
                  _CategoryHeader(
                    category: category,
                    done: grouped[category]!
                        .where((item) => item.checked)
                        .length,
                    total: grouped[category]!.length,
                  ),
                  for (final item in grouped[category]!)
                    _PackingTile(
                      item: item,
                      onToggle: (value) => _toggle(item, value),
                      onDelete: item.isDefault ? null : () => _delete(item),
                    ),
                ],
            ],
          );
        },
      ),
    );
  }

  Map<PackingCategory, List<PackingItem>> _groupByCategory(
    List<PackingItem> items,
  ) {
    final grouped = <PackingCategory, List<PackingItem>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.category, () => <PackingItem>[]).add(item);
    }
    return grouped;
  }

  Future<void> _toggle(PackingItem item, bool value) async {
    await _repository.upsert(
      item.copyWith(checked: value, updatedAt: DateTime.now()),
    );
  }

  Future<void> _delete(PackingItem item) async {
    await _repository.delete(item.id);
  }

  Future<void> _showAddDialog() async {
    final titleController = TextEditingController();
    PackingCategory selected = PackingCategory.other;

    final created = await showDialog<PackingItem>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Neues Packlisten-Item'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Titel'),
                    autofocus: true,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<PackingCategory>(
                    initialValue: selected,
                    items: PackingCategory.values
                        .map(
                          (cat) => DropdownMenuItem<PackingCategory>(
                            value: cat,
                            child: Text(cat.label),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) {
                      if (value == null) return;
                      setDialogState(() => selected = value);
                    },
                    decoration: const InputDecoration(labelText: 'Kategorie'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Abbrechen'),
                ),
                FilledButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    if (title.isEmpty) return;
                    final uid = FirebaseAuth.instance.currentUser?.uid;
                    if (uid == null || uid.trim().isEmpty) {
                      Navigator.of(dialogContext).pop();
                      return;
                    }
                    final now = DateTime.now();
                    Navigator.of(dialogContext).pop(
                      PackingItem(
                        id: 'packing_${now.microsecondsSinceEpoch}',
                        ownerId: uid,
                        title: title,
                        category: selected,
                        checked: false,
                        createdAt: now,
                        updatedAt: now,
                        isDefault: false,
                      ),
                    );
                  },
                  child: const Text('Hinzufügen'),
                ),
              ],
            );
          },
        );
      },
    );
    titleController.dispose();

    if (created == null) return;
    await _repository.upsert(created);
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({
    required this.category,
    required this.done,
    required this.total,
  });

  final PackingCategory category;
  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              category.label,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          Text('$done/$total', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _PackingTile extends StatelessWidget {
  const _PackingTile({
    required this.item,
    required this.onToggle,
    required this.onDelete,
  });

  final PackingItem item;
  final ValueChanged<bool> onToggle;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: CheckboxListTile(
        value: item.checked,
        onChanged: (v) => onToggle(v ?? false),
        title: Text(
          item.title,
          style: TextStyle(
            decoration: item.checked ? TextDecoration.lineThrough : null,
          ),
        ),
        secondary: onDelete == null
            ? const Icon(Icons.checklist_rounded)
            : IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed: onDelete,
              ),
      ),
    );
  }
}
