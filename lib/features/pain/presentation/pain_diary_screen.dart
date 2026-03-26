import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../main.dart';
import '../../../ui/ui.dart';
import '../../pro/domain/trigger_context.dart';
import '../../pro/presentation/smart_paywall.dart';
import '../data/pain_repository_sync.dart';
import '../domain/pain_entry.dart';
import 'pain_entry_editor_screen.dart';
import '../../../ui/theme/app_icons.dart';
import '../../../l10n/app_localizations.dart';

class PainDiaryScreen extends StatefulWidget {
  const PainDiaryScreen({super.key});

  @override
  State<PainDiaryScreen> createState() => _PainDiaryScreenState();
}

class _PainDiaryScreenState extends State<PainDiaryScreen> {
  static final PainRepositorySync _repository = PainRepositorySync.instance;

  BodyRegion? _filterRegion;
  PainType? _filterType;
  bool _showFilters = false;

  bool get _isPro =>
      ProServices.maybeOf(context)?.entitlementService.isPro ?? false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _repository.loadFromDisk();
    if (!mounted) return;
    try {
      await _repository.pullLatest();
    } catch (e) {
      debugPrint('[PainDiaryScreen] pullLatest failed (offline?): $e');
    }
  }

  List<PainEntry> _applyFilters(List<PainEntry> items) {
    var result = items;
    if (_filterRegion != null) {
      result = result.where((e) => e.bodyRegion == _filterRegion).toList();
    }
    if (_filterType != null) {
      result = result.where((e) => e.painType == _filterType).toList();
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return GlassPage(
      title: 'Schmerztagebuch',
      titleIcon: AppIcons.diary,
      titleColor: AppColors.warning,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openEditor,
        icon: const Icon(Icons.add_rounded),
        label: Text(l.entryNew),
        backgroundColor: const Color(0xFF0A74FF),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      scrollableBody: (headerHeight) => StreamBuilder<List<PainEntry>>(
        stream: _repository.watchAll(),
        builder: (context, snapshot) {
          final allItems = snapshot.data ?? const <PainEntry>[];
          final items = _applyFilters(allItems);

          return ListView(
            padding: EdgeInsets.only(top: headerHeight + 8, bottom: 100),
            children: [
              // Calendar heatmap (Pro feature)
              _buildCalendarSection(allItems),

              // Filters
              _buildFilterSection(),

              // Statistics card
              if (items.length >= 2) ...[
                _buildInsightsCard(items),
                const SizedBox(height: 8),
              ],

              if (items.isEmpty)
                _buildEmptyState()
              else ...[
                // Grouped entries
                ..._buildGroupedEntries(items),
              ],
            ],
          );
        },
      ),
    );
  }

  // ── Calendar heatmap ────────────────────────────────────────────────────
  Widget _buildCalendarSection(List<PainEntry> items) {
    final isPro = _isPro;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: _CardContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GlassIcon(icon: AppIcons.appointments, color: AppIcons.appointmentsColor, size: 14),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Kalender',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                ),
                if (!isPro)
                  GestureDetector(
                    onTap: () => SmartPaywall.trigger(
                      context: context,
                      triggerContext: TriggerContext.painDiaryInsights,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock_rounded,
                              size: 11, color: Color(0xFFFF9500)),
                          SizedBox(width: 3),
                          Text(
                            'Pro',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFFF9500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (isPro)
              _CalendarHeatmap(entries: items)
            else
              GestureDetector(
                onTap: () => SmartPaywall.trigger(
                  context: context,
                  triggerContext: TriggerContext.painDiaryInsights,
                ),
                child: _CalendarHeatmap(
                  entries: items,
                  blurred: true,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Filter section ──────────────────────────────────────────────────────
  Widget _buildFilterSection() {
    final l = AppLocalizations.of(context)!;
    final hasFilter = _filterRegion != null || _filterType != null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _showFilters = !_showFilters),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: hasFilter
                    ? const Color(0xFF0A74FF).withValues(alpha: 0.08)
                    : const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasFilter
                      ? const Color(0xFF0A74FF).withValues(alpha: 0.3)
                      : const Color(0xFFE5E5EA),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _showFilters
                        ? Icons.filter_list_off_rounded
                        : Icons.filter_list_rounded,
                    size: 18,
                    color: hasFilter
                        ? const Color(0xFF0A74FF)
                        : const Color(0xFF8E8E93),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    hasFilter ? 'Filter aktiv' : 'Filtern',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: hasFilter
                          ? const Color(0xFF0A74FF)
                          : const Color(0xFF3C3C43),
                    ),
                  ),
                  const Spacer(),
                  if (hasFilter)
                    GestureDetector(
                      onTap: () => setState(() {
                        _filterRegion = null;
                        _filterType = null;
                      }),
                      child: Text(
                        l.reset,
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFFFF3B30),
                        ),
                      ),
                    ),
                  if (!hasFilter)
                    Icon(
                      _showFilters
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      size: 20,
                      color: const Color(0xFF8E8E93),
                    ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _showFilters
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Körperregion',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: BodyRegion.values.map((r) {
                      final sel = _filterRegion == r;
                      return _FilterChip(
                        label: r.label,
                        selected: sel,
                        onTap: () => setState(
                          () => _filterRegion = sel ? null : r,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Schmerzart',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: PainType.values.map((t) {
                      final sel = _filterType == t;
                      return _FilterChip(
                        label: t.label,
                        selected: sel,
                        onTap: () => setState(
                          () => _filterType = sel ? null : t,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Insights card ───────────────────────────────────────────────────────
  Widget _buildInsightsCard(List<PainEntry> items) {
    final now = DateTime.now();
    final last7 =
        items.where((e) => now.difference(e.occurredAt).inDays < 7).toList();
    final avg7 = last7.isEmpty
        ? 0.0
        : last7.map((e) => e.painLevel).reduce((a, b) => a + b) / last7.length;
    final lowest = items.map((e) => e.painLevel).reduce(math.min);
    final highest = items.map((e) => e.painLevel).reduce(math.max);

    // Most common body region
    String? topRegion;
    final regionCounts = <BodyRegion, int>{};
    for (final e in items) {
      if (e.bodyRegion != null) {
        regionCounts[e.bodyRegion!] = (regionCounts[e.bodyRegion!] ?? 0) + 1;
      }
    }
    if (regionCounts.isNotEmpty) {
      final sorted = regionCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      topRegion = sorted.first.key.label;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _CardContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                GlassIcon(icon: AppIcons.info, color: AppIcons.infoColor, size: 14),
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
                  icon: AppIcons.analytics, iconColor: AppIcons.analyticsColor,
                  label: 'Ø 7 Tage',
                  value: avg7.toStringAsFixed(1),
                  color: _colorForLevel(avg7.round()),
                ),
                const SizedBox(width: 8),
                _InsightPill(
                  icon: AppIcons.analytics, iconColor: AppIcons.analyticsColor,
                  label: 'Min',
                  value: '$lowest',
                  color: const Color(0xFF34C759),
                ),
                const SizedBox(width: 8),
                _InsightPill(
                  icon: AppIcons.progress, iconColor: AppIcons.progressColor,
                  label: 'Max',
                  value: '$highest',
                  color: const Color(0xFFFF3B30),
                ),
              ],
            ),
            if (topRegion != null) ...[
              const SizedBox(height: 8),
              Text(
                'Häufigstes Gebiet: $topRegion',
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

  // ── Empty state ─────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          const SizedBox(height: 60),
          GlassIcon(icon: AppIcons.notes, color: AppIcons.notesColor, size: 33),
          const SizedBox(height: 12),
          Text(
            (_filterRegion != null || _filterType != null)
                ? 'Keine Einträge mit diesen Filtern'
                : 'Noch keine Einträge',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3C3C43),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tippe auf "+ Neuer Eintrag" um zu starten',
            style: TextStyle(fontSize: 14, color: Color(0xFF8E8E93)),
          ),
        ],
      ),
    );
  }

  // ── Grouped entries ─────────────────────────────────────────────────────
  List<Widget> _buildGroupedEntries(List<PainEntry> items) {
    final grouped = _groupByDay(items);
    final widgets = <Widget>[];
    for (final entry in grouped.entries) {
      widgets.add(
        _DayHeader(dayKey: entry.key, entries: entry.value),
      );
      for (final item in entry.value) {
        widgets.add(
          _PainEntryCard(
            entry: item,
            onTap: () => _openEditor(existing: item),
          ),
        );
      }
    }
    return widgets;
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
    final mm = value.month.toString().padLeft(2, '0');
    final dd = value.day.toString().padLeft(2, '0');
    return '${value.year}-$mm-$dd';
  }

  Color _colorForLevel(int level) {
    if (level <= 2) return const Color(0xFF34C759);
    if (level <= 4) return const Color(0xFFFFCC00);
    if (level <= 6) return const Color(0xFFFF9500);
    if (level <= 8) return const Color(0xFFFF6B6B);
    return const Color(0xFFFF3B30);
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

// ═══════════════════════════════════════════════════════════════════════════════
// ── Supporting widgets
// ═══════════════════════════════════════════════════════════════════════════════

class _CardContainer extends StatelessWidget {
  const _CardContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 16,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
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
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF0A74FF).withValues(alpha: 0.1)
              : const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? const Color(0xFF0A74FF)
                : const Color(0xFFE5E5EA),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected
                ? const Color(0xFF0A74FF)
                : const Color(0xFF3C3C43),
          ),
        ),
      ),
    );
  }
}

class _InsightPill extends StatelessWidget {
  const _InsightPill({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF8E8E93),
              ),
            ),
          ],
        ),
      ),
    );
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

    Color avgColor;
    if (avgPain <= 2) {
      avgColor = const Color(0xFF34C759);
    } else if (avgPain <= 4) {
      avgColor = const Color(0xFFFFCC00);
    } else if (avgPain <= 6) {
      avgColor = const Color(0xFFFF9500);
    } else {
      avgColor = const Color(0xFFFF3B30);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${_humanLabel(date)}, ${_formatDate(date)}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1C1C1E),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: avgColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Ø ${avgPain.toStringAsFixed(1)}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: avgColor,
              ),
            ),
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

class _PainEntryCard extends StatelessWidget {
  const _PainEntryCard({required this.entry, this.onTap});

  final PainEntry entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(entry.painLevel);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border(
              left: BorderSide(color: color, width: 3),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 12,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Pain level badge
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${entry.painLevel}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _formatTime(entry.occurredAt),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1C1C1E),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${entry.painLevel}/10',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    _buildSubtitle(),
                  ],
                ),
              ),
              // Chips
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (entry.bodyRegion != null)
                    _SmallTag(
                      text: entry.bodyRegion!.label,
                      bgColor: const Color(0xFFF2F2F7),
                    ),
                  if (entry.painType != null) ...[
                    const SizedBox(height: 2),
                    _SmallTag(
                      text: entry.painType!.label,
                      bgColor: const Color(0xFFF2F2F7),
                    ),
                  ],
                  if (entry.medicationTaken == true) ...[
                    const SizedBox(height: 2),
                    const _SmallTag(
                      text: '💊',
                      bgColor: Color(0xFFE8F5E9),
                    ),
                  ],
                ],
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: Color(0xFFD1D1D6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    final parts = <String>[];
    if (entry.bodyRegion != null) parts.add(entry.bodyRegion!.label);
    if (entry.painType != null) parts.add(entry.painType!.label);
    final note = entry.note.trim();
    if (note.isNotEmpty) parts.add(note);
    final location = entry.location?.trim();
    if (location != null && location.isNotEmpty) parts.add(location);
    final trigger = entry.trigger?.trim();
    if (trigger != null && trigger.isNotEmpty) parts.add(trigger);

    if (parts.isEmpty) {
      return const Text(
        'Keine Details',
        style: TextStyle(fontSize: 13, color: Color(0xFFC7C7CC)),
      );
    }
    return Text(
      parts.join(' · '),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 13, color: Color(0xFF8E8E93)),
    );
  }

  String _formatTime(DateTime value) {
    final hh = value.hour.toString().padLeft(2, '0');
    final mm = value.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  Color _colorFor(int level) {
    if (level <= 2) return const Color(0xFF34C759);
    if (level <= 4) return const Color(0xFFFFCC00);
    if (level <= 6) return const Color(0xFFFF9500);
    if (level <= 8) return const Color(0xFFFF6B6B);
    return const Color(0xFFFF3B30);
  }
}

class _SmallTag extends StatelessWidget {
  const _SmallTag({required this.text, required this.bgColor});

  final String text;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }
}

// ── Calendar heatmap ─────────────────────────────────────────────────────────

class _CalendarHeatmap extends StatelessWidget {
  const _CalendarHeatmap({required this.entries, this.blurred = false});

  final List<PainEntry> entries;
  final bool blurred;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Show last 35 days (5 weeks)
    final start = today.subtract(const Duration(days: 34));

    // Build pain-per-day map
    final dayPain = <String, List<int>>{};
    for (final e in entries) {
      final key = _dayKey(e.occurredAt);
      dayPain.putIfAbsent(key, () => <int>[]).add(e.painLevel);
    }

    final cells = <Widget>[];
    for (int i = 0; i < 35; i++) {
      final day = start.add(Duration(days: i));
      final key = _dayKey(day);
      final levels = dayPain[key];
      final avg =
          levels == null ? -1.0 : levels.reduce((a, b) => a + b) / levels.length;
      cells.add(_HeatCell(
        day: day,
        avgPain: avg,
        isToday: day == today,
        entryCount: levels?.length ?? 0,
      ));
    }

    return Stack(
      children: [
        // Weekday labels
        Column(
          children: [
            // Day labels row
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _WeekdayLabel('Mo'),
                _WeekdayLabel('Di'),
                _WeekdayLabel('Mi'),
                _WeekdayLabel('Do'),
                _WeekdayLabel('Fr'),
                _WeekdayLabel('Sa'),
                _WeekdayLabel('So'),
              ],
            ),
            const SizedBox(height: 4),
            // Grid
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 3,
              crossAxisSpacing: 3,
              children: cells,
            ),
            const SizedBox(height: 8),
            // Legend
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendDot(color: Color(0xFFE5E5EA), label: 'Kein'),
                SizedBox(width: 8),
                _LegendDot(color: Color(0xFF34C759), label: '0–2'),
                SizedBox(width: 8),
                _LegendDot(color: Color(0xFFFFCC00), label: '3–4'),
                SizedBox(width: 8),
                _LegendDot(color: Color(0xFFFF9500), label: '5–6'),
                SizedBox(width: 8),
                _LegendDot(color: Color(0xFFFF3B30), label: '7+'),
              ],
            ),
          ],
        ),
        if (blurred)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_rounded, color: Color(0xFFFF9500), size: 24),
                  SizedBox(height: 4),
                  Text(
                    'Kalender mit Pro freischalten',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFF9500),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  String _dayKey(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }
}

class _HeatCell extends StatelessWidget {
  const _HeatCell({
    required this.day,
    required this.avgPain,
    required this.isToday,
    required this.entryCount,
  });

  final DateTime day;
  final double avgPain;
  final bool isToday;
  final int entryCount;

  Color get _color {
    if (avgPain < 0) return const Color(0xFFF2F2F7);
    if (avgPain <= 2) return const Color(0xFF34C759);
    if (avgPain <= 4) return const Color(0xFFFFCC00);
    if (avgPain <= 6) return const Color(0xFFFF9500);
    return const Color(0xFFFF3B30);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _color.withValues(alpha: avgPain < 0 ? 1.0 : 0.6),
        borderRadius: BorderRadius.circular(4),
        border: isToday
            ? Border.all(color: const Color(0xFF0A74FF), width: 1.5)
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: TextStyle(
          fontSize: 9,
          fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
          color: avgPain >= 5
              ? Colors.white
              : const Color(0xFF3C3C43),
        ),
      ),
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  const _WeekdayLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Color(0xFF8E8E93),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(fontSize: 9, color: Color(0xFF8E8E93)),
        ),
      ],
    );
  }
}
