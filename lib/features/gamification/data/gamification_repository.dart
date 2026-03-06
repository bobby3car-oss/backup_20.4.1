import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/daily_challenge.dart';
import '../domain/daily_log.dart';
import '../domain/gamification_state.dart';
import '../domain/recovery_event.dart';

/// Firestore repository for all gamification data.
class GamificationRepository {
  GamificationRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String? get _patientId => _auth.currentUser?.uid;

  // ── State document ─────────────────────────────────────────────

  DocumentReference<Map<String, dynamic>> _stateDoc(String patientId) =>
      _firestore
          .collection('patients')
          .doc(patientId)
          .collection('gamification')
          .doc('state');

  /// Stream of gamification state changes.
  Stream<GamificationState> watchState() {
    final pid = _patientId;
    if (pid == null) return Stream.value(const GamificationState());

    return _stateDoc(pid).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) {
        return const GamificationState();
      }
      return GamificationState.fromJson(snap.data()!);
    });
  }

  /// Read current state once.
  Future<GamificationState> getState() async {
    final pid = _patientId;
    if (pid == null) return const GamificationState();

    final snap = await _stateDoc(pid).get();
    if (!snap.exists || snap.data() == null) {
      return const GamificationState();
    }
    return GamificationState.fromJson(snap.data()!);
  }

  /// Write full state (merge to avoid overwriting concurrent writes).
  Future<void> saveState(GamificationState state) async {
    final pid = _patientId;
    if (pid == null) return;

    await _stateDoc(pid).set(state.toJson(), SetOptions(merge: true));
  }

  /// Atomically update state with a transaction.
  Future<GamificationState> updateStateTransactional(
    GamificationState Function(GamificationState current) updater,
  ) async {
    final pid = _patientId;
    if (pid == null) return const GamificationState();

    final ref = _stateDoc(pid);
    return _firestore.runTransaction<GamificationState>((tx) async {
      final snap = await tx.get(ref);
      final current = snap.exists && snap.data() != null
          ? GamificationState.fromJson(snap.data()!)
          : const GamificationState();

      final updated = updater(current);
      tx.set(ref, updated.toJson(), SetOptions(merge: true));
      return updated;
    });
  }

  // ── Daily log ──────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> _logCollection(String patientId) =>
      _firestore
          .collection('patients')
          .doc(patientId)
          .collection('gamification_log');

  /// Get today's log document.
  Future<DailyLog?> getDailyLog(String dateKey) async {
    final pid = _patientId;
    if (pid == null) return null;

    final snap = await _logCollection(pid).doc(dateKey).get();
    if (!snap.exists || snap.data() == null) return null;
    return DailyLog.fromJson(snap.data()!);
  }

  /// Save / update a daily log entry.
  Future<void> saveDailyLog(DailyLog log) async {
    final pid = _patientId;
    if (pid == null) return;

    final data = log.toJson();
    data['ownerId'] = pid;
    await _logCollection(pid).doc(log.date).set(data, SetOptions(merge: true));
  }

  /// Stream the last [days] of daily logs for heatmap rendering.
  Stream<List<DailyLog>> watchRecentLogs({int days = 35}) {
    final pid = _patientId;
    if (pid == null) return Stream.value([]);

    final cutoff = DateTime.now().subtract(Duration(days: days));
    final cutoffKey =
        '${cutoff.year}-${cutoff.month.toString().padLeft(2, '0')}-${cutoff.day.toString().padLeft(2, '0')}';

    return _logCollection(pid)
        .where('date', isGreaterThanOrEqualTo: cutoffKey)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .where((d) => d.data().isNotEmpty)
            .map((d) => DailyLog.fromJson(d.data()))
            .toList());
  }

  // ── Daily challenges ───────────────────────────────────────────

  DocumentReference<Map<String, dynamic>> _challengeDoc(
          String patientId, String dateKey) =>
      _firestore
          .collection('patients')
          .doc(patientId)
          .collection('daily_challenges')
          .doc(dateKey);

  /// Get today's challenge set, if it exists.
  Future<DailyChallengeSet?> getDailyChallenges(String dateKey) async {
    final pid = _patientId;
    if (pid == null) return null;

    final snap = await _challengeDoc(pid, dateKey).get();
    if (!snap.exists || snap.data() == null) return null;
    return DailyChallengeSet.fromJson(snap.data()!);
  }

  /// Save / update daily challenges.
  Future<void> saveDailyChallenges(DailyChallengeSet cs) async {
    final pid = _patientId;
    if (pid == null) return;

    final data = cs.toJson();
    data['ownerId'] = pid;
    await _challengeDoc(pid, cs.date).set(data, SetOptions(merge: true));
  }

  /// Stream today's challenge set.
  Stream<DailyChallengeSet?> watchDailyChallenges(String dateKey) {
    final pid = _patientId;
    if (pid == null) return Stream.value(null);

    return _challengeDoc(pid, dateKey).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return DailyChallengeSet.fromJson(snap.data()!);
    });
  }

  // ── Recovery feed events ───────────────────────────────────────

  CollectionReference<Map<String, dynamic>> _feedCollection(
          String patientId) =>
      _firestore
          .collection('patients')
          .doc(patientId)
          .collection('recovery_feed');

  /// Save a new recovery event.
  Future<void> saveRecoveryEvent(RecoveryEvent event) async {
    final pid = _patientId;
    if (pid == null) return;

    final data = event.toJson();
    data['ownerId'] = pid;
    await _feedCollection(pid).doc(event.id).set(data);
  }

  /// Stream today's recovery events (newest first).
  Stream<List<RecoveryEvent>> watchTodayEvents() {
    final pid = _patientId;
    if (pid == null) return Stream.value([]);

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    return _feedCollection(pid)
        .where('createdAt',
            isGreaterThanOrEqualTo: todayStart.toIso8601String())
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs
            .where((d) => d.data().isNotEmpty)
            .map((d) => RecoveryEvent.fromJson(d.data()))
            .toList());
  }

  /// Stream recent recovery events (last [days] days, newest first).
  Stream<List<RecoveryEvent>> watchRecentEvents({int days = 7}) {
    final pid = _patientId;
    if (pid == null) return Stream.value([]);

    final cutoff = DateTime.now().subtract(Duration(days: days));

    return _feedCollection(pid)
        .where('createdAt',
            isGreaterThanOrEqualTo: cutoff.toIso8601String())
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snap) => snap.docs
            .where((d) => d.data().isNotEmpty)
            .map((d) => RecoveryEvent.fromJson(d.data()))
            .toList());
  }
}
