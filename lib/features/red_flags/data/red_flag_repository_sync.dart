import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../domain/red_flag.dart';
import 'red_flag_repository_local.dart';

class RedFlagRepositorySync {
  static final RedFlagRepositorySync instance =
      RedFlagRepositorySync._internal();

  factory RedFlagRepositorySync() => instance;

  RedFlagRepositorySync._internal({
    RedFlagRepositoryLocal? local,
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _local = local ?? RedFlagRepositoryLocal.instance,
       _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  final RedFlagRepositoryLocal _local;
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  // ── Public API ────────────────────────────────────────────────────────

  Stream<List<RedFlag>> watchAll() => _local.watchAll();

  List<RedFlag> get activeFlags => _local.activeFlags;

  Future<void> loadFromDisk() => _local.loadFromDisk();

  Future<void> upsert(RedFlag flag) async {
    final now = DateTime.now();
    final updated = flag.copyWith(updatedAt: now);
    await _local.upsert(updated);

    final uid = _patientId;
    if (uid == null) return;

    try {
      await _docRef(uid, updated.id).set(<String, dynamic>{
        ...updated.toJson(),
        'updatedAt': now.toIso8601String(),
        'clientUpdatedAt': now.toIso8601String(),
      });
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[RedFlagRepositorySync] remote upsert failed: $error');
        debugPrint('$stackTrace');
      }
    }
  }

  Future<void> upsertAll(List<RedFlag> flags) async {
    for (final flag in flags) {
      await upsert(flag);
    }
  }

  /// Acknowledge a flag (doctor / caregiver).
  Future<void> acknowledge(String flagId, {String? byUid}) async {
    final existing = _local.getByIdSync(flagId);
    if (existing == null) return;
    final now = DateTime.now();
    await upsert(existing.copyWith(
      status: RedFlagStatus.acknowledged,
      assigneeUid: byUid,
      acknowledgedAt: now,
    ));
  }

  /// Set flag to monitoring.
  Future<void> monitor(String flagId) async {
    final existing = _local.getByIdSync(flagId);
    if (existing == null) return;
    await upsert(existing.copyWith(status: RedFlagStatus.monitoring));
  }

  /// Escalate a flag.
  Future<void> escalate(String flagId) async {
    final existing = _local.getByIdSync(flagId);
    if (existing == null) return;
    await upsert(existing.copyWith(status: RedFlagStatus.escalated));
  }

  /// Resolve a flag.
  Future<void> resolve(String flagId, {String? byUid, String? comment}) async {
    final existing = _local.getByIdSync(flagId);
    if (existing == null) return;
    final now = DateTime.now();
    await upsert(existing.copyWith(
      status: RedFlagStatus.resolved,
      resolvedByUid: byUid,
      resolvedAt: now,
      comment: comment,
    ));
  }

  /// Add a comment without changing status.
  Future<void> addComment(String flagId, String comment) async {
    final existing = _local.getByIdSync(flagId);
    if (existing == null) return;
    await upsert(existing.copyWith(comment: comment));
  }

  /// Pull latest from Firestore and merge with local.
  Future<void> pullLatest() async {
    final uid = _patientId;
    if (uid == null) return;

    try {
      final snapshot = await _collection(uid).get();
      if (snapshot.docs.isEmpty) return;

      for (final doc in snapshot.docs) {
        final remoteMap = <String, dynamic>{...doc.data(), 'id': doc.id};
        final remote = RedFlag.fromJson(remoteMap);
        final local = _local.getByIdSync(doc.id);

        if (local == null || remote.updatedAt.isAfter(local.updatedAt)) {
          await _local.upsert(remote);
        }
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[RedFlagRepositorySync] pullLatest failed: $error');
        debugPrint('$stackTrace');
      }
    }
  }

  /// Pull flags for a specific patient (used by doctors).
  Future<List<RedFlag>> fetchForPatient(String patientId) async {
    try {
      final snapshot = await _collection(patientId).get();
      return snapshot.docs
          .map((d) => RedFlag.fromJson(<String, dynamic>{
                ...d.data(),
                'id': d.id,
              }))
          .toList();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint(
            '[RedFlagRepositorySync] fetchForPatient failed: $error');
        debugPrint('$stackTrace');
      }
      return const [];
    }
  }

  /// Update a flag for a specific patient (used by doctors).
  Future<void> upsertForPatient(String patientId, RedFlag flag) async {
    final now = DateTime.now();
    final updated = flag.copyWith(updatedAt: now);
    try {
      await _docRef(patientId, updated.id).set(<String, dynamic>{
        ...updated.toJson(),
        'updatedAt': now.toIso8601String(),
        'clientUpdatedAt': now.toIso8601String(),
      });
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint(
            '[RedFlagRepositorySync] upsertForPatient failed: $error');
        debugPrint('$stackTrace');
      }
    }
  }

  // ── Private ───────────────────────────────────────────────────────────

  String? get _patientId {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null || uid.trim().isEmpty) return null;
    return uid;
  }

  CollectionReference<Map<String, dynamic>> _collection(String uid) {
    return _firestore.collection('patients/$uid/red_flags');
  }

  DocumentReference<Map<String, dynamic>> _docRef(String uid, String id) {
    return _collection(uid).doc(id);
  }
}
