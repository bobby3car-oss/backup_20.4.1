import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../data/wound_repository.dart';
import '../data/wound_repository_sync.dart';
import '../domain/wound_entry.dart';
import 'wound_entry_detail_screen.dart';
import '../../../ui/theme/app_icons.dart';

class WoundHistoryScreen extends StatefulWidget {
  const WoundHistoryScreen({super.key, this.repository});

  final WoundRepository? repository;

  @override
  State<WoundHistoryScreen> createState() => _WoundHistoryScreenState();
}

class _WoundHistoryScreenState extends State<WoundHistoryScreen> {
  late final WoundRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? WoundRepositorySync.instance;
    if (_repository is WoundRepositorySync) {
      unawaited(_repository.pullLatest());
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassPage(
      title: 'Wundverlauf',
      titleIcon: AppIcons.documents,
      titleColor: AppColors.success,
      scrollableBody: (headerHeight) => RefreshIndicator(
        onRefresh: () async {
          if (_repository is WoundRepositorySync) {
            try {
              await _repository.pullLatest();
            } catch (e) {
              debugPrint('[WoundHistoryScreen] pullLatest failed (offline?): $e');
            }
          }
        },
        child: StreamBuilder<List<WoundEntry>>(
          stream: _repository.watchAll(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final sorted = List<WoundEntry>.from(
              snapshot.data ?? <WoundEntry>[],
            )..sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return ListView.builder(
              physics: adaptiveScrollPhysics,
              padding: EdgeInsets.fromLTRB(16, headerHeight + 12, 16, 40),
              itemCount: sorted.length + 2,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const _WoundDiaryHeader();
                }

                if (sorted.isEmpty) {
                  if (index == 1) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 20, bottom: 8),
                      child: Center(
                        child: Text('Noch keine Wundeinträge vorhanden.'),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }

                final entryIndex = index - 1;
                if (entryIndex >= sorted.length) {
                  return const SizedBox(height: 4);
                }
                final entry = sorted[entryIndex];
                final isLast = entryIndex == sorted.length - 1;
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

class _WoundDiaryHeader extends StatelessWidget {
  const _WoundDiaryHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Wundtagebuch',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Chronologische Übersicht Ihrer Wundheilung mit Fotos und Notizen.',
            style: TextStyle(
              fontSize: 15,
              height: 1.35,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0A74FF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Foto-Anleitung',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Für eine gute Dokumentation empfehlen wir täglich 2 Fotos:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    Expanded(
                      child: _GuideTile(
                        icon: AppIcons.wound,
                    iconColor: AppIcons.woundColor,
                        title: '1. Foto: Pflaster',
                        subtitle: 'Zeigt den Zustand des Verbands',
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _GuideTile(
                        icon: AppIcons.search,
                    iconColor: AppIcons.searchColor,
                        title: '2. Foto: Wunde',
                        subtitle: 'Nach Abnehmen des Pflasters',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Tipp: Achten Sie auf gute Beleuchtung und fotografieren Sie aus dem gleichen Winkel.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideTile extends StatelessWidget {
  const _GuideTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;


  final Color iconColor;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassIcon(icon: icon, color: iconColor, size: 24),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              height: 1.3,
            ),
          ),
        ],
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
                                'Schmerzstärke: ${entry.pain}/10',
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
