import 'package:flutter/material.dart';

import '../ui/ui.dart';
import 'quick_actions_config.dart';

/// Shows the categorised Quick Actions sheet.
/// Returns the chosen route name, or `null` if dismissed.
Future<String?> showQuickActionsSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _QuickActionsSheet(),
  );
}

class _QuickActionsSheet extends StatefulWidget {
  const _QuickActionsSheet();

  @override
  State<_QuickActionsSheet> createState() => _QuickActionsSheetState();
}

class _QuickActionsSheetState extends State<_QuickActionsSheet> {
  String _query = '';

  List<QuickActionItem> get _filtered {
    if (_query.isEmpty) return kQuickActions;
    final q = _query.toLowerCase();
    return kQuickActions
        .where(
          (a) =>
              a.title.toLowerCase().contains(q) ||
              (a.subtitle?.toLowerCase().contains(q) ?? false),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final grouped = <QuickActionCategory, List<QuickActionItem>>{};
    for (final item in _filtered) {
      grouped.putIfAbsent(item.category, () => <QuickActionItem>[]).add(item);
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              _handle(),
              _title(context),
              _searchField(),
              const SizedBox(height: AppSpacing.xs),
              Expanded(child: _list(context, grouped, scrollController)),
            ],
          ),
        );
      },
    );
  }

  Widget _handle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12, bottom: 6),
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.grey400,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _title(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Text(
            '⚡ Schnellzugriff',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.all(AppSpacing.xs),
              child: Icon(
                Icons.close_rounded,
                size: 22,
                color: AppColors.grey600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: TextField(
        onChanged: (v) => setState(() => _query = v),
        decoration: InputDecoration(
          hintText: 'Suchen…',
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          filled: true,
          fillColor: AppColors.grey100,
          contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _list(
    BuildContext context,
    Map<QuickActionCategory, List<QuickActionItem>> grouped,
    ScrollController controller,
  ) {
    return ListView(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.huge,
      ),
      children: [
        for (final cat in QuickActionCategory.values)
          if (grouped.containsKey(cat)) ...[
            Padding(
              padding: const EdgeInsets.only(
                top: AppSpacing.lg,
                bottom: AppSpacing.sm,
                left: AppSpacing.xs,
              ),
              child: Text(
                categoryLabel(cat),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.grey600,
                ),
              ),
            ),
            for (final item in grouped[cat]!)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: GlassListTile(
                  leading: Text(
                    item.emoji,
                    style: const TextStyle(fontSize: 22),
                  ),
                  title: Text(item.title),
                  subtitle: item.subtitle != null ? Text(item.subtitle!) : null,
                  onTap: () => Navigator.of(context).pop(item.routeName),
                ),
              ),
          ],
      ],
    );
  }
}
