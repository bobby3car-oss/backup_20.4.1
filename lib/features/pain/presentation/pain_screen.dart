import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../main.dart';
import '../../../ui/ui.dart';
import '../../pro/domain/trigger_context.dart';
import '../../pro/presentation/smart_paywall.dart';
import '../data/pain_repository_sync.dart';
import '../domain/pain_entry.dart';
import 'pain_diary_screen.dart';
import 'pain_entry_editor_screen.dart';
import '../../../ui/theme/app_icons.dart';
import '../../../l10n/app_localizations.dart';

/// Card-layout pain screen with slider, emoji row, body-region chips,
/// pain-type chips, mini chart and trend card.
class PainScreen extends StatefulWidget {
  const PainScreen({super.key});

  @override
  State<PainScreen> createState() => _PainScreenState();
}

class _PainScreenState extends State<PainScreen>
    with SingleTickerProviderStateMixin {
  static final PainRepositorySync _repository = PainRepositorySync.instance;

  double _painLevel = 3;
  bool _saving = false;
  BodyRegion? _bodyRegion;
  PainType? _painType;

  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnimation;

  bool get _isPro =>
      ProServices.maybeOf(context)?.entitlementService.isPro ?? false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
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
    try {
      await _repository.pullLatest();
    } catch (e) {
      debugPrint('[PainScreen] pullLatest failed (offline?): $e');
    }
  }

  // ── Save ──────────────────────────────────────────────────────────────────
  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    HapticFeedback.mediumImpact();
    try {
      final l = AppLocalizations.of(context)!;
      final now = DateTime.now();
      final id = 'pain_${now.millisecondsSinceEpoch}';
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final entry = PainEntry(
        id: id,
        ownerId: uid,
        occurredAt: now,
        painLevel: _painLevel.round(),
        bodyRegion: _bodyRegion,
        painType: _painType,
        note: '',
        createdAt: now,
        updatedAt: now,
        metadata: const <String, dynamic>{'source': 'pain_screen'},
      );
      await _repository.upsert(entry);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _colorForLevel(_painLevel.round()),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${_painLevel.round()}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(l.painSaved),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(userFacingError(e))));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Color _colorForLevel(int level) {
    if (level <= 2) return const Color(0xFF34C759);
    if (level <= 4) return const Color(0xFFFFCC00);
    if (level <= 6) return const Color(0xFFFF9500);
    if (level <= 8) return const Color(0xFFFF6B6B);
    return const Color(0xFFFF3B30);
  }

  String _painDescription(int level) {
    final l = AppLocalizations.of(context)!;
    if (level == 0) return l.schmerzfrei;
    if (level <= 2) return l.scSeverityMild;
    if (level <= 4) return l.maessig;
    if (level <= 6) return l.scSeverityModerate;
    if (level <= 8) return l.scSeveritySevere;
    return l.sehrStark;
  }

  String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final hh = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    return '$dd.$mm.${d.year}, $hh:$min';
  }

  String _formatRelative(DateTime d) {
    final l = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final diff = now.difference(d);
    if (diff.inMinutes < 1) return l.gradesEben;
    if (diff.inMinutes < 60) return l.vorMinuten(diff.inMinutes);
    if (diff.inHours < 24) return l.vorStunden(diff.inHours);
    if (diff.inDays == 1) return l.gestern;
    if (diff.inDays < 7) return l.vorTagen(diff.inDays);
    return _formatDate(d);
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final level = _painLevel.round();
    final color = _colorForLevel(level);

    return GlassPage(
      title: l.schmerztagebuch,
      titleIcon: AppIcons.notes,
      titleColor: AppColors.warning,
      horizontalPadding: AppSpacing.lg,
      children: [
        const SizedBox(height: AppSpacing.lg),

        // ── Card 1: Pain Level Selector ──────────────────────
        _AnimatedCard(
          borderColor: color.withValues(alpha: 0.3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Wie stark sind deine Schmerzen?',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Big emoji + level
              Center(
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        final scale = level >= 7
                            ? _pulseAnimation.value
                            : 1.0;
                        return Transform.scale(
                          scale: scale,
                          child: child,
                        );
                      },
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          key: ValueKey(level ~/ 2),
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _colorForLevel(level),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$level',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        '$level/10 – ${_painDescription(level)}',
                        key: ValueKey(level),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Custom slider
              _PainSlider(
                value: _painLevel,
                onChanged: (v) {
                  HapticFeedback.selectionClick();
                  setState(() => _painLevel = v);
                },
              ),

              // Scale labels
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l.none,
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
                    Text(
                      l.unbearable,
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // ── Card 2: Body Region ──────────────────────────────
        _AnimatedCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const GlassIcon(icon: AppIcons.location, color: AppIcons.locationColor, size: 14),
                  const SizedBox(width: 8),
                  Text(
                    l.woTutEsWeh,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                l.optionalTippeAufEineRegion,
                style: const TextStyle(fontSize: 13, color: Color(0xFF8E8E93)),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: BodyRegion.values.map((region) {
                  final selected = _bodyRegion == region;
                  return _SelectChip(
                    label: region.label,
                    selected: selected,
                    onTap: () => setState(
                      () => _bodyRegion = selected ? null : region,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // ── Card 3: Pain Type ────────────────────────────────
        _AnimatedCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const GlassIcon(icon: AppIcons.search, color: AppIcons.searchColor, size: 14),
                  const SizedBox(width: 8),
                  Text(
                    l.artDerSchmerzen,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                l.optionalWieFuehltEsSichAn,
                style: const TextStyle(fontSize: 13, color: Color(0xFF8E8E93)),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: PainType.values.map((type) {
                  final selected = _painType == type;
                  return _SelectChip(
                    label: type.label,
                    selected: selected,
                    onTap: () => setState(
                      () => _painType = selected ? null : type,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // ── Save button ──────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                textStyle: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
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
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _colorForLevel(level),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$level',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(l.save),
                      ],
                    ),
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.xxl),

        // ── Card 4: Trend / Stats ────────────────────────────
        StreamBuilder<List<PainEntry>>(
          stream: _repository.watchAll(),
          builder: (context, snapshot) {
            final items = snapshot.data ?? const <PainEntry>[];
            if (items.isEmpty) return const SizedBox.shrink();
            return Column(
              children: [
                _buildStatsCard(items),
                const SizedBox(height: AppSpacing.md),
                _buildChartCard(items),
                const SizedBox(height: AppSpacing.md),
                _buildRecentEntries(items),
                const SizedBox(height: AppSpacing.lg),
                _buildDiaryCta(),
                const SizedBox(height: AppSpacing.xxxl),
              ],
            );
          },
        ),
      ],
    );
  }

  // ── Stats card ──────────────────────────────────────────────────────────
  Widget _buildStatsCard(List<PainEntry> items) {
    final l = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final last7 =
        items.where((e) => now.difference(e.occurredAt).inDays < 7).toList();
    final avgAll = items.isEmpty
        ? 0.0
        : items.map((e) => e.painLevel).reduce((a, b) => a + b) / items.length;
    final avg7 = last7.isEmpty
        ? 0.0
        : last7.map((e) => e.painLevel).reduce((a, b) => a + b) / last7.length;

    // Trend: compare last 3 vs previous 3
    String trend = '→';
    Color trendColor = const Color(0xFF8E8E93);
    if (items.length >= 6) {
      final recent3 =
          items.take(3).map((e) => e.painLevel).reduce((a, b) => a + b) / 3;
      final prev3 = items
              .skip(3)
              .take(3)
              .map((e) => e.painLevel)
              .reduce((a, b) => a + b) /
          3;
      if (recent3 < prev3 - 0.3) {
        trend = '↓';
        trendColor = const Color(0xFF34C759);
      } else if (recent3 > prev3 + 0.3) {
        trend = '↑';
        trendColor = const Color(0xFFFF3B30);
      }
    }

    final lowest = items.map((e) => e.painLevel).reduce(math.min);
    final highest = items.map((e) => e.painLevel).reduce(math.max);

    return _AnimatedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const GlassIcon(icon: AppIcons.analytics, color: AppIcons.analyticsColor, size: 14),
              const SizedBox(width: 8),
              Text(
                l.uebersicht,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1C1C1E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatTile(
                label: l.avgSiebenTage,
                value: avg7.toStringAsFixed(1),
                color: _colorForLevel(avg7.round()),
              ),
              _StatTile(
                label: l.gesamt,
                value: avgAll.toStringAsFixed(1),
                color: _colorForLevel(avgAll.round()),
              ),
              _StatTile(
                label: l.trendLabel,
                value: trend,
                color: trendColor,
                large: true,
              ),
              _StatTile(
                label: l.minMax,
                value: '$lowest / $highest',
                color: const Color(0xFF1C1C1E),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              l.eintraegeInsgesamt(items.length),
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF8E8E93),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Chart card ──────────────────────────────────────────────────────────
  Widget _buildChartCard(List<PainEntry> items) {
    final l = AppLocalizations.of(context)!;
    final isPro = _isPro;
    final maxEntries = isPro ? 14 : 5;
    final chartEntries =
        items.length > maxEntries ? items.sublist(0, maxEntries) : items;

    return _AnimatedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GlassIcon(icon: AppIcons.progress, color: AppIcons.progressColor, size: 14),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l.history,
                  style: TextStyle(
                    fontSize: 17,
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
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.lock_rounded,
                            size: 12, color: Color(0xFFFF9500)),
                        const SizedBox(width: 4),
                        Text(
                          l.mehrMitPro,
                          style: const TextStyle(
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
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: _PainLineChart(
              entries: chartEntries.reversed.toList(),
              colorForLevel: _colorForLevel,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              isPro
                  ? l.letzteEintraege(chartEntries.length)
                  : l.letzteEintraegeGratis(chartEntries.length),
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF8E8E93),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Recent entries ──────────────────────────────────────────────────────
  Widget _buildRecentEntries(List<PainEntry> items) {
    final l = AppLocalizations.of(context)!;
    final recent = items.take(5).toList();
    return _AnimatedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GlassIcon(icon: AppIcons.timer, color: AppIcons.timerColor, size: 14),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l.letzteEintraegeHeader,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1C1C1E),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const PainDiaryScreen(),
                  ),
                ),
                child: Text(
                  l.alleAnzeigen,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0A74FF),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...recent.map(
            (entry) => _RecentEntryRow(
              entry: entry,
              formatRelative: _formatRelative,
              colorForLevel: _colorForLevel,
              onTap: () => Navigator.of(context).push<bool>(
                MaterialPageRoute<bool>(
                  builder: (_) =>
                      PainEntryEditorScreen(initialEntry: entry),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiaryCta() {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton.icon(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const PainDiaryScreen(),
            ),
          ),
          icon: GlassIcon(icon: AppIcons.diary, color: AppIcons.diaryColor, size: 14),
          label: Text(l.openDiary),
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            side: const BorderSide(color: Color(0xFFD1D1D6)),
            foregroundColor: const Color(0xFF1C1C1E),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── Reusable widgets
// ═══════════════════════════════════════════════════════════════════════════════

class _AnimatedCard extends StatelessWidget {
  const _AnimatedCard({required this.child, this.borderColor});

  final Widget child;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 1.5)
            : null,
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 6,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SelectChip extends StatelessWidget {
  const _SelectChip({
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
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF0A74FF).withValues(alpha: 0.1)
              : const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? const Color(0xFF0A74FF)
                : const Color(0xFFE5E5EA),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
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

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
    this.large = false,
  });

  final String label;
  final String value;
  final Color color;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: large ? 28 : 20,
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
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Custom pain slider ───────────────────────────────────────────────────────

class _PainSlider extends StatelessWidget {
  const _PainSlider({required this.value, required this.onChanged});

  final double value;
  final ValueChanged<double> onChanged;

  Color _colorForLevel(int level) {
    if (level <= 2) return const Color(0xFF34C759);
    if (level <= 4) return const Color(0xFFFFCC00);
    if (level <= 6) return const Color(0xFFFF9500);
    if (level <= 8) return const Color(0xFFFF6B6B);
    return const Color(0xFFFF3B30);
  }

  @override
  Widget build(BuildContext context) {
    final level = value.round();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(11, (i) {
              final active = i <= level;
              return Container(
                width: 3,
                height: i == level ? 14 : 8,
                decoration: BoxDecoration(
                  color: active
                      ? _colorForLevel(i)
                      : const Color(0xFFD1D1D6),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 4),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: _colorForLevel(level),
            inactiveTrackColor: const Color(0xFFE5E5EA),
            thumbColor: Colors.white,
            overlayColor: _colorForLevel(level).withValues(alpha: 0.12),
            trackHeight: 8,
            thumbShape: _CustomThumbShape(color: _colorForLevel(level)),
          ),
          child: Slider(
            value: value,
            min: 0,
            max: 10,
            divisions: 10,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _CustomThumbShape extends SliderComponentShape {
  const _CustomThumbShape({required this.color});

  final Color color;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size.fromRadius(16);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    // Shadow
    canvas.drawCircle(
      center + const Offset(0, 2),
      16,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    // White circle
    canvas.drawCircle(
      center,
      16,
      Paint()..color = Colors.white,
    );
    // Inner colored circle
    canvas.drawCircle(
      center,
      10,
      Paint()..color = color,
    );
  }
}

// ── Pain line chart ──────────────────────────────────────────────────────────

class _PainLineChart extends StatelessWidget {
  const _PainLineChart({
    required this.entries,
    required this.colorForLevel,
  });

  final List<PainEntry> entries;
  final Color Function(int) colorForLevel;

  @override
  Widget build(BuildContext context) {
    if (entries.length < 2) {
      final l = AppLocalizations.of(context)!;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GlassIcon(icon: AppIcons.analytics, color: AppIcons.analyticsColor, size: 22),
            SizedBox(height: 4),
            Text(
              l.mind2EintraegeFuerChart,
              style: TextStyle(fontSize: 13, color: Color(0xFF8E8E93)),
            ),
          ],
        ),
      );
    }
    return CustomPaint(
      size: Size.infinite,
      painter: _PainChartPainter(
        entries: entries,
        colorForLevel: colorForLevel,
      ),
    );
  }
}

class _PainChartPainter extends CustomPainter {
  _PainChartPainter({
    required this.entries,
    required this.colorForLevel,
  });

  final List<PainEntry> entries;
  final Color Function(int) colorForLevel;

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.length < 2) return;

    final w = size.width;
    final h = size.height;
    const padTop = 16.0;
    const padBottom = 24.0;
    final chartH = h - padTop - padBottom;

    // Grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFFE5E5EA)
      ..strokeWidth = 0.5;

    for (int i = 0; i <= 10; i += 2) {
      final y = padTop + chartH - (i / 10 * chartH);
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // Calculate points
    final points = <Offset>[];
    for (int i = 0; i < entries.length; i++) {
      final x = entries.length == 1
          ? w / 2
          : i / (entries.length - 1) * w;
      final y = padTop + chartH - (entries[i].painLevel / 10 * chartH);
      points.add(Offset(x, y));
    }

    // Gradient fill under curve
    final fillPath = Path()..moveTo(points.first.dx, h - padBottom);
    for (final p in points) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(points.last.dx, h - padBottom);
    fillPath.close();

    final avgLevel = entries.map((e) => e.painLevel).reduce((a, b) => a + b) /
        entries.length;
    final avgColor = colorForLevel(avgLevel.round());

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          avgColor.withValues(alpha: 0.25),
          avgColor.withValues(alpha: 0.02),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(fillPath, fillPaint);

    // Line
    final linePaint = Paint()
      ..color = avgColor
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(linePath, linePaint);

    // Dots
    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final dotColor = colorForLevel(entries[i].painLevel);

      canvas.drawCircle(p, 5, Paint()..color = Colors.white);
      canvas.drawCircle(p, 3.5, Paint()..color = dotColor);
    }

    // Labels at bottom
    if (entries.length <= 10) {
      for (int i = 0; i < entries.length; i++) {
        final tp = TextPainter(
          text: TextSpan(
            text: '${entries[i].painLevel}',
            style: TextStyle(
              fontSize: 9,
              color: colorForLevel(entries[i].painLevel),
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(
          canvas,
          Offset(points[i].dx - tp.width / 2, h - padBottom + 6),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PainChartPainter old) =>
      entries.length != old.entries.length;
}

// ── Recent entry row ─────────────────────────────────────────────────────────

class _RecentEntryRow extends StatelessWidget {
  const _RecentEntryRow({
    required this.entry,
    required this.formatRelative,
    required this.colorForLevel,
    this.onTap,
  });

  final PainEntry entry;
  final String Function(DateTime) formatRelative;
  final Color Function(int) colorForLevel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = colorForLevel(entry.painLevel);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                '${entry.painLevel}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${entry.painLevel}/10${entry.bodyRegion != null ? ' · ${entry.bodyRegion!.label}' : ''}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                  Text(
                    formatRelative(entry.occurredAt),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${entry.painLevel}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
