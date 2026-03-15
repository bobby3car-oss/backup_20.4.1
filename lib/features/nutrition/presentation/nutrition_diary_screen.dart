import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../ui/ui.dart';
import '../data/nutrition_repository_sync.dart';
import '../domain/nutrition_entry.dart';
import 'nutrition_entry_editor_screen.dart';
import '../../../ui/theme/app_icons.dart';

/// Full nutrition diary with grouped-by-date entries, daily totals,
/// meal-type filter, and FAB for new entries.
class NutritionDiaryScreen extends StatefulWidget {
  const NutritionDiaryScreen({super.key});

  @override
  State<NutritionDiaryScreen> createState() => _NutritionDiaryScreenState();
}

class _NutritionDiaryScreenState extends State<NutritionDiaryScreen> {
  static final NutritionRepositorySync _repository =
      NutritionRepositorySync.instance;

  MealType? _filter;

  @override
  Widget build(BuildContext context) {
    return GlassPage(
      title: 'Ernährungstagebuch',
      titleIcon: AppIcons.diary,
      titleColor: const Color(0xFF34C759),
      horizontalPadding: AppSpacing.lg,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF34C759),
        foregroundColor: Colors.white,
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const NutritionEntryEditorScreen(),
          ),
        ),
        child: const Icon(Icons.add_rounded),
      ),
      children: [
        const SizedBox(height: AppSpacing.md),

        // ── Filter chips ──
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _FilterChip(
                label: 'Alle',
                selected: _filter == null,
                onTap: () => setState(() => _filter = null),
              ),
              const SizedBox(width: 8),
              ...MealType.values.map((type) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _FilterChip(
                      label: type.label,
                      selected: _filter == type,
                      onTap: () => setState(() => _filter = type),
                    ),
                  )),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // ── Entry list ──
        StreamBuilder<List<NutritionEntry>>(
          stream: _repository.watchAll(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            var items = snapshot.data!;
            if (_filter != null) {
              items = items
                  .where((e) => e.mealType == _filter)
                  .toList();
            }

            if (items.isEmpty) {
              return _buildEmptyState();
            }

            // Group by date.
            final grouped = <String, List<NutritionEntry>>{};
            for (final e in items) {
              final key = _dateKey(e.occurredAt);
              (grouped[key] ??= []).add(e);
            }

            final sortedKeys = grouped.keys.toList()
              ..sort((a, b) => b.compareTo(a));

            return Column(
              children: [
                for (final key in sortedKeys) ...[
                  _DayHeader(
                    dateKey: key,
                    entries: grouped[key]!,
                  ),
                  ...grouped[key]!.map((entry) => _EntryTile(
                        entry: entry,
                        onTap: () => _openEditor(entry),
                        onDismissed: () => _delete(entry),
                      )),
                  const SizedBox(height: AppSpacing.md),
                ],
                const SizedBox(height: 80), // FAB clearance
              ],
            );
          },
        ),
      ],
    );
  }

  void _openEditor(NutritionEntry entry) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            NutritionEntryEditorScreen(initialEntry: entry),
      ),
    );
  }

  Future<void> _delete(NutritionEntry entry) async {
    try {
      await _repository.delete(entry.id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFacingError(e))),
      );
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Eintrag gelöscht'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Column(
        children: [
          GlassIcon(icon: AppIcons.nutrition, color: AppIcons.nutritionColor, size: 33),
          const SizedBox(height: 16),
          Text(
            _filter != null
                ? 'Keine ${_filter!.label}-Einträge'
                : 'Noch keine Einträge',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1C1C1E),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tippe auf + um deine erste Mahlzeit zu erfassen.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF8E8E93)),
          ),
        ],
      ),
    );
  }

  String _dateKey(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }
}

// ── Day header with daily totals ────────────────────────────────────────────

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.dateKey, required this.entries});
  final String dateKey;
  final List<NutritionEntry> entries;

  @override
  Widget build(BuildContext context) {
    final totalCals = entries
        .where((e) => e.calories != null)
        .fold<int>(0, (s, e) => s + e.calories!);
    final totalProtein = entries
        .where((e) => e.protein != null)
        .fold<int>(0, (s, e) => s + e.protein!);
    final totalWater = entries
        .where((e) => e.waterMl != null)
        .fold<int>(0, (s, e) => s + e.waterMl!);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _formatDate(dateKey),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1C1C1E),
              ),
            ),
          ),
          if (totalCals > 0)
            _MiniStat(label: '$totalCals kcal'),
          if (totalProtein > 0)
            _MiniStat(label: '🥩 ${totalProtein}g'),
          if (totalWater > 0)
            _MiniStat(label: '${totalWater}ml'),
        ],
      ),
    );
  }

  String _formatDate(String key) {
    final now = DateTime.now();
    final parts = key.split('-');
    if (parts.length != 3) return key;
    final y = int.parse(parts[0]);
    final m = int.parse(parts[1]);
    final d = int.parse(parts[2]);
    if (y == now.year && m == now.month && d == now.day) return 'Heute';
    final yesterday = now.subtract(const Duration(days: 1));
    if (y == yesterday.year &&
        m == yesterday.month &&
        d == yesterday.day) {
      return 'Gestern';
    }
    const months = [
      '',
      'Jan',
      'Feb',
      'Mär',
      'Apr',
      'Mai',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Okt',
      'Nov',
      'Dez',
    ];
    return '$d. ${months[m]} $y';
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF636366)),
        ),
      ),
    );
  }
}

// ── Entry tile ──────────────────────────────────────────────────────────────

class _EntryTile extends StatelessWidget {
  const _EntryTile({
    required this.entry,
    required this.onTap,
    required this.onDismissed,
  });
  final NutritionEntry entry;
  final VoidCallback onTap;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: ValueKey(entry.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFFF3B30),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.delete_rounded,
              color: Colors.white, size: 22),
        ),
        confirmDismiss: (_) async {
          HapticFeedback.mediumImpact();
          return true;
        },
        onDismissed: (_) => onDismissed(),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                GlassIcon(icon: entry.mealType.icon, color: entry.mealType.iconColor, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.description.isNotEmpty
                            ? entry.description
                            : entry.mealType.label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1C1C1E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _subtitle(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8E8E93),
                        ),
                      ),
                    ],
                  ),
                ),
                if (entry.tolerability != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      _tolerabilityEmoji(entry.tolerability!),
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                if (entry.symptoms.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF3B30)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${entry.symptoms.length}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFF3B30),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded,
                    size: 18, color: Color(0xFFC7C7CC)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _subtitle() {
    final parts = <String>[];
    final hh = entry.occurredAt.hour.toString().padLeft(2, '0');
    final mm = entry.occurredAt.minute.toString().padLeft(2, '0');
    parts.add('$hh:$mm');
    if (entry.calories != null) parts.add('${entry.calories} kcal');
    if (entry.waterMl != null) parts.add('${entry.waterMl} ml');
    return parts.join(' · ');
  }

  String _tolerabilityEmoji(int level) {
    const emojis = ['😫', '😣', '😐', '🙂', '😊'];
    if (level < 1 || level > 5) return '❓';
    return emojis[level - 1];
  }
}

// ── Filter chip ─────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF34C759).withValues(alpha: 0.15)
              : const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? const Color(0xFF34C759)
                : const Color(0xFFE5E5EA),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected
                ? const Color(0xFF34C759)
                : const Color(0xFF636366),
          ),
        ),
      ),
    );
  }
}
