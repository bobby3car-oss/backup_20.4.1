import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/task_orchestrator.dart';
import '../../../domain/timeline_engine.dart';
import '../../gamification/data/gamification_repository_local.dart';
import '../../medication/data/medication_repository_local.dart';
import '../../mood/data/mood_repository_local.dart';
import '../../pain/data/pain_repository_local.dart';
import '../../sleep/data/sleep_repository_local.dart';
import '../../vitals/data/vital_repository_local.dart';
import '../../wound/data/wound_repository_local.dart';

/// Types of proactive recommendations.
enum BellaRecommendationType {
  documentationGap,
  painTrendRising,
  openTasks,
  streakAtRisk,
  medicationReminder,
}

/// A single proactive recommendation from Bella.
class BellaRecommendation {
  const BellaRecommendation({
    required this.type,
    required this.message,
    required this.chatPrompt,
    this.priority = 0,
    this.params = const {},
  });

  /// The kind of recommendation.
  final BellaRecommendationType type;

  /// Short display message (e.g. "Du hast seit 2 Tagen nichts dokumentiert").
  final String message;

  /// Pre-filled prompt to send when the user taps the card.
  final String chatPrompt;

  /// Higher = more important. Used to sort recommendations.
  final int priority;

  /// Extra data used for building localized messages in the UI.
  final Map<String, dynamic> params;
}

/// Evaluates local patient data and returns proactive recommendations.
///
/// All logic is purely local — no external API calls.
class BellaProactiveEngine {
  BellaProactiveEngine({
    TaskOrchestrator? orchestrator,
  }) : _orchestrator = orchestrator;

  final TaskOrchestrator? _orchestrator;

  static const _dismissKeyPrefix = 'bella_proactive_dismissed_';

  /// Evaluate the current patient state and return recommendations
  /// sorted by priority (highest first).
  Future<List<BellaRecommendation>> evaluatePatientState() async {
    final recommendations = <BellaRecommendation>[];

    await Future.wait([
      _checkDocumentationGap(recommendations),
      _checkPainTrend(recommendations),
      _checkOpenTasks(recommendations),
      _checkStreakAtRisk(recommendations),
      _checkMedicationNotTaken(recommendations),
    ]);

    recommendations.sort((a, b) => b.priority.compareTo(a.priority));
    return recommendations;
  }

  /// Returns the single most important recommendation that hasn't
  /// been dismissed today. Returns null if none or all dismissed.
  Future<BellaRecommendation?> topRecommendation() async {
    final all = await evaluatePatientState();
    if (all.isEmpty) return null;

    final prefs = await SharedPreferences.getInstance();
    final todayKey = _todayKey();

    for (final rec in all) {
      final dismissKey = '$_dismissKeyPrefix${rec.type.name}';
      final dismissedDate = prefs.getString(dismissKey);
      if (dismissedDate == todayKey) continue;
      return rec;
    }
    return null;
  }

  /// Mark a recommendation type as dismissed for today.
  Future<void> dismiss(BellaRecommendationType type) async {
    final prefs = await SharedPreferences.getInstance();
    final dismissKey = '$_dismissKeyPrefix${type.name}';
    await prefs.setString(dismissKey, _todayKey());
  }

  // ── Check: Documentation gap (>48h since last pain/vitals entry) ──

  Future<void> _checkDocumentationGap(
    List<BellaRecommendation> out,
  ) async {
    try {
      final painList =
          await PainRepositoryLocal.instance.watchAll().first;
      final vitalList =
          await VitalRepositoryLocal.instance.watchAll().first;
      final moodList =
          await MoodRepositoryLocal.instance.watchAll().first;
      final sleepList =
          await SleepRepositoryLocal.instance.watchAll().first;
      final woundList =
          await WoundRepositoryLocal.instance.watchAll().first;

      DateTime? lastEntry;

      void updateLast(DateTime? candidate) {
        if (candidate == null) return;
        if (lastEntry == null || candidate.isAfter(lastEntry!)) {
          lastEntry = candidate;
        }
      }

      if (painList.isNotEmpty) updateLast(painList.first.occurredAt);
      if (vitalList.isNotEmpty) updateLast(vitalList.first.createdAt);
      if (moodList.isNotEmpty) updateLast(moodList.first.createdAt);
      if (sleepList.isNotEmpty) updateLast(sleepList.first.createdAt);
      if (woundList.isNotEmpty) updateLast(woundList.first.createdAt);

      if (lastEntry == null) return;

      final gap = DateTime.now().difference(lastEntry!);
      if (gap.inHours >= 48) {
        final days = gap.inDays;
        out.add(BellaRecommendation(
          type: BellaRecommendationType.documentationGap,
          message: 'Du hast seit $days Tagen nichts dokumentiert',
          chatPrompt:
              'Ich habe seit $days Tagen nichts dokumentiert. '
              'Kannst du mir helfen, meine aktuellen Werte einzutragen?',
          priority: 3,
          params: {'days': days},
        ));
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[BellaProactive] documentationGap check failed: $e');
    }
  }

  // ── Check: Pain trend rising (last 3 entries) ─────────────────

  Future<void> _checkPainTrend(
    List<BellaRecommendation> out,
  ) async {
    try {
      final painList =
          await PainRepositoryLocal.instance.watchAll().first;

      if (painList.length < 3) return;

      // watchAll returns sorted descending, so index 0 = newest.
      final recent3 = painList.take(3).toList();
      final levels = recent3.map((e) => e.painLevel).toList();

      // Check if strictly rising: oldest < middle < newest.
      // recent3[0]=newest, recent3[2]=oldest
      if (levels[2] < levels[1] && levels[1] < levels[0]) {
        out.add(BellaRecommendation(
          type: BellaRecommendationType.painTrendRising,
          message:
              'Dein Schmerzlevel steigt – möchtest du darüber sprechen?',
          chatPrompt:
              'Mein Schmerzlevel steigt in den letzten Einträgen '
              '(${levels[2]} → ${levels[1]} → ${levels[0]}). '
              'Kannst du mir dazu Empfehlungen geben?',
          priority: 5,
          params: const {},
        ));
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[BellaProactive] painTrend check failed: $e');
    }
  }

  // ── Check: Open timeline tasks for today ──────────────────────

  Future<void> _checkOpenTasks(
    List<BellaRecommendation> out,
  ) async {
    try {
      if (_orchestrator == null) return;

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      final openToday = _orchestrator.items.where((t) {
        final isOpen = t.state == TaskState.planned ||
            t.state == TaskState.due ||
            t.state == TaskState.inProgress;
        final isToday = t.scheduledAt.isAfter(todayStart) &&
            t.scheduledAt.isBefore(todayEnd);
        return isOpen && isToday;
      }).toList();

      if (openToday.isNotEmpty) {
        final count = openToday.length;
        out.add(BellaRecommendation(
          type: BellaRecommendationType.openTasks,
          message: 'Du hast noch $count offene Aufgaben für heute',
          chatPrompt:
              'Ich habe noch $count offene Aufgaben für heute. '
              'Welche sollte ich priorisieren?',
          priority: 2,
          params: {'count': count},
        ));
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[BellaProactive] openTasks check failed: $e');
    }
  }

  // ── Check: Streak at risk ─────────────────────────────────────

  Future<void> _checkStreakAtRisk(
    List<BellaRecommendation> out,
  ) async {
    try {
      final state =
          await GamificationRepositoryLocal.instance.watchState().first;

      if (state.currentStreak <= 0) return;

      final lastActive = state.lastActiveDate;
      if (lastActive == null) return;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final lastDay = DateTime(
        lastActive.year,
        lastActive.month,
        lastActive.day,
      );

      // If last active was yesterday and nothing done today → at risk.
      if (today.difference(lastDay).inDays >= 1) {
        out.add(BellaRecommendation(
          type: BellaRecommendationType.streakAtRisk,
          message: 'Dein ${state.currentStreak}-Tage Streak ist in Gefahr!',
          chatPrompt:
              'Mein Streak von ${state.currentStreak} Tagen ist in Gefahr. '
              'Was kann ich schnell tun, um ihn zu retten?',
          priority: 4,
          params: {'streak': state.currentStreak},
        ));
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[BellaProactive] streakAtRisk check failed: $e');
    }
  }

  // ── Check: Medication not taken today ─────────────────────────

  Future<void> _checkMedicationNotTaken(
    List<BellaRecommendation> out,
  ) async {
    try {
      final medList =
          await MedicationRepositoryLocal.instance.watchAll().first;

      if (medList.isEmpty) return;

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);

      // Find medications that have been taken before but not today.
      final allNames = <String>{};
      final takenTodayNames = <String>{};
      for (final m in medList) {
        if (m.isDeleted) continue;
        allNames.add(m.name);
        if (m.takenAt.isAfter(todayStart)) {
          takenTodayNames.add(m.name);
        }
      }

      final notTakenToday = allNames.difference(takenTodayNames);
      if (notTakenToday.isEmpty) return;

      // Only show if it's past 9 AM (don't nag early morning).
      if (now.hour < 9) return;

      final medName = notTakenToday.first;
      final message = notTakenToday.length == 1
          ? 'Hast du heute dein $medName genommen?'
          : 'Hast du heute deine Medikamente genommen? '
              '(${notTakenToday.length} ausstehend)';

      out.add(BellaRecommendation(
        type: BellaRecommendationType.medicationReminder,
        message: message,
        chatPrompt:
            'Ich habe heute noch nicht alle Medikamente genommen '
            '(${notTakenToday.join(", ")}). Kannst du mich daran erinnern?',
        priority: 4,
        params: notTakenToday.length == 1
            ? {'name': medName, 'multiple': false}
            : {'count': notTakenToday.length, 'multiple': true},
      ));
    } catch (e) {
      if (kDebugMode) debugPrint('[BellaProactive] medicationNotTaken check failed: $e');
    }
  }

  // ── Helpers ───────────────────────────────────────────────────

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }
}
