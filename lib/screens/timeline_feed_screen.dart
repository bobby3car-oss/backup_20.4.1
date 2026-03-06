import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../domain/task_orchestrator_sync.dart';
import '../domain/task_orchestrator.dart' show phaseTitle, phaseOrder;
import '../domain/timeline_engine.dart';
import '../features/pro/presentation/pro_badge.dart';
import '../features/pro/presentation/smart_upsell_card.dart';
import '../features/pro/presentation/timeline_upsell_banner.dart';
import '../main.dart';
import '../navigation/quick_actions_config.dart';
import '../navigation/quick_actions_sheet.dart';
import '../navigation/timeline_routes.dart';
import '../theme/app_colors.dart' as timeline_theme;
import '../ui/ui.dart';

timeline_theme.TimelineStatusColors _statusColorsForState(TaskState state) {
  switch (state) {
    case TaskState.planned:
      return timeline_theme.TimelineAppColors.planned;
    case TaskState.due:
      return timeline_theme.TimelineAppColors.due;
    case TaskState.inProgress:
      return timeline_theme.TimelineAppColors.inProgress;
    case TaskState.done:
      return timeline_theme.TimelineAppColors.done;
    case TaskState.skipped:
      return timeline_theme.TimelineAppColors.skipped;
  }
}

// ── Models ───────────────────────────────────────────────────────────────────

class TimelineTask {
  const TimelineTask({
    required this.id,
    required this.emoji,
    required this.title,
    this.subtitle,
    this.milestone,
    this.routeKey,
    required this.state,
    required this.type,
  });

  final String id;
  final String emoji;
  final String title;
  final String? subtitle;
  final String? milestone;
  final String? routeKey;
  final TaskState state;
  final TaskType type;

  bool get isDone => state == TaskState.done;
  bool get isSkipped => state == TaskState.skipped;
}

class TimelineSection {
  TimelineSection({
    required this.offsetLabel,
    required this.dateLabel,
    required this.tasks,
    this.sectionState = TaskState.planned,
  });

  final String offsetLabel;
  final String dateLabel;
  final TaskState sectionState;
  final List<TimelineTask> tasks;

  int get completedCount => tasks.where((t) => t.isDone).length;
  int get totalCount => tasks.length;
}

class _PhaseHeaderData {
  const _PhaseHeaderData({
    required this.title,
    required this.doneCount,
    required this.totalCount,
  });

  final String title;
  final int doneCount;
  final int totalCount;
}

class _TimelineFeedEntry {
  const _TimelineFeedEntry.phase(this.phase)
    : section = null,
      sectionIndex = -1;

  const _TimelineFeedEntry.section(this.section, this.sectionIndex)
    : phase = null;

  final _PhaseHeaderData? phase;
  final TimelineSection? section;
  final int sectionIndex;
}

// ── Dummy data ───────────────────────────────────────────────────────────────

// ── Quick actions (sourced from quick_actions_config.dart) ────────────────

// ── Screen ───────────────────────────────────────────────────────────────────

class TimelineFeedScreen extends StatefulWidget {
  const TimelineFeedScreen({super.key});

  @override
  State<TimelineFeedScreen> createState() => _TimelineFeedScreenState();
}

class _TimelineFeedScreenState extends State<TimelineFeedScreen> {
  final TaskOrchestratorSync _orchestrator = TaskOrchestratorSync.instance;
  late final Stream<List<TimelineItem>> _timelineStream;
  bool _showTimelineBanner = false;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _timelineStream = _orchestrator.watch(
      from: DateTime.now().subtract(const Duration(days: 365)),
      to: DateTime.now().add(const Duration(days: 365)),
    );
    _bootstrap();
    _checkTimelineOpenTrigger();
  }

  Future<void> _bootstrap() async {
    await _orchestrator.initialize();
    if (mounted) {
      setState(() => _isInitializing = false);
    }
  }

  Future<void> _checkTimelineOpenTrigger() async {
    final pro = ProServices.maybeOf(context);
    if (pro == null) return;
    final shouldShow = await pro.paywallTriggerService.onTimelineOpened();
    if (shouldShow && mounted) {
      setState(() => _showTimelineBanner = true);
    }
  }

  @override
  void dispose() {
    // Singleton – do not dispose.
    super.dispose();
  }

  Future<void> _setTaskDone(String id) {
    return _orchestrator.setState(id, TaskState.done);
  }

  Future<void> _toggleTaskDone(String id, TaskState currentState) {
    final nextState = currentState == TaskState.done
        ? TaskState.planned
        : TaskState.done;
    return _orchestrator.setState(id, nextState);
  }

  Future<void> _setTaskSkipped(String id) {
    return _orchestrator.setState(id, TaskState.skipped);
  }

  Future<void> _snoozeTask(String id) {
    return _orchestrator.snoozeItem30Minutes(id);
  }

  Future<void> _openQuickActionsSheet() async {
    final route = await showQuickActionsSheet(context);
    if (route != null && mounted) {
      _openNamedRoute(route);
    }
  }

  Future<void> _pickOperationDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null) return;

    await _orchestrator.setOperationDate(picked);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Care Plan für OP-Datum generiert.'),
        duration: Duration(milliseconds: 1300),
      ),
    );
  }

  Future<void> _openNamedRoute(String routeName, {String? taskId}) async {
    try {
      final arguments =
          routeName == '/wound' && taskId != null && taskId.isNotEmpty
          ? <String, dynamic>{'taskId': taskId}
          : null;
      await Navigator.of(context).pushNamed(routeName, arguments: arguments);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('kommt gleich'),
          duration: Duration(milliseconds: 1400),
        ),
      );
    }
  }



  String _emojiForType(TaskType type) {
    switch (type) {
      case TaskType.wound:
        return '📸';
      case TaskType.meds:
        return '💊';
      case TaskType.checklist:
        return '✅';
      case TaskType.appointment:
        return '📅';
      case TaskType.message:
        return '💬';
      case TaskType.custom:
        return '📝';
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  String _dayKey(DateTime value) {
    final d = _dateOnly(value);
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }

  DateTime _dayFromKey(String key) {
    final parts = key.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  String _dateLabel(DateTime date) {
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    return '$dd.$mm.';
  }

  String _weekdayLabel(DateTime date) {
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

  List<_TimelineFeedEntry> _buildTimelineEntries(List<TimelineItem> items) {
    final now = DateTime.now();
    final groupedByPhaseAndDay = <String, Map<String, List<TimelineItem>>>{};
    final todayDate = _dateOnly(now);
    final tomorrowDate = todayDate.add(const Duration(days: 1));

    for (final item in items) {
      final computed = computeState(item, now);
      final normalized = item.copyWith(state: computed);
      final phase = (normalized.metadata['phase'] as String?) ?? 'followup';
      final dayKey = _dayKey(normalized.scheduledAt.toLocal());
      final byDay = groupedByPhaseAndDay.putIfAbsent(
        phase,
        () => <String, List<TimelineItem>>{},
      );
      byDay.putIfAbsent(dayKey, () => <TimelineItem>[]).add(normalized);
    }

    TimelineSection mapSection({
      required String dayLabel,
      required String dateLabel,
      required TaskState sectionState,
      required List<TimelineItem> source,
    }) {
      return TimelineSection(
        offsetLabel: dayLabel,
        dateLabel: dateLabel,
        sectionState: sectionState,
        tasks: source
            .map(
              (item) => TimelineTask(
                id: item.id,
                emoji: _emojiForType(item.type),
                title: item.title,
                subtitle: item.subtitle,
                milestone: item.metadata['milestone'] as String?,
                routeKey: item.deeplinkRoute,
                state: item.state,
                type: item.type,
              ),
            )
            .toList(),
      );
    }

    final entries = <_TimelineFeedEntry>[];
    var sectionIndex = 0;

    final sortedPhases = groupedByPhaseAndDay.keys.toList()
      ..sort((a, b) => phaseOrder(a).compareTo(phaseOrder(b)));

    for (final phase in sortedPhases) {
      final byDay =
          groupedByPhaseAndDay[phase] ?? const <String, List<TimelineItem>>{};
      final allPhaseItems = byDay.values.expand((e) => e);
      final totalCount = allPhaseItems.length;
      final doneCount = allPhaseItems
          .where((item) => item.state == TaskState.done)
          .length;
      final title = phaseTitle(phase);

      entries.add(
        _TimelineFeedEntry.phase(
          _PhaseHeaderData(
            title: title,
            doneCount: doneCount,
            totalCount: totalCount,
          ),
        ),
      );

      final sortedDayKeys = byDay.keys.toList()
        ..sort((a, b) => _dayFromKey(a).compareTo(_dayFromKey(b)));

      for (final key in sortedDayKeys) {
        final day = _dayFromKey(key);
        final source = sortItems(byDay[key] ?? const <TimelineItem>[]);
        final dayDoneCount = source
            .where((task) => task.state == TaskState.done)
            .length;
        final hasDue = source.any((task) => task.state == TaskState.due);
        final label = _isSameDay(day, todayDate)
            ? 'Heute'
            : _isSameDay(day, tomorrowDate)
            ? 'Morgen'
            : '${_weekdayLabel(day)} · ${_dateLabel(day)}';

        entries.add(
          _TimelineFeedEntry.section(
            mapSection(
              dayLabel: label,
              dateLabel:
                  '${_dateLabel(day)} · $dayDoneCount/${source.length} erledigt',
              sectionState: hasDue
                  ? TaskState.due
                  : _isSameDay(day, todayDate)
                  ? TaskState.inProgress
                  : TaskState.planned,
              source: source,
            ),
            sectionIndex++,
          ),
        );
      }
    }
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return StreamBuilder<List<TimelineItem>>(
      stream: _timelineStream,
      builder: (context, snapshot) {
        if ((snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) ||
            _isInitializing) {
          return const _LoadingTimelineState();
        }

        final items = snapshot.data ?? const <TimelineItem>[];
        if (items.isEmpty) {
          return _EmptyTimelineState(
            onSetOperationDate: _pickOperationDate,
          );
        }

        final entries = _buildTimelineEntries(items);
        final doneCount = items.where((e) => e.state == TaskState.done).length;
        final bannerData = HeroBannerData(
          opTypeLabel: 'Knie-Arthroskopie',
          locationLabel: 'Stationär',
          dayLabel: 'Tag 18 nach OP',
          encouragementText: 'Weiterhin gute Genesung! 💪',
          dateLabel: '14.02.26',
          doneCount: doneCount,
          totalCount: items.length,
        );

        return CustomScrollView(
          physics: adaptiveScrollPhysics,
          slivers: [
            // ── App header ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  top: topPadding + AppSpacing.lg,
                ),
                child: _AppHeader(),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),

            // ── Hero banner ─────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: TimelineHeroBanner(
                  data: bannerData,
                  onTap: () => navigateToRoute(context, 'checklist'),
                  onActionsPressed: _openQuickActionsSheet,
                ),
              ),
            ),

            // ── Quick actions ─────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  top: AppSpacing.lg,
                ),
                child: _QuickActionsRow(
                  onMorePressed: _openQuickActionsSheet,
                ),
              ),
            ),

            // ── Smart Pro upsell card (only for free users, ≥3 active days) ──
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  top: AppSpacing.lg,
                ),
                child: SmartUpsellCard(),
              ),
            ),

            // ── Timeline upsell banner (≥3 opens in session) ─────────
            if (_showTimelineBanner)
              const SliverToBoxAdapter(
                child: TimelineUpsellBanner(),
              ),

            // ── Sticky "Timeline" + "+ Neu" header ──────────────
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyTimelineHeaderDelegate(
                onNewEntry: () => showNewEntrySheet(context),
              ),
            ),

            // ── Phase + day sections ───────────────────────────
            SliverPadding(
              padding: const EdgeInsets.only(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                top: AppSpacing.lg,
                bottom: 120,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final entry = entries[index];
                  if (entry.phase != null) {
                    final phase = entry.phase!;
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == entries.length - 1 ? 0 : AppSpacing.md,
                      ),
                      child: _PhaseHeader(
                        title: phase.title,
                        progressText:
                            '${phase.doneCount}/${phase.totalCount} erledigt',
                      ),
                    );
                  }

                  final section = entry.section!;
                  final si = entry.sectionIndex;
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == entries.length - 1 ? 0 : AppSpacing.lg,
                    ),
                    child: _DaySection(
                      section: section,
                      sectionIndex: si,
                      onDone: (ti) => _setTaskDone(section.tasks[ti].id),
                      onToggle: (ti) => _toggleTaskDone(
                        section.tasks[ti].id,
                        section.tasks[ti].state,
                      ),
                      onSkip: (ti) => _setTaskSkipped(section.tasks[ti].id),
                      onSnooze: (ti) => _snoozeTask(section.tasks[ti].id),
                      onNavigate: (ti) {
                        final key = section.tasks[ti].routeKey;
                        if (key != null && key.isNotEmpty) {
                          _openNamedRoute(key, taskId: section.tasks[ti].id);
                        }
                      },
                    ),
                  );
                }, childCount: entries.length),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── App header ───────────────────────────────────────────────────────────────

class _AppHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final pro = ProServices.maybeOf(context);

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: AppRadius.borderRadiusLg,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.monitor_heart_outlined,
              size: 24,
              color: AppColors.white,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        ShaderMask(
          shaderCallback: (bounds) =>
              AppColors.primaryGradient.createShader(bounds),
          child: Text(
            'Operationsbegleiter',
            style: tt.titleLarge?.copyWith(color: AppColors.white),
          ),
        ),
        const Spacer(),
        // ── Pro badge (small, subtle) ─────────────────────
        if (pro != null)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: ProBadge(
              entitlementService: pro.entitlementService,
              onTap: () {
                if (pro.entitlementService.isPro) {
                  Navigator.of(context).pushNamed('/pro-status');
                } else {
                  Navigator.of(context).pushNamed(
                    '/paywall',
                    arguments: const {'source': 'header_badge'},
                  );
                }
              },
            ),
          ),
        PressableScale(
          onTap: () {},
          scaleFactor: 0.90,
          child: GlassContainer(
            padding: const EdgeInsets.all(AppSpacing.sm + 2),
            borderRadius: AppRadius.borderRadiusMd,
            variant: GlassVariant.thin,
            elevation: GlassElevation.low,
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 22,
              color: AppColors.grey700,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Quick actions row ─────────────────────────────────────────────────────────

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({required this.onMorePressed});

  final VoidCallback onMorePressed;

  @override
  Widget build(BuildContext context) {
    final dockItems = primaryDockActions;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: adaptiveScrollPhysics,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          for (var i = 0; i < dockItems.length; i++) ...[
            _QuickActionChip(item: dockItems[i]),
            const SizedBox(width: AppSpacing.sm),
          ],
          _MoreActionChip(onTap: onMorePressed),
          const SizedBox(width: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({required this.item});

  final QuickActionItem item;

  static const _accentColors = <String, Color>{
    'wound': Color(0xFFFF6B6B),
    'pain': Color(0xFFD97706),
    'documents': Color(0xFF1D4ED8),
    'appointments': Color(0xFF059669),
    'voice': Color(0xFF7C3AED),
    'photos': Color(0xFF0A84FF),
  };

  @override
  Widget build(BuildContext context) {
    final accent = _accentColors[item.id] ?? AppColors.primary;
    return PressableScale(
      onTap: () => navigateToNamedRoute(context, item.routeName),
      scaleFactor: 0.94,
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        borderRadius: AppRadius.borderRadiusPill,
        variant: GlassVariant.thin,
        elevation: GlassElevation.low,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: accent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.35),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs + 2),
            Text(item.emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: AppSpacing.xs + 2),
            Text(
              item.title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreActionChip extends StatelessWidget {
  const _MoreActionChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      scaleFactor: 0.94,
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        borderRadius: AppRadius.borderRadiusPill,
        variant: GlassVariant.thin,
        elevation: GlassElevation.low,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('➕', style: TextStyle(fontSize: 14)),
            const SizedBox(width: AppSpacing.xs + 2),
            Text(
              'Mehr…',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sticky header delegate ───────────────────────────────────────────────────

class _StickyTimelineHeaderDelegate extends SliverPersistentHeaderDelegate {
  _StickyTimelineHeaderDelegate({required this.onNewEntry});

  final VoidCallback onNewEntry;

  static const double _contentHeight = 56.0;

  @override
  double get maxExtent => _contentHeight;

  @override
  double get minExtent => _contentHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return _StickyTimelineHeader(
      isPinned: overlapsContent || shrinkOffset > 0,
      height: _contentHeight,
      onNewEntry: onNewEntry,
    );
  }

  @override
  bool shouldRebuild(covariant _StickyTimelineHeaderDelegate old) => false;
}

class _StickyTimelineHeader extends StatelessWidget {
  const _StickyTimelineHeader({
    required this.isPinned,
    required this.height,
    required this.onNewEntry,
  });

  final bool isPinned;
  final double height;
  final VoidCallback onNewEntry;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    Widget content = ClipRect(
      child: BackdropFilter(
        filter: isPinned
            ? ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20)
            : ui.ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: isPinned
                ? AppColors.background.withValues(alpha: 0.82)
                : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: isPinned
                    ? AppColors.grey300.withValues(alpha: 0.45)
                    : Colors.transparent,
                width: 0.5,
              ),
            ),
          ),
          padding: const EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.sm,
            bottom: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Text('Timeline', style: tt.headlineLarge),
              const Spacer(),
              PressableScale(
                onTap: onNewEntry,
                scaleFactor: 0.93,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: AppRadius.borderRadiusPill,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.add_rounded,
                        size: 18,
                        color: AppColors.white,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Neu',
                        style: tt.titleSmall?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return content;
  }
}

// ── Day section ──────────────────────────────────────────────────────────────

class _PhaseHeader extends StatelessWidget {
  const _PhaseHeader({required this.title, required this.progressText});

  final String title;
  final String progressText;

  static String _phaseEmoji(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('vor')) return '✂️';
    if (lower.contains('op-tag') || lower.contains('optag')) return '🏥';
    if (lower.contains('woche 1') || lower.contains('week1')) return '🩹';
    if (lower.contains('woche 2') || lower.contains('week2')) return '💪';
    if (lower.contains('nachsorge') || lower.contains('follow')) return '✅';
    return '📋';
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.lg,
        bottom: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 22,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: AppRadius.borderRadiusPill,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            _phaseEmoji(title),
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              title,
              style: tt.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: timeline_theme.TimelineAppColors.textPrimary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: AppRadius.borderRadiusPill,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.15),
              ),
            ),
            child: Text(
              progressText,
              style: tt.labelSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DaySection extends StatelessWidget {
  const _DaySection({
    required this.section,
    required this.sectionIndex,
    required this.onDone,
    required this.onToggle,
    required this.onSkip,
    required this.onSnooze,
    required this.onNavigate,
  });

  final TimelineSection section;
  final int sectionIndex;
  final ValueChanged<int> onDone;
  final ValueChanged<int> onToggle;
  final ValueChanged<int> onSkip;
  final ValueChanged<int> onSnooze;
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final sectionTone = _statusColorsForState(section.sectionState);
    final isDueSection = section.sectionState == TaskState.due;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Day header with subtle phase wash ────────────────
        Container(
          padding: const EdgeInsets.only(
            left: AppSpacing.sm,
            right: AppSpacing.sm,
            top: AppSpacing.sm,
            bottom: AppSpacing.sm + 2,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [sectionTone.bg, Colors.transparent],
            ),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.md),
            ),
          ),
          child: Row(
            children: [
              if (isDueSection)
                Container(
                  width: 3,
                  height: 20,
                  margin: const EdgeInsets.only(right: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: sectionTone.fg,
                    borderRadius: AppRadius.borderRadiusPill,
                  ),
                ),
              _OffsetBadge(label: section.offsetLabel, tone: sectionTone),
              const SizedBox(width: AppSpacing.md),
              const Spacer(),
              Text(
                section.dateLabel,
                style: tt.labelMedium?.copyWith(
                  color: timeline_theme.TimelineAppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // ── Task card ────────────────────────────────────────
        _TaskCard(
          section: section,
          sectionIndex: sectionIndex,
          sectionTone: sectionTone,
          isDueSection: isDueSection,
          onDone: onDone,
          onToggle: onToggle,
          onSkip: onSkip,
          onSnooze: onSnooze,
          onNavigate: onNavigate,
        ),
      ],
    );
  }
}

// ── Offset badge pill ────────────────────────────────────────────────────────

class _OffsetBadge extends StatelessWidget {
  const _OffsetBadge({required this.label, required this.tone});

  final String label;
  final timeline_theme.TimelineStatusColors tone;

  @override
  Widget build(BuildContext context) {
    final isToday = label == 'Heute';
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md + 2,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        gradient: isToday
            ? AppColors.primaryGradient
            : null,
        color: isToday
            ? null
            : Color.alphaBlend(
                tone.bg.withValues(alpha: 0.9),
                timeline_theme.TimelineAppColors.surface,
              ),
        borderRadius: AppRadius.borderRadiusPill,
        border: isToday
            ? null
            : Border.all(color: tone.border, width: 0.8),
        boxShadow: isToday
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: isToday ? AppColors.white : tone.fg,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

// ── Task card (grouped, iOS-like) ────────────────────────────────────────────

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.section,
    required this.sectionIndex,
    required this.onDone,
    required this.onToggle,
    required this.onSkip,
    required this.onSnooze,
    required this.onNavigate,
    required this.sectionTone,
    required this.isDueSection,
  });

  final TimelineSection section;
  final int sectionIndex;
  final ValueChanged<int> onDone;
  final ValueChanged<int> onToggle;
  final ValueChanged<int> onSkip;
  final ValueChanged<int> onSnooze;
  final ValueChanged<int> onNavigate;
  final timeline_theme.TimelineStatusColors sectionTone;
  final bool isDueSection;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: isDueSection
            ? Border(left: BorderSide(color: sectionTone.fg, width: 2))
            : null,
        borderRadius: AppRadius.borderRadiusLg,
      ),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
        borderRadius: AppRadius.borderRadiusLg,
        variant: GlassVariant.thin,
        elevation: GlassElevation.low,
        color: isDueSection ? sectionTone.bg : null,
        child: Column(
          children: [
            for (var i = 0; i < section.tasks.length; i++) ...[
              FadeSlideIn(
                delay: Duration(milliseconds: 80 + sectionIndex * 40 + i * 35),
                slideOffset: 6,
                duration: const Duration(milliseconds: 280),
                child: _TaskTile(
                  task: section.tasks[i],
                  onDone: () => onDone(i),
                  onToggle: () => onToggle(i),
                  onSkip: () => onSkip(i),
                  onSnooze: () => onSnooze(i),
                  onNavigate: () => onNavigate(i),
                ),
              ),
              if (i < section.tasks.length - 1) _separator(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _separator() {
    return Padding(
      padding: const EdgeInsets.only(left: 72, right: AppSpacing.lg),
      child: Container(
        height: 0.33,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              timeline_theme.TimelineAppColors.surface2.withValues(alpha: 0.0),
              timeline_theme.TimelineAppColors.surface2.withValues(alpha: 0.8),
              timeline_theme.TimelineAppColors.surface2.withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Task tile ────────────────────────────────────────────────────────────────

class _TaskTile extends StatelessWidget {
  const _TaskTile({
    required this.task,
    required this.onDone,
    required this.onToggle,
    required this.onSkip,
    required this.onSnooze,
    required this.onNavigate,
  });

  final TimelineTask task;
  final VoidCallback onDone;
  final VoidCallback onToggle;
  final VoidCallback onSkip;
  final VoidCallback onSnooze;
  final VoidCallback onNavigate;

  @override
  Widget build(BuildContext context) {
    final isFinalized = task.isDone || task.isSkipped;
    final stateTone = _statusColorsForState(task.state);

    return PressableScale(
      onTap: onNavigate,
      scaleFactor: 0.988,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            // ── Status indicator ─────────────────────────
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onToggle,
              child: SizedBox(
                width: 44,
                height: 44,
                child: Center(child: _TaskStateIndicator(state: task.state)),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),

            // ── Emoji icon ───────────────────────────────
            AnimatedContainer(
              duration: MotionDuration.medium,
              curve: MotionCurve.standard,
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: stateTone.bg,
                borderRadius: AppRadius.borderRadiusSm,
                border: Border.all(color: stateTone.border, width: 0.5),
              ),
              child: Center(
                child: AnimatedOpacity(
                  duration: MotionDuration.medium,
                  opacity: isFinalized ? 0.5 : 1.0,
                  child: Text(task.emoji, style: const TextStyle(fontSize: 18)),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // ── Title + subtitle ─────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: MotionDuration.medium,
                    curve: MotionCurve.standard,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isFinalized
                          ? FontWeight.w500
                          : FontWeight.w600,
                      color: isFinalized
                          ? timeline_theme.TimelineAppColors.textSecondary
                          : timeline_theme.TimelineAppColors.textPrimary,
                      decoration: isFinalized
                          ? TextDecoration.lineThrough
                          : null,
                      decorationColor: timeline_theme
                          .TimelineAppColors
                          .textMuted
                          .withValues(alpha: 0.6),
                      decorationThickness: 1.0,
                    ),
                    child: Text(task.title),
                  ),
                  if (task.subtitle != null) ...[
                    const SizedBox(height: 3),
                    AnimatedDefaultTextStyle(
                      duration: MotionDuration.medium,
                      curve: MotionCurve.standard,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: isFinalized
                            ? timeline_theme.TimelineAppColors.textMuted
                            : timeline_theme.TimelineAppColors.textMuted,
                        height: 1.3,
                      ),
                      child: Text(
                        task.subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  if (task.milestone != null && task.milestone!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    _MilestoneChip(label: task.milestone!),
                  ],
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      _StateActionPill(
                        label: 'Done',
                        isPrimary: true,
                        tone: timeline_theme.TimelineAppColors.done,
                        onTap: onDone,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      _StateActionPill(
                        label: 'Skip',
                        tone: timeline_theme.TimelineAppColors.skipped,
                        onTap: onSkip,
                      ),
                      if (task.state == TaskState.due) ...[
                        const SizedBox(width: AppSpacing.xs),
                        _StateActionPill(
                          label: 'Snooze 30m',
                          tone: timeline_theme.TimelineAppColors.inProgress,
                          onTap: onSnooze,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),

            // ── Chevron ──────────────────────────────────
            AnimatedOpacity(
              duration: MotionDuration.medium,
              opacity: isFinalized ? 0.3 : 0.5,
              child: const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.grey500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskStateIndicator extends StatelessWidget {
  const _TaskStateIndicator({required this.state});

  final TaskState state;

  @override
  Widget build(BuildContext context) {
    final tone = _statusColorsForState(state);
    const size = 30.0;

    switch (state) {
      case TaskState.done:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF16A34A), Color(0xFF34D399)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF16A34A).withValues(alpha: 0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.check_rounded, size: 17, color: Colors.white),
        );
      case TaskState.skipped:
        return _filledIndicator(
          size: size,
          color: tone.fg,
          icon: Icons.remove_rounded,
        );
      case TaskState.due:
        return _PulsingDueIndicator(size: size, tone: tone);
      case TaskState.inProgress:
        return Stack(
          alignment: Alignment.center,
          children: [
            _ringIndicator(size: size, color: tone.fg, bg: tone.bg),
            Container(
              width: 12,
              height: 3,
              decoration: BoxDecoration(
                color: tone.fg,
                borderRadius: AppRadius.borderRadiusPill,
              ),
            ),
          ],
        );
      case TaskState.planned:
        return _ringIndicator(size: size, color: tone.fg, bg: tone.bg);
    }
  }

  Widget _ringIndicator({
    required double size,
    required Color color,
    required Color bg,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.45),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.85), width: 2),
      ),
    );
  }

  Widget _filledIndicator({
    required double size,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(icon, size: 17, color: Colors.white),
    );
  }
}

class _PulsingDueIndicator extends StatefulWidget {
  const _PulsingDueIndicator({required this.size, required this.tone});

  final double size;
  final timeline_theme.TimelineStatusColors tone;

  @override
  State<_PulsingDueIndicator> createState() => _PulsingDueIndicatorState();
}

class _PulsingDueIndicatorState extends State<_PulsingDueIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) {
        final scale = 1.0 + _ctrl.value * 0.12;
        final glowAlpha = 0.15 + _ctrl.value * 0.3;
        return Transform.scale(
          scale: scale,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: widget.tone.bg.withValues(alpha: 0.45),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.tone.fg.withValues(alpha: 0.85),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.tone.fg.withValues(alpha: glowAlpha),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: widget.tone.fg,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MilestoneChip extends StatelessWidget {
  const _MilestoneChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs + 1,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: AppRadius.borderRadiusPill,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.18),
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _StateActionPill extends StatelessWidget {
  const _StateActionPill({
    required this.label,
    required this.tone,
    required this.onTap,
    this.isPrimary = false,
  });

  final String label;
  final timeline_theme.TimelineStatusColors tone;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      scaleFactor: 0.94,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          gradient: isPrimary
              ? LinearGradient(
                  colors: [
                    tone.fg.withValues(alpha: 0.9),
                    tone.fg,
                  ],
                )
              : null,
          color: isPrimary ? null : tone.bg,
          borderRadius: AppRadius.borderRadiusPill,
          border: isPrimary
              ? null
              : Border.all(color: tone.border, width: 0.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isPrimary ? Colors.white : tone.fg,
          ),
        ),
      ),
    );
  }
}

// ── Empty state fallback ──────────────────────────────────────────────────────

class _EmptyTimelineState extends StatelessWidget {
  const _EmptyTimelineState({required this.onSetOperationDate});

  final VoidCallback onSetOperationDate;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: topPadding + AppSpacing.huge,
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: AppRadius.borderRadiusLg,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.22),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.timeline_rounded,
              size: 32,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            'Deine Timeline ist leer',
            style: tt.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Lege dein OP-Datum fest, um deinen\npersönlichen Care Plan zu starten.',
            style: tt.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxl),
          GlassButton(
            onPressed: onSetOperationDate,
            label: 'OP-Datum festlegen',
            icon: Icons.event_rounded,
          ),
        ],
      ),
    );
  }
}

class _LoadingTimelineState extends StatelessWidget {
  const _LoadingTimelineState();

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: topPadding + AppSpacing.huge,
      ),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xl),
          const CircularProgressIndicator(),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Timeline wird geladen…',
            style: tt.titleMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
