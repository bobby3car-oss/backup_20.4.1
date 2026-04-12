import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../features/assistant/domain/wound_analysis_result.dart';
import '../../../../features/wound/domain/wound_entry.dart';
import '../../../../ui/ui.dart';

/// Horizontal photo timeline grouped by body location.
///
/// Shows wound photos chronologically (oldest → newest) so doctors can
/// visually track healing progress over time.
class WoundPhotoTimeline extends StatelessWidget {
  const WoundPhotoTimeline({super.key, required this.wounds});

  final List<WoundEntry> wounds;

  @override
  Widget build(BuildContext context) {
    // Group wounds that have photos by body location.
    final groups = <String, List<WoundEntry>>{};
    for (final w in wounds) {
      if (w.photoPath == null && w.photoUrl == null) continue;
      final loc = w.bodyLocation ?? 'Unbekannt';
      (groups[loc] ??= []).add(w);
    }

    if (groups.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.photo_library_outlined,
                size: 48, color: AppColors.grey400),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Keine Fotos vorhanden',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    // Sort each group chronologically (oldest first).
    for (final list in groups.values) {
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }

    return ListView(
      padding: AppSpacing.screenPadding,
      children: groups.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  const Icon(Icons.location_on_rounded,
                      size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    entry.key,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${entry.value.length} Fotos',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 160,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: entry.value.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, i) {
                  final w = entry.value[i];
                  return _TimelinePhoto(wound: w);
                },
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        );
      }).toList(),
    );
  }
}

class _TimelinePhoto extends StatelessWidget {
  const _TimelinePhoto({required this.wound});

  final WoundEntry wound;

  @override
  Widget build(BuildContext context) {
    final path = wound.photoPath;
    final hasLocal = path != null &&
        path.trim().isNotEmpty &&
        File(path.trim()).existsSync();
    final hasRemote = wound.photoUrl != null && wound.photoUrl!.isNotEmpty;

    final analysisMap = wound.metadata['bellaAnalysis'];
    final hasAnalysis = analysisMap != null && analysisMap is Map;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 120,
                height: 120,
                child: hasLocal
                    ? Image.file(File(path.trim()), fit: BoxFit.cover)
                    : hasRemote
                        ? Image.network(wound.photoUrl!, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _placeholder())
                        : _placeholder(),
              ),
            ),
            // AI status badge overlay.
            if (hasAnalysis)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    WoundAnalysisResult.fromJson(
                      Map<String, dynamic>.from(analysisMap),
                    ).statusEmoji,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 120,
          child: Row(
            children: [
              Text(
                '${wound.createdAt.day}.${wound.createdAt.month}.',
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary),
              ),
              const Spacer(),
              _MiniPainBadge(level: wound.pain),
            ],
          ),
        ),
      ],
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.grey100,
      child: Center(
        child: Icon(Icons.image_not_supported_outlined,
            size: 24, color: AppColors.grey400),
      ),
    );
  }
}

class _MiniPainBadge extends StatelessWidget {
  const _MiniPainBadge({required this.level});

  final int level;

  Color get _color {
    if (level <= 3) return AppColors.success;
    if (level <= 6) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$level',
        style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w600, color: _color),
      ),
    );
  }
}
