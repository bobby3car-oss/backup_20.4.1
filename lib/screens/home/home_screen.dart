import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../domain/task_orchestrator_sync.dart';
import '../../domain/timeline_engine.dart';
import '../../navigation/timeline_routes.dart';
import '../../ui/ui.dart';
import '../profile_settings_screen.dart';
import 'home_view_model.dart';
import 'widgets/heute_focus_card.dart';
import 'widgets/home_header.dart';
import 'widgets/nearby_days_card.dart';
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

  @override
  void initState() {
    super.initState();
    _bootstrap();
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

    return ListView(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: topPadding + AppSpacing.lg,
        bottom: 120,
      ),
      physics: adaptiveScrollPhysics,
      children: [
        // ── App header ──────────────────────────────────────
        const HomeHeader(),
        const SizedBox(height: AppSpacing.md),

        // ── Willkommensgruß ──────────────────────────────────
        _WelcomeBanner(
          greeting: _greetingText(),
          firstName: _firstName(),
          date: DateTime.now(),
        ),
        const SizedBox(height: AppSpacing.lg),

        // ── Focus card (day label + next step) ──────────────
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

        // ── Nearby days (past + upcoming) ────────────────────
        NearbyDaysCard(
          sections: nearbySections,
          onToggle: (id, state) => _toggleTaskDone(id, state),
          onNavigate: (routeKey, id) {
            if (routeKey != null && routeKey.isNotEmpty) {
              _openNamedRoute(routeKey, taskId: id);
            }
          },
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

// ── Welcome banner ───────────────────────────────────────────────────────────

class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner({
    required this.greeting,
    required this.firstName,
    required this.date,
  });

  final String greeting;
  final String? firstName;
  final DateTime date;

  String _dateFormatted() {
    const weekdays = [
      'Montag', 'Dienstag', 'Mittwoch', 'Donnerstag',
      'Freitag', 'Samstag', 'Sonntag'
    ];
    const months = [
      'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
      'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember'
    ];
    return '${weekdays[date.weekday - 1]}, ${date.day}. ${months[date.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final name = firstName;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name != null ? '$greeting, $name!' : '$greeting!',
          style: tt.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          _dateFormatted(),
          style: tt.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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


