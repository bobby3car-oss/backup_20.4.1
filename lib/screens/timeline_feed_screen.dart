import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';

import '../domain/task_orchestrator_sync.dart';
import '../domain/task_orchestrator.dart' show phaseTitle, phaseOrder;
import '../domain/timeline_engine.dart';
import '../features/ads/data/ad_config.dart';
import '../features/ads/presentation/ad_banner_widget.dart';
import '../features/ads/presentation/ad_slot_helper.dart';
import '../features/gamification/domain/daily_log.dart';
import '../features/gamification/domain/gamification_state.dart';
import '../features/gamification/domain/recovery_event.dart';
import '../features/gamification/domain/xp_config.dart';
import '../features/gamification/gamification_service.dart';
import '../features/pro/presentation/floating_pro_badge.dart';
import '../features/pro/presentation/pro_badge.dart';
import '../main.dart';
import '../navigation/quick_actions_config.dart';
import '../navigation/quick_actions_sheet.dart';
import '../navigation/timeline_routes.dart';
import '../theme/app_colors.dart' as timeline_theme;
import '../ui/ui.dart';
import 'profile_settings_screen.dart';
import 'package:operationsbegleiter_v3/ui/theme/app_icons.dart';

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
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.milestone,
    this.routeKey,
    required this.state,
    required this.type,
  });

  final String id;
  final IconData icon;

  final Color iconColor;
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
    this.isOpDay = false,
  });

  final String offsetLabel;
  final String dateLabel;
  final TaskState sectionState;
  final bool isOpDay;
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

class _TimelineHeaderSummary {
  const _TimelineHeaderSummary({
    required this.totalCount,
    required this.doneCount,
    required this.openCount,
    required this.todayCount,
    required this.dueCount,
    required this.focusLabel,
  });

  final int totalCount;
  final int doneCount;
  final int openCount;
  final int todayCount;
  final int dueCount;
  final String focusLabel;

  double get progress => totalCount == 0 ? 0 : doneCount / totalCount;
  int get progressPercent => (progress * 100).round();
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
  late final GamificationService _gamificationService;
  late Stream<List<TimelineItem>> _timelineStream;
  bool _isInitializing = true;

  final ScrollController _scrollController = ScrollController();
  bool _showStickyHeader = false;
  static const double _stickyScrollThreshold = 280.0;

  @override
  void initState() {
    super.initState();
    _gamificationService = GamificationService();
    _timelineStream = _orchestrator.watch(
      from: DateTime.now().subtract(const Duration(days: 365)),
      to: DateTime.now().add(const Duration(days: 365)),
    );
    _scrollController.addListener(_onScroll);
    _bootstrap();
    _checkTimelineOpenTrigger();
  }

  void _onScroll() {
    final show = _scrollController.offset > _stickyScrollThreshold;
    if (show != _showStickyHeader) {
      setState(() => _showStickyHeader = show);
    }
  }

  bool _isPro(BuildContext context) {
    final pro = ProServices.maybeOf(context);
    return pro?.entitlementService.isPro ?? false;
  }

  Future<void> _bootstrap() async {
    try {
      await _orchestrator.initialize();
    } catch (e) {
      debugPrint('[TimelineFeedScreen] bootstrap failed: $e');
    }
    if (mounted) {
      setState(() {
        _isInitializing = false;
        // Create a fresh stream so the StreamBuilder picks up items
        // generated during initialize() or during the onboarding
        // questionnaire (setOperationDate).
        _timelineStream = _orchestrator.watch(
          from: DateTime.now().subtract(const Duration(days: 365)),
          to: DateTime.now().add(const Duration(days: 365)),
        );
      });
    }
  }

  Future<void> _checkTimelineOpenTrigger() async {
    final pro = ProServices.maybeOf(context);
    if (pro == null) return;
    await pro.paywallTriggerService.onTimelineOpened();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
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

  Future<void> _openProfileSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ProfileSettingsScreen(),
      ),
    );
    // Refresh stream when returning – picks up items generated during save.
    if (mounted) {
      setState(() {
        _timelineStream = _orchestrator.watch(
          from: DateTime.now().subtract(const Duration(days: 365)),
          to: DateTime.now().add(const Duration(days: 365)),
        );
      });
    }
  }

  Future<void> _openNamedRoute(String routeName, {String? taskId}) async {
    try {
      final arguments =
          routeName == '/wound-editor' && taskId != null && taskId.isNotEmpty
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

  (IconData, Color) _iconForType(TaskType type) {
    switch (type) {
      case TaskType.wound:
        return (AppIcons.photos, AppIcons.photosColor);
      case TaskType.meds:
        return (AppIcons.medication, AppIcons.medicationColor);
      case TaskType.checklist:
        return (AppIcons.done, AppIcons.doneColor);
      case TaskType.appointment:
        return (AppIcons.appointments, AppIcons.appointmentsColor);
      case TaskType.message:
        return (AppIcons.messages, AppIcons.messagesColor);
      case TaskType.custom:
        return (AppIcons.notes, AppIcons.notesColor);
      case TaskType.note:
        return (Icons.sticky_note_2_rounded, AppIcons.messagesColor);
      case TaskType.nutrition:
        return (AppIcons.nutrition, AppIcons.nutritionColor);
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
      final phase = (normalized.metadata['phase'] as String?) ??
          inferPhase(
            normalized.scheduledAt.toLocal(),
            _orchestrator.operationDate,
          );
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
      bool isOpDay = false,
    }) {
      return TimelineSection(
        offsetLabel: dayLabel,
        dateLabel: dateLabel,
        sectionState: sectionState,
        isOpDay: isOpDay,
        tasks: source
            .map(
              (item) {
                final (icon, iconColor) = _iconForType(item.type);
                return TimelineTask(
                id: item.id,
                icon: icon,
                iconColor: iconColor,
                title: item.title,
                subtitle: item.subtitle,
                milestone: item.metadata['milestone'] as String?,
                routeKey: item.deeplinkRoute,
                state: item.state,
                type: item.type,
              );
              },
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
              isOpDay: phase == 'opday',
            ),
            sectionIndex++,
          ),
        );
      }
    }
    return entries;
  }

  _TimelineHeaderSummary _buildHeaderSummary(List<TimelineItem> items) {
    final now = DateTime.now();
    final todayDate = _dateOnly(now);
    var doneCount = 0;
    var skippedCount = 0;
    var todayCount = 0;
    var dueCount = 0;
    TimelineItem? nextRelevant;

    for (final item in items) {
      final computed = computeState(item, now);
      final scheduledAt = item.scheduledAt.toLocal();

      if (_isSameDay(scheduledAt, todayDate)) {
        todayCount++;
      }

      switch (computed) {
        case TaskState.done:
          doneCount++;
          break;
        case TaskState.skipped:
          skippedCount++;
          break;
        case TaskState.due:
        case TaskState.inProgress:
          dueCount++;
          break;
        case TaskState.planned:
          break;
      }

      final isRelevant =
          computed != TaskState.done && computed != TaskState.skipped;
      if (!isRelevant) continue;

      if (nextRelevant == null ||
          scheduledAt.isBefore(nextRelevant.scheduledAt)) {
        nextRelevant = item;
      }
    }

    final openCount = (items.length - doneCount - skippedCount).clamp(
      0,
      items.length,
    );
    final focusLabel = switch ((dueCount, todayCount, nextRelevant)) {
      (> 0, _, _) => '$dueCount brauchen heute Aufmerksamkeit',
      (0, > 0, _) => '$todayCount Aufgaben fuer heute eingeplant',
      (0, 0, TimelineItem item) => 'Als Naechstes: ${item.title}',
      _ => 'Dein Plan ist aktuell komplett erledigt',
    };

    return _TimelineHeaderSummary(
      totalCount: items.length,
      doneCount: doneCount,
      openCount: openCount,
      todayCount: todayCount,
      dueCount: dueCount,
      focusLabel: focusLabel,
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return StreamBuilder<List<TimelineItem>>(
      stream: _timelineStream,
      builder: (context, snapshot) {
        if (kDebugMode) {
          debugPrint(
            '[TimelineFeedScreen] StreamBuilder – '
            'conn=${snapshot.connectionState}, '
            'hasData=${snapshot.hasData}, '
            'itemCount=${snapshot.data?.length ?? 0}',
          );
        }
        if ((snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) ||
            _isInitializing) {
          return const _LoadingTimelineState();
        }

        final items = snapshot.data ?? const <TimelineItem>[];
        if (items.isEmpty) {
          return _EmptyTimelineState(onSetOperationDate: _openProfileSettings);
        }

        final entries = _buildTimelineEntries(items);
        final headerSummary = _buildHeaderSummary(items);
        final bottomPad = MediaQuery.of(context).padding.bottom;
        return Stack(
          children: [
            CustomScrollView(
          controller: _scrollController,
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

            // ── Hero banner with streak ─────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: StreamBuilder<GamificationState>(
                  stream: _gamificationService.watchState(),
                  builder: (context, gamSnap) {
                    final gamState = gamSnap.data ?? const GamificationState();
                    final isPro = _isPro(context);
                    return StreamBuilder<List<DailyLog>>(
                      stream: _gamificationService.watchRecentLogs(days: 7),
                      builder: (context, logSnap) {
                        final logs = logSnap.data ?? const [];
                        final logDates = {for (final l in logs) l.date};
                        final now = DateTime.now();
                        final recentDays = List.generate(7, (i) {
                          final day = now.subtract(Duration(days: 6 - i));
                          final key =
                              '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
                          return logDates.contains(key);
                        });

                        final doneCount = items
                            .where((e) => e.state == TaskState.done)
                            .length;

                        final bannerData = HeroBannerData(
                          dayLabel: headerSummary.focusLabel,
                          encouragementText:
                              '${headerSummary.progressPercent}% geschafft – weiter so!',
                          doneCount: doneCount,
                          totalCount: items.length,
                          currentStreak: gamState.currentStreak,
                          todayXp: gamState.todayXp,
                          level: gamState.level,
                          levelProgress: gamState.levelProgress,
                          streakMultiplier:
                              XpConfig.streakMultiplier(gamState.currentStreak),
                          recentDaysActive: recentDays,
                          isPro: isPro,
                        );

                        return TimelineHeroBanner(
                          data: bannerData,
                          onTap: () =>
                              Navigator.of(context).pushNamed('/progress'),
                          onActionsPressed: _openQuickActionsSheet,
                        );
                      },
                    );
                  },
                ),
              ),
            ),

            // ── Recovery Feed (today's events, Pro only) ────────
            SliverToBoxAdapter(
              child: _isPro(context)
                  ? StreamBuilder<List<RecoveryEvent>>(
                      stream: _gamificationService.watchTodayEvents(),
                      builder: (context, feedSnap) {
                        final events = feedSnap.data ?? const [];
                        if (events.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        // Show max 5 recent events
                        final visible = events.take(5).toList();
                        return Padding(
                          padding: const EdgeInsets.only(
                            left: AppSpacing.lg,
                            right: AppSpacing.lg,
                            top: AppSpacing.md,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: AppSpacing.xs,
                                  bottom: AppSpacing.sm,
                                ),
                                child: Text(
                                  'Heute',
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                              ),
                              for (final event in visible) ...[
                                RecoveryFeedCard(event: event),
                                const SizedBox(height: AppSpacing.xs),
                              ],
                            ],
                          ),
                        );
                      },
                    )
                  : const SizedBox.shrink(),
            ),

            // ── Quick actions ─────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  top: AppSpacing.lg,
                ),
                child: _QuickActionsRow(onMorePressed: _openQuickActionsSheet),
              ),
            ),

            // ── Phase + day sections ───────────────────────────
            ValueListenableBuilder<AdConfig>(
              valueListenable: AdServiceScope.of(context).config,
              builder: (context, adConfig, _) {
                final adFrequency = normalizeAdFrequency(adConfig.adFrequency);
                return SliverPadding(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.lg,
                    right: AppSpacing.lg,
                    top: AppSpacing.lg,
                    bottom: 120,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final adsBefore = adsBeforeIndex(index, adFrequency);
                      final isAdSlot = isAdSlotIndex(index, adFrequency);

                      if (isAdSlot) {
                        return const Padding(
                          padding: EdgeInsets.only(bottom: AppSpacing.md),
                          child: AdBannerWidget(),
                        );
                      }

                      final realIndex = index - adsBefore;
                      if (realIndex < 0 || realIndex >= entries.length) {
                        return const SizedBox.shrink();
                      }
                      final entry = entries[realIndex];
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
                    }, childCount: itemCountWithAds(entries.length, adFrequency)),
                  ),
                );
              },
            ),
          ],
        ),
            // ── Floating sticky timeline bar ───────────────
            Positioned(
              top: topPadding + AppSpacing.sm,
              left: AppSpacing.md,
              right: AppSpacing.md,
              child: IgnorePointer(
                ignoring: !_showStickyHeader,
                child: AnimatedOpacity(
                  opacity: _showStickyHeader ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  child: AnimatedSlide(
                    offset: Offset(0, _showStickyHeader ? 0.0 : -0.5),
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    child: _FloatingTimelineBar(
                      summary: headerSummary,
                      gamificationService: _gamificationService,
                      onNewEntry: () => showNewEntrySheet(context),
                    ),
                  ),
                ),
              ),
            ),
            // ── Floating Pro badge ────────────────────────
            Positioned(
              bottom: bottomPad + 24,
              right: AppSpacing.lg,
              child: const FloatingProBadge(),
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
    'rehab': Color(0xFF34C759),
    'doctor-report': Color(0xFF00C7BE),
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
            GlassIcon(icon: item.icon, color: item.iconColor, size: 14),
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
            if (item.isProFeature) ...[
              const SizedBox(width: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.14),
                  borderRadius: AppRadius.borderRadiusPill,
                ),
                child: const Text(
                  'PRO',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: AppColors.warning,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
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
            GlassIcon(icon: CupertinoIcons.plus, color: AppColors.primary, size: 14),
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

// ── Floating compact timeline bar (shown on scroll) ──────────────────────────

class _FloatingTimelineBar extends StatelessWidget {
  const _FloatingTimelineBar({
    required this.summary,
    required this.gamificationService,
    required this.onNewEntry,
  });

  final _TimelineHeaderSummary summary;
  final GamificationService gamificationService;
  final VoidCallback onNewEntry;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.grey200.withValues(alpha: 0.5),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.grey900.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm + 2,
            ),
            child: StreamBuilder<GamificationState>(
              stream: gamificationService.watchState(),
              builder: (context, gamSnap) {
                final gam = gamSnap.data ?? const GamificationState();
                return _FloatingBarContent(
                  summary: summary,
                  streak: gam.currentStreak,
                  onNewEntry: onNewEntry,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _FloatingBarContent extends StatelessWidget {
  const _FloatingBarContent({
    required this.summary,
    required this.streak,
    required this.onNewEntry,
  });

  final _TimelineHeaderSummary summary;
  final int streak;
  final VoidCallback onNewEntry;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Row 1: progress + streak + button ──
        Row(
          children: [
            // Progress ring
            SizedBox(
              width: 36,
              height: 36,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(
                      value: summary.progress,
                      strokeWidth: 3.5,
                      backgroundColor:
                          AppColors.primary.withValues(alpha: 0.12),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Text(
                    '${summary.progressPercent}',
                    style: tt.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm + 2),
            // Title + subtitle
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${summary.doneCount} von ${summary.totalCount} erledigt',
                    style: tt.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Row(
                    children: [
                      if (streak > 0) ...[
                        Text(
                          '$streak Tage',
                          style: tt.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFFF9500),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs + 1,
                          ),
                          child: Text(
                            '·',
                            style: tt.labelSmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                      if (summary.todayCount > 0)
                        Text(
                          '${summary.todayCount} heute',
                          style: tt.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      if (summary.dueCount > 0) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs + 1,
                          ),
                          child: Text(
                            '·',
                            style: tt.labelSmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Text(
                          '${summary.dueCount} fällig',
                          style: tt.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            // Add button – compact pill
            PressableScale(
              onTap: () {
                Haptic.light();
                onNewEntry();
              },
              scaleFactor: 0.95,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: AppRadius.borderRadiusPill,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.add_rounded,
                      size: 16,
                      color: AppColors.white,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Neu',
                      style: tt.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Day section ──────────────────────────────────────────────────────────────

class _PhaseHeader extends StatelessWidget {
  const _PhaseHeader({required this.title, required this.progressText});

  final String title;
  final String progressText;

  static (IconData, Color) _phaseIcon(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('vor')) return (CupertinoIcons.scissors, AppColors.primary);
    if (lower.contains('op-tag') || lower.contains('optag')) return (AppIcons.hospital, AppIcons.hospitalColor);
    if (lower.contains('woche 1') || lower.contains('week1')) return (AppIcons.wound, AppIcons.woundColor);
    if (lower.contains('woche 2') || lower.contains('week2')) return (AppIcons.progress, AppIcons.progressColor);
    if (lower.contains('nachsorge') || lower.contains('follow')) return (AppIcons.done, AppIcons.doneColor);
    return (AppIcons.clipboard, AppIcons.clipboardColor);
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl, bottom: AppSpacing.xs),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              AppColors.primary.withValues(alpha: 0.10),
              AppColors.primary.withValues(alpha: 0.03),
            ],
          ),
          borderRadius: AppRadius.borderRadiusLg,
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.15),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(9),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.28),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: () {
                  final (icon, color) = _phaseIcon(title);
                  return Icon(icon, color: Colors.white, size: 15);
                }(),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                title,
                style: tt.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm + 2,
                vertical: AppSpacing.xxs + 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: AppRadius.borderRadiusPill,
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

  static const _opDayBorderColor = Color(0xFFDC2626);

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final isOpDay = section.isOpDay;
    final sectionTone = isOpDay
        ? timeline_theme.TimelineAppColors.due
        : _statusColorsForState(section.sectionState);
    final isDueSection = section.sectionState == TaskState.due || isOpDay;

    Widget content = Column(
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

    if (isOpDay) {
      content = Container(
        decoration: BoxDecoration(
          border: Border.all(color: _opDayBorderColor, width: 2),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg - 1),
          child: content,
        ),
      );
    }

    return content;
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
        gradient: isToday ? AppColors.primaryGradient : null,
        color: isToday
            ? null
            : Color.alphaBlend(
                tone.bg.withValues(alpha: 1.0),
                timeline_theme.TimelineAppColors.surface,
              ),
        borderRadius: AppRadius.borderRadiusPill,
        border: isToday ? null : Border.all(color: tone.border, width: 0.8),
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
    Widget card = GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      borderRadius: AppRadius.borderRadiusLg,
      variant: GlassVariant.medium,
      elevation: GlassElevation.medium,
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
    );

    card = IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 3,
            decoration: BoxDecoration(
              color: sectionTone.fg.withValues(
                alpha: isDueSection ? 1.0 : 0.45,
              ),
              borderRadius: AppRadius.borderRadiusPill,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(child: card),
        ],
      ),
    );

    return card;
  }

  Widget _separator() {
    return Padding(
      padding: const EdgeInsets.only(left: 72, right: AppSpacing.lg),
      child: Container(
        height: 0.5,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              timeline_theme.TimelineAppColors.surface2.withValues(alpha: 0.0),
              timeline_theme.TimelineAppColors.surface2.withValues(alpha: 0.55),
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
          vertical: AppSpacing.sm,
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
                border: Border.all(color: stateTone.border, width: 1.0),
              ),
              child: Center(
                child: AnimatedOpacity(
                  duration: MotionDuration.medium,
                  opacity: isFinalized ? 0.5 : 1.0,
                  child: GlassIcon(icon: task.icon, color: task.iconColor, size: 18),
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
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      _StateActionPill(
                        label: 'Done',
                        isPrimary: true,
                        tone: timeline_theme.TimelineAppColors.done,
                        onTap: onDone,
                      ),
                      _StateActionPill(
                        label: 'Skip',
                        tone: timeline_theme.TimelineAppColors.skipped,
                        onTap: onSkip,
                      ),
                      if (task.state == TaskState.due)
                        _StateActionPill(
                          label: 'Snooze 30m',
                          tone: timeline_theme.TimelineAppColors.inProgress,
                          onTap: onSnooze,
                        ),
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
        color: bg.withValues(alpha: 0.6),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 1.0), width: 2.5),
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
        final scale = 1.0 + _ctrl.value * 0.14;
        final glowAlpha = 0.25 + _ctrl.value * 0.35;
        return Transform.scale(
          scale: scale,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: widget.tone.bg.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.tone.fg.withValues(alpha: 1.0),
                    width: 2.5,
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: isPrimary
              ? LinearGradient(
                  colors: [tone.fg.withValues(alpha: 0.9), tone.fg],
                )
              : null,
          color: isPrimary ? null : tone.bg,
          borderRadius: AppRadius.borderRadiusPill,
          border: isPrimary ? null : Border.all(color: tone.border, width: 0.5),
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
            'Dein Care Plan wird generiert, sobald du\ndein OP-Datum in den Profil-Einstellungen hinterlegst.',
            style: tt.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxl),
          GlassButton(
            onPressed: onSetOperationDate,
            label: 'Zu den Einstellungen',
            icon: Icons.settings_rounded,
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
