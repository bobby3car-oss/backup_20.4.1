import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../features/ads/data/ad_config.dart';
import '../../../features/ads/presentation/ad_banner_widget.dart';
import '../../../features/ads/presentation/ad_slot_helper.dart';
import '../../../ui/ui.dart';
import '../data/packing_repository_sync.dart';
import '../domain/packing_item.dart';
import '../../../ui/theme/app_icons.dart';

class PackingListScreen extends StatefulWidget {
  const PackingListScreen({super.key});

  @override
  State<PackingListScreen> createState() => _PackingListScreenState();
}

class _PackingListScreenState extends State<PackingListScreen> {
  static final PackingRepositorySync _repository =
      PackingRepositorySync.instance;

  HospitalMode? _mode;
  bool _bootstrapped = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _repository.loadFromDisk();
    final mode = await _repository.getMode();
    if (mode != null) {
      _mode = mode;
      await _repository.seedDefaultsIfEmpty(mode);
      await _repository.pullLatest();
      if (mounted) setState(() => _bootstrapped = true);
    } else {
      // No mode chosen yet → show onboarding after first frame.
      if (mounted) {
        setState(() => _bootstrapped = true);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _showModeDialog();
        });
      }
    }
  }

  // ── Mode selection dialog ──────────────────────────────────

  Future<void> _showModeDialog() async {
    final selected = await showDialog<HospitalMode>(
      context: context,
      barrierDismissible: _mode != null,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Art des Aufenthalts'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Deine Packliste wird automatisch an deinen '
                'Aufenthalt angepasst.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
              _ModeCard(
                mode: HospitalMode.ambulant,
                subtitle: 'Kein Übernachten – nur das Nötigste',
                onTap: () =>
                    Navigator.of(dialogContext).pop(HospitalMode.ambulant),
              ),
              const SizedBox(height: 12),
              _ModeCard(
                mode: HospitalMode.stationary,
                subtitle: 'Mit Übernachtung – vollständige Liste',
                onTap: () =>
                    Navigator.of(dialogContext).pop(HospitalMode.stationary),
              ),
            ],
          ),
        );
      },
    );
    if (selected == null || !mounted) return;
    await _repository.setMode(selected);
    if (!mounted) return;
    setState(() => _mode = selected);
    await _repository.seedDefaultsIfEmpty(selected);
    await _repository.pullLatest();
  }

  // ── Reset ──────────────────────────────────────────────────

  Future<void> _showResetDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Packliste zurücksetzen?'),
          content: const Text(
            'Alle Einträge werden gelöscht und die Standard-Items '
            'werden erneut angelegt. Diese Aktion kann nicht '
            'rückgängig gemacht werden.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Abbrechen'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              child: const Text('Zurücksetzen'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;
    await _repository.clearMode();
    if (!mounted) return;
    setState(() => _mode = null);
    // Show mode selector again → triggers re-seed
    await _showModeDialog();
  }

  // ── Build ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GlassPage(
      title: 'Packliste',
      titleIcon: AppIcons.packing,
      titleColor: AppColors.warning,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_mode != null)
            ActionChip(
              avatar: GlassIcon(icon: _mode!.icon, color: _mode!.iconColor, size: 14),
              label: Text(_mode!.label),
              onPressed: _showModeDialog,
              visualDensity: VisualDensity.compact,
            ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.restart_alt_rounded),
            tooltip: 'Zurücksetzen',
            onPressed: _showResetDialog,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('Item hinzufügen'),
      ),
      scrollableBody: (headerHeight) => StreamBuilder<List<PackingItem>>(
        stream: _repository.watchAll(),
        builder: (context, snapshot) {
          final items = snapshot.data ?? const <PackingItem>[];
          if (!_bootstrapped) {
            return const Center(child: CircularProgressIndicator());
          }
          if (items.isEmpty) {
            return const Center(
              child: Text('Keine Packlisten-Einträge vorhanden.'),
            );
          }

          final totalCount = items.length;
          final checkedCount = items.where((i) => i.checked).length;
          final progress = totalCount == 0 ? 0.0 : checkedCount / totalCount;

          final grouped = _groupByCategory(items);
          final visibleCategories = PackingCategory.values
              .where((category) =>
                  (grouped[category] ?? const <PackingItem>[]).isNotEmpty)
              .toList(growable: false);

          return ValueListenableBuilder<AdConfig>(
            valueListenable: AdServiceScope.of(context).config,
            builder: (context, adConfig, _) {
              final adFrequency = normalizeAdFrequency(adConfig.adFrequency);

              return ListView(
                padding: EdgeInsets.only(top: headerHeight + 8, bottom: 100),
                children: [
                  // ── Progress bar ─────────────────────────────────
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '$checkedCount von $totalCount gepackt',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                            Text(
                              '${(progress * 100).round()} %',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: progress >= 1.0
                                        ? AppColors.success
                                        : AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            backgroundColor: AppColors.grey200,
                            color: progress >= 1.0
                                ? AppColors.success
                                : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Grouped items ────────────────────────────────
                  for (final (catIndex, category) in visibleCategories.indexed) ...[
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
                        onEdit: () => _showEditDialog(item),
                        onDelete: item.isDefault ? null : () => _delete(item),
                      ),
                    if (shouldInsertAdAfterRealItem(
                      catIndex,
                      visibleCategories.length,
                      adFrequency,
                    ))
                      const AdBannerWidget(),
                  ],
                ],
              );
            },
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

  // ── Add dialog ─────────────────────────────────────────────

  Future<void> _showAddDialog() async {
    final result = await _showItemDialog(title: 'Neues Packlisten-Item');
    if (result == null) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.trim().isEmpty) return;
    final now = DateTime.now();
    await _repository.upsert(
      PackingItem(
        id: 'packing_${now.microsecondsSinceEpoch}',
        ownerId: uid,
        title: result.title,
        category: result.category,
        checked: false,
        createdAt: now,
        updatedAt: now,
        isDefault: false,
        isRequired: result.isRequired,
      ),
    );
  }

  // ── Edit dialog ────────────────────────────────────────────

  Future<void> _showEditDialog(PackingItem item) async {
    final result = await _showItemDialog(
      title: 'Item bearbeiten',
      initialTitle: item.title,
      initialCategory: item.category,
      initialRequired: item.isRequired,
    );
    if (result == null) return;
    await _repository.upsert(
      item.copyWith(
        title: result.title,
        category: result.category,
        isRequired: result.isRequired,
        updatedAt: DateTime.now(),
      ),
    );
  }

  // ── Shared item dialog ─────────────────────────────────────

  Future<_ItemDialogResult?> _showItemDialog({
    required String title,
    String? initialTitle,
    PackingCategory? initialCategory,
    bool? initialRequired,
  }) async {
    final titleController = TextEditingController(text: initialTitle ?? '');
    var selectedCategory = initialCategory ?? PackingCategory.other;
    var isRequired = initialRequired ?? false;

    final result = await showDialog<_ItemDialogResult>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(title),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Titel'),
                    autofocus: initialTitle == null,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<PackingCategory>(
                    initialValue: selectedCategory,
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
                      setDialogState(() => selectedCategory = value);
                    },
                    decoration: const InputDecoration(labelText: 'Kategorie'),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('Pflichtitem'),
                    subtitle:
                        const Text('Darf auf keinen Fall vergessen werden'),
                    value: isRequired,
                    onChanged: (v) => setDialogState(() => isRequired = v),
                    contentPadding: EdgeInsets.zero,
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
                    final text = titleController.text.trim();
                    if (text.isEmpty) return;
                    Navigator.of(dialogContext).pop(
                      _ItemDialogResult(
                        title: text,
                        category: selectedCategory,
                        isRequired: isRequired,
                      ),
                    );
                  },
                  child: Text(initialTitle != null ? 'Speichern' : 'Hinzufügen'),
                ),
              ],
            );
          },
        );
      },
    );
    titleController.dispose();
    return result;
  }
}

// ── Helper record for dialog result ────────────────────────────

class _ItemDialogResult {
  const _ItemDialogResult({
    required this.title,
    required this.category,
    required this.isRequired,
  });

  final String title;
  final PackingCategory category;
  final bool isRequired;
}

// ── Mode card ──────────────────────────────────────────────────

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.mode,
    required this.subtitle,
    required this.onTap,
  });

  final HospitalMode mode;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              GlassIcon(icon: mode.icon, color: mode.iconColor, size: 28),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mode.label,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Category header ────────────────────────────────────────────

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
          GlassIcon(icon: category.icon, color: category.iconColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              category.label,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          Text(
            '$done/$total',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: done == total && total > 0
                      ? AppColors.success
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

// ── Packing tile ───────────────────────────────────────────────

class _PackingTile extends StatelessWidget {
  const _PackingTile({
    required this.item,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final PackingItem item;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: CheckboxListTile(
        value: item.checked,
        onChanged: (v) => onToggle(v ?? false),
        title: Row(
          children: [
            if (item.isRequired)
              const Padding(
                padding: EdgeInsets.only(right: 6),
                child: Icon(
                  Icons.priority_high_rounded,
                  color: AppColors.error,
                  size: 18,
                ),
              ),
            Expanded(
              child: Text(
                item.title,
                style: TextStyle(
                  decoration:
                      item.checked ? TextDecoration.lineThrough : null,
                  color: item.checked ? AppColors.textSecondary : null,
                ),
              ),
            ),
          ],
        ),
        secondary: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              tooltip: 'Bearbeiten',
              onPressed: onEdit,
              visualDensity: VisualDensity.compact,
            ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                tooltip: 'Löschen',
                onPressed: onDelete,
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
      ),
    );
  }
}
