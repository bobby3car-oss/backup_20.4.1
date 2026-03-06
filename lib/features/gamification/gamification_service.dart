import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'data/gamification_repository.dart';
import 'domain/badge_rules.dart';
import 'domain/daily_challenge.dart';
import 'domain/daily_log.dart';
import 'domain/gamification_state.dart';
import 'domain/milestone.dart';
import 'domain/recovery_event.dart';
import 'domain/xp_config.dart';

/// Result returned after [GamificationService.recordActivity].
///
/// Callers can inspect this to show inline XP chips, trigger overlays, etc.
class RecordResult {
  const RecordResult({
    this.xpAwarded = 0,
    this.newLevel,
    this.newBadges = const [],
    this.newMilestones = const [],
    this.comboCount = 0,
    this.streakMultiplier = 1.0,
    this.events = const [],
  });

  /// Total XP awarded for this action (incl. combo + streak bonus).
  final int xpAwarded;

  /// Non-null if a level-up occurred.
  final int? newLevel;

  /// Badge IDs earned by this action.
  final List<String> newBadges;

  /// Milestone IDs completed by this action.
  final List<String> newMilestones;

  /// Current combo count after this action.
  final int comboCount;

  /// Active streak multiplier.
  final double streakMultiplier;

  /// Feed events generated.
  final List<RecoveryEvent> events;
}

/// Central gamification / recovery-loop service.
///
/// Exposes a [Stream<GamificationState>] and methods to award XP,
/// record activity, update streaks, evaluate badges, manage
/// daily challenges, track milestones, and emit recovery feed events.
class GamificationService {
  GamificationService({GamificationRepository? repository})
      : _repo = repository ?? GamificationRepository();

  final GamificationRepository _repo;

  // ── Streams ────────────────────────────────────────────────────

  Stream<GamificationState> watchState() => _repo.watchState();

  Stream<List<DailyLog>> watchRecentLogs({int days = 35}) =>
      _repo.watchRecentLogs(days: days);

  Stream<DailyChallengeSet?> watchDailyChallenges() =>
      _repo.watchDailyChallenges(_todayKey());

  Stream<List<RecoveryEvent>> watchTodayEvents() =>
      _repo.watchTodayEvents();

  Stream<List<RecoveryEvent>> watchRecentEvents({int days = 7}) =>
      _repo.watchRecentEvents(days: days);

  Future<GamificationState> getState() => _repo.getState();

  // ── Activity recording ─────────────────────────────────────────

  /// The central entry point called after every patient activity.
  ///
  /// Updates daily log, awards XP (with streak multiplier + combo bonus),
  /// updates streak, evaluates badges & milestones, emits feed events,
  /// and returns a [RecordResult] so callers can show inline rewards.
  Future<RecordResult> recordActivity({
    bool task = false,
    bool wound = false,
    bool pain = false,
    bool vitals = false,
    bool medication = false,
    bool rehab = false,
    ActivityCounts? activityCounts,
    String? relatedItemId,
  }) async {
    try {
      final today = _todayKey();
      final now = DateTime.now();

      // 1. Update daily log
      var log = await _repo.getDailyLog(today) ?? DailyLog(date: today);
      var baseXp = 0;

      if (task) {
        log = log.copyWith(tasksCompleted: log.tasksCompleted + 1);
        baseXp += XpConfig.taskDone;
      }
      if (wound) {
        log = log.copyWith(woundLogged: true);
        baseXp += XpConfig.woundPhoto;
      }
      if (pain) {
        log = log.copyWith(painLogged: true);
        baseXp += XpConfig.painLog;
      }
      if (vitals) {
        log = log.copyWith(vitalsLogged: true);
        baseXp += XpConfig.vitalsLog;
      }
      if (medication) {
        log = log.copyWith(medicationLogged: true);
        baseXp += XpConfig.medicationLog;
      }
      if (rehab) {
        baseXp += XpConfig.rehabSession;
      }

      final wasComplete = log.activityCount >= 5;

      log = log.copyWith(xpEarned: log.xpEarned + baseXp);
      await _repo.saveDailyLog(log);

      // 2. Transactional state update
      final events = <RecoveryEvent>[];
      int? levelUpTo;
      final newBadgeIds = <String>[];
      final newMilestoneIds = <String>[];
      var comboAfter = 0;
      var streakMult = 1.0;

      await _repo.updateStateTransactional((state) {
        var s = state;

        // ── Combo ──
        var combo = s.comboCount;
        final lastReward = s.lastRewardAt;
        if (lastReward != null &&
            now.difference(lastReward).inSeconds <=
                XpConfig.comboWindowSeconds) {
          combo = (combo + 1).clamp(0, XpConfig.comboMax);
        } else {
          combo = 1;
        }
        comboAfter = combo;

        // ── Streak multiplier ──
        streakMult = XpConfig.streakMultiplier(s.currentStreak);

        // ── XP with bonuses ──
        var xpForAction =
            (baseXp * streakMult).round() + (combo - 1) * XpConfig.comboBonus;

        // Daily complete bonus (award once)
        if (log.activityCount >= 5 && !wasComplete) {
          xpForAction += XpConfig.dailyCompleteBonus;
        }

        var totalXp = s.xp + xpForAction;
        final oldLevel = s.level;
        final newLevel = XpConfig.levelFromXp(totalXp);
        if (newLevel > oldLevel) levelUpTo = newLevel;

        // ── Streak ──
        final todayDate = DateTime(now.year, now.month, now.day);
        var streak = s.currentStreak;
        var longest = s.longestStreak;
        var daysActive = s.totalDaysActive;

        final lastActive = s.lastActiveDate;
        if (lastActive == null) {
          streak = 1;
          daysActive = 1;
        } else {
          final lastDate = DateTime(
              lastActive.year, lastActive.month, lastActive.day);
          final diff = todayDate.difference(lastDate).inDays;
          if (diff == 0) {
            // Same day — no streak change
          } else if (diff == 1) {
            streak++;
            daysActive++;
          } else {
            streak = 1;
            daysActive++;
          }
        }
        if (streak > longest) longest = streak;

        var tasksDone = s.totalTasksDone;
        if (task) tasksDone++;

        // Today XP – reset if new day
        var todayXp = s.todayXp;
        if (lastActive != null) {
          final lastDate = DateTime(
              lastActive.year, lastActive.month, lastActive.day);
          if (todayDate.isAfter(lastDate)) todayXp = 0;
        }
        todayXp += xpForAction;

        s = s.copyWith(
          xp: totalXp,
          level: newLevel,
          currentStreak: streak,
          longestStreak: longest,
          lastActiveDate: todayDate,
          totalTasksDone: tasksDone,
          totalDaysActive: daysActive,
          todayXp: todayXp,
          comboCount: combo,
          lastRewardAt: now,
        );

        // ── Badges ──
        final counts = activityCounts ?? const ActivityCounts();
        final badgeResults = BadgeRules.evaluate(s, counts);
        if (badgeResults.isNotEmpty) {
          final updatedBadges = List<EarnedBadge>.from(s.badges);
          var badgeXp = 0;
          for (final badgeId in badgeResults) {
            updatedBadges.add(EarnedBadge(id: badgeId, earnedAt: now));
            final def = BadgeCatalog.byId(badgeId);
            if (def != null) badgeXp += def.xpReward;
            newBadgeIds.add(badgeId);
          }
          totalXp = s.xp + badgeXp;
          s = s.copyWith(
            badges: updatedBadges,
            xp: totalXp,
            level: XpConfig.levelFromXp(totalXp),
            todayXp: s.todayXp + badgeXp,
          );
        }

        // ── Milestones ──
        s = _evaluateMilestones(s, counts, newMilestoneIds, now);

        return s;
      });

      // 3. Generate feed events (fire-and-forget persistence)
      final effectiveXp =
          (baseXp * streakMult).round() +
          (comboAfter - 1) * XpConfig.comboBonus;

      // Activity event
      final actType = task
          ? RecoveryEventType.taskDone
          : wound
              ? RecoveryEventType.woundLogged
              : pain
                  ? RecoveryEventType.painLogged
                  : vitals
                      ? RecoveryEventType.vitalsLogged
                      : medication
                          ? RecoveryEventType.medicationLogged
                          : rehab
                              ? RecoveryEventType.rehabDone
                              : RecoveryEventType.taskDone;

      final actTitle = switch (actType) {
        RecoveryEventType.taskDone => 'Aufgabe erledigt',
        RecoveryEventType.woundLogged => 'Wunde dokumentiert',
        RecoveryEventType.painLogged => 'Schmerz erfasst',
        RecoveryEventType.vitalsLogged => 'Vitalwerte eingetragen',
        RecoveryEventType.medicationLogged => 'Medikation genommen',
        RecoveryEventType.rehabDone => 'Übung abgeschlossen',
        _ => 'Aktivität erfasst',
      };

      final actEvent = RecoveryEvent(
        id: _eventId(),
        type: actType,
        title: actTitle,
        subtitle: comboAfter > 1 ? 'Combo x$comboAfter' : null,
        createdAt: now,
        xpDelta: effectiveXp,
        relevance: EventRelevance.normal,
        relatedItemId: relatedItemId,
      );
      events.add(actEvent);
      unawaited(_repo.saveRecoveryEvent(actEvent));

      // Daily complete event
      if (log.activityCount >= 5 && !wasComplete) {
        final dcEvent = RecoveryEvent(
          id: _eventId(),
          type: RecoveryEventType.dailyComplete,
          title: 'Alle Kategorien erledigt!',
          subtitle: '+${XpConfig.dailyCompleteBonus} XP Bonus',
          createdAt: now,
          xpDelta: XpConfig.dailyCompleteBonus,
          relevance: EventRelevance.high,
        );
        events.add(dcEvent);
        unawaited(_repo.saveRecoveryEvent(dcEvent));
      }

      // Badge events
      for (final badgeId in newBadgeIds) {
        final def = BadgeCatalog.byId(badgeId);
        if (def == null) continue;
        final bEvent = RecoveryEvent(
          id: _eventId(),
          type: RecoveryEventType.badgeEarned,
          title: '${def.title} freigeschaltet!',
          subtitle: def.description,
          createdAt: now,
          xpDelta: def.xpReward,
          relevance: EventRelevance.high,
          relatedBadgeId: badgeId,
        );
        events.add(bEvent);
        unawaited(_repo.saveRecoveryEvent(bEvent));
      }

      // Milestone events
      for (final msId in newMilestoneIds) {
        final def = MilestoneCatalog.byId(msId);
        if (def == null) continue;
        final mEvent = RecoveryEvent(
          id: _eventId(),
          type: RecoveryEventType.milestoneReached,
          title: '🏆 ${def.title}',
          subtitle: def.description,
          createdAt: now,
          xpDelta: def.xpReward,
          relevance: EventRelevance.epic,
          relatedMilestoneId: msId,
        );
        events.add(mEvent);
        unawaited(_repo.saveRecoveryEvent(mEvent));
      }

      // Level-up event
      if (levelUpTo != null) {
        final levelName = LevelNames.forLevel(levelUpTo!);
        final luEvent = RecoveryEvent(
          id: _eventId(),
          type: RecoveryEventType.levelUp,
          title: 'Level $levelUpTo erreicht!',
          subtitle: levelName,
          createdAt: now,
          xpDelta: 0,
          relevance: EventRelevance.epic,
        );
        events.add(luEvent);
        unawaited(_repo.saveRecoveryEvent(luEvent));
      }

      return RecordResult(
        xpAwarded: effectiveXp,
        newLevel: levelUpTo,
        newBadges: newBadgeIds,
        newMilestones: newMilestoneIds,
        comboCount: comboAfter,
        streakMultiplier: streakMult,
        events: events,
      );
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[GamificationService] recordActivity error: $e');
        debugPrintStack(stackTrace: st);
      }
      return const RecordResult();
    }
  }

  // ── Milestone evaluation ───────────────────────────────────────

  GamificationState _evaluateMilestones(
    GamificationState state,
    ActivityCounts counts,
    List<String> newlyCompleted,
    DateTime now,
  ) {
    final milestones = List<MilestoneProgress>.from(state.milestones);

    for (final def in MilestoneCatalog.all) {
      var existing = milestones
          .where((m) => m.milestoneId == def.id)
          .firstOrNull;
      if (existing != null && existing.status == MilestoneStatus.completed) {
        continue;
      }

      final currentValue = _milestoneValue(def, state, counts);
      final isComplete = currentValue >= def.targetValue;
      final status = isComplete
          ? MilestoneStatus.completed
          : currentValue > 0
              ? MilestoneStatus.inProgress
              : MilestoneStatus.locked;

      final updated = MilestoneProgress(
        milestoneId: def.id,
        currentValue: currentValue,
        status: status,
        completedAt: isComplete ? now : null,
      );

      if (existing != null) {
        final idx = milestones.indexWhere((m) => m.milestoneId == def.id);
        milestones[idx] = updated;
      } else {
        milestones.add(updated);
      }

      if (isComplete && (existing == null || existing.status != MilestoneStatus.completed)) {
        newlyCompleted.add(def.id);
      }
    }

    // Award milestone XP
    if (newlyCompleted.isNotEmpty) {
      var msXp = 0;
      for (final id in newlyCompleted) {
        final def = MilestoneCatalog.byId(id);
        if (def != null) msXp += def.xpReward;
      }
      final newXp = state.xp + msXp;
      return state.copyWith(
        milestones: milestones,
        xp: newXp,
        level: XpConfig.levelFromXp(newXp),
        todayXp: state.todayXp + msXp,
      );
    }

    return state.copyWith(milestones: milestones);
  }

  int _milestoneValue(
    MilestoneDefinition def,
    GamificationState state,
    ActivityCounts counts,
  ) {
    return switch (def.id) {
      // Phase milestones are set to 1 externally via completePhase()
      'ms_preop' || 'ms_opday' || 'ms_week1' || 'ms_week2' || 'ms_followup' =>
        state.milestoneById(def.id)?.currentValue ?? 0,
      'ms_perfect_week' => state.currentStreak.clamp(0, 7),
      'ms_docu_week' => state.currentStreak.clamp(0, 7), // simplified
      'ms_tasks_25' => state.totalTasksDone.clamp(0, 25),
      'ms_tasks_100' => state.totalTasksDone.clamp(0, 100),
      'ms_photos_10' => counts.totalWoundPhotos.clamp(0, 10),
      'ms_vitals_20' => counts.totalVitalsEntries.clamp(0, 20),
      'ms_pain_15' => counts.totalPainEntries.clamp(0, 15),
      _ => 0,
    };
  }

  /// Call when a timeline phase has all tasks done.
  Future<RecordResult> completePhase(String phase) async {
    final phaseId = 'ms_$phase';
    final def = MilestoneCatalog.byId(phaseId);
    if (def == null) return const RecordResult();

    final now = DateTime.now();
    final events = <RecoveryEvent>[];
    final newMilestoneIds = <String>[];

    await _repo.updateStateTransactional((state) {
      final milestones = List<MilestoneProgress>.from(state.milestones);
      final existing = milestones
          .where((m) => m.milestoneId == phaseId)
          .firstOrNull;

      if (existing != null && existing.status == MilestoneStatus.completed) {
        return state; // already done
      }

      final updated = MilestoneProgress(
        milestoneId: phaseId,
        currentValue: 1,
        status: MilestoneStatus.completed,
        completedAt: now,
      );

      if (existing != null) {
        final idx = milestones.indexWhere((m) => m.milestoneId == phaseId);
        milestones[idx] = updated;
      } else {
        milestones.add(updated);
      }

      newMilestoneIds.add(phaseId);

      final newXp = state.xp + def.xpReward;
      return state.copyWith(
        milestones: milestones,
        xp: newXp,
        level: XpConfig.levelFromXp(newXp),
        todayXp: state.todayXp + def.xpReward,
      );
    });

    if (newMilestoneIds.isNotEmpty) {
      final mEvent = RecoveryEvent(
        id: _eventId(),
        type: RecoveryEventType.milestoneReached,
        title: '🏆 ${def.title}',
        subtitle: def.description,
        createdAt: now,
        xpDelta: def.xpReward,
        relevance: EventRelevance.epic,
        relatedMilestoneId: phaseId,
      );
      events.add(mEvent);
      unawaited(_repo.saveRecoveryEvent(mEvent));
    }

    return RecordResult(
      xpAwarded: def.xpReward,
      newMilestones: newMilestoneIds,
      events: events,
    );
  }

  // ── Daily Challenges (Pro) ─────────────────────────────────────

  /// Returns today's challenges, generating them if they don't exist yet.
  Future<DailyChallengeSet> getOrGenerateDailyChallenges() async {
    final today = _todayKey();
    var existing = await _repo.getDailyChallenges(today);
    if (existing != null) return existing;

    // Generate deterministically from date seed
    final seed = today.hashCode;
    final rng = math.Random(seed);
    final pool = List<DailyChallenge>.from(ChallengeTemplates.pool);
    pool.shuffle(rng);

    final selected = pool.take(3).toList();
    final set = DailyChallengeSet(
      date: today,
      challenges: selected,
      generatedAt: DateTime.now(),
    );
    await _repo.saveDailyChallenges(set);
    return set;
  }

  /// Mark a challenge as completed and award XP.
  Future<RecordResult> completeChallenge(String challengeId) async {
    final today = _todayKey();
    final now = DateTime.now();
    final set = await _repo.getDailyChallenges(today);
    if (set == null) return const RecordResult();

    final updated = set.challenges.map((c) {
      if (c.id == challengeId && !c.completed) {
        return c.copyWith(completed: true);
      }
      return c;
    }).toList();

    final challenge = set.challenges
        .where((c) => c.id == challengeId && !c.completed)
        .firstOrNull;

    await _repo.saveDailyChallenges(DailyChallengeSet(
      date: set.date,
      challenges: updated,
      generatedAt: set.generatedAt,
    ));

    final events = <RecoveryEvent>[];

    if (challenge != null) {
      await _repo.updateStateTransactional((state) {
        final newXp = state.xp + challenge.xpReward;
        return state.copyWith(
          xp: newXp,
          level: XpConfig.levelFromXp(newXp),
          todayXp: state.todayXp + challenge.xpReward,
        );
      });

      final cEvent = RecoveryEvent(
        id: _eventId(),
        type: RecoveryEventType.challengeDone,
        title: 'Challenge geschafft!',
        subtitle: challenge.title,
        createdAt: now,
        xpDelta: challenge.xpReward,
        relevance: EventRelevance.high,
      );
      events.add(cEvent);
      unawaited(_repo.saveRecoveryEvent(cEvent));

      return RecordResult(
        xpAwarded: challenge.xpReward,
        events: events,
      );
    }

    return const RecordResult();
  }

  // ── Legacy compatibility ───────────────────────────────────────

  /// Call after a timeline phase is completed.
  @Deprecated('Use completePhase() instead')
  Future<void> awardMilestone(String phase) async {
    await completePhase(phase);
  }

  // ── Helpers ────────────────────────────────────────────────────

  static String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static int _eventCounter = 0;
  static String _eventId() {
    _eventCounter++;
    final now = DateTime.now();
    return '${now.millisecondsSinceEpoch}_$_eventCounter';
  }
}
