import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../data/pain_repository_sync.dart';
import '../domain/pain_entry.dart';

/// Card-layout pain screen with slider, emoji row, and history card.
class PainScreen extends StatefulWidget {
  const PainScreen({super.key});

  @override
  State<PainScreen> createState() => _PainScreenState();
}

class _PainScreenState extends State<PainScreen> {
  static final PainRepositorySync _repository = PainRepositorySync.instance;

  double _painLevel = 3;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _repository.loadFromDisk();
    await _repository.pullLatest();
  }

  // ── Save ──────────────────────────────────────────────────────────────────
  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      final id = 'pain_${now.millisecondsSinceEpoch}';
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final entry = PainEntry(
        id: id,
        ownerId: uid,
        occurredAt: now,
        painLevel: _painLevel.round(),
        note: '',
        createdAt: now,
        updatedAt: now,
        metadata: const <String, dynamic>{'source': 'pain_screen'},
      );
      await _repository.upsert(entry);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Schmerzwert gespeichert'),
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  static const _emojis = ['😊', '😐', '😣', '😖', '😫'];

  String _emojiForLevel(int level) {
    if (level <= 2) return _emojis[0];
    if (level <= 4) return _emojis[1];
    if (level <= 6) return _emojis[2];
    if (level <= 8) return _emojis[3];
    return _emojis[4];
  }

  Color _colorForLevel(int level) {
    if (level <= 2) return const Color(0xFF34C759);
    if (level <= 4) return const Color(0xFFFFCC00);
    if (level <= 6) return const Color(0xFFFF9500);
    if (level <= 8) return const Color(0xFFFF6B6B);
    return const Color(0xFFFF3B30);
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
    final level = _painLevel.round();

    return GlassPage(
      title: 'Schmerz',
      titleEmoji: '😣',
      titleColor: AppColors.warning,
      horizontalPadding: AppSpacing.lg,
      children: [
        const SizedBox(height: AppSpacing.xl),

        // ── Card 1: Aktuelle Schmerzen ───────────────────────
        _IosCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Aktuelle Schmerzen',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1C1C1E),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '0 = keine, 10 = unerträglich',
                style: TextStyle(fontSize: 14, color: Color(0xFF8E8E93)),
              ),
              const SizedBox(height: 20),

              // Slider + value
              Row(
                children: [
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: _colorForLevel(level),
                        inactiveTrackColor: const Color(0xFFE5E5EA),
                        thumbColor: const Color(0xFF0A74FF),
                        overlayColor: const Color(
                          0xFF0A74FF,
                        ).withValues(alpha: 0.12),
                        trackHeight: 6,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 14,
                        ),
                      ),
                      child: Slider(
                        value: _painLevel,
                        min: 0,
                        max: 10,
                        divisions: 10,
                        onChanged: (v) => setState(() => _painLevel = v),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$level',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: _colorForLevel(level),
                      height: 1,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Emoji row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _emojis.map((emoji) {
                  final isActive = _emojiForLevel(level) == emoji;
                  return AnimatedScale(
                    scale: isActive ? 1.25 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      emoji,
                      style: TextStyle(
                        fontSize: 28,
                        color: isActive
                            ? null
                            : Colors.black.withValues(alpha: 0.25),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A74FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                    textStyle: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Speichern'),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // ── Card 2: Verlauf ──────────────────────────────────
        StreamBuilder<List<PainEntry>>(
          stream: _repository.watchAll(),
          builder: (context, snapshot) {
            final items = snapshot.data ?? const <PainEntry>[];
            return _IosCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Verlauf',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (items.length < 2)
                    _buildEmptyState()
                  else
                    _buildHistory(items),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // ── Empty state ─────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          const SizedBox(height: 12),
          const Text('📊', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 8),
          const Text(
            'Mind. 2 Einträge',
            style: TextStyle(fontSize: 15, color: Color(0xFF8E8E93)),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ── History list ────────────────────────────────────────────────────────
  Widget _buildHistory(List<PainEntry> items) {
    // Show last 10 entries, newest first (watchAll already sorts descending).
    final recent = items.take(10).toList();
    return Column(
      children: [
        // Mini chart bar
        _MiniChart(entries: recent),
        const SizedBox(height: 16),
        // List
        ...recent.map(
          (entry) => _HistoryRow(
            entry: entry,
            formatDate: _formatDate,
            colorForLevel: _colorForLevel,
          ),
        ),
      ],
    );
  }
}

// ── Reusable iOS card container ──────────────────────────────────────────────

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

// ── Mini bar chart ───────────────────────────────────────────────────────────

class _MiniChart extends StatelessWidget {
  const _MiniChart({required this.entries});

  final List<PainEntry> entries;

  Color _color(int level) {
    if (level <= 2) return const Color(0xFF34C759);
    if (level <= 4) return const Color(0xFFFFCC00);
    if (level <= 6) return const Color(0xFFFF9500);
    if (level <= 8) return const Color(0xFFFF6B6B);
    return const Color(0xFFFF3B30);
  }

  @override
  Widget build(BuildContext context) {
    // Show entries in chronological order (oldest left, newest right).
    final ordered = entries.reversed.toList();
    return SizedBox(
      height: 60,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: ordered.map((e) {
          final ratio = e.painLevel / 10;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${e.painLevel}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
                  const SizedBox(height: 2),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 4 + (ratio * 36),
                    decoration: BoxDecoration(
                      color: _color(e.painLevel),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── History row ──────────────────────────────────────────────────────────────

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.entry,
    required this.formatDate,
    required this.colorForLevel,
  });

  final PainEntry entry;
  final String Function(DateTime) formatDate;
  final Color Function(int) colorForLevel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          // Color badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colorForLevel(entry.painLevel).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${entry.painLevel}',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: colorForLevel(entry.painLevel),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              formatDate(entry.occurredAt),
              style: const TextStyle(fontSize: 15, color: Color(0xFF1C1C1E)),
            ),
          ),
          Text(
            '${entry.painLevel}/10',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: colorForLevel(entry.painLevel),
            ),
          ),
        ],
      ),
    );
  }
}
