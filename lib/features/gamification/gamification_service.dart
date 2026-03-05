import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'data/gamification_repository.dart';
import 'domain/badge_rules.dart';
import 'domain/daily_challenge.dart';
import 'domain/daily_log.dart';
import 'domain/gamification_state.dart';
import 'domain/xp_config.dart';

/// Central gamification service.
///
/// Exposes a [Stream<GamificationState>] and methods to award XP,
/// record activity, update streaks, evaluate badges, and manage
/// daily challenges.
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

  Future<GamificationState> getState() => _repo.getState();

  // ── Activity recording ─────────────────────────────────────────

  /// The central entry point called after every patient activity.
  ///
  /// Updates daily log, awards XP, updates streak, and evaluates badges.
  Future<void> recordActivity({
    bool task = false,
    bool wound = false,
    bool pain = false,
    bool vitals = false,
    bool medication = false,
    ActivityCounts? activityCounts,
  }) async {
    try {
      final today = _todayKey();

      // 1. Update daily log
      var log = await _repo.getDailyLog(today) ?? DailyLog(date: today);
      var xpForThisAction = 0;

      if (task) {
        log = log.copyWith(tasksCompleted: log.tasksCompleted + 1);
        xpForThisAction += XpConfig.taskDone;
      }
      if (wound) {
        log = log.copyWith(woundLogged: true);
        xpForThisAction += XpConfig.woundPhoto;
      }
      if (pain) {
        log = log.copyWith(painLogged: true);
        xpForThisAction += XpConfig.painLog;
      }
      if (vitals) {
        log = log.copyWith(vitalsLogged: true);
        xpForThisAction += XpConfig.vitalsLog;
      }
      if (medication) {
        log = log.copyWith(medicationLogged: true);
        xpForThisAction += XpConfig.medicationLog;
      }

      // Daily complete bonus: all 5 types logged today
      final wasComplete = log.activityCount >= 5;

      log = log.copyWith(xpEarned: log.xpEarned + xpForThisAction);
      await _repo.saveDailyLog(log);

      // 2. Update state (transactional)
      await _repo.updateStateTransactional((state) {
        var s = state;

        // XP
        var totalXp = s.xp + xpForThisAction;

        // Daily complete bonus (award once)
        if (log.activityCount >= 5 && !wasComplete) {
          totalXp += XpConfig.dailyCompleteBonus;
        }

        // Level
        final newLevel = XpConfig.levelFromXp(totalXp);

        // Streak
        final now = DateTime.now();
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
            // Same day, no streak change
          } else if (diff == 1) {
            streak++;
            daysActive++;
          } else {
            streak = 1;
            daysActive++;
          }
        }
        if (streak > longest) longest = streak;

        // Tasks done
        var tasksDone = s.totalTasksDone;
        if (task) tasksDone++;

        s = s.copyWith(
          xp: totalXp,
          level: newLevel,
          currentStreak: streak,
          longestStreak: longest,
          lastActiveDate: todayDate,
          totalTasksDone: tasksDone,
          totalDaysActive: daysActive,
        );

        // Evaluate badges
        final counts = activityCounts ?? const ActivityCounts();
        final newBadges = BadgeRules.evaluate(s, counts);
        if (newBadges.isNotEmpty) {
          final now = DateTime.now();
          final updatedBadges = List<EarnedBadge>.from(s.badges);
          var badgeXp = 0;
          for (final badgeId in newBadges) {
            updatedBadges.add(EarnedBadge(id: badgeId, earnedAt: now));
            final def = BadgeCatalog.byId(badgeId);
            if (def != null) badgeXp += def.xpReward;
          }
          s = s.copyWith(
            badges: updatedBadges,
            xp: s.xp + badgeXp,
            level: XpConfig.levelFromXp(s.xp + badgeXp),
          );
        }

        return s;
      });
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[GamificationService] recordActivity error: $e');
        debugPrintStack(stackTrace: st);
      }
    }
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
  Future<void> completeChallenge(String challengeId) async {
    final today = _todayKey();
    final set = await _repo.getDailyChallenges(today);
    if (set == null) return;

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

    // Award challenge XP
    if (challenge != null) {
      await _repo.updateStateTransactional((state) {
        final newXp = state.xp + challenge.xpReward;
        return state.copyWith(
          xp: newXp,
          level: XpConfig.levelFromXp(newXp),
        );
      });
    }
  }

  // ── Milestone detection ────────────────────────────────────────

  /// Call after a timeline phase is completed.
  Future<void> awardMilestone(String phase) async {
    await _repo.updateStateTransactional((state) {
      final newXp = state.xp + XpConfig.milestonePhase;
      return state.copyWith(
        xp: newXp,
        level: XpConfig.levelFromXp(newXp),
      );
    });
  }

  // ── Helpers ────────────────────────────────────────────────────

  static String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
