import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../sync/firestore_client.dart';
import '../../../sync/sync_models.dart';
import '../../../sync/sync_queue_local.dart';
import '../../../sync/sync_service.dart';
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
    SyncQueueLocal? queue,
    SyncService? syncService,
    FirestoreClient? firestoreClient,
  }) : _local = local ?? RedFlagRepositoryLocal.instance,
       _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _queue = queue ?? SyncQueueLocal(fileName: 'red_flags_sync_queue.json'),
       _firestoreClient = firestoreClient ?? FirestoreClient() {
    _syncService =
        syncService ??
        SyncService(queue: _queue, firestoreClient: _firestoreClient);
  }

  final RedFlagRepositoryLocal _local;
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final SyncQueueLocal _queue;
  late final SyncService _syncService;
  final FirestoreClient _firestoreClient;

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
      final payload = <String, dynamic>{
        ...updated.toJson(),
        'updatedAt': now.toIso8601String(),
        'clientUpdatedAt': now.toIso8601String(),
      };
      await _queue.enqueue(
        SyncOp(
          id: 'redflag_upsert_${updated.id}_${now.microsecondsSinceEpoch}',
          collectionPath: 'patients/$uid/red_flags',
          docId: updated.id,
          type: SyncOpType.upsert,
          payload: payload,
          createdAt: now,
        ),
      );
      unawaited(_syncService.syncNow());
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[RedFlagRepositorySync] enqueue failed: $error');
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
      final remoteDocs = await _firestoreClient.fetchCollectionDocs(
        'patients/$uid/red_flags',
      );
      if (remoteDocs.isEmpty) return;

      for (final remoteDoc in remoteDocs) {
        final remoteMap = <String, dynamic>{
          ...remoteDoc.data,
          'id': remoteDoc.id,
        };
        final remote = RedFlag.fromJson(remoteMap);
        final local = _local.getByIdSync(remoteDoc.id);

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

  /// Flush the sync queue. Called by [ConnectivityService] on reconnect.
  Future<void> syncNow() => _syncService.syncNow();

  CollectionReference<Map<String, dynamic>> _collection(String uid) {
    return _firestore.collection('patients/$uid/red_flags');
  }

  DocumentReference<Map<String, dynamic>> _docRef(String uid, String id) {
    return _collection(uid).doc(id);
  }
}
