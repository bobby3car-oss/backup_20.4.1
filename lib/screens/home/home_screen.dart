import 'package:flutter/material.dart';

import '../../domain/task_orchestrator_sync.dart';
import '../../domain/timeline_engine.dart';
import '../../features/ads/presentation/ad_banner_widget.dart';
import '../../features/gamification/domain/daily_log.dart';
import '../../features/gamification/domain/gamification_state.dart';
import '../../features/gamification/domain/recovery_event.dart';
import '../../features/gamification/domain/xp_config.dart';
import '../../features/gamification/gamification_service.dart';
import '../../features/pro/presentation/smart_upsell_card.dart';
import '../../features/pro/presentation/timeline_upsell_banner.dart';
import '../../main.dart';
import '../../navigation/quick_actions_sheet.dart';
import '../../navigation/timeline_routes.dart';
import '../../ui/ui.dart';
import '../profile_settings_screen.dart';
import 'home_view_model.dart';
import 'widgets/home_header.dart';
import 'widgets/home_quick_actions.dart';
import 'widgets/timeline_phase_header.dart';
import 'widgets/timeline_section.dart';
import 'widgets/timeline_task_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TaskOrchestratorSync _orchestrator = TaskOrchestratorSync.instance;
  late final GamificationService _gamificationService;
  Stream<List<TimelineItem>>? _timelineStream;
  bool _showTimelineBanner = false;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _gamificationService = GamificationService();
    _bootstrap();
    _checkTimelineOpenTrigger();
  }

  /// Initialize the orchestrator first, THEN create the stream.
  /// This eliminates the race condition where the old code created
  /// the stream before data was loaded.
  Future<void> _bootstrap() async {
    try {
      await _orchestrator.initialize();
      debugPrint(
        '[HomeScreen] bootstrap done – '
        '${_orchestrator.operationDate != null ? "opDate=${_orchestrator.operationDate}" : "no opDate"}, '
        'initialized=${_orchestrator.isInitialized}',
      );
    } catch (e) {
      debugPrint('[HomeScreen] bootstrap failed: $e');
    }
    if (mounted) {
      setState(() {
        _isInitializing = false;
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
    final shouldShow = await pro.paywallTriggerService.onTimelineOpened();
    if (shouldShow && mounted) {
      setState(() => _showTimelineBanner = true);
    }
  }

  bool _isPro(BuildContext context) {
    final pro = ProServices.maybeOf(context);
    return pro?.entitlementService.isPro ?? false;
  }

  // ── Task actions ───────────────────────────────────────────────────────

  Future<void> _setTaskDone(String id) {
    return _orchestrator.setState(id, TaskState.done);
  }

  Future<void> _toggleTaskDone(String id, TaskState currentState) {
    final nextState =
        currentState == TaskState.done ? TaskState.planned : TaskState.done;
    return _orchestrator.setState(id, nextState);
  }

  Future<void> _setTaskSkipped(String id) {
    return _orchestrator.setState(id, TaskState.skipped);
  }

  Future<void> _snoozeTask(String id) {
    return _orchestrator.snoozeItem30Minutes(id);
  }

  // ── Navigation ─────────────────────────────────────────────────────────

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

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    if (_isInitializing || _timelineStream == null) {
      return _LoadingState(topPadding: topPadding);
    }

    return StreamBuilder<List<TimelineItem>>(
      stream: _timelineStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return _LoadingState(topPadding: topPadding);
        }

        final items = snapshot.data ?? const <TimelineItem>[];
        if (items.isEmpty) {
          return _EmptyState(
            topPadding: topPadding,
            onSetOperationDate: _openProfileSettings,
          );
        }

        final entries = buildTimelineEntries(items);
        final headerSummary = buildHeaderSummary(items);
        return _buildContent(
          context,
          items: items,
          entries: entries,
          headerSummary: headerSummary,
          topPadding: topPadding,
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context, {
    required List<TimelineItem> items,
    required List<TimelineFeedEntry> entries,
    required TimelineHeaderSummary headerSummary,
    required double topPadding,
  }) {
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
            child: const HomeHeader(),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),

        // ── Hero banner with streak ─────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: _buildHeroBanner(items, headerSummary),
          ),
        ),

        // ── Recovery Feed (today's events, Pro only) ────────
        SliverToBoxAdapter(child: _buildRecoveryFeed(context)),

        // ── Quick actions ─────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              top: AppSpacing.lg,
            ),
            child:
                HomeQuickActionsRow(onMorePressed: _openQuickActionsSheet),
          ),
        ),

        // ── Smart Pro upsell card ────────────────────────────
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

        // ── Timeline upsell banner ───────────────────────────
        if (_showTimelineBanner)
          const SliverToBoxAdapter(child: TimelineUpsellBanner()),

        // ── Sticky "Timeline" + "+ Neu" header ──────────────
        SliverPersistentHeader(
          pinned: true,
          delegate: StickyTimelineHeaderDelegate(
            summary: headerSummary,
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
              const adFrequency = 5;
              final adsBefore =
                  adFrequency > 0 ? (index + 1) ~/ (adFrequency + 1) : 0;
              final isAdSlot = adFrequency > 0 &&
                  index > 0 &&
                  (index + 1) % (adFrequency + 1) == 0;

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
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == entries.length - 1 ? 0 : AppSpacing.md,
                  ),
                  child: TimelinePhaseHeader(data: entry.phase!),
                );
              }

              final section = entry.section!;
              final si = entry.sectionIndex;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == entries.length - 1 ? 0 : AppSpacing.lg,
                ),
                child: TimelineDaySection(
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
            }, childCount: entries.length + (entries.length ~/ 5)),
          ),
        ),
      ],
    );
  }

  // ── Hero banner ────────────────────────────────────────────────────────

  Widget _buildHeroBanner(
    List<TimelineItem> items,
    TimelineHeaderSummary headerSummary,
  ) {
    return StreamBuilder<GamificationState>(
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

            final doneCount =
                items.where((e) => e.state == TaskState.done).length;

            final bannerData = HeroBannerData(
              dayLabel: headerSummary.focusLabel,
              encouragementText:
                  '${headerSummary.progressPercent}% geschafft – weiter so! 💪',
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
              onTap: () => Navigator.of(context).pushNamed('/progress'),
              onActionsPressed: _openQuickActionsSheet,
            );
          },
        );
      },
    );
  }

  // ── Recovery feed ──────────────────────────────────────────────────────

  Widget _buildRecoveryFeed(BuildContext context) {
    if (!_isPro(context)) return const SizedBox.shrink();

    return StreamBuilder<List<RecoveryEvent>>(
      stream: _gamificationService.watchTodayEvents(),
      builder: (context, feedSnap) {
        final events = feedSnap.data ?? const [];
        if (events.isEmpty) return const SizedBox.shrink();
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
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
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
    );
  }
}

// ── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.topPadding, required this.onSetOperationDate});

  final double topPadding;
  final VoidCallback onSetOperationDate;

  @override
  Widget build(BuildContext context) {
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

// ── Loading state ────────────────────────────────────────────────────────────

class _LoadingState extends StatelessWidget {
  const _LoadingState({required this.topPadding});

  final double topPadding;

  @override
  Widget build(BuildContext context) {
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
