import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../ui/ui.dart';
import '../../../ui/theme/app_icons.dart';
import '../data/mood_repository_sync.dart';
import '../domain/mood_entry.dart';
import 'mood_entry_editor_screen.dart';

/// Main mood screen with quick-entry emoji row, mini chart and recent entries.
class MoodScreen extends StatefulWidget {
  const MoodScreen({super.key});

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen>
    with SingleTickerProviderStateMixin {
  static final MoodRepositorySync _repository = MoodRepositorySync.instance;

  MoodLevel _selectedLevel = MoodLevel.neutral;
  bool _saving = false;

  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _bootstrap();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    await _repository.loadFromDisk();
    await _repository.pullLatest();
  }

  // ── Save ──────────────────────────────────────────────────────────────────
  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    HapticFeedback.mediumImpact();
    try {
      final now = DateTime.now();
      final id = 'mood_${now.millisecondsSinceEpoch}';
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final entry = MoodEntry(
        id: id,
        ownerId: uid,
        moodLevel: _selectedLevel,
        createdAt: now,
        updatedAt: now,
        metadata: const <String, dynamic>{'source': 'mood_screen'},
      );
      await _repository.upsert(entry);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Text(_selectedLevel.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              const Text('Stimmung gespeichert'),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1400),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _openEditor([MoodEntry? entry]) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MoodEntryEditorScreen(initialEntry: entry),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Color _colorForLevel(MoodLevel level) {
    return switch (level) {
      MoodLevel.veryBad => const Color(0xFFFF3B30),
      MoodLevel.bad => const Color(0xFFFF9500),
      MoodLevel.neutral => const Color(0xFFFFCC00),
      MoodLevel.good => const Color(0xFF34C759),
      MoodLevel.veryGood => const Color(0xFF30D158),
    };
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GlassPage(
      title: 'Stimmung',
      titleIcon: Icons.sentiment_satisfied_rounded,
      titleColor: AppColors.accent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Detaillierter Eintrag'),
        backgroundColor: const Color(0xFF0A74FF),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      scrollableBody: (headerHeight) => StreamBuilder<List<MoodEntry>>(
        stream: _repository.watchAll(),
        builder: (context, snapshot) {
          final items = snapshot.data ?? const <MoodEntry>[];

          return ListView(
            padding: EdgeInsets.only(top: headerHeight + 8, bottom: 100),
            children: [
              // Quick entry
              _buildQuickEntry(),

              // Calendar overview
              _buildCalendarSection(items),

              // Insights
              if (items.length >= 2) ...[
                _buildInsightsCard(items),
                const SizedBox(height: 8),
              ],

              // Entries list
              if (items.isEmpty)
                _buildEmptyState()
              else
                ..._buildGroupedEntries(items),
            ],
          );
        },
      ),
    );
  }

  // ── Quick Entry ─────────────────────────────────────────────────────────

  Widget _buildQuickEntry() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: _CardContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                GlassIcon(
                  icon: Icons.sentiment_satisfied_rounded,
                  color: AppColors.accent,
                  size: 14,
                ),
                SizedBox(width: 8),
                Text(
                  'Wie geht es dir?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1C1C1E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: MoodLevel.values.map((level) {
                final isSelected = _selectedLevel == level;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedLevel = level);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _colorForLevel(level).withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? _colorForLevel(level).withValues(alpha: 0.5)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            final scale =
                                isSelected ? _pulseAnimation.value : 1.0;
                            return Transform.scale(
                              scale: scale,
                              child: child,
                            );
                          },
                          child: Text(
                            level.emoji,
                            style: TextStyle(
                              fontSize: isSelected ? 36 : 28,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          level.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? _colorForLevel(level)
                                : const Color(0xFF8E8E93),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _colorForLevel(_selectedLevel),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          '${_selectedLevel.emoji}  Speichern',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Calendar ────────────────────────────────────────────────────────────

  Widget _buildCalendarSection(List<MoodEntry> items) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: _CardContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                GlassIcon(
                  icon: AppIcons.appointments,
                  color: AppIcons.appointmentsColor,
                  size: 14,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Kalender',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _MoodCalendarHeatmap(entries: items),
          ],
        ),
      ),
    );
  }

  // ── Insights ────────────────────────────────────────────────────────────

  Widget _buildInsightsCard(List<MoodEntry> items) {
    final now = DateTime.now();
    final last7 =
        items.where((e) => now.difference(e.createdAt).inDays < 7).toList();
    final avg7 = last7.isEmpty
        ? 0.0
        : last7.map((e) => e.moodLevel.value).reduce((a, b) => a + b) /
            last7.length;

    // Most common category
    String? topCategory;
    final catCounts = <MoodCategory, int>{};
    for (final e in items) {
      for (final c in e.categories) {
        catCounts[c] = (catCounts[c] ?? 0) + 1;
      }
    }
    if (catCounts.isNotEmpty) {
      final sorted = catCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      topCategory = '${sorted.first.key.emoji} ${sorted.first.key.label}';
    }

    final best =
        items.map((e) => e.moodLevel.value).reduce(math.max);
    final worst =
        items.map((e) => e.moodLevel.value).reduce(math.min);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _CardContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                GlassIcon(
                  icon: AppIcons.info,
                  color: AppIcons.infoColor,
                  size: 14,
                ),
                SizedBox(width: 8),
                Text(
                  'Insights',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1C1C1E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _InsightPill(
                  label: 'Ø 7 Tage',
                  value: avg7.toStringAsFixed(1),
                  color: _colorForMoodValue(avg7),
                ),
                const SizedBox(width: 8),
                _InsightPill(
                  label: 'Beste',
                  value: MoodLevel.values[best - 1].emoji,
                  color: const Color(0xFF34C759),
                ),
                const SizedBox(width: 8),
                _InsightPill(
                  label: 'Schlechteste',
                  value: MoodLevel.values[worst - 1].emoji,
                  color: const Color(0xFFFF3B30),
                ),
              ],
            ),
            if (topCategory != null) ...[
              const SizedBox(height: 8),
              Text(
                'Häufigster Faktor: $topCategory',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF8E8E93),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _colorForMoodValue(double value) {
    if (value <= 1.5) return const Color(0xFFFF3B30);
    if (value <= 2.5) return const Color(0xFFFF9500);
    if (value <= 3.5) return const Color(0xFFFFCC00);
    if (value <= 4.5) return const Color(0xFF34C759);
    return const Color(0xFF30D158);
  }

  // ── Empty state ─────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('😊', style: TextStyle(fontSize: 32)),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Noch keine Stimmungseinträge',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C1C1E),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Erfasse deine Stimmung, um Trends und Muster zu erkennen.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Color(0xFF8E8E93)),
          ),
        ],
      ),
    );
  }

  // ── Grouped entries ─────────────────────────────────────────────────────

  List<Widget> _buildGroupedEntries(List<MoodEntry> items) {
    final grouped = <String, List<MoodEntry>>{};
    for (final entry in items) {
      final key = _dayKey(entry.createdAt);
      (grouped[key] ??= []).add(entry);
    }

    final widgets = <Widget>[];
    for (final MapEntry(key: dayKey, value: dayItems) in grouped.entries) {
      final date = DateTime.tryParse(dayKey) ?? DateTime.now();
      final avg = dayItems.map((e) => e.moodLevel.value).reduce((a, b) => a + b) /
          dayItems.length;

      widgets.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Text(
                _formatDate(date),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF8E8E93),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _colorForMoodValue(avg).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Ø ${avg.toStringAsFixed(1)}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _colorForMoodValue(avg),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      for (final entry in dayItems) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
            child: _MoodEntryCard(
              entry: entry,
              onTap: () => _openEditor(entry),
            ),
          ),
        );
      }
    }
    return widgets;
  }

  String _dayKey(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day).toIso8601String().split('T').first;

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    if (d == today) return 'Heute';
    if (d == today.subtract(const Duration(days: 1))) return 'Gestern';
    return '${date.day}.${date.month}.${date.year}';
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Private widgets
// ═════════════════════════════════════════════════════════════════════════════

class _CardContainer extends StatelessWidget {
  const _CardContainer({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _InsightPill extends StatelessWidget {
  const _InsightPill({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8E8E93),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodEntryCard extends StatelessWidget {
  const _MoodEntryCard({required this.entry, this.onTap});
  final MoodEntry entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final time =
        '${entry.createdAt.hour.toString().padLeft(2, '0')}:${entry.createdAt.minute.toString().padLeft(2, '0')}';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 8,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(entry.moodLevel.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.moodLevel.label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                  if (entry.categories.isNotEmpty)
                    Text(
                      entry.categories.map((c) => c.label).join(', '),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8E8E93),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (entry.note != null && entry.note!.isNotEmpty)
                    Text(
                      entry.note!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8E8E93),
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8E8E93),
                  ),
                ),
                if (entry.sleepHours != null)
                  Text(
                    '😴 ${entry.sleepHours!.toStringAsFixed(1)}h',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: Color(0xFFC7C7CC),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Calendar Heatmap ──────────────────────────────────────────────────────

class _MoodCalendarHeatmap extends StatelessWidget {
  const _MoodCalendarHeatmap({required this.entries});
  final List<MoodEntry> entries;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final startDay = today.subtract(const Duration(days: 34));

    // Build day → avg mood value map
    final dayMap = <String, List<int>>{};
    for (final e in entries) {
      final key = '${e.createdAt.year}-${e.createdAt.month}-${e.createdAt.day}';
      (dayMap[key] ??= []).add(e.moodLevel.value);
    }

    final days = List.generate(35, (i) => startDay.add(Duration(days: i)));

    return Column(
      children: [
        // Day labels
        Row(
          children: ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So']
              .map(
                (d) => Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFAEAEB2),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 4),
        // Grid
        ...List.generate(5, (week) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Row(
              children: List.generate(7, (dow) {
                final index = week * 7 + dow;
                if (index >= days.length) {
                  return const Expanded(child: SizedBox(height: 28));
                }
                final day = days[index];
                final key = '${day.year}-${day.month}-${day.day}';
                final values = dayMap[key];
                final isToday = day.year == today.year &&
                    day.month == today.month &&
                    day.day == today.day;

                Color bgColor;
                String? emoji;
                if (values != null && values.isNotEmpty) {
                  final avg = values.reduce((a, b) => a + b) / values.length;
                  final level = MoodLevel.values[(avg.round() - 1).clamp(0, 4)];
                  bgColor = _colorForLevel(level).withValues(alpha: 0.25);
                  emoji = level.emoji;
                } else {
                  bgColor = const Color(0xFFF2F2F7);
                }

                return Expanded(
                  child: Container(
                    height: 28,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(6),
                      border: isToday
                          ? Border.all(
                              color: AppColors.primary.withValues(alpha: 0.5),
                              width: 1.5,
                            )
                          : null,
                    ),
                    child: Center(
                      child: emoji != null
                          ? Text(emoji, style: const TextStyle(fontSize: 14))
                          : Text(
                              '${day.day}',
                              style: TextStyle(
                                fontSize: 10,
                                color: isToday
                                    ? AppColors.primary
                                    : const Color(0xFFAEAEB2),
                                fontWeight: isToday
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ],
    );
  }

  Color _colorForLevel(MoodLevel level) {
    return switch (level) {
      MoodLevel.veryBad => const Color(0xFFFF3B30),
      MoodLevel.bad => const Color(0xFFFF9500),
      MoodLevel.neutral => const Color(0xFFFFCC00),
      MoodLevel.good => const Color(0xFF34C759),
      MoodLevel.veryGood => const Color(0xFF30D158),
    };
  }
}
