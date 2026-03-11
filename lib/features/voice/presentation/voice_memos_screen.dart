import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';

import '../../../ui/ui.dart';
import '../data/voice_repository_sync.dart';
import '../domain/voice_memo.dart';
import '../../../ui/theme/app_icons.dart';

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
    await _repository.pullLatest();
  }

  @override
  Widget build(BuildContext context) {
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
          Expanded(
            child: StreamBuilder<List<VoiceMemo>>(
              stream: _repository.watchAll(),
              builder: (context, snapshot) {
                final items = snapshot.data ?? const <VoiceMemo>[];
                if (items.isEmpty) {
                  return const Center(child: Text('Noch keine Memos.'));
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
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mikrofon-Berechtigung fehlt.')),
      );
      return;
    }

    final memoId = 'voice_${DateTime.now().microsecondsSinceEpoch}';
    final path = await _repository.recordingPathFor(memoId);

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: path,
    );

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

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Bitte zuerst anmelden.')));
      return;
    }

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
    await _repository.upsert(memo);
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Audiodatei lokal nicht gefunden.')),
      );
      return;
    }

    await _player.stop();
    await _player.play(DeviceFileSource(memo.localFilePath));
    if (!mounted) return;
    setState(() => _playingMemoId = memo.id);
  }

  Future<void> _renameMemo(VoiceMemo memo) async {
    final controller = TextEditingController(text: memo.title);
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Titel bearbeiten'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Titel'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Abbrechen'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Speichern'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (result == null || result.trim().isEmpty) return;
    await _repository.updateTitle(memo, result);
  }

  Future<void> _deleteMemo(VoiceMemo memo) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Memo löschen?'),
              content: const Text(
                'Die lokale Datei und Metadaten werden entfernt.',
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
    if (!confirmed) return;

    if (_playingMemoId == memo.id) {
      await _player.stop();
      if (mounted) setState(() => _playingMemoId = null);
    }
    await _repository.delete(memo);
  }

  String _defaultTitle(DateTime date) {
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final hh = date.hour.toString().padLeft(2, '0');
    final min = date.minute.toString().padLeft(2, '0');
    return 'Memo $dd.$mm. $hh:$min';
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
  });

  final VoiceMemo memo;
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
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
              tooltip: 'Titel bearbeiten',
              onPressed: onRename,
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: 'Löschen',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
          ],
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
