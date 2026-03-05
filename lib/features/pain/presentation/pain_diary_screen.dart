import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../data/pain_repository_sync.dart';
import '../domain/pain_entry.dart';
import 'pain_entry_editor_screen.dart';

class PainDiaryScreen extends StatefulWidget {
  const PainDiaryScreen({super.key});

  @override
  State<PainDiaryScreen> createState() => _PainDiaryScreenState();
}

class _PainDiaryScreenState extends State<PainDiaryScreen> {
  static final PainRepositorySync _repository = PainRepositorySync.instance;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _repository.loadFromDisk();
    await _repository.pullLatest();
  }

  @override
  Widget build(BuildContext context) {
    return GlassPage(
      title: 'Schmerztagebuch',
      titleEmoji: '😣',
      titleColor: AppColors.warning,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openEditor,
        icon: const Icon(Icons.add),
        label: const Text('Neu'),
      ),
      scrollableBody: (headerHeight) => StreamBuilder<List<PainEntry>>(
        stream: _repository.watchAll(),
        builder: (context, snapshot) {
          final items = snapshot.data ?? const <PainEntry>[];
          if (items.isEmpty) {
            return const Center(
              child: Text('Noch keine Einträge. Tippe auf "Neu".'),
            );
          }

          final grouped = _groupByDay(items);
          return ListView(
            padding: EdgeInsets.only(top: headerHeight + 8, bottom: 100),
            children: [
              for (final entry in grouped.entries) ...[
                _DayHeader(dayKey: entry.key, entries: entry.value),
                for (final item in entry.value) _PainTile(entry: item),
              ],
            ],
          );
        },
      ),
    );
  }

  Map<String, List<PainEntry>> _groupByDay(List<PainEntry> items) {
    final grouped = <String, List<PainEntry>>{};
    for (final item in items) {
      final key = _dayKey(item.occurredAt);
      grouped.putIfAbsent(key, () => <PainEntry>[]).add(item);
    }

    final sortedKeys = grouped.keys.toList(growable: false)
      ..sort((a, b) => b.compareTo(a));
    return <String, List<PainEntry>>{
      for (final key in sortedKeys) key: grouped[key]!,
    };
  }

  String _dayKey(DateTime value) {
    final day = DateTime(value.year, value.month, value.day);
    final mm = day.month.toString().padLeft(2, '0');
    final dd = day.day.toString().padLeft(2, '0');
    return '${day.year}-$mm-$dd';
  }

  Future<void> _openEditor({PainEntry? existing}) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => PainEntryEditorScreen(initialEntry: existing),
      ),
    );
    if (changed == true) {
      await _repository.pullLatest();
    }
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.dayKey, required this.entries});

  final String dayKey;
  final List<PainEntry> entries;

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(dayKey) ?? DateTime.now();
    final avgPain = entries.isEmpty
        ? 0
        : entries.map((e) => e.painLevel).reduce((a, b) => a + b) /
              entries.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${_humanLabel(date)}, ${_formatDate(date)}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          Text(
            'Ø ${avgPain.toStringAsFixed(1)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  String _humanLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final delta = target.difference(today).inDays;
    if (delta == 0) return 'Heute';
    if (delta == -1) return 'Gestern';
    const weekdays = <String>[
      'Montag',
      'Dienstag',
      'Mittwoch',
      'Donnerstag',
      'Freitag',
      'Samstag',
      'Sonntag',
    ];
    return weekdays[date.weekday - 1];
  }

  String _formatDate(DateTime date) {
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    return '$dd.$mm.${date.year}';
  }
}

class _PainTile extends StatelessWidget {
  const _PainTile({required this.entry});

  final PainEntry entry;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: _PainBadge(level: entry.painLevel),
        title: Text(
          '${_formatTime(entry.occurredAt)} · Schmerz ${entry.painLevel}/10',
        ),
        subtitle: Text(_subtitle()),
        isThreeLine: true,
        onTap: () {
          Navigator.of(context).push<bool>(
            MaterialPageRoute<bool>(
              builder: (_) => PainEntryEditorScreen(initialEntry: entry),
            ),
          );
        },
      ),
    );
  }

  String _subtitle() {
    final parts = <String>[];
    final note = entry.note.trim();
    if (note.isNotEmpty) parts.add(note);
    final location = entry.location?.trim();
    if (location != null && location.isNotEmpty) parts.add('Ort: $location');
    final trigger = entry.trigger?.trim();
    if (trigger != null && trigger.isNotEmpty) parts.add('Trigger: $trigger');
    if (entry.medicationTaken != null) {
      parts.add(entry.medicationTaken! ? 'Medikation: Ja' : 'Medikation: Nein');
    }
    if (parts.isEmpty) return 'Kein zusätzlicher Text';
    return parts.join(' · ');
  }

  String _formatTime(DateTime value) {
    final hh = value.hour.toString().padLeft(2, '0');
    final mm = value.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}

class _PainBadge extends StatelessWidget {
  const _PainBadge({required this.level});

  final int level;

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(level);
    return CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.15),
      child: Text(
        '$level',
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }

  Color _colorFor(int value) {
    if (value <= 3) return Colors.green;
    if (value <= 6) return Colors.orange;
    return Colors.red;
  }
}
