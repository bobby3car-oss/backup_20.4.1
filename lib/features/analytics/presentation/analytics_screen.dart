import 'dart:async';
import 'dart:ui' as ui;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../main.dart';
import '../../../ui/ui.dart';
import '../../../ui/theme/app_icons.dart';
import '../../mood/data/mood_repository_local.dart';
import '../../mood/domain/mood_entry.dart';
import '../../nutrition/data/nutrition_repository_local.dart';
import '../../nutrition/domain/nutrition_entry.dart';
import '../../pain/data/pain_repository_local.dart';
import '../../pain/domain/pain_entry.dart';
import '../../pro/domain/trigger_context.dart';
import '../../pro/presentation/pro_feature_gate_view.dart';
import '../../pro/presentation/smart_paywall.dart';
import '../../red_flags/data/red_flag_repository_local.dart';
import '../../red_flags/domain/red_flag.dart';
import '../../sleep/data/sleep_repository_local.dart';
import '../../sleep/domain/sleep_entry.dart';
import '../../vitals/data/vital_repository_local.dart';
import '../../vitals/domain/vital_entry.dart';
import '../../wound/data/wound_repository_local.dart';
import '../../wound/domain/wound_entry.dart';
import '../../../l10n/app_localizations.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Analytics Screen — PRO Feature
// ─────────────────────────────────────────────────────────────────────────────

enum _TimeRange { days7, days14, days30, all }

extension on _TimeRange {
  String get label => switch (this) {
        _TimeRange.days7 => '7 T',
        _TimeRange.days14 => '14 T',
        _TimeRange.days30 => '30 T',
        _TimeRange.all => 'Alles',
      };

  Duration? get duration => switch (this) {
        _TimeRange.days7 => const Duration(days: 7),
        _TimeRange.days14 => const Duration(days: 14),
        _TimeRange.days30 => const Duration(days: 30),
        _TimeRange.all => null,
      };
}

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  final GlobalKey _repaintKey = GlobalKey();

  _TimeRange _range = _TimeRange.days7;

  List<PainEntry> _painEntries = const [];
  List<VitalEntry> _vitalEntries = const [];
  List<WoundEntry> _woundEntries = const [];
  List<NutritionEntry> _nutritionEntries = const [];
  List<RedFlag> _flagEntries = const [];
  List<MoodEntry> _moodEntries = const [];
  List<SleepEntry> _sleepEntries = const [];

  StreamSubscription<List<PainEntry>>? _painSub;
  StreamSubscription<List<VitalEntry>>? _vitalSub;
  StreamSubscription<List<WoundEntry>>? _woundSub;
  StreamSubscription<List<NutritionEntry>>? _nutritionSub;
  StreamSubscription<List<RedFlag>>? _flagSub;
  StreamSubscription<List<MoodEntry>>? _moodSub;
  StreamSubscription<List<SleepEntry>>? _sleepSub;

  bool get _isPro =>
      kDebugMode ||
      (ProServices.maybeOf(context)?.entitlementService.isPro ?? false);

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 8, vsync: this);
    _subscribe();
  }

  void _subscribe() {
    final painRepo = PainRepositoryLocal.instance;
    final vitalRepo = VitalRepositoryLocal.instance;
    final woundRepo = WoundRepositoryLocal.instance;
    final nutritionRepo = NutritionRepositoryLocal.instance;
    final flagRepo = RedFlagRepositoryLocal.instance;
    final moodRepo = MoodRepositoryLocal.instance;
    final sleepRepo = SleepRepositoryLocal.instance;

    _painSub = painRepo.watchAll().listen((data) {
      if (mounted) setState(() => _painEntries = data);
    });
    _vitalSub = vitalRepo.watchAll().listen((data) {
      if (mounted) setState(() => _vitalEntries = data);
    });
    _woundSub = woundRepo.watchAll().listen((data) {
      if (mounted) setState(() => _woundEntries = data);
    });
    _nutritionSub = nutritionRepo.watchAll().listen((data) {
      if (mounted) setState(() => _nutritionEntries = data);
    });
    _flagSub = flagRepo.watchAll().listen((data) {
      if (mounted) setState(() => _flagEntries = data);
    });
    _moodSub = moodRepo.watchAll().listen((data) {
      if (mounted) setState(() => _moodEntries = data);
    });
    _sleepSub = sleepRepo.watchAll().listen((data) {
      if (mounted) setState(() => _sleepEntries = data);
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _painSub?.cancel();
    _vitalSub?.cancel();
    _woundSub?.cancel();
    _nutritionSub?.cancel();
    _flagSub?.cancel();
    _moodSub?.cancel();
    _sleepSub?.cancel();
    super.dispose();
  }

  // ── Filtering ──────────────────────────────────────────────────────────────

  DateTime? get _cutoff {
    final dur = _range.duration;
    return dur != null ? DateTime.now().subtract(dur) : null;
  }

  List<PainEntry> get _filteredPain {
    final c = _cutoff;
    final list = c != null
        ? _painEntries.where((e) => e.occurredAt.isAfter(c)).toList()
        : List<PainEntry>.of(_painEntries);
    list.sort((a, b) => a.occurredAt.compareTo(b.occurredAt));
    return list;
  }

  List<VitalEntry> get _filteredVitals {
    final c = _cutoff;
    final list = c != null
        ? _vitalEntries.where((e) => e.createdAt.isAfter(c)).toList()
        : List<VitalEntry>.of(_vitalEntries);
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  List<WoundEntry> get _filteredWounds {
    final c = _cutoff;
    final list = c != null
        ? _woundEntries.where((e) => e.createdAt.isAfter(c)).toList()
        : List<WoundEntry>.of(_woundEntries);
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  List<NutritionEntry> get _filteredNutrition {
    final c = _cutoff;
    final list = c != null
        ? _nutritionEntries.where((e) => e.occurredAt.isAfter(c)).toList()
        : List<NutritionEntry>.of(_nutritionEntries);
    list.sort((a, b) => a.occurredAt.compareTo(b.occurredAt));
    return list;
  }

  List<RedFlag> get _filteredFlags {
    final c = _cutoff;
    final list = c != null
        ? _flagEntries.where((e) => e.createdAt.isAfter(c)).toList()
        : List<RedFlag>.of(_flagEntries);
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  List<MoodEntry> get _filteredMood {
    final c = _cutoff;
    final list = c != null
        ? _moodEntries.where((e) => e.createdAt.isAfter(c)).toList()
        : List<MoodEntry>.of(_moodEntries);
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  List<SleepEntry> get _filteredSleep {
    final c = _cutoff;
    final list = c != null
        ? _sleepEntries.where((e) => e.createdAt.isAfter(c)).toList()
        : List<SleepEntry>.of(_sleepEntries);
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  Future<void> _shareCurrentTab() async {
    final boundary = _repaintKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) return;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;
    final bytes = byteData.buffer.asUint8List();
    await SharePlus.instance.share(
      ShareParams(files: [XFile.fromData(bytes, mimeType: 'image/png', name: 'analytics.png')]),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (!_isPro) {
      final l = AppLocalizations.of(context)!;
      return ProFeatureGateView(
        pageTitle: 'Analytics',
        pageIcon: AppIcons.analytics,
        pageColor: const Color(0xFF5856D6),
        heroIcon: AppIcons.analytics,
        heroTitle: 'Deine Daten erzählen eine Geschichte',
        heroSubtitle:
            'Schmerzverlauf, Vitalwerte und Wundheilung als übersichtliche '
            'Diagramme – damit du und dein Arzt Trends sofort erkennen.',
        primaryCta: 'Jetzt Pro freischalten',
        onPrimaryTap: () {
          SmartPaywall.trigger(
            context: context,
            triggerContext: TriggerContext.analyticsFeature,
          );
        },
        benefits: <(String, String)>[
          (
            'Schmerztrend im Blick',
            'Erkenne Muster in deinem Schmerzverlauf – Woche für Woche visuell aufbereitet.',
          ),
          (
            'Vitaldaten-Verlauf',
            'Blutdruck und Puls als Diagramm – ideal zur Vorbereitung auf den Arzttermin.',
          ),
          (
            'Wundheilung dokumentiert',
            l.verfolgeDeineWundheilungMitFotosUndEintraegenImZeitli,
          ),
        ],
        preview: _AnalyticsLockedPreview(),
      );
    }

    return GlassPage(
      title: 'Analytics',
      titleIcon: AppIcons.analytics,
      titleColor: const Color(0xFF5856D6),
      trailing: PressableScale(
        onTap: () {
          Haptic.light();
          _shareCurrentTab();
        },
        scaleFactor: 0.90,
        child: GlassContainer(
          padding: const EdgeInsets.all(AppSpacing.sm + 2),
          borderRadius: AppRadius.borderRadiusMd,
          variant: GlassVariant.thin,
          elevation: GlassElevation.low,
          child: const Icon(
            Icons.ios_share_rounded,
            size: 18,
            color: AppColors.grey700,
          ),
        ),
      ),
      scrollableBody: (headerHeight) => Column(
        children: [
          SizedBox(height: headerHeight + AppSpacing.sm),

          // ── Time range chips ─────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: _TimeRange.values.map((r) {
                final selected = r == _range;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: ChoiceChip(
                    label: Text(r.label),
                    selected: selected,
                    onSelected: (_) => setState(() => _range = r),
                    selectedColor: AppColors.primary.withValues(alpha: 0.15),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w500,
                      color:
                          selected ? AppColors.primary : AppColors.grey600,
                    ),
                    side: BorderSide(
                      color: selected
                          ? AppColors.primary.withValues(alpha: 0.3)
                          : AppColors.grey300,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.borderRadiusPill,
                    ),
                    backgroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // ── Tabs ─────────────────────────────────────────
          TabBar(
            controller: _tabCtrl,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.grey500,
            indicatorColor: AppColors.primary,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            tabs: const [
              Tab(text: 'Übersicht'),
              Tab(text: 'Schmerz'),
              Tab(text: 'Vitals'),
              Tab(text: 'Wunden'),
              Tab(text: 'Ernährung'),
              Tab(text: 'Stimmung'),
              Tab(text: 'Schlaf'),
              Tab(text: 'Red Flags'),
            ],
          ),

          // ── Tab content ──────────────────────────────────
          Expanded(
            child: RepaintBoundary(
              key: _repaintKey,
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  _OverviewTab(
                    painEntries: _painEntries,
                    vitalEntries: _vitalEntries,
                    nutritionEntries: _nutritionEntries,
                    flagEntries: _flagEntries,
                  ),
                  _PainTab(entries: _filteredPain),
                  _VitalsTab(entries: _filteredVitals),
                  _WoundsTab(entries: _filteredWounds),
                  _NutritionTab(entries: _filteredNutrition),
                  _MoodTab(entries: _filteredMood),
                  _SleepTab(entries: _filteredSleep),
                  _RedFlagsTab(entries: _filteredFlags),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Overview Tab
// =============================================================================

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({
    required this.painEntries,
    required this.vitalEntries,
    required this.nutritionEntries,
    required this.flagEntries,
  });
  final List<PainEntry> painEntries;
  final List<VitalEntry> vitalEntries;
  final List<NutritionEntry> nutritionEntries;
  final List<RedFlag> flagEntries;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final tt = Theme.of(context).textTheme;
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    return ListView(
      physics: adaptiveScrollPhysics,
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(l.healthOverview, style: tt.titleMedium),
        const SizedBox(height: AppSpacing.md),

        // ── Pain summary card ──
        _OverviewCard(
          icon: Icons.favorite_rounded,
          iconColor: AppColors.error,
          title: 'Schmerz',
          child: _buildPainSummary(context, todayStart),
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Vitals summary card ──
        _OverviewCard(
          icon: Icons.monitor_heart_rounded,
          iconColor: AppColors.primary,
          title: 'Vitals',
          child: _buildVitalsSummary(context),
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Nutrition summary card ──
        _OverviewCard(
          icon: Icons.restaurant_rounded,
          iconColor: AppColors.success,
          title: l.ernaehrungHeute,
          child: _buildNutritionSummary(context, todayStart),
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Red Flags card ──
        _OverviewCard(
          icon: Icons.flag_rounded,
          iconColor: AppColors.error,
          title: 'Red Flags',
          child: _buildRedFlagsSummary(context),
        ),

        const SizedBox(height: AppSpacing.xxl),

        // ── Pain sparkline ──
        Text(l.painCourse7d, style: tt.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        _buildPainSparkline(context, now),
      ],
    );
  }

  Widget _buildPainSummary(BuildContext context, DateTime todayStart) {
    final today = painEntries.where((e) => e.occurredAt.isAfter(todayStart));
    final todayAvg = today.isEmpty
        ? null
        : today.map((e) => e.painLevel).reduce((a, b) => a + b) /
            today.length;

    // Trend: last 7d vs prev 7d
    final now = DateTime.now();
    final last7 = painEntries
        .where((e) => e.occurredAt.isAfter(now.subtract(const Duration(days: 7))));
    final prev7 = painEntries.where((e) =>
        e.occurredAt.isAfter(now.subtract(const Duration(days: 14))) &&
        e.occurredAt.isBefore(now.subtract(const Duration(days: 7))));

    final last7Avg = last7.isEmpty
        ? null
        : last7.map((e) => e.painLevel).reduce((a, b) => a + b) /
            last7.length;
    final prev7Avg = prev7.isEmpty
        ? null
        : prev7.map((e) => e.painLevel).reduce((a, b) => a + b) /
            prev7.length;

    final IconData trendIcon;
    final Color trendColor;
    if (last7Avg == null || prev7Avg == null) {
      trendIcon = Icons.trending_flat_rounded;
      trendColor = AppColors.grey500;
    } else if (last7Avg > prev7Avg + 0.5) {
      trendIcon = Icons.trending_up_rounded;
      trendColor = AppColors.error;
    } else if (last7Avg < prev7Avg - 0.5) {
      trendIcon = Icons.trending_down_rounded;
      trendColor = AppColors.success;
    } else {
      trendIcon = Icons.trending_flat_rounded;
      trendColor = AppColors.warning;
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                todayAvg != null
                    ? 'Ø heute: ${todayAvg.toStringAsFixed(1)}'
                    : 'Heute: keine Einträge',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: todayAvg != null
                      ? _painColor(todayAvg)
                      : AppColors.grey500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                last7Avg != null
                    ? 'Ø 7 Tage: ${last7Avg.toStringAsFixed(1)}'
                    : '7 Tage: keine Daten',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.grey600,
                ),
              ),
            ],
          ),
        ),
        Icon(trendIcon, color: trendColor, size: 28),
      ],
    );
  }

  Widget _buildVitalsSummary(BuildContext context) {
    if (vitalEntries.isEmpty) {
      return const Text(
        'Noch keine Vitalwerte erfasst',
        style: TextStyle(fontSize: 13, color: AppColors.grey500),
      );
    }
    final last = vitalEntries.last;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${last.systolic}/${last.diastolic} mmHg  ·  ${last.pulse} bpm',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Letzte Messung: ${DateFormat('dd.MM.yy HH:mm').format(last.createdAt)}',
          style: const TextStyle(fontSize: 12, color: AppColors.grey600),
        ),
      ],
    );
  }

  Widget _buildNutritionSummary(BuildContext context, DateTime todayStart) {
    final today =
        nutritionEntries.where((e) => e.occurredAt.isAfter(todayStart));
    if (today.isEmpty) {
      return const Text(
        'Heute noch nichts erfasst',
        style: TextStyle(fontSize: 13, color: AppColors.grey500),
      );
    }
    final totalCal =
        today.fold<int>(0, (sum, e) => sum + (e.calories ?? 0));
    final totalWater =
        today.fold<int>(0, (sum, e) => sum + (e.waterMl ?? 0));
    final totalProtein =
        today.fold<int>(0, (sum, e) => sum + (e.protein ?? 0));
    final totalCarbs =
        today.fold<int>(0, (sum, e) => sum + (e.carbs ?? 0));
    final totalFat =
        today.fold<int>(0, (sum, e) => sum + (e.fat ?? 0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$totalCal kcal  ·  $totalWater ml Wasser',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        _MacroMiniBar(protein: totalProtein, carbs: totalCarbs, fat: totalFat),
      ],
    );
  }

  Widget _buildRedFlagsSummary(BuildContext context) {
    final active = flagEntries.where((f) => f.status.isActive).toList();
    if (active.isEmpty) {
      return const Text(
        'Keine offenen Red Flags',
        style: TextStyle(
          fontSize: 13,
          color: AppColors.success,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    final highestSeverity = active.map((f) => f.severity.index).reduce(
          (a, b) => a > b ? a : b,
        );
    final severityColor = _severityColor(
      RedFlagSeverity.values[highestSeverity],
    );

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: severityColor.withValues(alpha: 0.15),
            borderRadius: AppRadius.borderRadiusMd,
          ),
          child: Text(
            '${active.length}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: severityColor,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            '${active.length} offene${active.length == 1 ? 's' : ''} Flag${active.length == 1 ? '' : 's'}',
            style: const TextStyle(fontSize: 13, color: AppColors.grey700),
          ),
        ),
      ],
    );
  }

  Widget _buildPainSparkline(BuildContext context, DateTime now) {
    final cutoff = now.subtract(const Duration(days: 7));
    final recent =
        painEntries.where((e) => e.occurredAt.isAfter(cutoff)).toList()
          ..sort((a, b) => a.occurredAt.compareTo(b.occurredAt));

    if (recent.length < 2) {
      return GlassContainer(
        variant: GlassVariant.thin,
        elevation: GlassElevation.flat,
        borderRadius: AppRadius.borderRadiusMd,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: const Center(
          child: Text(
            'Mindestens 2 Einträge nötig für den Sparkline',
            style: TextStyle(fontSize: 12, color: AppColors.grey500),
          ),
        ),
      );
    }

    final spots = <FlSpot>[];
    for (var i = 0; i < recent.length; i++) {
      spots.add(FlSpot(i.toDouble(), recent[i].painLevel.toDouble()));
    }

    return GlassContainer(
      variant: GlassVariant.medium,
      elevation: GlassElevation.low,
      borderRadius: AppRadius.borderRadiusLg,
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      child: SizedBox(
        height: 80,
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: 10,
            gridData: const FlGridData(show: false),
            titlesData: const FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                preventCurveOverShooting: true,
                color: AppColors.primary,
                barWidth: 2,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.18),
                      AppColors.primary.withValues(alpha: 0.02),
                    ],
                  ),
                ),
              ),
            ],
            lineTouchData: const LineTouchData(enabled: false),
          ),
        ),
      ),
    );
  }

  static Color _painColor(double level) {
    if (level < 4) return AppColors.success;
    if (level < 7) return AppColors.warning;
    return AppColors.error;
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
  });
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      variant: GlassVariant.thin,
      elevation: GlassElevation.flat,
      borderRadius: AppRadius.borderRadiusLg,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: iconColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}

class _MacroMiniBar extends StatelessWidget {
  const _MacroMiniBar({
    required this.protein,
    required this.carbs,
    required this.fat,
  });
  final int protein;
  final int carbs;
  final int fat;

  @override
  Widget build(BuildContext context) {
    final total = protein + carbs + fat;
    if (total == 0) {
      return const Text(
        'Keine Makros erfasst',
        style: TextStyle(fontSize: 11, color: AppColors.grey500),
      );
    }
    return Column(
      children: [
        ClipRRect(
          borderRadius: AppRadius.borderRadiusSm,
          child: SizedBox(
            height: 6,
            child: Row(
              children: [
                Flexible(
                  flex: protein,
                  child: Container(color: const Color(0xFF5856D6)),
                ),
                Flexible(
                  flex: carbs,
                  child: Container(color: AppColors.warning),
                ),
                Flexible(
                  flex: fat,
                  child: Container(color: AppColors.error),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _macroLabel('P', protein, const Color(0xFF5856D6)),
            const SizedBox(width: AppSpacing.md),
            _macroLabel('K', carbs, AppColors.warning),
            const SizedBox(width: AppSpacing.md),
            _macroLabel('F', fat, AppColors.error),
          ],
        ),
      ],
    );
  }

  Widget _macroLabel(String prefix, int grams, Color color) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 3),
          Text(
            '$prefix: ${grams}g',
            style: const TextStyle(fontSize: 10, color: AppColors.grey600),
          ),
        ],
      );
}

// =============================================================================
// Pain Tab
// =============================================================================

class _PainTab extends StatelessWidget {
  const _PainTab({required this.entries});
  final List<PainEntry> entries;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (entries.isEmpty) return _emptyState(l.nochKeineSchmerzeintraege);

    final spots = <FlSpot>[];
    for (var i = 0; i < entries.length; i++) {
      spots.add(FlSpot(i.toDouble(), entries[i].painLevel.toDouble()));
    }

    // Summary stats
    final levels = entries.map((e) => e.painLevel);
    final avg = levels.reduce((a, b) => a + b) / levels.length;
    final max = levels.reduce((a, b) => a > b ? a : b);
    final min = levels.reduce((a, b) => a < b ? a : b);

    return ListView(
      physics: adaptiveScrollPhysics,
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // Stats row
        Row(
          children: [
            _StatCard(
              label: 'Ø Schmerz',
              value: avg.toStringAsFixed(1),
              color: _painColor(avg),
            ),
            const SizedBox(width: AppSpacing.sm),
            _StatCard(
              label: 'Min',
              value: '$min',
              color: AppColors.success,
            ),
            const SizedBox(width: AppSpacing.sm),
            _StatCard(
              label: 'Max',
              value: '$max',
              color: AppColors.error,
            ),
            const SizedBox(width: AppSpacing.sm),
            _StatCard(
              label: 'Einträge',
              value: '${entries.length}',
              color: AppColors.primary,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),

        // Chart
        GlassContainer(
          variant: GlassVariant.medium,
          elevation: GlassElevation.low,
          padding: const EdgeInsets.fromLTRB(12, 20, 20, 12),
          borderRadius: AppRadius.borderRadiusLg,
          child: AspectRatio(
            aspectRatio: 1.6,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 10,
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.grey200,
                    strokeWidth: 0.5,
                  ),
                  drawVerticalLine: false,
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 2,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.grey500,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: _bottomInterval(entries.length),
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= entries.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            DateFormat('dd.MM').format(
                              entries[idx].occurredAt,
                            ),
                            style: const TextStyle(
                              fontSize: 9,
                              color: AppColors.grey500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                rangeAnnotations: RangeAnnotations(
                  horizontalRangeAnnotations: [
                    HorizontalRangeAnnotation(
                      y1: 0,
                      y2: 3,
                      color: AppColors.success.withValues(alpha: 0.06),
                    ),
                    HorizontalRangeAnnotation(
                      y1: 3,
                      y2: 7,
                      color: AppColors.warning.withValues(alpha: 0.06),
                    ),
                    HorizontalRangeAnnotation(
                      y1: 7,
                      y2: 10,
                      color: AppColors.error.withValues(alpha: 0.06),
                    ),
                  ],
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    preventCurveOverShooting: true,
                    color: AppColors.primary,
                    barWidth: 2.5,
                    dotData: FlDotData(
                      show: entries.length <= 30,
                      getDotPainter: (spot, xPct, bar, idx) =>
                          FlDotCirclePainter(
                        radius: 3,
                        color: _painColor(spot.y),
                        strokeWidth: 1.5,
                        strokeColor: AppColors.white,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary.withValues(alpha: 0.20),
                          AppColors.primary.withValues(alpha: 0.02),
                        ],
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (spots) => spots.map((s) {
                      final idx = s.spotIndex;
                      final entry = entries[idx];
                      return LineTooltipItem(
                        '${entry.painLevel}/10\n'
                        '${DateFormat('dd.MM HH:mm').format(entry.occurredAt)}',
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ),

        // ── Detail Analysis ──────────────────────────────────
        const SizedBox(height: AppSpacing.xxl),
        ..._buildBodyRegionChart(context),
        const SizedBox(height: AppSpacing.xxl),
        ..._buildPainTypeDonut(context),
        const SizedBox(height: AppSpacing.xxl),
        ..._buildTriggerChart(context),
        const SizedBox(height: AppSpacing.xxl),
        ..._buildMedicationImpact(context),

        // ── Correlations ─────────────────────────────────────
        const SizedBox(height: AppSpacing.xxl),
        ..._buildWeekdayChart(context),
        const SizedBox(height: AppSpacing.xxl),
        ..._buildDaytimeChart(context),
      ],
    );
  }

  // ── Body Region frequency ──
  List<Widget> _buildBodyRegionChart(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final regionCount = <BodyRegion, int>{};
    for (final e in entries) {
      if (e.bodyRegion != null) {
        regionCount[e.bodyRegion!] = (regionCount[e.bodyRegion!] ?? 0) + 1;
      }
    }
    if (regionCount.isEmpty) return [];

    final sorted = regionCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return [
      _sectionLabel(context, l.koerperregionHaeufigkeit),
      const SizedBox(height: AppSpacing.sm),
      GlassContainer(
        variant: GlassVariant.medium,
        elevation: GlassElevation.low,
        borderRadius: AppRadius.borderRadiusLg,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: sorted.map((e) {
            final pct = sorted.first.value == 0 ? 1.0 : e.value / sorted.first.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  SizedBox(
                    width: 90,
                    child: Text(
                      e.key.label,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.grey700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: AppRadius.borderRadiusSm,
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 14,
                        backgroundColor: AppColors.grey100,
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '${e.value}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey700,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    ];
  }

  // ── Pain type donut ──
  List<Widget> _buildPainTypeDonut(BuildContext context) {
    final typeCount = <PainType, int>{};
    for (final e in entries) {
      if (e.painType != null) {
        typeCount[e.painType!] = (typeCount[e.painType!] ?? 0) + 1;
      }
    }
    if (typeCount.isEmpty) return [];

    final colors = [
      const Color(0xFF5856D6),
      AppColors.error,
      AppColors.warning,
      AppColors.success,
      const Color(0xFFFF6B6B),
      const Color(0xFF34C759),
      const Color(0xFFFF9500),
      const Color(0xFFAF52DE),
    ];

    final sorted = typeCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = sorted.fold<int>(0, (s, e) => s + e.value);

    return [
      _sectionLabel(context, 'Schmerztyp-Verteilung'),
      const SizedBox(height: AppSpacing.sm),
      GlassContainer(
        variant: GlassVariant.medium,
        elevation: GlassElevation.low,
        borderRadius: AppRadius.borderRadiusLg,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            SizedBox(
              height: 160,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 36,
                  sections: List.generate(sorted.length, (i) {
                    final pct = sorted[i].value / total * 100;
                    return PieChartSectionData(
                      value: sorted[i].value.toDouble(),
                      color: colors[i % colors.length],
                      radius: 40,
                      title: '${pct.toStringAsFixed(0)}%',
                      titleStyle: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.xs,
              children: List.generate(sorted.length, (i) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colors[i % colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${sorted[i].key.label} (${sorted[i].value})',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.grey600,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    ];
  }

  // ── Trigger frequency ──
  List<Widget> _buildTriggerChart(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final triggerCount = <String, int>{};
    for (final e in entries) {
      if (e.trigger != null && e.trigger!.isNotEmpty) {
        triggerCount[e.trigger!] = (triggerCount[e.trigger!] ?? 0) + 1;
      }
    }
    if (triggerCount.isEmpty) return [];

    final sorted = triggerCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(8).toList();

    return [
      _sectionLabel(context, l.triggerHaeufigkeit),
      const SizedBox(height: AppSpacing.sm),
      GlassContainer(
        variant: GlassVariant.medium,
        elevation: GlassElevation.low,
        borderRadius: AppRadius.borderRadiusLg,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: top.map((e) {
            final pct = sorted.first.value == 0 ? 1.0 : e.value / sorted.first.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      e.key,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.grey700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: AppRadius.borderRadiusSm,
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 12,
                        backgroundColor: AppColors.grey100,
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.warning,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '${e.value}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey700,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    ];
  }

  // ── Medication impact ──
  List<Widget> _buildMedicationImpact(BuildContext context) {
    final withMed =
        entries.where((e) => e.medicationTaken == true).toList();
    final withoutMed =
        entries.where((e) => e.medicationTaken == false).toList();
    if (withMed.isEmpty && withoutMed.isEmpty) return [];

    final avgWith = withMed.isEmpty
        ? 0.0
        : withMed.map((e) => e.painLevel).reduce((a, b) => a + b) /
            withMed.length;
    final avgWithout = withoutMed.isEmpty
        ? 0.0
        : withoutMed.map((e) => e.painLevel).reduce((a, b) => a + b) /
            withoutMed.length;

    return [
      _sectionLabel(context, 'Medikations-Impact'),
      const SizedBox(height: AppSpacing.sm),
      GlassContainer(
        variant: GlassVariant.medium,
        elevation: GlassElevation.low,
        borderRadius: AppRadius.borderRadiusLg,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Expanded(
              child: _MedImpactBar(
                label: 'Mit Medikation',
                value: avgWith,
                count: withMed.length,
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _MedImpactBar(
                label: 'Ohne Medikation',
                value: avgWithout,
                count: withoutMed.length,
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ),
    ];
  }

  // ── Weekday correlation ──
  List<Widget> _buildWeekdayChart(BuildContext context) {
    if (entries.length < 3) return [];
    final dayNames = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
    final daySum = List.filled(7, 0.0);
    final dayCount = List.filled(7, 0);
    for (final e in entries) {
      final wd = (e.occurredAt.weekday - 1) % 7;
      daySum[wd] += e.painLevel;
      dayCount[wd]++;
    }

    return [
      _sectionLabel(context, 'Schmerz nach Wochentag'),
      const SizedBox(height: AppSpacing.sm),
      GlassContainer(
        variant: GlassVariant.medium,
        elevation: GlassElevation.low,
        borderRadius: AppRadius.borderRadiusLg,
        padding: const EdgeInsets.fromLTRB(12, 20, 20, 12),
        child: AspectRatio(
          aspectRatio: 1.8,
          child: BarChart(
            BarChartData(
              maxY: 10,
              barGroups: List.generate(7, (i) {
                final avg =
                    dayCount[i] > 0 ? daySum[i] / dayCount[i] : 0.0;
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: avg,
                      width: 20,
                      color: _painColor(avg),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              }),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: 2,
                    getTitlesWidget: (v, _) => Text(
                      v.toInt().toString(),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.grey500,
                      ),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 24,
                    getTitlesWidget: (v, _) {
                      final idx = v.toInt();
                      if (idx < 0 || idx >= 7) {
                        return const SizedBox.shrink();
                      }
                      return Text(
                        dayNames[idx],
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.grey600,
                        ),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                horizontalInterval: 2,
                getDrawingHorizontalLine: (v) => FlLine(
                  color: AppColors.grey200,
                  strokeWidth: 0.5,
                ),
                drawVerticalLine: false,
              ),
            ),
          ),
        ),
      ),
    ];
  }

  // ── Daytime correlation ──
  List<Widget> _buildDaytimeChart(BuildContext context) {
    if (entries.length < 3) return [];
    final slotNames = ['Nacht\n0–6', 'Morgen\n6–12', 'Mittag\n12–18', 'Abend\n18–24'];
    final slotSum = List.filled(4, 0.0);
    final slotCount = List.filled(4, 0);
    for (final e in entries) {
      final h = e.occurredAt.hour;
      final slot = h < 6 ? 0 : h < 12 ? 1 : h < 18 ? 2 : 3;
      slotSum[slot] += e.painLevel;
      slotCount[slot]++;
    }

    return [
      _sectionLabel(context, 'Schmerz nach Tageszeit'),
      const SizedBox(height: AppSpacing.sm),
      GlassContainer(
        variant: GlassVariant.medium,
        elevation: GlassElevation.low,
        borderRadius: AppRadius.borderRadiusLg,
        padding: const EdgeInsets.fromLTRB(12, 20, 20, 12),
        child: AspectRatio(
          aspectRatio: 2.0,
          child: BarChart(
            BarChartData(
              maxY: 10,
              barGroups: List.generate(4, (i) {
                final avg =
                    slotCount[i] > 0 ? slotSum[i] / slotCount[i] : 0.0;
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: avg,
                      width: 28,
                      color: _painColor(avg),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              }),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: 2,
                    getTitlesWidget: (v, _) => Text(
                      v.toInt().toString(),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.grey500,
                      ),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    getTitlesWidget: (v, _) {
                      final idx = v.toInt();
                      if (idx < 0 || idx >= 4) {
                        return const SizedBox.shrink();
                      }
                      return Text(
                        slotNames[idx],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 9,
                          color: AppColors.grey600,
                        ),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                horizontalInterval: 2,
                getDrawingHorizontalLine: (v) => FlLine(
                  color: AppColors.grey200,
                  strokeWidth: 0.5,
                ),
                drawVerticalLine: false,
              ),
            ),
          ),
        ),
      ),
    ];
  }

  Widget _sectionLabel(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.only(left: AppSpacing.xs),
        child: Text(text, style: Theme.of(context).textTheme.titleSmall),
      );

  static Color _painColor(double level) {
    if (level < 4) return AppColors.success;
    if (level < 7) return AppColors.warning;
    return AppColors.error;
  }
}

class _MedImpactBar extends StatelessWidget {
  const _MedImpactBar({
    required this.label,
    required this.value,
    required this.count,
    required this.color,
  });
  final String label;
  final double value;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.grey700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$count Einträge',
          style: const TextStyle(fontSize: 10, color: AppColors.grey500),
        ),
      ],
    );
  }
}

// =============================================================================
// Vitals Tab
// =============================================================================

class _VitalsTab extends StatelessWidget {
  const _VitalsTab({required this.entries});
  final List<VitalEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return _emptyState('Noch keine Vitalwerte');

    final sysSpots = <FlSpot>[];
    final diaSpots = <FlSpot>[];
    final pulseSpots = <FlSpot>[];
    for (var i = 0; i < entries.length; i++) {
      sysSpots.add(FlSpot(i.toDouble(), entries[i].systolic.toDouble()));
      diaSpots.add(FlSpot(i.toDouble(), entries[i].diastolic.toDouble()));
      pulseSpots.add(FlSpot(i.toDouble(), entries[i].pulse.toDouble()));
    }

    return ListView(
      physics: adaptiveScrollPhysics,
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // Blood pressure chart
        _chartLabel(context, '🩸 Blutdruck (mmHg)'),
        const SizedBox(height: AppSpacing.sm),
        GlassContainer(
          variant: GlassVariant.medium,
          elevation: GlassElevation.low,
          padding: const EdgeInsets.fromLTRB(12, 20, 20, 12),
          borderRadius: AppRadius.borderRadiusLg,
          child: AspectRatio(
            aspectRatio: 1.6,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.grey200,
                    strokeWidth: 0.5,
                  ),
                  drawVerticalLine: false,
                ),
                titlesData: _vitalTitles(entries),
                borderData: FlBorderData(show: false),
                rangeAnnotations: RangeAnnotations(
                  horizontalRangeAnnotations: [
                    HorizontalRangeAnnotation(
                      y1: 90,
                      y2: 140,
                      color: AppColors.success.withValues(alpha: 0.06),
                    ),
                  ],
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: sysSpots,
                    isCurved: true,
                    preventCurveOverShooting: true,
                    color: AppColors.error,
                    barWidth: 2,
                    dotData: FlDotData(show: entries.length <= 20),
                  ),
                  LineChartBarData(
                    spots: diaSpots,
                    isCurved: true,
                    preventCurveOverShooting: true,
                    color: AppColors.primary,
                    barWidth: 2,
                    dotData: FlDotData(show: entries.length <= 20),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (spots) => spots.map((s) {
                      final idx = s.spotIndex;
                      final e = entries[idx];
                      final label = s.barIndex == 0
                          ? 'Sys: ${e.systolic}'
                          : 'Dia: ${e.diastolic}';
                      return LineTooltipItem(
                        '$label\n'
                        '${DateFormat('dd.MM HH:mm').format(e.createdAt)}',
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _legendRow(context),

        const SizedBox(height: AppSpacing.xxl),

        // Pulse chart
        _chartLabel(context, 'Puls (bpm)'),
        const SizedBox(height: AppSpacing.sm),
        GlassContainer(
          variant: GlassVariant.medium,
          elevation: GlassElevation.low,
          padding: const EdgeInsets.fromLTRB(12, 20, 20, 12),
          borderRadius: AppRadius.borderRadiusLg,
          child: AspectRatio(
            aspectRatio: 1.6,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.grey200,
                    strokeWidth: 0.5,
                  ),
                  drawVerticalLine: false,
                ),
                titlesData: _vitalTitles(entries),
                borderData: FlBorderData(show: false),
                rangeAnnotations: RangeAnnotations(
                  horizontalRangeAnnotations: [
                    HorizontalRangeAnnotation(
                      y1: 60,
                      y2: 100,
                      color: AppColors.success.withValues(alpha: 0.06),
                    ),
                  ],
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: pulseSpots,
                    isCurved: true,
                    preventCurveOverShooting: true,
                    color: const Color(0xFFFF6B6B),
                    barWidth: 2.5,
                    dotData: FlDotData(show: entries.length <= 20),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFFFF6B6B).withValues(alpha: 0.15),
                          const Color(0xFFFF6B6B).withValues(alpha: 0.02),
                        ],
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (spots) => spots.map((s) {
                      final idx = s.spotIndex;
                      final e = entries[idx];
                      return LineTooltipItem(
                        '${e.pulse} bpm\n'
                        '${DateFormat('dd.MM HH:mm').format(e.createdAt)}',
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ),

        // ── Extended Vitals ─────────────────────────────────
        ..._buildWeightChart(context),
        ..._buildTemperatureChart(context),
        ..._buildOxygenChart(context),
      ],
    );
  }

  // ── Weight chart ──
  List<Widget> _buildWeightChart(BuildContext context) {
    final withWeight =
        entries.where((e) => e.weight != null).toList();
    if (withWeight.length < 2) return [];
    final spots = <FlSpot>[];
    for (var i = 0; i < withWeight.length; i++) {
      spots.add(FlSpot(i.toDouble(), withWeight[i].weight!));
    }
    return [
      const SizedBox(height: AppSpacing.xxl),
      _chartLabel(context, '⚖️ Gewicht (kg)'),
      const SizedBox(height: AppSpacing.sm),
      _buildSimpleLineChart(spots, withWeight, const Color(0xFF5856D6), (i) {
        final e = withWeight[i];
        return '${e.weight!.toStringAsFixed(1)} kg\n${DateFormat('dd.MM').format(e.createdAt)}';
      }),
    ];
  }

  // ── Temperature chart ──
  List<Widget> _buildTemperatureChart(BuildContext context) {
    final withTemp =
        entries.where((e) => e.temperature != null).toList();
    if (withTemp.length < 2) return [];
    final spots = <FlSpot>[];
    for (var i = 0; i < withTemp.length; i++) {
      spots.add(FlSpot(i.toDouble(), withTemp[i].temperature!));
    }
    return [
      const SizedBox(height: AppSpacing.xxl),
      _chartLabel(context, '🌡️ Temperatur (°C)'),
      const SizedBox(height: AppSpacing.sm),
      _buildSimpleLineChart(spots, withTemp, AppColors.warning, (i) {
        final e = withTemp[i];
        return '${e.temperature!.toStringAsFixed(1)} °C\n${DateFormat('dd.MM').format(e.createdAt)}';
      }),
    ];
  }

  // ── O2 saturation chart ──
  List<Widget> _buildOxygenChart(BuildContext context) {
    final withO2 =
        entries.where((e) => e.oxygenSaturation != null).toList();
    if (withO2.length < 2) return [];
    final spots = <FlSpot>[];
    for (var i = 0; i < withO2.length; i++) {
      spots.add(FlSpot(i.toDouble(), withO2[i].oxygenSaturation!.toDouble()));
    }
    return [
      const SizedBox(height: AppSpacing.xxl),
      _chartLabel(context, '💨 O₂-Sättigung (%)'),
      const SizedBox(height: AppSpacing.sm),
      _buildSimpleLineChart(spots, withO2, AppColors.primary, (i) {
        final e = withO2[i];
        return '${e.oxygenSaturation}%\n${DateFormat('dd.MM').format(e.createdAt)}';
      }),
    ];
  }

  Widget _buildSimpleLineChart(
    List<FlSpot> spots,
    List<VitalEntry> data,
    Color color,
    String Function(int idx) tooltipBuilder,
  ) {
    return GlassContainer(
      variant: GlassVariant.medium,
      elevation: GlassElevation.low,
      padding: const EdgeInsets.fromLTRB(12, 20, 20, 12),
      borderRadius: AppRadius.borderRadiusLg,
      child: AspectRatio(
        aspectRatio: 1.6,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              getDrawingHorizontalLine: (v) => FlLine(
                color: AppColors.grey200,
                strokeWidth: 0.5,
              ),
              drawVerticalLine: false,
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 36,
                  getTitlesWidget: (v, _) => Text(
                    v.toStringAsFixed(0),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.grey500,
                    ),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  interval: _bottomInterval(data.length),
                  getTitlesWidget: (v, _) {
                    final idx = v.toInt();
                    if (idx < 0 || idx >= data.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        DateFormat('dd.MM').format(data[idx].createdAt),
                        style: const TextStyle(
                          fontSize: 9,
                          color: AppColors.grey500,
                        ),
                      ),
                    );
                  },
                ),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                preventCurveOverShooting: true,
                color: color,
                barWidth: 2.5,
                dotData: FlDotData(show: data.length <= 20),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      color.withValues(alpha: 0.15),
                      color.withValues(alpha: 0.02),
                    ],
                  ),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (touchedSpots) => touchedSpots.map((s) {
                  return LineTooltipItem(
                    tooltipBuilder(s.spotIndex),
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  FlTitlesData _vitalTitles(List<VitalEntry> entries) => FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 36,
            getTitlesWidget: (value, meta) => Text(
              value.toInt().toString(),
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.grey500,
              ),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            interval: _bottomInterval(entries.length),
            getTitlesWidget: (value, meta) {
              final idx = value.toInt();
              if (idx < 0 || idx >= entries.length) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  DateFormat('dd.MM').format(entries[idx].createdAt),
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppColors.grey500,
                  ),
                ),
              );
            },
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      );

  Widget _legendRow(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _legendDot(AppColors.error, 'Systolisch'),
          const SizedBox(width: AppSpacing.lg),
          _legendDot(AppColors.primary, 'Diastolisch'),
        ],
      );

  Widget _legendDot(Color color, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.grey600,
            ),
          ),
        ],
      );

  Widget _chartLabel(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.only(left: AppSpacing.xs),
        child: Text(
          text,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
}

// =============================================================================
// Wounds Tab
// =============================================================================

class _WoundsTab extends StatelessWidget {
  const _WoundsTab({required this.entries});
  final List<WoundEntry> entries;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (entries.isEmpty) return _emptyState(l.nochKeineWundeintraege);

    final spots = <FlSpot>[];
    for (var i = 0; i < entries.length; i++) {
      spots.add(FlSpot(i.toDouble(), entries[i].pain.toDouble()));
    }

    final levels = entries.map((e) => e.pain);
    final avg = levels.reduce((a, b) => a + b) / levels.length;

    return ListView(
      physics: adaptiveScrollPhysics,
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // Stats
        Row(
          children: [
            _StatCard(
              label: 'Ø Wundschmerz',
              value: avg.toStringAsFixed(1),
              color: AppColors.warning,
            ),
            const SizedBox(width: AppSpacing.sm),
            _StatCard(
              label: 'Einträge',
              value: '${entries.length}',
              color: AppColors.primary,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),

        // Chart
        GlassContainer(
          variant: GlassVariant.medium,
          elevation: GlassElevation.low,
          padding: const EdgeInsets.fromLTRB(12, 20, 20, 12),
          borderRadius: AppRadius.borderRadiusLg,
          child: AspectRatio(
            aspectRatio: 1.6,
            child: BarChart(
              BarChartData(
                maxY: 10,
                barGroups: List.generate(entries.length, (i) {
                  final pain = entries[i].pain.toDouble();
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: pain,
                        width: entries.length > 20 ? 6 : 14,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            AppColors.primary.withValues(alpha: 0.6),
                            pain >= 7
                                ? AppColors.error
                                : pain >= 4
                                    ? AppColors.warning
                                    : AppColors.success,
                          ],
                        ),
                      ),
                    ],
                  );
                }),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.grey200,
                    strokeWidth: 0.5,
                  ),
                  drawVerticalLine: false,
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 2,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.grey500,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: _bottomInterval(entries.length),
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= entries.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            DateFormat('dd.MM').format(
                              entries[idx].createdAt,
                            ),
                            style: const TextStyle(
                              fontSize: 9,
                              color: AppColors.grey500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, gIdx, rod, rIdx) {
                      final e = entries[group.x];
                      return BarTooltipItem(
                        'Schmerz: ${e.pain}/10\n'
                        '${DateFormat('dd.MM.yy').format(e.createdAt)}'
                        '${e.bodyLocation != null ? '\n${e.bodyLocation}' : ''}',
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Shared helpers
// =============================================================================

double _bottomInterval(int count) {
  if (count <= 7) return 1;
  if (count <= 14) return 2;
  if (count <= 30) return 5;
  return (count / 6).ceilToDouble();
}

Widget _emptyState(String message) => Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.bar_chart_rounded,
              size: 56,
              color: AppColors.grey300,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );

class _StatCard extends StatelessWidget {
  const _StatCard({
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
      child: GlassContainer(
        variant: GlassVariant.thin,
        elevation: GlassElevation.flat,
        borderRadius: AppRadius.borderRadiusMd,
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.sm,
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.grey600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Pro locked preview ───────────────────────────────────────────────────────

class _AnalyticsLockedPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return GlassContainer(
      variant: GlassVariant.medium,
      borderRadius: AppRadius.borderRadiusLg,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _PreviewChip(
                  label: 'Schmerz',
                  value: '7 Tage',
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _PreviewChip(
                  label: 'Vitals',
                  value: 'Trend',
                  color: AppColors.error,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _PreviewChip(
                  label: 'Wunden',
                  value: l.history,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.grey100.withValues(alpha: 0.55),
              borderRadius: AppRadius.borderRadiusLg,
            ),
            child: Text(
              'Vorschau: Schmerzverlauf, Blutdruck-Trend und '
              'Wundheilung als interaktive Diagramme – '
              'filtere nach Zeitraum und erkenne Muster.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewChip extends StatelessWidget {
  const _PreviewChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: AppRadius.borderRadiusLg,
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Nutrition Tab
// =============================================================================

class _NutritionTab extends StatelessWidget {
  const _NutritionTab({required this.entries});
  final List<NutritionEntry> entries;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (entries.isEmpty) return _emptyState(l.nochKeineErnaehrungseintraege);

    return ListView(
      physics: adaptiveScrollPhysics,
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        ..._buildCalorieTrend(context),
        const SizedBox(height: AppSpacing.xxl),
        ..._buildWaterChart(context),
        const SizedBox(height: AppSpacing.xxl),
        ..._buildMacroSummary(context),
        const SizedBox(height: AppSpacing.xxl),
        ..._buildSymptomChart(context),
      ],
    );
  }

  // ── Calorie trend (sum per day) ──
  List<Widget> _buildCalorieTrend(BuildContext context) {
    final perDay = <String, int>{};
    for (final e in entries) {
      if (e.calories != null) {
        final key = DateFormat('yyyy-MM-dd').format(e.occurredAt);
        perDay[key] = (perDay[key] ?? 0) + e.calories!;
      }
    }
    if (perDay.isEmpty) return [];

    final sorted = perDay.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final spots = <FlSpot>[];
    for (var i = 0; i < sorted.length; i++) {
      spots.add(FlSpot(i.toDouble(), sorted[i].value.toDouble()));
    }

    return [
      _sectionLabel(context, '🔥 Kalorien-Trend (kcal/Tag)'),
      const SizedBox(height: AppSpacing.sm),
      GlassContainer(
        variant: GlassVariant.medium,
        elevation: GlassElevation.low,
        borderRadius: AppRadius.borderRadiusLg,
        padding: const EdgeInsets.fromLTRB(12, 20, 20, 12),
        child: AspectRatio(
          aspectRatio: 1.6,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                getDrawingHorizontalLine: (v) => FlLine(
                  color: AppColors.grey200,
                  strokeWidth: 0.5,
                ),
                drawVerticalLine: false,
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (v, _) => Text(
                      v.toInt().toString(),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.grey500,
                      ),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: _bottomInterval(sorted.length),
                    getTitlesWidget: (v, _) {
                      final idx = v.toInt();
                      if (idx < 0 || idx >= sorted.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          sorted[idx].key.substring(5),
                          style: const TextStyle(
                            fontSize: 9,
                            color: AppColors.grey500,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  preventCurveOverShooting: true,
                  color: AppColors.warning,
                  barWidth: 2.5,
                  dotData: FlDotData(show: sorted.length <= 20),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.warning.withValues(alpha: 0.18),
                        AppColors.warning.withValues(alpha: 0.02),
                      ],
                    ),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (spots) => spots.map((s) {
                    return LineTooltipItem(
                      '${s.y.toInt()} kcal\n${sorted[s.spotIndex].key.substring(5)}',
                      const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    ];
  }

  // ── Water chart (bar per day with 2000ml target) ──
  List<Widget> _buildWaterChart(BuildContext context) {
    final perDay = <String, int>{};
    for (final e in entries) {
      if (e.waterMl != null) {
        final key = DateFormat('yyyy-MM-dd').format(e.occurredAt);
        perDay[key] = (perDay[key] ?? 0) + e.waterMl!;
      }
    }
    if (perDay.isEmpty) return [];

    final sorted = perDay.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final maxWater = sorted
        .map((e) => e.value)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    return [
      _sectionLabel(context, '💧 Wasserzufuhr (ml/Tag)'),
      const SizedBox(height: AppSpacing.sm),
      GlassContainer(
        variant: GlassVariant.medium,
        elevation: GlassElevation.low,
        borderRadius: AppRadius.borderRadiusLg,
        padding: const EdgeInsets.fromLTRB(12, 20, 20, 12),
        child: AspectRatio(
          aspectRatio: 1.6,
          child: BarChart(
            BarChartData(
              maxY: (maxWater > 2000 ? maxWater : 2000) * 1.1,
              barGroups: List.generate(sorted.length, (i) {
                final ml = sorted[i].value.toDouble();
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: ml,
                      width: sorted.length > 20 ? 6 : 14,
                      color: ml >= 2000
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.5),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              }),
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: 2000,
                    color: AppColors.success,
                    strokeWidth: 1.5,
                    dashArray: [6, 4],
                    label: HorizontalLineLabel(
                      show: true,
                      alignment: Alignment.topRight,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                      labelResolver: (_) => '2000 ml',
                    ),
                  ),
                ],
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (v, _) => Text(
                      v.toInt().toString(),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.grey500,
                      ),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: _bottomInterval(sorted.length),
                    getTitlesWidget: (v, _) {
                      final idx = v.toInt();
                      if (idx < 0 || idx >= sorted.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          sorted[idx].key.substring(5),
                          style: const TextStyle(
                            fontSize: 9,
                            color: AppColors.grey500,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                getDrawingHorizontalLine: (v) => FlLine(
                  color: AppColors.grey200,
                  strokeWidth: 0.5,
                ),
                drawVerticalLine: false,
              ),
            ),
          ),
        ),
      ),
    ];
  }

  // ── Macro totals summary ──
  List<Widget> _buildMacroSummary(BuildContext context) {
    final totalProtein =
        entries.fold<int>(0, (s, e) => s + (e.protein ?? 0));
    final totalCarbs =
        entries.fold<int>(0, (s, e) => s + (e.carbs ?? 0));
    final totalFat = entries.fold<int>(0, (s, e) => s + (e.fat ?? 0));
    if (totalProtein + totalCarbs + totalFat == 0) return [];

    final colors = [
      const Color(0xFF5856D6),
      AppColors.warning,
      AppColors.error,
    ];
    final labels = ['Protein', 'Kohlenhydrate', 'Fett'];
    final values = [totalProtein, totalCarbs, totalFat];
    final total = totalProtein + totalCarbs + totalFat;

    return [
      _sectionLabel(context, '📊 Makro-Verteilung (gesamt)'),
      const SizedBox(height: AppSpacing.sm),
      GlassContainer(
        variant: GlassVariant.medium,
        elevation: GlassElevation.low,
        borderRadius: AppRadius.borderRadiusLg,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            SizedBox(
              height: 140,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 30,
                  sections: List.generate(3, (i) {
                    final pct = values[i] / total * 100;
                    return PieChartSectionData(
                      value: values[i].toDouble(),
                      color: colors[i],
                      radius: 36,
                      title: '${pct.toStringAsFixed(0)}%',
                      titleStyle: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (i) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colors[i],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${labels[i]}: ${values[i]}g',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.grey600,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    ];
  }

  // ── Symptom frequency ──
  List<Widget> _buildSymptomChart(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final symptomCount = <NutritionSymptom, int>{};
    for (final e in entries) {
      for (final s in e.symptoms) {
        symptomCount[s] = (symptomCount[s] ?? 0) + 1;
      }
    }
    if (symptomCount.isEmpty) return [];

    final sorted = symptomCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return [
      _sectionLabel(context, l.symptomHaeufigkeit),
      const SizedBox(height: AppSpacing.sm),
      GlassContainer(
        variant: GlassVariant.medium,
        elevation: GlassElevation.low,
        borderRadius: AppRadius.borderRadiusLg,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: sorted.map((e) {
            final pct = sorted.first.value == 0 ? 1.0 : e.value / sorted.first.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  SizedBox(
                    width: 90,
                    child: Text(
                      e.key.label,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.grey700,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: AppRadius.borderRadiusSm,
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 12,
                        backgroundColor: AppColors.grey100,
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.error,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '${e.value}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey700,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    ];
  }

  Widget _sectionLabel(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.only(left: AppSpacing.xs),
        child: Text(text, style: Theme.of(context).textTheme.titleSmall),
      );
}

// =============================================================================
// Red Flags Tab
// =============================================================================

class _RedFlagsTab extends StatelessWidget {
  const _RedFlagsTab({required this.entries});
  final List<RedFlag> entries;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (entries.isEmpty) return _emptyState('Noch keine Red Flags');

    final tt = Theme.of(context).textTheme;

    return ListView(
      physics: adaptiveScrollPhysics,
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // ── Severity overview tiles ──
        Row(
          children: RedFlagSeverity.values.map((sev) {
            final count =
                entries.where((e) => e.severity == sev).length;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                ),
                child: GlassContainer(
                  variant: GlassVariant.thin,
                  elevation: GlassElevation.flat,
                  borderRadius: AppRadius.borderRadiusMd,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.md,
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _severityColor(sev),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sev.label,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: AppSpacing.xxl),

        // ── Timeline scatter chart ──
        Text(l.severityCourse, style: tt.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        GlassContainer(
          variant: GlassVariant.medium,
          elevation: GlassElevation.low,
          borderRadius: AppRadius.borderRadiusLg,
          padding: const EdgeInsets.fromLTRB(12, 20, 20, 12),
          child: AspectRatio(
            aspectRatio: 1.6,
            child: ScatterChart(
              ScatterChartData(
                minY: -0.5,
                maxY: 3.5,
                scatterSpots: List.generate(entries.length, (i) {
                  return ScatterSpot(
                    i.toDouble(),
                    entries[i].severity.index.toDouble(),
                    dotPainter: FlDotCirclePainter(
                      radius: 6,
                      color: _severityColor(entries[i].severity),
                      strokeWidth: 1.5,
                      strokeColor: AppColors.white,
                    ),
                  );
                }),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      interval: 1,
                      getTitlesWidget: (v, _) {
                        final idx = v.toInt();
                        if (idx < 0 || idx >= RedFlagSeverity.values.length) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          RedFlagSeverity.values[idx].label,
                          style: TextStyle(
                            fontSize: 10,
                            color: _severityColor(
                              RedFlagSeverity.values[idx],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: _bottomInterval(entries.length),
                      getTitlesWidget: (v, _) {
                        final idx = v.toInt();
                        if (idx < 0 || idx >= entries.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            DateFormat('dd.MM').format(
                              entries[idx].createdAt,
                            ),
                            style: const TextStyle(
                              fontSize: 9,
                              color: AppColors.grey500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: AppColors.grey200,
                    strokeWidth: 0.5,
                  ),
                  drawVerticalLine: false,
                ),
                scatterTouchData: ScatterTouchData(
                  touchTooltipData: ScatterTouchTooltipData(
                    getTooltipItems: (spot) {
                      final idx = spot.x.toInt();
                      if (idx < 0 || idx >= entries.length) return null;
                      final flag = entries[idx];
                      return ScatterTooltipItem(
                        '${flag.severity.label}\n${flag.title}\n'
                        '${DateFormat('dd.MM.yy').format(flag.createdAt)}',
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.xxl),

        // ── Status summary ──
        Text(l.adminStatusOverview, style: tt.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            _StatusCountCard(
              label: 'Offen',
              count: entries.where((f) => f.status.isActive).length,
              color: AppColors.warning,
            ),
            const SizedBox(width: AppSpacing.sm),
            _StatusCountCard(
              label: l.resolved,
              count: entries
                  .where((f) => f.status == RedFlagStatus.resolved)
                  .length,
              color: AppColors.success,
            ),
            const SizedBox(width: AppSpacing.sm),
            _StatusCountCard(
              label: 'Eskaliert',
              count: entries
                  .where((f) => f.status == RedFlagStatus.escalated)
                  .length,
              color: AppColors.error,
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.xxl),

        // ── Recent flags list ──
        Text(l.lastFlags, style: tt.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        ...entries.reversed.take(5).map((f) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: GlassContainer(
                variant: GlassVariant.thin,
                elevation: GlassElevation.flat,
                borderRadius: AppRadius.borderRadiusMd,
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _severityColor(f.severity),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            f.title,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${f.status.label} · ${DateFormat('dd.MM.yy').format(f.createdAt)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.grey500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}

class _StatusCountCard extends StatelessWidget {
  const _StatusCountCard({
    required this.label,
    required this.count,
    required this.color,
  });
  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassContainer(
        variant: GlassVariant.thin,
        elevation: GlassElevation.flat,
        borderRadius: AppRadius.borderRadiusMd,
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.sm,
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.grey600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Mood Tab
// =============================================================================

class _MoodTab extends StatelessWidget {
  const _MoodTab({required this.entries});
  final List<MoodEntry> entries;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (entries.isEmpty) return _emptyState(l.nochKeineStimmungseintraege);

    final spots = <FlSpot>[];
    for (var i = 0; i < entries.length; i++) {
      spots.add(FlSpot(i.toDouble(), entries[i].moodLevel.value.toDouble()));
    }

    final levels = entries.map((e) => e.moodLevel.value);
    final avg = levels.reduce((a, b) => a + b) / levels.length;
    final max = levels.reduce((a, b) => a > b ? a : b);
    final min = levels.reduce((a, b) => a < b ? a : b);

    return ListView(
      physics: adaptiveScrollPhysics,
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Row(
          children: [
            _StatCard(
              label: 'Ø Stimmung',
              value: avg.toStringAsFixed(1),
              color: _moodColor(avg),
            ),
            const SizedBox(width: AppSpacing.sm),
            _StatCard(
              label: 'Min',
              value: '$min',
              color: AppColors.error,
            ),
            const SizedBox(width: AppSpacing.sm),
            _StatCard(
              label: 'Max',
              value: '$max',
              color: AppColors.success,
            ),
            const SizedBox(width: AppSpacing.sm),
            _StatCard(
              label: 'Einträge',
              value: '${entries.length}',
              color: AppColors.primary,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),

        GlassContainer(
          variant: GlassVariant.medium,
          elevation: GlassElevation.low,
          padding: const EdgeInsets.fromLTRB(12, 20, 20, 12),
          borderRadius: AppRadius.borderRadiusLg,
          child: AspectRatio(
            aspectRatio: 1.6,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 5,
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.grey200,
                    strokeWidth: 0.5,
                  ),
                  drawVerticalLine: false,
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt() - 1;
                        if (idx < 0 || idx >= MoodLevel.values.length) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          MoodLevel.values[idx].emoji,
                          style: const TextStyle(fontSize: 14),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: _bottomInterval(entries.length),
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= entries.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            DateFormat('dd.MM').format(entries[idx].createdAt),
                            style: const TextStyle(
                              fontSize: 9,
                              color: AppColors.grey500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                rangeAnnotations: RangeAnnotations(
                  horizontalRangeAnnotations: [
                    HorizontalRangeAnnotation(
                      y1: 0,
                      y2: 2,
                      color: AppColors.error.withValues(alpha: 0.06),
                    ),
                    HorizontalRangeAnnotation(
                      y1: 2,
                      y2: 4,
                      color: AppColors.warning.withValues(alpha: 0.06),
                    ),
                    HorizontalRangeAnnotation(
                      y1: 4,
                      y2: 5,
                      color: AppColors.success.withValues(alpha: 0.06),
                    ),
                  ],
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    preventCurveOverShooting: true,
                    color: AppColors.accent,
                    barWidth: 2.5,
                    dotData: FlDotData(
                      show: entries.length <= 30,
                      getDotPainter: (spot, xPct, bar, idx) =>
                          FlDotCirclePainter(
                        radius: 3,
                        color: _moodColor(spot.y),
                        strokeWidth: 1.5,
                        strokeColor: AppColors.white,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.accent.withValues(alpha: 0.20),
                          AppColors.accent.withValues(alpha: 0.02),
                        ],
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (spots) => spots.map((s) {
                      final idx = s.spotIndex;
                      final entry = entries[idx];
                      return LineTooltipItem(
                        '${entry.moodLevel.emoji} ${entry.moodLevel.label}\n'
                        '${DateFormat('dd.MM HH:mm').format(entry.createdAt)}',
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Category breakdown
        if (_hasCategoryData) ...[
          const SizedBox(height: AppSpacing.xxl),
          Text(
            'Häufigste Faktoren',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          ..._buildCategoryBreakdown(context),
        ],
      ],
    );
  }

  bool get _hasCategoryData =>
      entries.any((e) => e.categories.isNotEmpty);

  List<Widget> _buildCategoryBreakdown(BuildContext context) {
    final counts = <MoodCategory, int>{};
    for (final e in entries) {
      for (final c in e.categories) {
        counts[c] = (counts[c] ?? 0) + 1;
      }
    }
    if (counts.isEmpty) return const [];

    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxCount = sorted.first.value;

    return sorted.map((e) {
      final fraction = e.value / maxCount;
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: GlassContainer(
          variant: GlassVariant.thin,
          elevation: GlassElevation.low,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          borderRadius: AppRadius.borderRadiusMd,
          child: Row(
            children: [
              Text(e.key.emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.key.label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: fraction,
                        minHeight: 6,
                        backgroundColor: AppColors.grey200,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '${e.value}×',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.grey600,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  static Color _moodColor(double value) {
    if (value <= 1.5) return AppColors.error;
    if (value <= 2.5) return AppColors.warning;
    if (value <= 3.5) return const Color(0xFFFFCC00);
    if (value <= 4.5) return AppColors.success;
    return const Color(0xFF30D158);
  }

  static double _bottomInterval(int count) {
    if (count <= 7) return 1;
    if (count <= 14) return 2;
    if (count <= 30) return 5;
    return (count / 6).ceilToDouble();
  }
}

// =============================================================================
// Sleep Tab
// =============================================================================

class _SleepTab extends StatelessWidget {
  const _SleepTab({required this.entries});

  final List<SleepEntry> entries;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (entries.isEmpty) return _emptyState(l.nochKeineSchlafeintraege);

    final durationHours = entries
        .map((entry) => entry.durationMinutes / 60)
        .toList(growable: false);
    final avgHours =
        durationHours.reduce((a, b) => a + b) / durationHours.length;
    final avgQuality =
        entries.map((entry) => entry.quality.value).reduce((a, b) => a + b) /
            entries.length;
    final totalDisturbances =
        entries.fold<int>(0, (sum, entry) => sum + entry.disturbances);

    final spots = <FlSpot>[];
    for (var i = 0; i < entries.length; i++) {
      spots.add(FlSpot(i.toDouble(), entries[i].durationMinutes / 60));
    }

    return ListView(
      physics: adaptiveScrollPhysics,
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Row(
          children: [
            _StatCard(
              label: 'Ø Schlaf',
              value: '${avgHours.toStringAsFixed(1)} h',
              color: AppColors.primary,
            ),
            const SizedBox(width: AppSpacing.sm),
            _StatCard(
              label: 'Ø Qualität',
              value: avgQuality.toStringAsFixed(1),
              color: _sleepQualityColor(avgQuality),
            ),
            const SizedBox(width: AppSpacing.sm),
            _StatCard(
              label: 'Störungen',
              value: '$totalDisturbances',
              color: AppColors.warning,
            ),
            const SizedBox(width: AppSpacing.sm),
            _StatCard(
              label: 'Einträge',
              value: '${entries.length}',
              color: AppColors.success,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),
        GlassContainer(
          variant: GlassVariant.medium,
          elevation: GlassElevation.low,
          padding: const EdgeInsets.fromLTRB(12, 20, 20, 12),
          borderRadius: AppRadius.borderRadiusLg,
          child: AspectRatio(
            aspectRatio: 1.6,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 12,
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.grey200,
                    strokeWidth: 0.5,
                  ),
                  drawVerticalLine: false,
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 34,
                      interval: 2,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.toInt()}h',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.grey500,
                        ),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: _MoodTab._bottomInterval(entries.length),
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= entries.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            DateFormat('dd.MM').format(entries[index].createdAt),
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.grey500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    barWidth: 3,
                    color: AppColors.primary,
                    dotData: FlDotData(
                      show: spots.length <= 14,
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withValues(alpha: 0.14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Letzte Einträge',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        ...entries.reversed.take(10).map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: GlassContainer(
              variant: GlassVariant.thin,
              elevation: GlassElevation.low,
              padding: const EdgeInsets.all(AppSpacing.md),
              borderRadius: AppRadius.borderRadiusMd,
              child: Row(
                children: [
                  Text(entry.quality.emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${entry.durationFormatted} · ${entry.quality.label}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('dd.MM.yy · HH:mm').format(entry.createdAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (entry.disturbances > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.12),
                        borderRadius: AppRadius.borderRadiusPill,
                      ),
                      child: Text(
                        '${entry.disturbances}x',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  static Color _sleepQualityColor(double value) {
    if (value <= 1.5) return AppColors.error;
    if (value <= 2.5) return AppColors.warning;
    if (value <= 3.5) return const Color(0xFFFFCC00);
    if (value <= 4.5) return AppColors.success;
    return const Color(0xFF30D158);
  }
}

Color _severityColor(RedFlagSeverity severity) => switch (severity) {
      RedFlagSeverity.green => AppColors.success,
      RedFlagSeverity.yellow => AppColors.warning,
      RedFlagSeverity.orange => const Color(0xFFFF9500),
      RedFlagSeverity.red => AppColors.error,
    };
