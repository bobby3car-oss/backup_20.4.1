import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import '../../domain/task_orchestrator_sync.dart';
import '../../domain/timeline_engine.dart';
import '../appointments/data/appointments_repository_sync.dart';
import '../appointments/domain/appointment.dart';
import '../gamification/gamification_service.dart';
import '../pain/data/pain_repository_sync.dart';
import '../pain/domain/pain_entry.dart';

/// iOS App Group identifier shared between the main app and widget extension.
const _iosAppGroupId = 'group.com.jangoede.operationsbegleiter';

/// Android widget fully-qualified class names.
const _androidNextTaskWidget =
    'com.jangoede.operationsbegleiter.widget.NextTaskWidget';
const _androidStreakWidget =
    'com.jangoede.operationsbegleiter.widget.StreakWidget';
const _androidDayOverviewWidget =
    'com.jangoede.operationsbegleiter.widget.DayOverviewWidget';
const _androidQuickActionsWidget =
    'com.jangoede.operationsbegleiter.widget.QuickActionsWidget';

/// Bridge between Flutter data sources and native home-screen widgets.
///
/// Collects the relevant data points (next task, streak, next appointment,
/// last pain level, open task count) and pushes them to shared storage
/// via [HomeWidget] so the native WidgetKit / AppWidget can display them.
class WidgetDataService {
  WidgetDataService._();

  static final WidgetDataService instance = WidgetDataService._();

  final List<StreamSubscription<dynamic>> _subscriptions = [];
  bool _listening = false;

  /// Start listening to all relevant data streams and update widgets
  /// whenever data changes.
  void startListening({
    required GamificationService gamificationService,
  }) {
    if (_listening) return;
    _listening = true;

    // Configure app group for iOS – ignore if App Group is not available
    // (e.g. simulator without a registered App Group).
    HomeWidget.setAppGroupId(_iosAppGroupId).catchError((Object e) {
      if (kDebugMode) debugPrint('[WidgetDataService] setAppGroupId failed: $e');
      return false;
    });

    // Initial push.
    unawaited(_update(gamificationService));

    // React to timeline changes.
    final orchestrator = TaskOrchestratorSync.instance.orchestrator;
    _subscriptions.add(
      orchestrator
          .watch(
            from: DateTime.now().subtract(const Duration(hours: 1)),
            to: DateTime.now().add(const Duration(days: 7)),
          )
          .listen(
            (_) => _update(gamificationService),
            onError: (Object e) {
              if (kDebugMode) {
                debugPrint('[WidgetDataService] orchestrator watch error: $e');
              }
            },
            cancelOnError: false,
          ),
    );

    // React to gamification / streak changes.
    _subscriptions.add(
      gamificationService.watchState().listen(
        (_) => _update(gamificationService),
        onError: (Object e) {
          if (kDebugMode) {
            debugPrint('[WidgetDataService] gamification watch error: $e');
          }
        },
        cancelOnError: false,
      ),
    );

    // React to appointment changes.
    _subscriptions.add(
      AppointmentsRepositorySync.instance
          .watchRange(DateTime.now(), DateTime.now().add(const Duration(days: 7)))
          .listen(
            (_) => _update(gamificationService),
            onError: (Object e) {
              if (kDebugMode) {
                debugPrint('[WidgetDataService] appointments watch error: $e');
              }
            },
            cancelOnError: false,
          ),
    );

    // React to pain diary changes.
    _subscriptions.add(
      PainRepositorySync.instance.watchAll().listen(
        (_) => _update(gamificationService),
        onError: (Object e) {
          if (kDebugMode) {
            debugPrint('[WidgetDataService] pain watch error: $e');
          }
        },
        cancelOnError: false,
      ),
    );
  }

  /// Stop all listeners (e.g. on sign-out).
  void stopListening() {
    _debounce?.cancel();
    _debounce = null;
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
    _listening = false;
  }

  /// Manually trigger a widget data refresh (e.g. after a specific action).
  Future<void> refresh(GamificationService gamificationService) =>
      _update(gamificationService);

  // ── Private ───────────────────────────────────────────────────

  /// Debounce guard – avoids flooding native widget updates.
  Timer? _debounce;

  Future<void> _update(GamificationService gamificationService) async {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        await _doUpdate(gamificationService);
      } catch (e) {
        if (kDebugMode) debugPrint('[WidgetDataService] update failed: $e');
      }
    });
  }

  Future<void> _doUpdate(GamificationService gamificationService) async {
    // ── Next task ────────────────────────────────────────────────
    final orchestrator = TaskOrchestratorSync.instance.orchestrator;
    final now = DateTime.now();
    final openTasks = orchestrator.items
        .where((t) =>
            t.state != TaskState.done && t.state != TaskState.skipped)
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    final nextTask = openTasks.isNotEmpty ? openTasks.first : null;
    final openTaskCount = openTasks.length;

    await HomeWidget.saveWidgetData('nextTaskTitle', nextTask?.title ?? '');
    await HomeWidget.saveWidgetData('nextTaskType', nextTask?.type.name ?? '');
    await HomeWidget.saveWidgetData(
      'nextTaskTime',
      nextTask != null ? _formatTime(nextTask.scheduledAt) : '',
    );
    await HomeWidget.saveWidgetData('openTaskCount', openTaskCount);

    // ── Streak ──────────────────────────────────────────────────
    final gamState = await gamificationService.getState();
    await HomeWidget.saveWidgetData('currentStreak', gamState.currentStreak);
    await HomeWidget.saveWidgetData('longestStreak', gamState.longestStreak);
    await HomeWidget.saveWidgetData('level', gamState.level);
    await HomeWidget.saveWidgetData('xp', gamState.xp);

    // ── Next appointment ────────────────────────────────────────
    List<Appointment> upcoming;
    try {
      upcoming = await AppointmentsRepositorySync.instance
          .watchRange(now, now.add(const Duration(days: 7)))
          .first;
    } catch (_) {
      upcoming = [];
    }
    upcoming.sort((a, b) => a.startAt.compareTo(b.startAt));
    final nextApt = upcoming.isNotEmpty ? upcoming.first : null;

    await HomeWidget.saveWidgetData(
      'nextAppointmentTitle',
      nextApt?.title ?? '',
    );
    await HomeWidget.saveWidgetData(
      'nextAppointmentTime',
      nextApt != null ? _formatDateTime(nextApt.startAt) : '',
    );

    // ── Last pain level ─────────────────────────────────────────
    List<PainEntry> painEntries;
    try {
      painEntries = await PainRepositorySync.instance.watchAll().first;
    } catch (_) {
      painEntries = [];
    }
    painEntries.sort((a, b) => a.occurredAt.compareTo(b.occurredAt));
    final lastPain = painEntries.isNotEmpty ? painEntries.last : null;

    await HomeWidget.saveWidgetData(
      'lastPainLevel',
      lastPain?.painLevel ?? -1,
    );

    // ── Timestamp for freshness ─────────────────────────────────
    await HomeWidget.saveWidgetData(
      'lastUpdated',
      DateTime.now().toIso8601String(),
    );

    // ── Trigger native widget refresh ───────────────────────────
    await HomeWidget.updateWidget(
      iOSName: 'OpBegleiterWidget',
      androidName: _androidNextTaskWidget,
    );
    await HomeWidget.updateWidget(
      iOSName: 'OpBegleiterWidget',
      androidName: _androidStreakWidget,
    );
    await HomeWidget.updateWidget(
      iOSName: 'OpBegleiterWidget',
      androidName: _androidDayOverviewWidget,
    );
    await HomeWidget.updateWidget(
      iOSName: 'OpBegleiterWidget',
      androidName: _androidQuickActionsWidget,
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime dt) {
    final dayNames = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
    final dayName = dayNames[dt.weekday - 1];
    return '$dayName ${dt.day}.${dt.month}. ${_formatTime(dt)}';
  }
}
