import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../ui/ui.dart';
import '../data/sleep_repository_sync.dart';
import '../domain/sleep_entry.dart';
import 'sleep_entry_editor.dart';

const _kNightPurple = Color(0xFF5C4D9A);
const _kNightSurface = Color(0x1A5C4D9A);
const _kNightBorder = Color(0x335C4D9A);
const _kStarYellow = Color(0xFFFFD700);

/// Sleep diary with history list, grouped by date.
class SleepDiaryScreen extends StatefulWidget {
  const SleepDiaryScreen({super.key});

  @override
  State<SleepDiaryScreen> createState() => _SleepDiaryScreenState();
}

class _SleepDiaryScreenState extends State<SleepDiaryScreen> {
  static final SleepRepositorySync _repository = SleepRepositorySync.instance;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _repository.loadFromDisk();
    if (!mounted) return;
    await _repository.pullLatest();
  }

  @override
  Widget build(BuildContext context) {
    return GlassPage(
      title: 'Schlaftagebuch',
      titleIcon: CupertinoIcons.book_fill,
      titleColor: _kNightPurple,
      trailing: PressableScale(
        onTap: () {
          Haptic.light();
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const SleepEntryEditor(),
            ),
          );
        },
        scaleFactor: 0.92,
        child: GlassContainer(
          padding: const EdgeInsets.all(AppSpacing.sm),
          borderRadius: AppRadius.borderRadiusSm,
          variant: GlassVariant.thin,
          elevation: GlassElevation.low,
          child: const Icon(
            CupertinoIcons.plus,
            size: 20,
            color: _kNightPurple,
          ),
        ),
      ),
      children: [
        const SizedBox(height: AppSpacing.md),
        StreamBuilder<List<SleepEntry>>(
          stream: _repository.watchAll(),
          builder: (context, snapshot) {
            final items = snapshot.data ?? [];
            if (items.isEmpty) {
              return _buildEmptyState(context);
            }

            // Group by date.
            final grouped = <String, List<SleepEntry>>{};
            for (final item in items) {
              final key =
                  '${item.bedTime.year}-${item.bedTime.month.toString().padLeft(2, '0')}-${item.bedTime.day.toString().padLeft(2, '0')}';
              grouped.putIfAbsent(key, () => []).add(item);
            }

            final sortedKeys = grouped.keys.toList()
              ..sort((a, b) => b.compareTo(a));

            return Column(
              children: [
                for (final key in sortedKeys) ...[
                  _DateHeader(dateKey: key),
                  for (final entry in grouped[key]!)
                    _SleepEntryTile(
                      entry: entry,
                      onTap: () => _openEditor(entry),
                      onDelete: () => _confirmDelete(entry),
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

  Widget _buildEmptyState(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
      child: Column(
        children: [
          Icon(
            CupertinoIcons.moon_zzz_fill,
            size: 64,
            color: _kNightPurple.withValues(alpha: 0.3),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Noch keine Einträge',
            style: tt.titleMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Erfasse deinen ersten Schlaf-Eintrag.',
            style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  void _openEditor(SleepEntry entry) {
    Haptic.light();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SleepEntryEditor(initialEntry: entry),
      ),
    );
  }

  Future<void> _confirmDelete(SleepEntry entry) async {
    HapticFeedback.mediumImpact();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eintrag löschen?'),
        content: const Text(
          'Dieser Schlaf-Eintrag wird unwiderruflich gelöscht.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _repository.delete(entry.id);
    }
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Helper widgets
// ═════════════════════════════════════════════════════════════════════════════

class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.dateKey});
  final String dateKey;

  @override
  Widget build(BuildContext context) {
    final parts = dateKey.split('-');
    if (parts.length < 3) return const SizedBox.shrink();
    final dt = DateTime(
      int.tryParse(parts[0]) ?? 2024,
      int.tryParse(parts[1]) ?? 1,
      int.tryParse(parts[2]) ?? 1,
    );
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    String label;
    if (dt == today) {
      label = 'Heute';
    } else if (dt == yesterday) {
      label = 'Gestern';
    } else {
      const weekdays = [
        'Montag',
        'Dienstag',
        'Mittwoch',
        'Donnerstag',
        'Freitag',
        'Samstag',
        'Sonntag',
      ];
      label =
          '${weekdays[dt.weekday - 1]}, ${dt.day}.${dt.month}.${dt.year}';
    }

    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.sm,
        bottom: AppSpacing.xs,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: _kNightPurple,
              ),
        ),
      ),
    );
  }
}

class _SleepEntryTile extends StatelessWidget {
  const _SleepEntryTile({
    required this.entry,
    required this.onTap,
    required this.onDelete,
  });
  final SleepEntry entry;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final bedStr =
        '${entry.bedTime.hour.toString().padLeft(2, '0')}:${entry.bedTime.minute.toString().padLeft(2, '0')}';
    final wakeStr =
        '${entry.wakeTime.hour.toString().padLeft(2, '0')}:${entry.wakeTime.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: PressableScale(
        onTap: onTap,
        scaleFactor: 0.97,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: _kNightSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _kNightBorder),
          ),
          child: Row(
            children: [
              // Stars
              Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (i) {
                      return Icon(
                        i < entry.quality.value
                            ? CupertinoIcons.star_fill
                            : CupertinoIcons.star,
                        size: 14,
                        color: i < entry.quality.value
                            ? _kStarYellow
                            : AppColors.grey400,
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.durationFormatted,
                    style: tt.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: _kNightPurple,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$bedStr → $wakeStr',
                      style: tt.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (entry.disturbances > 0)
                      Text(
                        '${entry.disturbances}× unterbrochen',
                        style: tt.labelSmall?.copyWith(
                          color: AppColors.warning,
                        ),
                      ),
                    if (entry.note != null && entry.note!.isNotEmpty)
                      Text(
                        entry.note!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tt.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(CupertinoIcons.trash, size: 18),
                color: AppColors.error.withValues(alpha: 0.7),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
