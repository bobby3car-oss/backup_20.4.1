import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../../domain/task_orchestrator_sync.dart';
import '../../../domain/timeline_engine.dart';
import '../../../ui/ui.dart';
import '../../../ui/theme/app_icons.dart';
import '../../assistant/presentation/bella_overlay_controller.dart';
import '../data/voice_repository_sync.dart';
import '../domain/voice_memo.dart';
import '../../../l10n/app_localizations.dart';

/// Detail screen for a single voice memo – playback, transcript editing,
/// tags, timeline linking, and Bella summary.
class VoiceMemoDetailScreen extends StatefulWidget {
  const VoiceMemoDetailScreen({super.key, required this.memoId});

  final String memoId;

  @override
  State<VoiceMemoDetailScreen> createState() => _VoiceMemoDetailScreenState();
}

class _VoiceMemoDetailScreenState extends State<VoiceMemoDetailScreen> {
  static final VoiceRepositorySync _repo = VoiceRepositorySync.instance;

  final AudioPlayer _player = AudioPlayer();
  late final StreamSubscription<void> _completeSub;

  VoiceMemo? _memo;
  bool _isPlaying = false;
  bool _editingTranscript = false;
  final TextEditingController _transcriptController = TextEditingController();

  // Timeline linking
  List<TimelineItem> _todayTasks = const [];
  bool _loadingTasks = false;

  @override
  void initState() {
    super.initState();
    _completeSub = _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _isPlaying = false);
    });
    _loadMemo();
    _loadTodayTasks();
  }

  @override
  void dispose() {
    _completeSub.cancel();
    _player.dispose();
    _transcriptController.dispose();
    super.dispose();
  }

  Future<void> _loadMemo() async {
    final memo = await _repo.getById(widget.memoId);
    if (!mounted) return;
    setState(() {
      _memo = memo;
      _transcriptController.text = memo?.transcript ?? '';
    });
  }

  Future<void> _loadTodayTasks() async {
    setState(() => _loadingTasks = true);
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    try {
      final items =
          await TaskOrchestratorSync.instance.watch(from: start, to: end).first;
      if (!mounted) return;
      setState(() {
        _todayTasks = items;
        _loadingTasks = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingTasks = false);
    }
  }

  // ── Playback ──────────────────────────────────────────────────────────

  Future<void> _togglePlay() async {
    final memo = _memo;
    if (memo == null) return;

    if (_isPlaying) {
      await _player.pause();
      if (mounted) setState(() => _isPlaying = false);
      return;
    }

    if (memo.localFilePath.trim().isEmpty) return;
    final file = File(memo.localFilePath);
    if (!await file.exists()) {
      final l = AppLocalizations.of(context)!;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.voiceAudioNotFound)),
      );
      return;
    }

    try {
      await _player.stop();
      await _player.play(DeviceFileSource(memo.localFilePath));
      if (mounted) setState(() => _isPlaying = true);
    } catch (e) {
      debugPrint('[VoiceMemoDetail] playback failed: $e');
    }
  }

  // ── Tags ──────────────────────────────────────────────────────────────

  Future<void> _toggleTag(String tag) async {
    final memo = _memo;
    if (memo == null) return;
    final current = List<String>.from(memo.tags);
    if (current.contains(tag)) {
      current.remove(tag);
    } else {
      current.add(tag);
    }
    await _repo.updateTags(memo, current);
    await _loadMemo();
  }

  Future<void> _addCustomTag() async {
    final l = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final tag = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.customDay),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'z.B. Befund'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(l.add),
          ),
        ],
      ),
    );
    controller.dispose();
    if (tag == null || tag.isEmpty) return;
    await _toggleTag(tag);
  }

  // ── Transcript ────────────────────────────────────────────────────────

  Future<void> _saveTranscript() async {
    final memo = _memo;
    if (memo == null) return;
    final text = _transcriptController.text.trim();
    await _repo.updateTranscript(memo, text);
    if (!mounted) return;
    setState(() => _editingTranscript = false);
    await _loadMemo();
  }

  // ── Timeline Link ─────────────────────────────────────────────────────

  Future<void> _linkToTimeline() async {
    final memo = _memo;
    if (memo == null) return;

    final selected = await showModalBottomSheet<String?>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _TimelineLinkSheet(
        tasks: _todayTasks,
        currentLinkId: memo.linkedTimelineItemId,
      ),
    );

    // null = dismissed, empty string = unlink
    if (selected == null) return;
    await _repo.linkToTimelineItem(memo, selected.isEmpty ? null : selected);
    await _loadMemo();
  }

  // ── Bella Summary ─────────────────────────────────────────────────────

  void _summarizeWithBella() {
    final memo = _memo;
    if (memo == null) return;
    final transcript = memo.transcript;
    if (transcript == null || transcript.trim().isEmpty) {
      final l = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.voiceNoTranscript),
        ),
      );
      return;
    }
    final bella = BellaOverlayController.instance;
    if (bella == null) return;
    bella.open();
    bella.send(
      'Bitte fasse folgende Sprachnotiz zusammen und erstelle daraus '
      'eine übersichtliche Notiz mit den wichtigsten Punkten:\n\n'
      '$transcript',
    );
  }

  // ── Format helpers ────────────────────────────────────────────────────

  String _formatDuration(int ms) {
    final totalSec = (ms / 1000).round();
    final m = (totalSec ~/ 60).toString().padLeft(2, '0');
    final s = (totalSec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final hh = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    return '$dd.$mm.${d.year}, $hh:$min';
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final memo = _memo;

    if (memo == null) {
      return GlassPage(
        title: 'Sprachnotiz',
        titleIcon: AppIcons.voice,
        titleColor: AppColors.accent,
        children: const [
          SizedBox(height: 64),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }

    return GlassPage(
      title: memo.title,
      titleIcon: AppIcons.voice,
      titleColor: AppColors.accent,
      horizontalPadding: AppSpacing.lg,
      children: [
        const SizedBox(height: AppSpacing.xxl),

        // ── Audio Player ──────────────────────────────────────────
        _Card(
          child: Column(
            children: [
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _togglePlay,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: _isPlaying
                        ? const Color(0xFFFF3B30)
                        : const Color(0xFF0A74FF),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (_isPlaying
                                ? const Color(0xFFFF3B30)
                                : const Color(0xFF0A74FF))
                            .withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    _isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _formatDuration(memo.durationMs),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8E8E93),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDate(memo.recordedAt),
                style:
                    const TextStyle(fontSize: 13, color: Color(0xFF8E8E93)),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // ── Transcript ────────────────────────────────────────────
        _SectionHeader(
          title: 'Transkript',
          trailing: memo.transcriptionStatus == TranscriptionStatus.processing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : IconButton(
                  icon: Icon(
                    _editingTranscript ? Icons.check : Icons.edit_outlined,
                    size: 20,
                  ),
                  onPressed: () {
                    if (_editingTranscript) {
                      _saveTranscript();
                    } else {
                      setState(() => _editingTranscript = true);
                    }
                  },
                ),
        ),
        const SizedBox(height: 4),
        _Card(
          child: _editingTranscript
              ? TextField(
                  controller: _transcriptController,
                  maxLines: null,
                  minLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Transkript bearbeiten…',
                    border: InputBorder.none,
                  ),
                )
              : Text(
                  (memo.transcript?.isNotEmpty ?? false)
                      ? memo.transcript!
                      : 'Kein Transkript vorhanden.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: (memo.transcript?.isNotEmpty ?? false)
                        ? const Color(0xFF1C1C1E)
                        : const Color(0xFF8E8E93),
                  ),
                ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // ── Tags ──────────────────────────────────────────────────
        _SectionHeader(title: l.tags),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...VoiceMemoTags.predefined.map(
              (tag) => _TagChip(
                label: tag,
                selected: memo.tags.contains(tag),
                onTap: () => _toggleTag(tag),
              ),
            ),
            // Custom tags (not in predefined)
            ...memo.tags
                .where((t) => !VoiceMemoTags.predefined.contains(t))
                .map(
                  (tag) => _TagChip(
                    label: tag,
                    selected: true,
                    onTap: () => _toggleTag(tag),
                  ),
                ),
            // Add custom tag button
            ActionChip(
              avatar: const Icon(Icons.add, size: 16),
              label: Text(l.day),
              onPressed: _addCustomTag,
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.lg),

        // ── Timeline Link ─────────────────────────────────────────
        const _SectionHeader(title: 'Timeline-Verknüpfung'),
        const SizedBox(height: 8),
        _Card(
          child: InkWell(
            onTap: _loadingTasks ? null : _linkToTimeline,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    memo.linkedTimelineItemId != null
                        ? Icons.link
                        : Icons.link_off,
                    color: memo.linkedTimelineItemId != null
                        ? const Color(0xFF0A74FF)
                        : const Color(0xFF8E8E93),
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      memo.linkedTimelineItemId != null
                          ? _linkedTaskTitle(memo.linkedTimelineItemId!)
                          : 'Nicht verknüpft – tippen zum Auswählen',
                      style: TextStyle(
                        fontSize: 15,
                        color: memo.linkedTimelineItemId != null
                            ? const Color(0xFF1C1C1E)
                            : const Color(0xFF8E8E93),
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 20,
                      color: Color(0xFF8E8E93)),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.xxl),

        // ── Bella Summary Button ──────────────────────────────────
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            onPressed: _summarizeWithBella,
            icon: const Text('🤖', style: TextStyle(fontSize: 18)),
            label: Text(l.bellaSummarize),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF5856D6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.xxxl),
      ],
    );
  }

  String _linkedTaskTitle(String itemId) {
    for (final task in _todayTasks) {
      if (task.id == itemId) return task.title;
    }
    return 'Verknüpft (ID: ${itemId.length > 12 ? '${itemId.substring(0, 12)}…' : itemId})';
  }
}

// ─── Timeline link bottom sheet ──────────────────────────────────────────────

class _TimelineLinkSheet extends StatelessWidget {
  const _TimelineLinkSheet({
    required this.tasks,
    this.currentLinkId,
  });

  final List<TimelineItem> tasks;
  final String? currentLinkId;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D1D6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Mit heutigem Task verknüpfen',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1C1C1E),
              ),
            ),
            const SizedBox(height: 12),
            if (currentLinkId != null)
              ListTile(
                leading: const Icon(Icons.link_off, color: Color(0xFFFF3B30)),
                title: Text(l.connectionRemove),
                onTap: () => Navigator.pop(context, ''),
              ),
            if (tasks.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Keine Tasks für heute gefunden.',
                  style: TextStyle(color: Color(0xFF8E8E93)),
                ),
              )
            else
              ...tasks.map(
                (task) => ListTile(
                  leading: Icon(
                    _iconForTaskType(task.type),
                    color: task.id == currentLinkId
                        ? const Color(0xFF0A74FF)
                        : const Color(0xFF8E8E93),
                  ),
                  title: Text(task.title),
                  subtitle: Text(task.subtitle),
                  trailing: task.id == currentLinkId
                      ? const Icon(Icons.check_circle,
                          color: Color(0xFF34C759))
                      : null,
                  onTap: () => Navigator.pop(context, task.id),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _iconForTaskType(TaskType type) {
    return switch (type) {
      TaskType.wound => Icons.healing,
      TaskType.meds => Icons.medication,
      TaskType.checklist => Icons.checklist,
      TaskType.appointment => Icons.calendar_today,
      TaskType.message => Icons.message,
      TaskType.custom => Icons.star_outline,
      TaskType.note => Icons.note,
      TaskType.nutrition => Icons.restaurant,
    };
  }
}

// ─── Reusable widgets ────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 24,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1C1C1E),
          ),
        ),
        const Spacer(),
        ?trailing,
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF0A74FF).withValues(alpha: 0.12)
              : const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? const Color(0xFF0A74FF)
                : const Color(0xFFE5E5EA),
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color:
                selected ? const Color(0xFF0A74FF) : const Color(0xFF3C3C43),
          ),
        ),
      ),
    );
  }
}
