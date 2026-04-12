import 'package:flutter/material.dart';

import '../features/observations/data/observation_repository.dart';
import '../features/observations/domain/observation_entry.dart';
import '../ui/ui.dart';

/// Shows observations (notes) created by a specific family member,
/// visible to the patient.
class CaregiverNotesScreen extends StatelessWidget {
  const CaregiverNotesScreen({
    super.key,
    required this.patientId,
    required this.authorUid,
    required this.authorName,
  });

  final String patientId;
  final String authorUid;
  final String authorName;

  @override
  Widget build(BuildContext context) {
    final repo = ObservationRepository();
    return GlassPage(
      title: 'Notizen von $authorName',
      titleIcon: Icons.sticky_note_2_rounded,
      titleColor: AppColors.accent,
      children: [
        StreamBuilder<List<ObservationEntry>>(
          stream: repo.watchObservations(patientId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return GlassContainer(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  'Fehler beim Laden: ${snapshot.error}',
                  style: const TextStyle(color: AppColors.error),
                ),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final entries = snapshot.data!
                .where((e) => e.authorUid == authorUid)
                .toList();

            if (entries.isEmpty) {
              return GlassContainer(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Column(
                  children: [
                    Icon(
                      Icons.sticky_note_2_outlined,
                      size: 48,
                      color: AppColors.grey400,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      '$authorName hat noch keine Notizen verfasst.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                for (var i = 0; i < entries.length; i++) ...[
                  _NoteCard(
                    entry: entries[i],
                    onEdit: () => _showEditDialog(context, repo, entries[i]),
                    onDelete: () =>
                        _confirmDelete(context, repo, entries[i]),
                  ),
                  if (i < entries.length - 1)
                    const SizedBox(height: AppSpacing.md),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  void _showEditDialog(
      BuildContext context, ObservationRepository repo, ObservationEntry entry) {
    final textController = TextEditingController(text: entry.text);
    var selectedSeverity = entry.severity;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Notiz bearbeiten'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: textController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Notiz',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<ObservationSeverity>(
                    segments: const [
                      ButtonSegment(
                        value: ObservationSeverity.info,
                        label: Text('Info'),
                        icon: Icon(Icons.info_outline),
                      ),
                      ButtonSegment(
                        value: ObservationSeverity.warning,
                        label: Text('Warnung'),
                        icon: Icon(Icons.warning_amber),
                      ),
                      ButtonSegment(
                        value: ObservationSeverity.critical,
                        label: Text('Kritisch'),
                        icon: Icon(Icons.error_outline),
                      ),
                    ],
                    selected: {selectedSeverity},
                    onSelectionChanged: (selection) {
                      setDialogState(() => selectedSeverity = selection.first);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Abbrechen'),
                ),
                FilledButton(
                  onPressed: () async {
                    final text = textController.text.trim();
                    if (text.isEmpty) return;
                    await repo.updateObservation(
                      patientId: patientId,
                      observationId: entry.id,
                      text: text,
                      severity: selectedSeverity,
                    );
                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                  },
                  child: const Text('Speichern'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) => textController.dispose());
  }

  void _confirmDelete(
      BuildContext context, ObservationRepository repo, ObservationEntry entry) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Notiz löschen'),
          content:
              const Text('Möchten Sie diese Notiz wirklich löschen?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Abbrechen'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              onPressed: () async {
                await repo.deleteObservation(patientId, entry.id);
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Löschen'),
            ),
          ],
        );
      },
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  final ObservationEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppRadius.borderRadiusXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _severityIcon(entry.severity),
              const SizedBox(width: AppSpacing.sm),
              Text(
                _severityLabel(entry.severity),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _severityColor(entry.severity),
                ),
              ),
              const Spacer(),
              Text(
                _formatDate(entry.createdAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            entry.text,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_rounded, size: 18),
                color: AppColors.primary,
                tooltip: 'Bearbeiten',
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                color: AppColors.error,
                tooltip: 'Löschen',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _severityIcon(ObservationSeverity severity) {
    return switch (severity) {
      ObservationSeverity.info =>
        const Icon(Icons.info_outline, color: Colors.blue, size: 20),
      ObservationSeverity.warning =>
        const Icon(Icons.warning_amber, color: Colors.orange, size: 20),
      ObservationSeverity.critical =>
        const Icon(Icons.error_outline, color: Colors.red, size: 20),
    };
  }

  Color _severityColor(ObservationSeverity severity) {
    return switch (severity) {
      ObservationSeverity.info => Colors.blue,
      ObservationSeverity.warning => Colors.orange,
      ObservationSeverity.critical => Colors.red,
    };
  }

  String _severityLabel(ObservationSeverity severity) {
    return switch (severity) {
      ObservationSeverity.info => 'Info',
      ObservationSeverity.warning => 'Warnung',
      ObservationSeverity.critical => 'Kritisch',
    };
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}
