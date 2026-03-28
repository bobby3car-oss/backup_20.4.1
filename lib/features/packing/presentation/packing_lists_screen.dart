import 'package:flutter/material.dart';

import '../../../main.dart';
import '../../../ui/ui.dart';
import '../data/packing_list_repository_sync.dart';
import '../domain/packing_list.dart';
import '../../pro/domain/trigger_context.dart';
import '../../pro/presentation/smart_paywall.dart';
import 'packing_detail_screen.dart';
import 'packing_template_sheet.dart';
import '../../../ui/theme/app_icons.dart';
import '../../../l10n/app_localizations.dart';

/// Overview screen showing all packing lists with progress and status.
class PackingListsScreen extends StatefulWidget {
  const PackingListsScreen({super.key});

  @override
  State<PackingListsScreen> createState() => _PackingListsScreenState();
}

class _PackingListsScreenState extends State<PackingListsScreen> {
  static final _repo = PackingListRepositorySync.instance;
  bool _bootstrapped = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _repo.bootstrap();
    if (mounted) setState(() => _bootstrapped = true);
  }

  bool _isPro(BuildContext context) {
    final pro = ProServices.maybeOf(context);
    return pro?.entitlementService.isPro ?? false;
  }

  // ── Create new list ──────────────────────────────────────────

  Future<void> _createNewList() async {
    if (!mounted) return;
    final result = await showModalBottomSheet<PackingTemplateResult>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const PackingTemplateSheet(),
    );
    if (result == null) return;

    try {
      await _repo.createListWithDefaults(
        title: result.title,
        type: result.type,
        mode: result.mode,
        icon: result.icon,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFacingError(e))),
      );
    }
  }

  // ── Rename list ─────────────────────────────────────────────

  Future<void> _renameList(PackingList list) async {
    final l = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: list.title);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.packingListRename),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: l.neuerName,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) Navigator.of(ctx).pop(text);
            },
            child: Text(l.save),
          ),
        ],
      ),
    );
    controller.dispose();
    if (newName == null || newName == list.title) return;
    try {
      await _repo.upsertList(list.copyWith(title: newName));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFacingError(e))),
      );
    }
  }

  // ── Delete list ──────────────────────────────────────────────

  Future<void> _confirmDeleteList(PackingList list) async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.packingListDelete),
        content: Text(
          '„${list.title}" wird unwiderruflich gelöscht.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _repo.deleteList(list.id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFacingError(e))),
      );
    }
  }

  // ── Build ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return GlassPage(
      title: 'Packlisten',
      titleIcon: AppIcons.packing,
      titleColor: AppColors.warning,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewList,
        icon: const Icon(Icons.add_rounded),
        label: Text(l.packingListNew),
      ),
      scrollableBody: (headerHeight) {
        if (!_bootstrapped) {
          return const Center(child: CircularProgressIndicator());
        }
        return StreamBuilder<List<PackingList>>(
          stream: _repo.watchLists(),
          builder: (context, snapshot) {
            final lists = (snapshot.data ?? const <PackingList>[])
                .where((l) => !l.isArchived)
                .toList()
              ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

            if (lists.isEmpty) {
              return _EmptyState(onCreateFirst: _createNewList);
            }

            // Compute aggregate progress.
            final totalItems =
                lists.fold<int>(0, (sum, l) => sum + l.itemCount);
            final totalChecked =
                lists.fold<int>(0, (sum, l) => sum + l.checkedCount);
            final overallProgress =
                totalItems == 0 ? 0.0 : totalChecked / totalItems;

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
                // ── Hero progress card ──────────────────────
                FadeSlideIn(
                  child: _HeroProgressCard(
                    totalItems: totalItems,
                    totalChecked: totalChecked,
                    progress: overallProgress,
                    listCount: lists.length,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                // ── Section title ───────────────────────────
                Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.xs),
                  child: Text(
                    'Deine Listen',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // ── List cards ──────────────────────────────
                for (var i = 0; i < lists.length; i++) ...[
                  FadeSlideIn(
                    delay: Duration(milliseconds: 60 * (i + 1)),
                    child: _PackingListCard(
                      list: lists[i],
                      onTap: () => _openDetail(lists[i]),
                      onDelete: () => _confirmDeleteList(lists[i]),
                      onArchive: () => _repo.archiveList(lists[i].id),
                      onRename: () => _renameList(lists[i]),
                    ),
                  ),
                  if (i < lists.length - 1)
                    const SizedBox(height: AppSpacing.md),
                ],

                // ── Pro upsell if free ──────────────────────
                if (!_isPro(context)) ...[
                  const SizedBox(height: AppSpacing.xxl),
                  FadeSlideIn(
                    delay: Duration(
                        milliseconds: 60 * (lists.length + 1)),
                    child: const _ProUpsellCard(),
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }

  void _openDetail(PackingList list) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PackingDetailScreen(listId: list.id),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// ── Hero progress card ──────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────

class _HeroProgressCard extends StatelessWidget {
  const _HeroProgressCard({
    required this.totalItems,
    required this.totalChecked,
    required this.progress,
    required this.listCount,
  });

  final int totalItems;
  final int totalChecked;
  final double progress;
  final int listCount;

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).round();
    final allDone = progress >= 1.0 && totalItems > 0;

    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.xl),
      borderRadius: AppRadius.borderRadiusXl,
      variant: GlassVariant.thick,
      elevation: GlassElevation.medium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: allDone
                        ? [AppColors.success, const Color(0xFF00C853)]
                        : [AppColors.warning, const Color(0xFFFF6D00)],
                  ),
                  borderRadius: AppRadius.borderRadiusLg,
                  boxShadow: [
                    BoxShadow(
                      color: (allDone ? AppColors.success : AppColors.warning)
                          .withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    allDone ? '✅' : '🧳',
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      allDone ? 'Alles gepackt!' : 'Pack-Fortschritt',
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                              ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$totalChecked von $totalItems Items · $listCount ${listCount == 1 ? 'Liste' : 'Listen'}',
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
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: allDone ? AppColors.success : AppColors.primary,
                      letterSpacing: -0.5,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          GlassProgressBar(
            value: progress,
            height: 10,
            gradient: allDone
                ? const LinearGradient(
                    colors: [Color(0xFF34C759), Color(0xFF00C853)],
                  )
                : null,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// ── Packing list card ───────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────

class _PackingListCard extends StatelessWidget {
  const _PackingListCard({
    required this.list,
    required this.onTap,
    this.onDelete,
    this.onArchive,
    this.onRename,
  });

  final PackingList list;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onArchive;
  final VoidCallback? onRename;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final percent = (list.progress * 100).round();
    final allDone = list.progress >= 1.0 && list.itemCount > 0;

    return PressableScale(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.all(AppSpacing.lg),
        borderRadius: AppRadius.borderRadiusLg,
        elevation: GlassElevation.low,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Emoji badge
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: allDone
                        ? AppColors.success.withValues(alpha: 0.12)
                        : AppColors.primary.withValues(alpha: 0.10),
                    borderRadius: AppRadius.borderRadiusMd,
                  ),
                  child: Center(
                    child: GlassIcon(
                      icon: list.type.icon,
                      color: list.type.iconColor,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        list.title,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${list.checkedCount}/${list.itemCount} · ${list.type.label}',
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                      ),
                    ],
                  ),
                ),
                // Shared indicator
                if (list.isShared) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.10),
                      borderRadius: AppRadius.borderRadiusSm,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.people_rounded,
                          size: 14,
                          color: AppColors.accent.withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${list.members.length}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accent.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Text(
                  '$percent%',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color:
                            allDone ? AppColors.success : AppColors.primary,
                      ),
                ),
                // Context menu
                if (onDelete != null || onArchive != null || onRename != null) ...[
                  const SizedBox(width: 4),
                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    iconSize: 20,
                    icon: Icon(
                      Icons.more_vert_rounded,
                      color: AppColors.textSecondary.withValues(alpha: 0.6),
                    ),
                    onSelected: (value) {
                      if (value == 'rename') onRename?.call();
                      if (value == 'delete') onDelete?.call();
                      if (value == 'archive') onArchive?.call();
                    },
                    itemBuilder: (_) => [
                      if (onRename != null)
                        PopupMenuItem(
                          value: 'rename',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 18),
                              SizedBox(width: 8),
                              Text(l.rename),
                            ],
                          ),
                        ),
                      if (onArchive != null)
                        PopupMenuItem(
                          value: 'archive',
                          child: Row(
                            children: [
                              Icon(Icons.archive_outlined, size: 18),
                              SizedBox(width: 8),
                              Text(l.archive),
                            ],
                          ),
                        ),
                      if (onDelete != null)
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline_rounded,
                                  size: 18, color: AppColors.error),
                              SizedBox(width: 8),
                              Text(l.delete,
                                  style: TextStyle(color: AppColors.error)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            GlassProgressBar(
              value: list.progress,
              height: 6,
              gradient: allDone
                  ? const LinearGradient(
                      colors: [Color(0xFF34C759), Color(0xFF00C853)],
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// ── Empty state ─────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreateFirst});

  final VoidCallback onCreateFirst;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GlassIcon(icon: AppIcons.packing, color: AppIcons.packingColor, size: 39),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Noch keine Packliste',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Erstelle deine erste Packliste, damit du nichts vergisst.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            GlassButton(
              onPressed: onCreateFirst,
              label: l.ersteListeErstellen,
              icon: Icons.add_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// ── Pro upsell card ─────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────

class _ProUpsellCard extends StatelessWidget {
  const _ProUpsellCard();

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: () {
        SmartPaywall.trigger(
          context: context,
          triggerContext: TriggerContext.packingCollaboration,
        );
      },
      child: GlassContainer(
        padding: const EdgeInsets.all(AppSpacing.lg),
        borderRadius: AppRadius.borderRadiusLg,
        variant: GlassVariant.medium,
        elevation: GlassElevation.low,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5856D6), Color(0xFF007AFF)],
                ),
                borderRadius: AppRadius.borderRadiusMd,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.workspace_premium_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gemeinsam packen',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Teile Listen mit Angehörigen & packt zusammen',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
