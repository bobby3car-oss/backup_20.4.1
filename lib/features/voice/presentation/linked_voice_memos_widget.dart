import 'package:flutter/material.dart';

import '../data/voice_repository_sync.dart';
import '../domain/voice_memo.dart';

/// A widget that shows a "Sprachnotiz anhören" button when there are
/// voice memos linked to the given [timelineItemId].
///
/// Intended to be embedded in timeline detail screens.
class LinkedVoiceMemosWidget extends StatelessWidget {
  const LinkedVoiceMemosWidget({
    super.key,
    required this.timelineItemId,
  });

  final String timelineItemId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<VoiceMemo>>(
      future:
          VoiceRepositorySync.instance.getByLinkedTimelineItemId(timelineItemId),
      builder: (context, snapshot) {
        final memos = snapshot.data;
        if (memos == null || memos.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            const Text(
              'Verknüpfte Sprachnotizen',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1C1C1E),
              ),
            ),
            const SizedBox(height: 8),
            ...memos.map(
              (memo) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _VoiceMemoLinkTile(memo: memo),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _VoiceMemoLinkTile extends StatelessWidget {
  const _VoiceMemoLinkTile({required this.memo});

  final VoiceMemo memo;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF0A74FF).withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).pushNamed(
          '/voice-memo-detail',
          arguments: memo.id,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              const Icon(Icons.mic_rounded, size: 20, color: Color(0xFF0A74FF)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      memo.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1C1C1E),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _formatDuration(memo.durationMs),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.play_circle_outline,
                  size: 24, color: Color(0xFF0A74FF)),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(int ms) {
    final totalSec = (ms / 1000).round();
    final m = (totalSec ~/ 60).toString().padLeft(2, '0');
    final s = (totalSec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
