import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../domain/task_orchestrator_sync.dart';
import '../../domain/timeline_engine.dart';
import '../../features/ads/presentation/ad_banner_widget.dart';
import '../../features/gamification/domain/gamification_state.dart';
import '../../features/gamification/domain/recovery_event.dart';
import '../../features/gamification/gamification_service.dart';
import '../../features/pro/presentation/smart_upsell_card.dart';
import '../../features/pro/presentation/timeline_upsell_banner.dart';
import '../../firebase/firebase_paths.dart';
import '../../main.dart';
import '../../navigation/quick_actions_sheet.dart';
import '../../navigation/timeline_routes.dart';
import '../../ui/ui.dart';
import '../profile_settings_screen.dart';
import 'home_view_model.dart';
import 'widgets/home_header.dart';
import 'widgets/home_quick_actions.dart';
import 'widgets/timeline_phase_header.dart';
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

  String? _opType;
  String? _opModus;

  final ScrollController _scrollController = ScrollController();
  bool _showStickyHeader = false;
  static const double _stickyScrollThreshold = 300.0;

  @override
  void initState() {
    super.initState();
    _gamificationService = GamificationService();
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
    // Load OP info from Firestore
    await _loadOpInfo();
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

  Future<void> _loadOpInfo() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final firestore = FirebaseFirestore.instance;
      final doc = await firestore.doc(FirestorePaths.patientDoc(uid)).get();
      final data = doc.data();
      if (data != null && mounted) {
        setState(() {
          _opType = data['opType'] as String?;
          _opModus = data['opModus'] as String?;
        });
      }
    } catch (e) {
      debugPrint('[HomeScreen] loadOpInfo failed: $e');
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

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
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

        final entries = buildTimelineEntries(
          items,
          operationDate: _orchestrator.operationDate,
        );
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

        // ── Timeline section header ──────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              top: AppSpacing.xxl,
              bottom: AppSpacing.sm,
            ),
            child: Row(
              children: [
                const Text('📋', style: TextStyle(fontSize: 20)),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Timeline',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                ),
                const Spacer(),
                PressableScale(
                  onTap: () {
                    Haptic.light();
                    showNewEntrySheet(context);
                  },
                  scaleFactor: 0.95,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: AppRadius.borderRadiusPill,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      '+ Neu',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
      ],
    );
  }

  // ── Hero banner ────────────────────────────────────────────────────────

  String _dayLabelFromOpDate() {
    final opDate = _orchestrator.operationDate;
    if (opDate == null) return 'Deine Timeline';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final op = DateTime(opDate.year, opDate.month, opDate.day);
    final diff = today.difference(op).inDays;
    if (diff == 0) return 'OP-Tag';
    if (diff > 0) return 'Tag $diff nach OP';
    return 'Tag ${diff.abs()} vor OP';
  }

  String? _opDateFormatted() {
    final opDate = _orchestrator.operationDate;
    if (opDate == null) return null;
    final dd = opDate.day.toString().padLeft(2, '0');
    final mm = opDate.month.toString().padLeft(2, '0');
    final yy = (opDate.year % 100).toString().padLeft(2, '0');
    return '$dd.$mm.$yy';
  }

  String _encouragementFromOpDate() {
    final opDate = _orchestrator.operationDate;
    if (opDate == null) return 'Alles Gute! 💪';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final op = DateTime(opDate.year, opDate.month, opDate.day);
    final diff = today.difference(op).inDays;
    if (diff < 0) return 'Gute Vorbereitung ist alles! 📋';
    if (diff == 0) return 'Heute ist der Tag – du schaffst das! 💪';
    if (diff <= 3) return 'Schone dich und erhol dich gut! 🛌';
    if (diff <= 14) return 'Weiterhin gute Genesung! 💪';
    return 'Du bist auf einem guten Weg! 🎉';
  }

  Widget _buildHeroBanner(
    List<TimelineItem> items,
    TimelineHeaderSummary headerSummary,
  ) {
    final doneCount =
        items.where((e) => e.state == TaskState.done).length;

    final bannerData = HeroBannerData(
      dayLabel: _dayLabelFromOpDate(),
      encouragementText: _encouragementFromOpDate(),
      doneCount: doneCount,
      totalCount: items.length,
      opType: _opType,
      opModus: _opModus,
      opDateFormatted: _opDateFormatted(),
    );

    return TimelineHeroBanner(
      data: bannerData,
      onTap: () => Navigator.of(context).pushNamed('/progress'),
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

// ── Floating compact timeline bar (shown on scroll) ──────────────────────────

class _FloatingTimelineBar extends StatelessWidget {
  const _FloatingTimelineBar({
    required this.summary,
    required this.gamificationService,
    required this.onNewEntry,
  });

  final TimelineHeaderSummary summary;
  final GamificationService gamificationService;
  final VoidCallback onNewEntry;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

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
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          child: StreamBuilder<GamificationState>(
            stream: gamificationService.watchState(),
            builder: (context, gamSnap) {
              final gam = gamSnap.data ?? const GamificationState();
              return Row(
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
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(
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
                  // Info
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
                            if (gam.currentStreak > 0) ...[
                              Text(
                                '🔥 ${gam.currentStreak} Tage',
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
                  // Add button
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
              );
            },
          ),
        ),
      ),
    );
  }
}
