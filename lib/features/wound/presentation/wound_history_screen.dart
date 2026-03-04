import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../data/wound_repository.dart';
import '../data/wound_repository_sync.dart';
import '../domain/wound_entry.dart';
import 'wound_entry_detail_screen.dart';

class WoundHistoryScreen extends StatelessWidget {
  WoundHistoryScreen({super.key, WoundRepository? repository})
    : _repository = repository ?? WoundRepositorySync.instance {
    if (_repository is WoundRepositorySync) {
      unawaited(_repository.pullLatest());
    }
  }

  final WoundRepository _repository;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wundverlauf')),
      body: RefreshIndicator(
        onRefresh: () async {
          if (_repository is WoundRepositorySync) {
            await _repository.pullLatest();
          }
        },
        child: StreamBuilder<List<WoundEntry>>(
          stream: _repository.watchAll(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final sorted = List<WoundEntry>.from(snapshot.data ?? <WoundEntry>[])
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

            if (sorted.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 220),
                  Center(child: Text('Noch keine Wundeinträge vorhanden.')),
                ],
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: sorted.length,
              itemBuilder: (context, index) {
                final entry = sorted[index];
                final isLast = index == sorted.length - 1;
                return _WoundTimelineItem(
                  entry: entry,
                  isLast: isLast,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => WoundEntryDetailScreen(
                          entry: entry,
                          repository: _repository,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _WoundTimelineItem extends StatelessWidget {
  const _WoundTimelineItem({
    required this.entry,
    required this.isLast,
    required this.onTap,
  });

  final WoundEntry entry;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateTimeLabel = _formatDateTime(entry.createdAt);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 18),
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      color: theme.colorScheme.primary.withValues(alpha: 0.25),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                elevation: 2,
                shadowColor: Colors.black.withValues(alpha: 0.12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Hero(
                          tag: 'wound-photo-${entry.id}',
                          child: _Thumbnail(photoPath: entry.photoPath),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dateTimeLabel,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Schmerzscore: ${entry.pain}/10',
                                style: theme.textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                entry.note.trim().isEmpty
                                    ? 'Keine Notiz'
                                    : entry.note.trim(),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.photoPath});

  final String? photoPath;

  @override
  Widget build(BuildContext context) {
    final path = photoPath;
    final hasPath = path != null && path.trim().isNotEmpty;
    final file = hasPath ? File(path.trim()) : null;
    final exists = file != null && file.existsSync();

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 80,
        height: 80,
        color: Colors.grey.shade200,
        child: exists
            ? Image.file(file, fit: BoxFit.cover)
            : Icon(
                Icons.image_not_supported_outlined,
                size: 30,
                color: Colors.grey.shade600,
              ),
      ),
    );
  }
}

String _formatDateTime(DateTime value) {
  return '${_formatDate(value)} ${_formatTime(value)}';
}

String _formatDate(DateTime value) {
  final dd = value.day.toString().padLeft(2, '0');
  final mm = value.month.toString().padLeft(2, '0');
  final yyyy = value.year.toString().padLeft(4, '0');
  return '$dd.$mm.$yyyy';
}

String _formatTime(DateTime value) {
  final hh = value.hour.toString().padLeft(2, '0');
  final min = value.minute.toString().padLeft(2, '0');
  return '$hh:$min';
}
