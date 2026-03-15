import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../main.dart';
import '../../../ui/ui.dart';
import '../data/packing_list_repository_sync.dart';
import '../domain/packing_item.dart';
import '../domain/packing_list.dart';
import '../../pro/domain/trigger_context.dart';
import '../../pro/presentation/smart_paywall.dart';
import 'packing_item_editor_sheet.dart';
import 'packing_share_sheet.dart';
import '../../../ui/theme/app_icons.dart';

/// Detail screen for a single packing list with category grouping,
/// animated checkboxes, swipe actions, and collaboration indicators.
class PackingDetailScreen extends StatefulWidget {
  const PackingDetailScreen({super.key, required this.listId});

  final String listId;

  @override
  State<PackingDetailScreen> createState() => _PackingDetailScreenState();
}

class _PackingDetailScreenState extends State<PackingDetailScreen> {
  static final _repo = PackingListRepositorySync.instance;

  bool _isPro(BuildContext context) {
    final pro = ProServices.maybeOf(context);
    return pro?.entitlementService.isPro ?? false;
  }

  // ── Actions ────────────────────────────────────────────────

  Future<void> _addItem(PackingList list) async {
    final result = await showModalBottomSheet<PackingItemEditorResult>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const PackingItemEditorSheet(),
    );
    if (result == null) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final now = DateTime.now();

    final item = PackingItem(
      id: 'packing_${now.microsecondsSinceEpoch}',
      ownerId: uid,
      title: result.title,
      category: result.category,
      checked: false,
      createdAt: now,
      updatedAt: now,
      isDefault: false,
      isRequired: result.isRequired,
      listId: widget.listId,
      quantity: result.quantity,
      note: result.note,
      priority: result.priority,
    );
    try {
      await _repo.upsertItem(item);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFacingError(e))),
      );
    }
  }

  Future<void> _editItem(PackingItem item) async {
    final result = await showModalBottomSheet<PackingItemEditorResult>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => PackingItemEditorSheet(
        initialTitle: item.title,
        initialCategory: item.category,
        initialRequired: item.isRequired,
        initialQuantity: item.quantity,
        initialNote: item.note,
        initialPriority: item.priority,
      ),
    );
    if (result == null) return;

    try {
      await _repo.upsertItem(
        item.copyWith(
          title: result.title,
          category: result.category,
          isRequired: result.isRequired,
          quantity: result.quantity,
          note: result.note,
          priority: result.priority,
          updatedAt: DateTime.now(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFacingError(e))),
      );
    }
  }

  Future<void> _deleteItem(PackingItem item) async {
    final listId = item.listId;
    if (listId == null) return;
    try {
      await _repo.deleteItem(listId, item.id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFacingError(e))),
      );
    }
  }

  Future<void> _toggleItem(PackingItem item, bool value) async {
    Haptic.light();
    try {
      await _repo.toggleItem(widget.listId, item, value);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFacingError(e))),
      );
    }
  }

  Future<void> _showShareSheet(PackingList list) async {
    final isPro = _isPro(context);
    if (!isPro) {
      final shown = await SmartPaywall.trigger(
        context: context,
        triggerContext: TriggerContext.packingCollaboration,
      );
      if (shown) return;
    }
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => PackingShareSheet(list: list),
    );
  }

  // ── Build ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PackingList>>(
      stream: _repo.watchLists(),
      builder: (context, listSnap) {
        final lists = listSnap.data ?? const <PackingList>[];
        final list = lists.cast<PackingList?>().firstWhere(
              (l) => l?.id == widget.listId,
              orElse: () => null,
            );

        if (list == null) {
          return GlassPage(
            title: 'Packliste',
            titleIcon: AppIcons.packing,
            children: [
              const SizedBox(height: 100),
              Center(
                child: Text(
                  'Liste nicht gefunden.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ),
            ],
          );
        }

        return StreamBuilder<List<PackingItem>>(
          stream: _repo.watchItems(widget.listId),
          builder: (context, itemSnap) {
            final items = itemSnap.data ?? const <PackingItem>[];
            return _buildContent(context, list, items);
          },
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    PackingList list,
    List<PackingItem> items,
  ) {
    final grouped = _groupByCategory(items);
    final percent = (list.progress * 100).round();
    final allDone = list.progress >= 1.0 && list.itemCount > 0;

    return GlassPage(
      title: list.title,
      titleIcon: list.type.icon,
      titleColor: allDone ? AppColors.success : AppColors.warning,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.people_outline_rounded, size: 22),
            tooltip: 'Teilen',
            onPressed: () => _showShareSheet(list),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addItem(list),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Item hinzufügen'),
      ),
      scrollableBody: (headerHeight) {
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GlassIcon(icon: list.type.icon, color: list.type.iconColor, size: 48),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Noch keine Items',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: AppSpacing.lg),
                GlassButton(
                  onPressed: () => _addItem(list),
                  label: 'Erstes Item hinzufügen',
                  icon: Icons.add_rounded,
                ),
              ],
            ),
          );
        }

        return ListView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: EdgeInsets.only(
            top: headerHeight + AppSpacing.md,
            bottom: 120,
            left: AppSpacing.xl,
            right: AppSpacing.xl,
          ),
          children: [
            // ── Progress header ──────────────────────────────
            FadeSlideIn(
              child: _DetailProgressHeader(
                list: list,
                percent: percent,
                allDone: allDone,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // ── Category sections ────────────────────────────
            for (var catIndex = 0;
                catIndex < PackingCategory.values.length;
                catIndex++)
              if ((grouped[PackingCategory.values[catIndex]] ??
                      const <PackingItem>[])
                  .isNotEmpty)
                _CategorySection(
                  category: PackingCategory.values[catIndex],
                  items: grouped[PackingCategory.values[catIndex]]!,
                  staggerIndex: catIndex,
                  onToggle: _toggleItem,
                  onEdit: _editItem,
                  onDelete: _deleteItem,
                  isPro: _isPro(context),
                ),
          ],
        );
      },
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
}

// ─────────────────────────────────────────────────────────────────
// ── Detail progress header ──────────────────────────────────────
// ─────────────────────────────────────────────────────────────────

class _DetailProgressHeader extends StatelessWidget {
  const _DetailProgressHeader({
    required this.list,
    required this.percent,
    required this.allDone,
  });

  final PackingList list;
  final int percent;
  final bool allDone;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppRadius.borderRadiusLg,
      elevation: GlassElevation.low,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      allDone
                          ? 'Alles gepackt!'
                          : '${list.checkedCount} von ${list.itemCount} gepackt',
                      style:
                          Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      list.type.label,
                      style:
                          Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                    ),
                  ],
                ),
              ),
              Text(
                '$percent%',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: allDone ? AppColors.success : AppColors.primary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          GlassProgressBar(
            value: list.progress,
            height: 8,
            gradient: allDone
                ? const LinearGradient(
                    colors: [Color(0xFF34C759), Color(0xFF00C853)],
                  )
                : null,
          ),
          // Shared members row
          if (list.isShared) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Icon(
                  Icons.people_rounded,
                  size: 16,
                  color: AppColors.accent.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${list.members.length} Personen packen gemeinsam',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// ── Category section ────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.category,
    required this.items,
    required this.staggerIndex,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    required this.isPro,
  });

  final PackingCategory category;
  final List<PackingItem> items;
  final int staggerIndex;
  final void Function(PackingItem item, bool value) onToggle;
  final void Function(PackingItem item) onEdit;
  final void Function(PackingItem item) onDelete;
  final bool isPro;

  @override
  Widget build(BuildContext context) {
    final done = items.where((i) => i.checked).length;
    final total = items.length;
    final allDone = done == total && total > 0;

    return FadeSlideIn(
      delay: Duration(milliseconds: 80 * staggerIndex),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category header
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.xs,
              bottom: AppSpacing.sm,
              top: AppSpacing.md,
            ),
            child: Row(
              children: [
                GlassIcon(icon: category.icon, color: category.iconColor, size: 18),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    category.label,
                    style:
                        Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: allDone
                        ? AppColors.success.withValues(alpha: 0.10)
                        : AppColors.grey200.withValues(alpha: 0.5),
                    borderRadius: AppRadius.borderRadiusSm,
                  ),
                  child: Text(
                    '$done/$total',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: allDone
                              ? AppColors.success
                              : AppColors.textSecondary,
                        ),
                  ),
                ),
              ],
            ),
          ),

          // Items in glass container
          GlassContainer(
            padding: EdgeInsets.zero,
            borderRadius: AppRadius.borderRadiusMd,
            variant: GlassVariant.thin,
            elevation: GlassElevation.flat,
            child: Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  _PackingItemTile(
                    item: items[i],
                    onToggle: (value) => onToggle(items[i], value),
                    onEdit: () => onEdit(items[i]),
                    onDelete:
                        items[i].isDefault ? null : () => onDelete(items[i]),
                    isPro: isPro,
                  ),
                  if (i < items.length - 1)
                    Divider(
                      height: 0.5,
                      thickness: 0.5,
                      indent: 56,
                      color: AppColors.grey200.withValues(alpha: 0.5),
                    ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// ── Packing item tile ───────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────

class _PackingItemTile extends StatelessWidget {
  const _PackingItemTile({
    required this.item,
    required this.onToggle,
    required this.onEdit,
    this.onDelete,
    required this.isPro,
  });

  final PackingItem item;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;
  final bool isPro;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: onDelete != null
          ? DismissDirection.endToStart
          : DismissDirection.none,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.12),
          borderRadius: AppRadius.borderRadiusMd,
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: AppColors.error,
        ),
      ),
      confirmDismiss: (_) async {
        onDelete?.call();
        return false; // Let the stream rebuild handle removal.
      },
      child: PressableScale(
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              AnimatedCheckbox(
                value: item.checked,
                onChanged: onToggle,
                activeColor:
                    item.priority == PackingPriority.critical
                        ? AppColors.error
                        : AppColors.success,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (item.isRequired || item.priority != PackingPriority.normal)
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: item.priority.icon != null
                                ? GlassIcon(
                                    icon: item.priority.icon!,
                                    color: item.priority.iconColor,
                                    size: 16,
                                  )
                                : const SizedBox.shrink(),
                          ),
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              decoration: item.checked
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: item.checked
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    // Subtitle: quantity, note, packed-by
                    if (item.quantity > 1 ||
                        item.note != null ||
                        item.packedByUid != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          if (item.quantity > 1)
                            _SubtitleChip(
                              label: '×${item.quantity}',
                              color: AppColors.primary,
                            ),
                          if (item.note != null && item.note!.isNotEmpty) ...[
                            if (item.quantity > 1)
                              const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                item.note!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                          if (item.packedByUid != null && isPro) ...[
                            const Spacer(),
                            Icon(
                              Icons.person_rounded,
                              size: 12,
                              color: AppColors.accent.withValues(alpha: 0.6),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.textSecondary.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubtitleChip extends StatelessWidget {
  const _SubtitleChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: AppRadius.borderRadiusXs,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
