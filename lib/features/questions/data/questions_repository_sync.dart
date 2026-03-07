import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../sync/firestore_client.dart';
import '../../../sync/sync_models.dart';
import '../../../sync/sync_queue_local.dart';
import '../../../sync/sync_service.dart';
import '../domain/doctor_question.dart';
import 'questions_repository_local.dart';

class QuestionsRepositorySync {
  static final QuestionsRepositorySync instance =
      QuestionsRepositorySync._internal();

  factory QuestionsRepositorySync() => instance;

  QuestionsRepositorySync._internal({
    QuestionsRepositoryLocal? local,
    FirebaseAuth? auth,
    SyncQueueLocal? queue,
    SyncService? syncService,
    FirestoreClient? firestoreClient,
  }) : _local = local ?? QuestionsRepositoryLocal.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _queue = queue ?? SyncQueueLocal(fileName: 'questions_sync_queue.json'),
       _firestoreClient = firestoreClient ?? FirestoreClient() {
    _syncService =
        syncService ??
        SyncService(queue: _queue, firestoreClient: _firestoreClient);
  }

  final QuestionsRepositoryLocal _local;
  final FirebaseAuth _auth;
  final SyncQueueLocal _queue;
  late final SyncService _syncService;
  final FirestoreClient _firestoreClient;

  Stream<List<DoctorQuestion>> watchAll() => _local.watchAll();

  Future<void> loadFromDisk() => _local.loadFromDisk();

  Future<void> seedDefaultsIfEmpty() async {
    final uid = _uid;
    if (uid == null) return;
    await _local.seedDefaultsIfEmpty(uid);
  }

  Future<void> upsert(DoctorQuestion question) async {
    final now = DateTime.now();
    final normalized = question.copyWith(
      updatedAt: now,
      metadata: <String, dynamic>{
        ...question.metadata,
        'clientUpdatedAt': now.toIso8601String(),
      },
    );
    await _local.upsert(normalized);

    final uid = _uid;
    if (uid == null) return;
    try {
      final now = DateTime.now();
      final payload = <String, dynamic>{
        ...normalized.toJson(),
        'updatedAt': normalized.updatedAt.toIso8601String(),
      };
      await _queue.enqueue(
        SyncOp(
          id: 'question_upsert_${normalized.id}_${now.microsecondsSinceEpoch}',
          collectionPath: 'patients/$uid/questions',
          docId: normalized.id,
          type: SyncOpType.upsert,
          payload: payload,
          createdAt: now,
        ),
      );
      unawaited(_syncService.syncNow());
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[QuestionsRepositorySync] enqueue failed: $error');
        debugPrint('$stackTrace');
      }
    }
  }

  Future<void> delete(String id) async {
    await _local.delete(id);

    final uid = _uid;
    if (uid == null) return;
    try {
      final now = DateTime.now();
      await _queue.enqueue(
        SyncOp(
          id: 'question_delete_${id}_${now.microsecondsSinceEpoch}',
          collectionPath: 'patients/$uid/questions',
          docId: id,
          type: SyncOpType.delete,
          payload: const <String, dynamic>{},
          createdAt: now,
        ),
      );
      unawaited(_syncService.syncNow());
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[QuestionsRepositorySync] delete enqueue failed: $error');
        debugPrint('$stackTrace');
      }
    }
  }

  Future<void> pullLatest() async {
    final uid = _uid;
    if (uid == null) return;

    try {
      final remoteDocs = await _firestoreClient.fetchCollectionDocs(
        'patients/$uid/questions',
      );
      if (remoteDocs.isEmpty) return;

      final local = await _local.watchAll().first;
      final localById = <String, DoctorQuestion>{
        for (final item in local) item.id: item,
      };

      for (final remoteDoc in remoteDocs) {
        final remote = <String, dynamic>{
          ...remoteDoc.data,
          'id': remoteDoc.id,
        };
        final remoteUpdatedAt =
            _parseRemoteDate(remote['updatedAt']) ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final localItem = localById[remoteDoc.id];
        final localUpdatedAt =
            localItem?.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        if (localItem != null && !remoteUpdatedAt.isAfter(localUpdatedAt)) {
          continue;
        }
        final merged = DoctorQuestion.fromJson(<String, dynamic>{
          ...remote,
          'createdAt': _remoteDateString(remote['createdAt']),
          'updatedAt': _remoteDateString(remote['updatedAt']),
        });
        await _local.upsert(merged);
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[QuestionsRepositorySync] pullLatest failed: $error');
        debugPrint('$stackTrace');
      }
    }
  }

  String? get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.trim().isEmpty) return null;
    return uid;
  }

  /// Flush the sync queue. Called by [ConnectivityService] on reconnect.
  Future<void> syncNow() => _syncService.syncNow();

  DateTime? _parseRemoteDate(Object? raw) {
    if (raw == null) return null;
    if (raw is Timestamp) return raw.toDate();
    if (raw is String && raw.trim().isNotEmpty) return DateTime.tryParse(raw);
    return null;
  }

  String? _remoteDateString(Object? raw) {
    if (raw == null) return null;
    if (raw is Timestamp) return raw.toDate().toIso8601String();
    return raw.toString();
  }
}
