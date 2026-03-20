import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../domain/task_orchestrator_sync.dart';
import '../../domain/timeline_engine.dart';
import '../../navigation/timeline_routes.dart';
import '../../ui/ui.dart';
import '../profile_settings_screen.dart';
import 'home_view_model.dart';
import 'widgets/heute_focus_card.dart';
import 'widgets/home_day_strip.dart';
import 'widgets/home_header.dart';
import 'widgets/today_appointments_card.dart';
import 'widgets/today_tasks_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TaskOrchestratorSync _orchestrator = TaskOrchestratorSync.instance;
  Stream<List<TimelineItem>>? _timelineStream;
  bool _isInitializing = true;

  // Sticky header state
  final ScrollController _scrollController = ScrollController();
  bool _showStickyHeader = false;
  static const double _stickyScrollThreshold = 200.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _bootstrap();
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

  // ── Task actions ───────────────────────────────────────────────────────

  Future<void> _toggleTaskDone(String id, TaskState currentState) {
    final nextState =
        currentState == TaskState.done ? TaskState.planned : TaskState.done;
    return _orchestrator.setState(id, nextState);
  }

  // ── Navigation ─────────────────────────────────────────────────────────

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
    if (routeName.isEmpty) return;
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
          content: Text('Diese Seite konnte nicht geöffnet werden.'),
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

        return _buildHeuteContent(context, items: items, topPadding: topPadding);
      },
    );
  }

  Widget _buildHeuteContent(
    BuildContext context, {
    required List<TimelineItem> items,
    required double topPadding,
  }) {
    final focus = extractTodayFocus(items);
    final todayTasks = extractTodayTasks(items);
    final todayAppointments = extractTodayAppointments(items);
    final nearbySections = extractNearbySections(items);
    final summary = buildHeaderSummary(items);

    return Stack(
      children: [
        ListView(
      controller: _scrollController,
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: topPadding + AppSpacing.lg,
        bottom: 120,
      ),
      physics: adaptiveScrollPhysics,
      children: [
        // ── Compact header: greeting + date + badges ────────
        HomeHeader(
          greeting: _greetingText(),
          firstName: _firstName(),
        ),
        const SizedBox(height: AppSpacing.xl),

        // ── Recovery context (day label + progress) ─────────
        _RecoveryContextRow(
          dayLabel: _dayLabelFromOpDate(),
          encouragement: _encouragementFromOpDate(),
          progress: summary.progress,
          hasOpDate: _orchestrator.operationDate != null,
        ),
        const SizedBox(height: AppSpacing.lg),

        // ── Focus card (next step) ──────────────────────────
        HeuteFocusCard(
          focus: focus,
          dayLabel: _dayLabelFromOpDate(),
          encouragement: _encouragementFromOpDate(),
          onAction: () {
            if (focus.routeKey != null && focus.routeKey!.isNotEmpty) {
              _openNamedRoute(focus.routeKey!, taskId: focus.taskId);
            }
          },
          onTap: () {
            if (focus.routeKey != null && focus.routeKey!.isNotEmpty) {
              _openNamedRoute(focus.routeKey!, taskId: focus.taskId);
            }
          },
        ),
        const SizedBox(height: AppSpacing.lg),

        // ── Today's tasks ────────────────────────────────────
        TodayTasksCard(
          tasks: todayTasks,
          onToggle: (id, state) => _toggleTaskDone(id, state),
          onNavigate: (routeKey, id) {
            if (routeKey != null && routeKey.isNotEmpty) {
              _openNamedRoute(routeKey, taskId: id);
            }
          },
          onShowAll: () => Navigator.of(context).pushNamed('/timeline'),
        ),
        const SizedBox(height: AppSpacing.lg),

        // ── Today's appointments ─────────────────────────────
        TodayAppointmentsCard(
          appointments: todayAppointments,
          onNavigate: (routeKey, id) {
            if (routeKey != null && routeKey.isNotEmpty) {
              _openNamedRoute(routeKey, taskId: id);
            }
          },
        ),
        const SizedBox(height: AppSpacing.lg),

        // ── Week overview (horizontal day strip) ─────────────
        HomeDayStrip(
          sections: nearbySections,
          todayDoneCount: todayTasks.where((t) => t.isDone).length,
          todayTotalCount: todayTasks.length,
          onTap: () => Navigator.of(context).pushNamed('/timeline'),
        ),
        const SizedBox(height: AppSpacing.xl),

        // ── Quick add ────────────────────────────────────────
        Center(
          child: PressableScale(
            onTap: () {
              Haptic.light();
              showNewEntrySheet(context);
            },
            scaleFactor: 0.95,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: AppRadius.borderRadiusPill,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, size: 18, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    'Neuen Eintrag hinzufügen',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),

        // ── Floating sticky home bar ─────────────────────────
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
                child: _FloatingHomeBar(
                  dayLabel: _dayLabelFromOpDate(),
                  summary: summary,
                  onNewEntry: () => showNewEntrySheet(context),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  String _dayLabelFromOpDate() {
    final opDate = _orchestrator.operationDate;
    if (opDate == null) return 'Heute';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final op = DateTime(opDate.year, opDate.month, opDate.day);
    final diff = today.difference(op).inDays;
    if (diff == 0) return 'OP-Tag';
    if (diff > 0) return 'Tag $diff nach OP';
    return 'Tag ${diff.abs()} vor OP';
  }

  String _encouragementFromOpDate() {
    final opDate = _orchestrator.operationDate;
    if (opDate == null) return 'Willkommen zurück!';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final op = DateTime(opDate.year, opDate.month, opDate.day);
    final diff = today.difference(op).inDays;
    if (diff < 0) return 'Gute Vorbereitung ist alles!';
    if (diff == 0) return 'Heute ist der Tag – du schaffst das!';
    if (diff <= 3) return 'Schone dich und erhol dich gut!';
    if (diff <= 14) return 'Weiterhin gute Genesung!';
    return 'Du bist auf einem guten Weg!';
  }

  String _greetingText() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Guten Morgen';
    if (hour < 17) return 'Guten Tag';
    return 'Guten Abend';
  }

  String? _firstName() {
    final raw = FirebaseAuth.instance.currentUser?.displayName ?? '';
    final first = raw.split(' ').first.trim();
    return first.isNotEmpty ? first : null;
  }
}

// ── Recovery context row ──────────────────────────────────────────────────────

class _RecoveryContextRow extends StatelessWidget {
  const _RecoveryContextRow({
    required this.dayLabel,
    required this.encouragement,
    required this.progress,
    required this.hasOpDate,
  });

  final String dayLabel;
  final String encouragement;
  final double progress;
  final bool hasOpDate;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return GlassContainer(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      borderRadius: BorderRadius.circular(20),
      variant: GlassVariant.thin,
      elevation: GlassElevation.low,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day label (prominent)
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.monitor_heart_outlined,
                  size: 18,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dayLabel,
                      style: tt.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      encouragement,
                      style: tt.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasOpDate)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${(progress * 100).round()}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),

          // Progress bar
          if (hasOpDate) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 6,
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor:
                      AppColors.textSecondary.withValues(alpha: 0.08),
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
          ],
        ],
      ),
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
            label: 'OP-Datum eintragen',
            icon: Icons.calendar_today_rounded,
          ),
        ],
      ),
    );
  }
}

// ── Loading state ────────────────────────────────────────────────────────────

class _LoadingState extends StatefulWidget {
  const _LoadingState({required this.topPadding});

  final double topPadding;

  @override
  State<_LoadingState> createState() => _LoadingStateState();
}

class _LoadingStateState extends State<_LoadingState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerCtrl;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  Widget _shimmerBox(double width, double height, {double radius = 8}) {
    return AnimatedBuilder(
      animation: _shimmerCtrl,
      builder: (_, _) {
        final color = ColorTween(
          begin: AppColors.textSecondary.withValues(alpha: 0.08),
          end: AppColors.textSecondary.withValues(alpha: 0.18),
        ).evaluate(_shimmerCtrl)!;
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(radius),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: widget.topPadding + AppSpacing.lg,
        bottom: 120,
      ),
      children: [
        // Header skeleton (greeting + date + bell)
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _shimmerBox(180, 22),
                  const SizedBox(height: 6),
                  _shimmerBox(130, 14),
                ],
              ),
            ),
            _shimmerBox(38, 38, radius: 14),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),

        // Recovery context skeleton
        _shimmerBox(double.infinity, 90, radius: 20),
        const SizedBox(height: AppSpacing.lg),

        // Focus card skeleton
        _shimmerBox(double.infinity, 120, radius: 24),
        const SizedBox(height: AppSpacing.lg),

        // Tasks card skeleton
        _shimmerBox(double.infinity, 180, radius: 20),
        const SizedBox(height: AppSpacing.lg),

        // Appointments card skeleton
        _shimmerBox(double.infinity, 80, radius: 20),
        const SizedBox(height: AppSpacing.lg),

        // Day strip skeleton
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Row(
            children: [
              for (var i = 0; i < 5; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                _shimmerBox(80, 76, radius: 16),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ── Floating home bar ────────────────────────────────────────────────────────

class _FloatingHomeBar extends StatelessWidget {
  const _FloatingHomeBar({
    required this.dayLabel,
    required this.summary,
    required this.onNewEntry,
  });

  final String dayLabel;
  final TimelineHeaderSummary summary;
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
          child: Row(
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
              // Day label + summary
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dayLabel,
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Row(
                      children: [
                        Text(
                          '${summary.doneCount}/${summary.totalCount} erledigt',
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
              // "Neu" button
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
        ),
      ),
    );
  }
}


