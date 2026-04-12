import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';

import '../../../auth/guest_data_migration_service.dart';
import '../../../ui/ui.dart';
import '../data/voice_repository_sync.dart';
import '../domain/voice_memo.dart';
import '../../../ui/theme/app_icons.dart';
import '../../../l10n/app_localizations.dart';

class VoiceMemosScreen extends StatefulWidget {
  const VoiceMemosScreen({super.key});

  @override
  State<VoiceMemosScreen> createState() => _VoiceMemosScreenState();
}

class _VoiceMemosScreenState extends State<VoiceMemosScreen> {
  static final VoiceRepositorySync _repository = VoiceRepositorySync.instance;

  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  late final StreamSubscription<void> _playerCompleteSub;

  bool _isRecording = false;
  DateTime? _recordingStartedAt;
  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;
  String? _recordingMemoId;
  String? _playingMemoId;

  String _searchQuery = '';
  String? _activeTagFilter;

  @override
  void initState() {
    super.initState();
    _bootstrap();
    _playerCompleteSub = _player.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() => _playingMemoId = null);
    });
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _playerCompleteSub.cancel();
    _player.dispose();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    await _repository.loadFromDisk();
    try {
      await _repository.pullLatest();
    } catch (e) {
      debugPrint('[VoiceMemosScreen] pullLatest failed (offline?): $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return GlassPage(
      title: 'Sprachnotizen',
      titleIcon: AppIcons.voice,
      titleColor: AppColors.accent,
      scrollableBody: (headerHeight) => Column(
        children: [
          SizedBox(height: headerHeight),
          _RecordHeader(
            isRecording: _isRecording,
            duration: _recordingDuration,
            onTap: _toggleRecording,
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: TextField(
              decoration: InputDecoration(
                hintText: l.voiceMemosMemosDurchsuchen,
                prefixIcon: const Icon(Icons.search, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFF2F2F7),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          // Tag filter row
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildFilterChip(l.all, _activeTagFilter == null, () {
                  setState(() => _activeTagFilter = null);
                }),
                ...VoiceMemoTags.predefined.map((tag) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _buildFilterChip(
                      tag,
                      _activeTagFilter == tag,
                      () => setState(() {
                        _activeTagFilter = _activeTagFilter == tag ? null : tag;
                      }),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: StreamBuilder<List<VoiceMemo>>(
              stream: _repository.watchAll(),
              builder: (context, snapshot) {
                var items = snapshot.data ?? const <VoiceMemo>[];
                if (_searchQuery.isNotEmpty) {
                  items = items.where((m) => m.matchesSearch(_searchQuery)).toList();
                }
                if (_activeTagFilter != null) {
                  items = items.where((m) => m.tags.contains(_activeTagFilter)).toList();
                }
                if (items.isEmpty) {
                  return Center(child: Text(l.voiceNoMemos));
                }
                return ListView.builder(
                  physics: adaptiveScrollPhysics,
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final memo = items[index];
                    return _VoiceMemoTile(
                      memo: memo,
                      isPlaying: _playingMemoId == memo.id,
                      onPlayPause: () => _togglePlay(memo),
                      onRename: () => _renameMemo(memo),
                      onDelete: () => _deleteMemo(memo),
                      onTap: () => Navigator.of(context).pushNamed(
                        '/voice-memo-detail',
                        arguments: memo.id,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    final l = AppLocalizations.of(context)!;
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.voiceMicPermissionMissing)),
      );
      return;
    }

    final memoId = 'voice_${DateTime.now().microsecondsSinceEpoch}';
    final path = await _repository.recordingPathFor(memoId);

    try {
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: path,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFacingError(e, fallback: l.aufnahmeStartFehler))),
      );
      return;
    }

    _recordingStartedAt = DateTime.now();
    _recordingMemoId = memoId;
    _recordingDuration = Duration.zero;
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final start = _recordingStartedAt;
      if (start == null || !mounted) return;
      setState(() {
        _recordingDuration = DateTime.now().difference(start);
      });
    });

    if (!mounted) return;
    setState(() => _isRecording = true);
  }

  Future<void> _stopRecording() async {
    final filePath = await _recorder.stop();
    final startedAt = _recordingStartedAt;
    final memoId = _recordingMemoId;

    _recordingTimer?.cancel();
    _recordingTimer = null;

    if (!mounted) return;
    setState(() {
      _isRecording = false;
      _recordingStartedAt = null;
      _recordingMemoId = null;
    });

    if (filePath == null ||
        filePath.trim().isEmpty ||
        memoId == null ||
        startedAt == null) {
      return;
    }

    final file = File(filePath);
    if (!await file.exists()) return;

    if (!mounted) return;
    if (!await GuestDataMigrationService.requireAuth(context)) return;
    if (!mounted) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final now = DateTime.now();
    final durationMs = DateTime.now().difference(startedAt).inMilliseconds;
    final memo = VoiceMemo(
      id: memoId,
      ownerId: uid,
      title: _defaultTitle(startedAt),
      localFilePath: filePath,
      durationMs: durationMs,
      recordedAt: startedAt,
      createdAt: now,
      updatedAt: now,
      syncStatus: VoiceSyncStatus.pending,
    );
    try {
      await _repository.upsert(memo);
    } catch (e) {
      if (!mounted) return;
      final l = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFacingError(e, fallback: l.fehlerBeimSpeichern))),
      );
    }
  }

  Future<void> _togglePlay(VoiceMemo memo) async {
    if (_playingMemoId == memo.id) {
      await _player.pause();
      if (!mounted) return;
      setState(() => _playingMemoId = null);
      return;
    }

    if (memo.localFilePath.trim().isEmpty) return;
    final file = File(memo.localFilePath);
    if (!await file.exists()) {
      if (!mounted) return;
      final l = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.voiceAudioNotFoundLocal)),
      );
      return;
    }

    try {
      await _player.stop();
      await _player.play(DeviceFileSource(memo.localFilePath));
    } catch (e) {
      debugPrint('[VoiceMemosScreen] playback failed: $e');
      return;
    }
    if (!mounted) return;
    setState(() => _playingMemoId = memo.id);
  }

  Future<void> _renameMemo(VoiceMemo memo) async {
    final controller = TextEditingController(text: memo.title);
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        final l = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l.editTitle),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Titel'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l.cancel),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: Text(l.save),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (result == null || result.trim().isEmpty) return;
    try {
      await _repository.updateTitle(memo, result);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFacingError(e))),
      );
    }
  }

  Future<void> _deleteMemo(VoiceMemo memo) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) {
            final l = AppLocalizations.of(context)!;
            return AlertDialog(
              title: Text(l.voiceMemoDelete),
              content: const Text(
                'Die lokale Datei und Metadaten werden entfernt.',
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
    if (!confirmed) return;

    if (_playingMemoId == memo.id) {
      await _player.stop();
      if (mounted) setState(() => _playingMemoId = null);
    }
    try {
      await _repository.delete(memo);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFacingError(e))),
      );
    }
  }

  String _defaultTitle(DateTime date) {
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final hh = date.hour.toString().padLeft(2, '0');
    final min = date.minute.toString().padLeft(2, '0');
    return 'Memo $dd.$mm. $hh:$min';
  }

  Widget _buildFilterChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0A74FF) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFF0A74FF) : const Color(0xFFE5E5EA),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : const Color(0xFF3C3C43),
          ),
        ),
      ),
    );
  }
}

class _RecordHeader extends StatelessWidget {
  const _RecordHeader({
    required this.isRecording,
    required this.duration,
    required this.onTap,
  });

  final bool isRecording;
  final Duration duration;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                isRecording ? 'Aufnahme läuft' : 'Bereit zur Aufnahme',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                _formatDuration(duration),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: 92,
                height: 92,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    backgroundColor: isRecording ? Colors.red : null,
                  ),
                  onPressed: onTap,
                  child: Icon(
                    isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                    size: 40,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration value) {
    final minutes = value.inMinutes.toString().padLeft(2, '0');
    final seconds = (value.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _VoiceMemoTile extends StatelessWidget {
  const _VoiceMemoTile({
    required this.memo,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onRename,
    required this.onDelete,
    required this.onTap,
  });

  final VoiceMemo memo;
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onRename;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                  ),
                  onPressed: onPlayPause,
                ),
                title: Text(memo.title),
                subtitle: Text(
                  '${_formatDate(memo.recordedAt)} · ${_formatDurationMs(memo.durationMs)}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _StatusChip(status: memo.syncStatus),
                    IconButton(
                      tooltip: l.editTitle,
                      onPressed: onRename,
                      icon: const Icon(Icons.edit_outlined),
                    ),
                    IconButton(
                      tooltip: l.delete,
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline_rounded),
                    ),
                  ],
                ),
              ),
              // Tags
              if (memo.tags.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: memo.tags
                        .map((tag) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0A74FF).withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                tag,
                                style: const TextStyle(fontSize: 11, color: Color(0xFF0A74FF)),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              // Transcript preview
              if (memo.transcript != null && memo.transcript!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    memo.transcript!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E93)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime value) {
    final dd = value.day.toString().padLeft(2, '0');
    final mm = value.month.toString().padLeft(2, '0');
    final hh = value.hour.toString().padLeft(2, '0');
    final min = value.minute.toString().padLeft(2, '0');
    return '$dd.$mm.${value.year} $hh:$min';
  }

  String _formatDurationMs(int durationMs) {
    final totalSeconds = (durationMs / 1000).round();
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final VoiceSyncStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      VoiceSyncStatus.pending => ('pending', Colors.orange),
      VoiceSyncStatus.synced => ('synced', Colors.green),
      VoiceSyncStatus.failed => ('failed', Colors.red),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
