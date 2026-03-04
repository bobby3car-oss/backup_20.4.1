import 'dart:io';

import 'package:flutter/material.dart';

import '../data/wound_repository.dart';
import '../data/wound_repository_sync.dart';
import '../domain/wound_entry.dart';
import 'wound_compare_screen.dart';

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
    final path = entry.photoPath;
    final hasPath = path != null && path.trim().isNotEmpty;
    final file = hasPath ? File(path.trim()) : null;
    final hasImage = file != null && file.existsSync();
    final dateLabel = _formatDate(entry.createdAt);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wunddetail'),
        actions: [
          if (showDeleteButton)
            IconButton(
              tooltip: 'Löschen',
              onPressed: () => _confirmDelete(context),
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
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
          _DetailRow(label: 'Schmerzscore', value: '${entry.pain}/10'),
          _DetailRow(
            label: 'Körperstelle',
            value: (entry.bodyLocation ?? '').trim().isEmpty
                ? 'Nicht angegeben'
                : entry.bodyLocation!.trim(),
          ),
          _DetailRow(
            label: 'Notiz',
            value: entry.note.trim().isEmpty ? 'Keine Notiz' : entry.note.trim(),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => _openCompare(context),
            icon: const Icon(Icons.compare_arrows_rounded),
            label: const Text('Vergleichen'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final shouldDelete =
        await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Eintrag löschen?'),
              content: const Text(
                'Dieser Wundeintrag wird dauerhaft entfernt.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Abbrechen'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Löschen'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldDelete || !context.mounted) return;
    await _repository.delete(entry.id);
    if (!context.mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _openCompare(BuildContext context) async {
    final allEntries = await _repository.watchAll().first;
    if (!context.mounted) return;

    if (allEntries.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mindestens 2 Wundeinträge für Vergleich erforderlich.'),
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
