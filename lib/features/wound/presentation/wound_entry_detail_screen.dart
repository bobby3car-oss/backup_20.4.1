import 'dart:io';

import 'package:flutter/material.dart';

import '../../../sync/connectivity_service.dart';
import '../../../ui/ui.dart';
import '../../assistant/presentation/bella_overlay_controller.dart';
import '../../pro/domain/trigger_context.dart';
import '../../pro/presentation/smart_paywall.dart';
import '../data/wound_repository.dart';
import '../data/wound_repository_sync.dart';
import '../domain/wound_entry.dart';
import 'wound_compare_screen.dart';
import '../../../ui/theme/app_icons.dart';
import '../../../l10n/app_localizations.dart';

class WoundEntryDetailScreen extends StatelessWidget {
  WoundEntryDetailScreen({
    super.key,
    required this.entry,
    WoundRepository? repository,
    this.showDeleteButton = true,
  }) : _repository = repository ?? WoundRepositorySync.instance;

  final WoundEntry entry;
  final WoundRepository _repository;
  final bool showDeleteButton;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final path = entry.photoPath;
    final hasPath = path != null && path.trim().isNotEmpty;
    final file = hasPath ? File(path.trim()) : null;
    final hasImage = file != null && file.existsSync();
    final dateLabel = _formatDate(entry.createdAt);

    return GlassPage(
      title: 'Wunddetail',
      titleIcon: AppIcons.wound,
      titleColor: AppColors.success,
      trailing: showDeleteButton
          ? PressableScale(
              onTap: () => _confirmDelete(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadius.borderRadiusSm,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: AppColors.error,
                ),
              ),
            )
          : null,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Hero(
                tag: 'wound-photo-${entry.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: hasImage
                      ? Image.file(file, height: 260, fit: BoxFit.cover)
                      : Container(
                          height: 260,
                          color: Colors.grey.shade200,
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 52,
                            color: Colors.grey.shade600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              _DetailRow(label: 'Datum', value: dateLabel),
              _DetailRow(label: l.painLevel, value: '${entry.pain}/10'),
              _DetailRow(
                label: 'Körperstelle',
                value: (entry.bodyLocation ?? '').trim().isEmpty
                    ? 'Nicht angegeben'
                    : entry.bodyLocation!.trim(),
              ),
              _DetailRow(
                label: 'Notiz',
                value: entry.note.trim().isEmpty
                    ? 'Keine Notiz'
                    : entry.note.trim(),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => _openCompare(context),
                icon: const Icon(Icons.compare_arrows_rounded),
                label: Text(l.woundCompare),
              ),
              const SizedBox(height: 8),
              _BellaAnalyzeButton(entry: entry, repository: _repository),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final shouldDelete =
        await showDialog<bool>(
          context: context,
          builder: (context) {
            final l = AppLocalizations.of(context)!;
            return AlertDialog(
              title: Text(l.entryDeleteConfirm),
              content: const Text(
                'Dieser Wundeintrag wird dauerhaft entfernt.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(l.cancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(l.delete),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldDelete || !context.mounted) return;
    try {
      await _repository.delete(entry.id);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFacingError(e))),
      );
      return;
    }
    if (!context.mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _openCompare(BuildContext context) async {
    final allEntries = await _repository.watchAll().first;
    if (!context.mounted) return;

    if (allEntries.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Mindestens 2 Wundeinträge für Vergleich erforderlich.',
          ),
          duration: Duration(milliseconds: 1600),
        ),
      );
      return;
    }

    final sorted = List<WoundEntry>.from(allEntries)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final currentIndex = sorted.indexWhere((e) => e.id == entry.id);
    final fallback = sorted.firstWhere((e) => e.id != entry.id);
    final other = (currentIndex >= 0 && currentIndex + 1 < sorted.length)
        ? sorted[currentIndex + 1]
        : fallback;

    final olderFirst = other.createdAt.isBefore(entry.createdAt);
    final entryA = olderFirst ? other : entry;
    final entryB = olderFirst ? entry : other;

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WoundCompareScreen(entryA: entryA, entryB: entryB),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(value, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}

String _formatDate(DateTime value) {
  final dd = value.day.toString().padLeft(2, '0');
  final mm = value.month.toString().padLeft(2, '0');
  final yyyy = value.year.toString().padLeft(4, '0');
  final hh = value.hour.toString().padLeft(2, '0');
  final min = value.minute.toString().padLeft(2, '0');
  return '$dd.$mm.$yyyy, $hh:$min';
}

// ── Bella Analyze Button ─────────────────────────────────────────────────

class _BellaAnalyzeButton extends StatelessWidget {
  const _BellaAnalyzeButton({required this.entry, required this.repository});
  final WoundEntry entry;
  final WoundRepository repository;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isOnline = ConnectivityService.instance.isOnline.value;

    return FilledButton.icon(
      onPressed: isOnline ? () => _analyze(context) : null,
      icon: const Text('🐰', style: TextStyle(fontSize: 16)),
      label: Text(l.bellaAnalyze),
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFFFCE4EC),
        foregroundColor: const Color(0xFFC62828),
        disabledBackgroundColor: Colors.grey.shade200,
        disabledForegroundColor: Colors.grey.shade500,
      ),
    );
  }

  Future<void> _analyze(BuildContext context) async {
    final bella = BellaOverlayController.instance;
    if (bella == null) return;

    // Pro gate
    if (!bella.isPro) {
      final l = AppLocalizations.of(context)!;
      if (!context.mounted) return;
      SmartPaywall.trigger(
        context: context,
        triggerContext: TriggerContext.assistantFeature,
      );
      return;
    }

    // Collect current photo + up to 3 previous photos for comparison
    final allEntries = await repository.watchAll().first;
    final sorted = List<WoundEntry>.from(allEntries)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final photoPaths = <String>[];

    // Current entry photo first
    final currentPath = entry.photoPath;
    if (currentPath != null && currentPath.trim().isNotEmpty) {
      final f = File(currentPath.trim());
      if (f.existsSync()) photoPaths.add(currentPath.trim());
    }

    // Previous photos (up to 3 more)
    for (final e in sorted) {
      if (photoPaths.length >= 4) break;
      if (e.id == entry.id) continue;
      final p = e.photoPath;
      if (p != null && p.trim().isNotEmpty) {
        final f = File(p.trim());
        if (f.existsSync()) photoPaths.add(p.trim());
      }
    }

    if (photoPaths.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kein Foto für die Analyse vorhanden.'),
          duration: Duration(milliseconds: 1600),
        ),
      );
      return;
    }

    // Open Bella and send with images
    bella.open();
    bella.sendWithImages(
      'Bitte analysiere mein Wundfoto vom '
      '${_formatDate(entry.createdAt)}'
      '${photoPaths.length > 1 ? ' und vergleiche es mit ${photoPaths.length - 1} früheren Aufnahmen' : ''}.',
      photoPaths,
    );
  }
}
