import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../ui/ui.dart';
import '../data/sleep_repository_sync.dart';
import '../domain/sleep_entry.dart';
import 'sleep_diary_screen.dart';
import 'sleep_entry_editor.dart';
import 'sleep_analytics_tab.dart';

// ── Night-theme colours ──────────────────────────────────────────────────────

const _kNightBlue = Color(0xFF1A1A3E);
const _kNightPurple = Color(0xFF5C4D9A);
const _kNightIndigo = Color(0xFF3F3D8F);
const _kNightAccent = Color(0xFF7C6FE0);
const _kNightSurface = Color(0x1A5C4D9A);
const _kNightBorder = Color(0x335C4D9A);
const _kStarYellow = Color(0xFFFFD700);

/// Main sleep screen with quick-log, week chart and analytics tab.
class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen>
    with SingleTickerProviderStateMixin {
  static final SleepRepositorySync _repository = SleepRepositorySync.instance;

  late final TabController _tabCtrl;

  // ── Quick-log state ──
  TimeOfDay _bedTime = const TimeOfDay(hour: 22, minute: 30);
  TimeOfDay _wakeTime = const TimeOfDay(hour: 6, minute: 30);
  double _quality = 3;
  int _disturbances = 0;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _bootstrap();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    await _repository.loadFromDisk();
    await _repository.pullLatest();
  }

  // ── Computed duration ──
  int get _durationMinutes {
    final bedMin = _bedTime.hour * 60 + _bedTime.minute;
    final wakeMin = _wakeTime.hour * 60 + _wakeTime.minute;
    final diff = wakeMin - bedMin;
    return diff < 0 ? diff + 1440 : diff; // handle overnight
  }

  String get _durationFormatted {
    final h = _durationMinutes ~/ 60;
    final m = _durationMinutes % 60;
    if (m == 0) return '${h}h';
    return '${h}h ${m}min';
  }

  // ── Save quick-log ──
  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    HapticFeedback.mediumImpact();
    try {
      final now = DateTime.now();
      // Build bedTime as yesterday, wakeTime as today (typical overnight sleep).
      final today = DateTime(now.year, now.month, now.day);
      DateTime bed = today.subtract(const Duration(days: 1)).add(
        Duration(hours: _bedTime.hour, minutes: _bedTime.minute),
      );
      DateTime wake = today.add(
        Duration(hours: _wakeTime.hour, minutes: _wakeTime.minute),
      );
      // If bed would be after wake, assume same-day nap.
      if (bed.isAfter(wake)) {
        bed = today.add(
          Duration(hours: _bedTime.hour, minutes: _bedTime.minute),
        );
      }

      final id = 'sleep_${now.millisecondsSinceEpoch}';
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final entry = SleepEntry(
        id: id,
        ownerId: uid,
        bedTime: bed,
        wakeTime: wake,
        quality: SleepQuality.fromValue(_quality.round()),
        disturbances: _disturbances,
        createdAt: now,
        updatedAt: now,
        metadata: const <String, dynamic>{'source': 'sleep_screen'},
      );
      await _repository.upsert(entry);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Schlafprotokoll gespeichert – $_durationFormatted',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      setState(() => _saving = false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e')),
        );
      }
      setState(() => _saving = false);
    }
  }

  // ── Time picker helper ──
  Future<void> _pickTime({required bool isBedTime}) async {
    final initial = isBedTime ? _bedTime : _wakeTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      HapticFeedback.selectionClick();
      setState(() {
        if (isBedTime) {
          _bedTime = picked;
        } else {
          _wakeTime = picked;
        }
      });
    }
  }

  // ── Quality colour ──
  Color _colorForQuality(int q) {
    if (q <= 1) return AppColors.error;
    if (q <= 2) return AppColors.warning;
    if (q <= 3) return const Color(0xFFFFCC00);
    if (q <= 4) return AppColors.success;
    return _kNightAccent;
  }

  // ── Build ──
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final qualityInt = _quality.round();
    final qColor = _colorForQuality(qualityInt);
    final sq = SleepQuality.fromValue(qualityInt);

    return GlassPage(
      title: 'Schlaf',
      titleIcon: CupertinoIcons.moon_fill,
      titleColor: _kNightPurple,
      trailing: PressableScale(
        onTap: () {
          Haptic.light();
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const SleepDiaryScreen()),
          );
        },
        scaleFactor: 0.92,
        child: GlassContainer(
          padding: const EdgeInsets.all(AppSpacing.sm),
          borderRadius: AppRadius.borderRadiusSm,
          variant: GlassVariant.thin,
          elevation: GlassElevation.low,
          child: const Icon(
            CupertinoIcons.book_fill,
            size: 20,
            color: _kNightPurple,
          ),
        ),
      ),
      children: [
        const SizedBox(height: AppSpacing.sm),

        // ── Tab bar ──
        GlassContainer(
          padding: const EdgeInsets.all(4),
          borderRadius: AppRadius.borderRadiusMd,
          variant: GlassVariant.thin,
          elevation: GlassElevation.flat,
          child: TabBar(
            controller: _tabCtrl,
            onTap: (_) => setState(() {}),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            indicator: BoxDecoration(
              color: _kNightPurple.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            labelColor: _kNightPurple,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle:
                tt.labelMedium?.copyWith(fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: 'Erfassen'),
              Tab(text: 'Woche'),
              Tab(text: 'Analyse'),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // ── Tab content ──
        if (_tabCtrl.index == 0) ..._buildQuickLog(tt, qColor, sq),
        if (_tabCtrl.index == 1) _WeekChart(repository: _repository),
        if (_tabCtrl.index == 2) SleepAnalyticsTab(repository: _repository),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Tab 0: Quick-log
  // ═══════════════════════════════════════════════════════════════════════════

  List<Widget> _buildQuickLog(
    TextTheme tt,
    Color qColor,
    SleepQuality sq,
  ) {
    return [
      // ── Time pickers ──
      _NightCard(
        child: Column(
          children: [
            Text(
              'Schlafzeit',
              style: tt.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: _kNightPurple,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _TimeTile(
                    label: 'Bettzeit',
                    icon: CupertinoIcons.moon_fill,
                    time: _bedTime,
                    onTap: () => _pickTime(isBedTime: true),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Column(
                  children: [
                    Icon(CupertinoIcons.arrow_right,
                        color: _kNightPurple.withValues(alpha: 0.5), size: 18),
                    const SizedBox(height: 4),
                    Text(
                      _durationFormatted,
                      style: tt.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: _kNightPurple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _TimeTile(
                    label: 'Aufwachen',
                    icon: CupertinoIcons.sun_max_fill,
                    time: _wakeTime,
                    onTap: () => _pickTime(isBedTime: false),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: AppSpacing.md),

      // ── Quality slider ──
      _NightCard(
        borderColor: qColor.withValues(alpha: 0.3),
        child: Column(
          children: [
            Text(
              'Schlafqualität',
              style: tt.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: _kNightPurple,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: qColor.withValues(alpha: 0.15),
                    border: Border.all(color: qColor, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    sq.emoji,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  sq.label,
                  style: tt.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: qColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            // Star rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final filled = i < _quality.round();
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _quality = (i + 1).toDouble());
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      filled
                          ? CupertinoIcons.star_fill
                          : CupertinoIcons.star,
                      size: 32,
                      color: filled ? _kStarYellow : AppColors.grey400,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      const SizedBox(height: AppSpacing.md),

      // ── Disturbances counter ──
      _NightCard(
        child: Column(
          children: [
            Text(
              'Unterbrechungen',
              style: tt.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: _kNightPurple,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _CounterButton(
                  icon: CupertinoIcons.minus,
                  onTap: _disturbances > 0
                      ? () => setState(() => _disturbances--)
                      : null,
                ),
                const SizedBox(width: AppSpacing.xl),
                Text(
                  '$_disturbances',
                  style: tt.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: _kNightPurple,
                  ),
                ),
                const SizedBox(width: AppSpacing.xl),
                _CounterButton(
                  icon: CupertinoIcons.plus,
                  onTap: () => setState(() => _disturbances++),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: AppSpacing.xl),

      // ── Save button ──
      GlassButton(
        onPressed: _saving ? null : _save,
        label: _saving ? 'Speichern…' : 'Schlaf speichern',
        icon: CupertinoIcons.moon_fill,
        isLoading: _saving,
        expand: true,
      ),
      const SizedBox(height: AppSpacing.md),

      // ── Detail editor link ──
      Center(
        child: PressableScale(
          onTap: () {
            Haptic.light();
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const SleepEntryEditor(),
              ),
            );
          },
          scaleFactor: 0.96,
          child: Text(
            'Detaillierten Eintrag erstellen →',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _kNightAccent,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.xxl),
    ];
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Tab 1: Week chart
// ═════════════════════════════════════════════════════════════════════════════

class _WeekChart extends StatelessWidget {
  const _WeekChart({required this.repository});
  final SleepRepositorySync repository;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return StreamBuilder<List<SleepEntry>>(
      stream: repository.watchAll(),
      builder: (context, snapshot) {
        final items = snapshot.data ?? [];
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        // Build 7-day data (Mon–Sun).
        final weekStart =
            today.subtract(Duration(days: today.weekday - 1));
        final days = List.generate(7, (i) => weekStart.add(Duration(days: i)));
        final dayLabels = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];

        final durations = <double>[];
        for (final day in days) {
          final dayEnd = day.add(const Duration(days: 1));
          final dayEntries = items.where((e) {
            return e.wakeTime.isAfter(day) && e.wakeTime.isBefore(dayEnd);
          });
          final totalMin =
              dayEntries.fold<int>(0, (sum, e) => sum + e.durationMinutes);
          durations.add(totalMin / 60.0);
        }

        final maxH = durations.fold<double>(0, math.max).clamp(1.0, 24.0);

        return Column(
          children: [
            Text(
              'Schlafstunden diese Woche',
              style: tt.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: _kNightPurple,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              height: 200,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (i) {
                  final barHeight = maxH > 0
                      ? (durations[i] / maxH * 160).clamp(0.0, 160.0)
                      : 0.0;
                  final isToday = days[i].day == today.day &&
                      days[i].month == today.month;
                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          durations[i] > 0
                              ? '${durations[i].toStringAsFixed(1)}h'
                              : '',
                          style: tt.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: _kNightPurple,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOut,
                          height: barHeight,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                _kNightIndigo,
                                _kNightAccent,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(6),
                            border: isToday
                                ? Border.all(
                                    color: _kStarYellow, width: 2)
                                : null,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          dayLabels[i],
                          style: tt.labelSmall?.copyWith(
                            fontWeight:
                                isToday ? FontWeight.w700 : FontWeight.w500,
                            color: isToday
                                ? _kNightPurple
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Summary row ──
            if (items.isNotEmpty) ...[
              _NightCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatColumn(
                      label: 'Ø Dauer',
                      value: _avgDuration(items),
                    ),
                    _StatColumn(
                      label: 'Ø Qualität',
                      value: _avgQuality(items),
                    ),
                    _StatColumn(
                      label: 'Einträge',
                      value: '${items.length}',
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
          ],
        );
      },
    );
  }

  String _avgDuration(List<SleepEntry> items) {
    if (items.isEmpty) return '–';
    final avg =
        items.fold<int>(0, (sum, e) => sum + e.durationMinutes) / items.length;
    final h = avg ~/ 60;
    final m = (avg % 60).round();
    return '${h}h ${m}m';
  }

  String _avgQuality(List<SleepEntry> items) {
    if (items.isEmpty) return '–';
    final avg = items.fold<int>(0, (sum, e) => sum + e.quality.value) /
        items.length;
    return avg.toStringAsFixed(1);
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Shared widgets
// ═════════════════════════════════════════════════════════════════════════════

class _NightCard extends StatelessWidget {
  const _NightCard({required this.child, this.borderColor});
  final Widget child;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: _kNightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor ?? _kNightBorder),
      ),
      child: child,
    );
  }
}

class _TimeTile extends StatelessWidget {
  const _TimeTile({
    required this.label,
    required this.icon,
    required this.time,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final TimeOfDay time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final formatted =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    return PressableScale(
      onTap: () {
        Haptic.light();
        onTap();
      },
      scaleFactor: 0.95,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: _kNightPurple.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kNightBorder),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: _kNightPurple),
            const SizedBox(height: 4),
            Text(
              formatted,
              style: tt.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: _kNightBlue,
              ),
            ),
            Text(
              label,
              style: tt.labelSmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  const _CounterButton({required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return PressableScale(
      onTap: enabled
          ? () {
              Haptic.light();
              onTap!();
            }
          : null,
      scaleFactor: 0.90,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled
              ? _kNightPurple.withValues(alpha: 0.12)
              : AppColors.grey200,
          border: Border.all(
            color: enabled ? _kNightPurple : AppColors.grey300,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? _kNightPurple : AppColors.grey400,
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(
          value,
          style: tt.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: _kNightPurple,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: tt.labelSmall?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
