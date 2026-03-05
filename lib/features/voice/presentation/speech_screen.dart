import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../ui/ui.dart';
import '../data/voice_repository_sync.dart';
import '../domain/voice_memo.dart';

/// Combined "Sprache" screen with Speech-to-Text stub (Section A)
/// and Voice Memos recorder/player (Section B).
class SpeechScreen extends StatefulWidget {
  const SpeechScreen({super.key});

  @override
  State<SpeechScreen> createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  static final VoiceRepositorySync _repository = VoiceRepositorySync.instance;

  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

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
    _player.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() => _playingMemoId = null);
    });
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _player.dispose();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    await _repository.loadFromDisk();
    await _repository.pullLatest();
  }

  // ── Recording ─────────────────────────────────────────────────────────────

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
    if (uid == null || uid.trim().isEmpty) return;

    final now = DateTime.now();
    final durationMs = now.difference(startedAt).inMilliseconds;
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
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Memo gespeichert'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // ── Playback ──────────────────────────────────────────────────────────────

  Future<void> _togglePlay(VoiceMemo memo) async {
    if (_playingMemoId == memo.id) {
      await _player.pause();
      if (!mounted) return;
      setState(() => _playingMemoId = null);
      return;
    }
    if (memo.localFilePath.trim().isEmpty) return;
    final file = File(memo.localFilePath);
    if (!await file.exists()) return;
    await _player.stop();
    await _player.play(DeviceFileSource(memo.localFilePath));
    if (!mounted) return;
    setState(() => _playingMemoId = memo.id);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _defaultTitle(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final hh = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    return 'Memo $dd.$mm. $hh:$min';
  }

  String _formatDurationMs(int ms) {
    final totalSec = (ms / 1000).round();
    final m = (totalSec ~/ 60).toString().padLeft(2, '0');
    final s = (totalSec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final hh = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    return '$dd.$mm.${d.year}, $hh:$min';
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GlassPage(
      title: 'Sprache & Memos',
      titleEmoji: '🎤',
      titleColor: AppColors.accent,
      horizontalPadding: AppSpacing.lg,
      children: [
        const SizedBox(height: AppSpacing.xxl),

        // ═══════════════════════════════════════════════════════
        // SECTION A – Speech to Text
        // ═══════════════════════════════════════════════════════
        const Text(
          '🎙️ Sprache zu Text',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1C1C1E),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Arzt-Gespräche direkt in Text umwandeln.',
          style: TextStyle(fontSize: 15, color: Color(0xFF8E8E93)),
        ),
        const SizedBox(height: 16),

        // Outlined "Aufnahme starten" button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: _openSpeechToText,
            icon: const Text('🎤', style: TextStyle(fontSize: 22)),
            label: const Text('Aufnahme starten'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0A74FF),
              side: const BorderSide(color: Color(0xFF0A74FF), width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              textStyle: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.xxxl),

        // ═══════════════════════════════════════════════════════
        // SECTION B – Voice Memos
        // ═══════════════════════════════════════════════════════
        const Text(
          '🎙️ Sprachmemos',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1C1C1E),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Audiomemos aufnehmen und abspielen. '
          'Aufnahmen werden lokal gespeichert.',
          style: TextStyle(fontSize: 15, color: Color(0xFF8E8E93)),
        ),
        const SizedBox(height: 16),

        // Record card
        _IosCard(
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Recording duration indicator
              if (_isRecording)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _formatDuration(_recordingDuration),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFF3B30),
                    ),
                  ),
                ),
              // Big circular mic button
              GestureDetector(
                onTap: _toggleRecording,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _isRecording
                        ? const Color(0xFFFF3B30)
                        : const Color(0xFF0A74FF),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            (_isRecording
                                    ? const Color(0xFFFF3B30)
                                    : const Color(0xFF0A74FF))
                                .withValues(alpha: 0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                    size: 36,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _isRecording ? 'Tippen zum Stoppen' : 'Tippen zum Aufnehmen',
                style: const TextStyle(fontSize: 15, color: Color(0xFF8E8E93)),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Memo list card
        StreamBuilder<List<VoiceMemo>>(
          stream: _repository.watchAll(),
          builder: (context, snapshot) {
            final items = snapshot.data ?? const <VoiceMemo>[];
            if (items.isEmpty) {
              return _IosCard(
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: const [
                      SizedBox(height: 16),
                      Text('🎙️', style: TextStyle(fontSize: 40)),
                      SizedBox(height: 8),
                      Text(
                        'Noch keine Memos',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF8E8E93),
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              );
            }
            return _IosCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Aufnahmen',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...items.map(
                    (memo) => _MemoRow(
                      memo: memo,
                      isPlaying: _playingMemoId == memo.id,
                      onPlayPause: () => _togglePlay(memo),
                      formatDate: _formatDate,
                      formatDurationMs: _formatDurationMs,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // ── Speech-to-text ───────────────────────────────────────────────────

  void _openSpeechToText() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => const _SpeechToTextSheet(),
    );
  }
}

// ── Speech-to-Text Bottom Sheet ──────────────────────────────────────────────

class _SpeechToTextSheet extends StatefulWidget {
  const _SpeechToTextSheet();

  @override
  State<_SpeechToTextSheet> createState() => _SpeechToTextSheetState();
}

class _SpeechToTextSheetState extends State<_SpeechToTextSheet> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _available = false;
  bool _listening = false;
  String _transcript = '';
  String _partialText = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    final ok = await _speech.initialize(
      onError: (e) {
        if (!mounted) return;
        setState(() => _listening = false);
      },
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (!mounted) return;
          setState(() => _listening = false);
        }
      },
    );
    if (mounted) setState(() => _available = ok);
  }

  void _toggleListening() {
    if (_listening) {
      _speech.stop();
      // Commit partial text to full transcript.
      if (_partialText.isNotEmpty) {
        setState(() {
          _transcript += _partialText;
          _partialText = '';
        });
      }
      setState(() => _listening = false);
    } else {
      if (!_available) return;
      _speech.listen(
        localeId: 'de_DE',
        listenFor: const Duration(minutes: 5),
        pauseFor: const Duration(seconds: 10),
        onResult: (result) {
          if (!mounted) return;
          setState(() {
            if (result.finalResult) {
              _transcript += '${result.recognizedWords} ';
              _partialText = '';
            } else {
              _partialText = result.recognizedWords;
            }
          });
        },
      );
      setState(() => _listening = true);
    }
  }

  Future<void> _saveTranscript() async {
    final text = '$_transcript$_partialText'.trim();
    if (text.isEmpty) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final now = DateTime.now();
    final memo = VoiceMemo(
      id: 'stt_${now.microsecondsSinceEpoch}',
      ownerId: uid,
      title: 'Transkript ${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}. '
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      localFilePath: '',
      durationMs: 0,
      recordedAt: now,
      createdAt: now,
      updatedAt: now,
      syncStatus: VoiceSyncStatus.synced,
      metadata: <String, dynamic>{'transcript': text},
    );
    await VoiceRepositorySync.instance.upsert(memo);

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transkript gespeichert')),
      );
    }
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayText = '$_transcript$_partialText'.trim();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          32 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D1D6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '🎙️ Sprache zu Text',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1C1C1E),
              ),
            ),
            const SizedBox(height: 16),
            // Transcript box
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 120, maxHeight: 250),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: SingleChildScrollView(
                child: Text(
                  displayText.isEmpty
                      ? (_listening
                          ? 'Höre zu …'
                          : 'Tippe auf den Button, um die Aufnahme zu starten.')
                      : displayText,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: displayText.isEmpty
                        ? const Color(0xFF8E8E93)
                        : const Color(0xFF1C1C1E),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (!_available)
              const Text(
                'Spracherkennung nicht verfügbar.',
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
            const SizedBox(height: 8),
            // Mic toggle
            GestureDetector(
              onTap: _available ? _toggleListening : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: _listening
                      ? const Color(0xFFFF3B30)
                      : const Color(0xFF0A74FF),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  _listening ? Icons.stop_rounded : Icons.mic_rounded,
                  size: 32,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Save button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: displayText.isNotEmpty ? _saveTranscript : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A74FF),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFD1D1D6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                  textStyle: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Speichern'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── iOS card container ───────────────────────────────────────────────────────

class _IosCard extends StatelessWidget {
  const _IosCard({required this.child});

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

// ── Memo list row ────────────────────────────────────────────────────────────

class _MemoRow extends StatelessWidget {
  const _MemoRow({
    required this.memo,
    required this.isPlaying,
    required this.onPlayPause,
    required this.formatDate,
    required this.formatDurationMs,
  });

  final VoiceMemo memo;
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final String Function(DateTime) formatDate;
  final String Function(int) formatDurationMs;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Play / pause button
          GestureDetector(
            onTap: onPlayPause,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF0A74FF).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                size: 22,
                color: const Color(0xFF0A74FF),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  memo.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1C1C1E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${formatDate(memo.recordedAt)} · ${formatDurationMs(memo.durationMs)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8E8E93),
                  ),
                ),
              ],
            ),
          ),
          // Sync status dot
          _SyncDot(status: memo.syncStatus),
        ],
      ),
    );
  }
}

// ── Sync status dot ──────────────────────────────────────────────────────────

class _SyncDot extends StatelessWidget {
  const _SyncDot({required this.status});

  final VoiceSyncStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      VoiceSyncStatus.pending => const Color(0xFFFF9500),
      VoiceSyncStatus.synced => const Color(0xFF34C759),
      VoiceSyncStatus.failed => const Color(0xFFFF3B30),
    };
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
