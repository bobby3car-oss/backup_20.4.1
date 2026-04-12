import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../sync/firestore_client.dart';
import '../../../sync/sync_models.dart';
import '../../../sync/sync_queue_local.dart';
import '../../../sync/sync_service.dart';
import '../domain/rts_assessment.dart';
import 'rts_repository.dart';
import 'rts_repository_local.dart';

class RtsRepositorySync implements RtsRepository {
  static final RtsRepositorySync instance = RtsRepositorySync._internal();

  factory RtsRepositorySync() => instance;

  RtsRepositorySync._internal({
    RtsRepositoryLocal? local,
    SyncQueueLocal? queue,
    SyncService? syncService,
    FirebaseAuth? firebaseAuth,
    FirestoreClient? firestoreClient,
  }) : _local = local ?? RtsRepositoryLocal.instance,
       _queue = queue ?? SyncQueueLocal(fileName: 'rts_sync_queue.json'),
       _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestoreClient = firestoreClient ?? FirestoreClient() {
    _syncService =
        syncService ??
        SyncService(queue: _queue, firestoreClient: _firestoreClient);
  }

  final RtsRepositoryLocal _local;
  final SyncQueueLocal _queue;
  late final SyncService _syncService;
  final FirebaseAuth _firebaseAuth;
  final FirestoreClient _firestoreClient;

  @override
  Stream<List<RtsAssessment>> watchAll() => _local.watchAll();

  @override
  Future<void> upsert(RtsAssessment assessment) async {
    final now = DateTime.now();
    final updatedAtIso = now.toIso8601String();
    final normalized = assessment.copyWith(
      updatedAt: now,
      metadata: <String, dynamic>{
        ...assessment.metadata,
        'updatedAt': updatedAtIso,
        'clientUpdatedAt': updatedAtIso,
      },
    );

    await _local.upsert(normalized);

    final uid = _patientId;
    if (uid == null) return;

    try {
      final payload = <String, dynamic>{
        ...normalized.toJson(),
        'updatedAt': updatedAtIso,
        'clientUpdatedAt': updatedAtIso,
      };
      await _queue.enqueue(
        SyncOp(
          id: 'rts_upsert_${normalized.id}_${now.microsecondsSinceEpoch}',
          collectionPath: 'patients/$uid/rts_assessments',
          docId: normalized.id,
          type: SyncOpType.upsert,
          payload: payload,
          createdAt: now,
        ),
      );
      unawaited(_syncService.syncNow());
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[RtsRepositorySync] enqueue failed: $error');
        debugPrint('$stackTrace');
      }
    }
  }

  @override
  Future<void> delete(String id) async {
    final now = DateTime.now();

    // Soft-delete locally: mark entry with deletedAt instead of removing.
    final entries = await _local.watchAll().first;
    final existing = entries.where((e) => e.id == id).firstOrNull;
    if (existing != null) {
      await _local.upsert(existing.copyWith(deletedAt: now, updatedAt: now));
    }

    final uid = _patientId;
    if (uid == null) return;

    try {
      await _queue.enqueue(
        SyncOp(
          id: 'rts_delete_${id}_${now.microsecondsSinceEpoch}',
          collectionPath: 'patients/$uid/rts_assessments',
          docId: id,
          type: SyncOpType.upsert,
          payload: <String, dynamic>{
            'id': id,
            'deletedAt': now.toIso8601String(),
            'updatedAt': now.toIso8601String(),
          },
          createdAt: now,
        ),
      );
      unawaited(_syncService.syncNow());
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[RtsRepositorySync] delete enqueue failed: $error');
        debugPrint('$stackTrace');
      }
    }
  }

  @override
  Future<RtsAssessment?> getById(String id) => _local.getById(id);

  @override
  Future<void> loadFromDisk() => _local.loadFromDisk();

  @override
  Future<void> saveToDisk() => _local.saveToDisk();

  Future<void> pullLatest() async {
    final uid = _patientId;
    if (uid == null) return;

    try {
      final remoteDocs = await _firestoreClient.fetchCollectionDocs(
        'patients/$uid/rts_assessments',
      );
      if (remoteDocs.isEmpty) return;

      final localItems = await _local.watchAll().first;
      final localById = <String, RtsAssessment>{
        for (final item in localItems) item.id: item,
      };

      for (final remoteDoc in remoteDocs) {
        final remoteMap = <String, dynamic>{
          ...remoteDoc.data,
          'id': remoteDoc.id,
        };

        final remoteUpdatedAt = _readUpdatedAt(remoteMap);
        final local = localById[remoteDoc.id];
        final localUpdatedAt =
            local == null
                ? DateTime.fromMillisecondsSinceEpoch(0)
                : (_parseIso(local.metadata['clientUpdatedAt']?.toString()) ??
                      _parseIso(local.metadata['updatedAt']?.toString()) ??
                      local.updatedAt);

        if (local != null && !remoteUpdatedAt.isAfter(localUpdatedAt)) {
          continue;
        }

        final mergedMetadata = <String, dynamic>{
          ...(remoteMap['metadata'] is Map
              ? Map<String, dynamic>.from(remoteMap['metadata'] as Map)
              : const <String, dynamic>{}),
          if (remoteMap['updatedAt'] != null)
            'updatedAt': _remoteDateString(remoteMap['updatedAt']),
          if (remoteMap['clientUpdatedAt'] != null)
            'clientUpdatedAt': _remoteDateString(
              remoteMap['clientUpdatedAt'],
            ),
        };

        final item = RtsAssessment.fromJson(<String, dynamic>{
          ...remoteMap,
          'performedAt': _remoteDateString(remoteMap['performedAt']),
          'createdAt': _remoteDateString(remoteMap['createdAt']),
          'updatedAt': _remoteDateString(remoteMap['updatedAt']),
          'metadata': mergedMetadata,
        });

        await _local.upsert(item);
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[RtsRepositorySync] pullLatest failed: $error');
        debugPrint('$stackTrace');
      }
    }
  }

  String? get _patientId {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null || uid.trim().isEmpty) return null;
    return uid;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  DateTime _readUpdatedAt(Map<String, dynamic> map) {
    final raw = map['clientUpdatedAt'] ?? map['updatedAt'];
    return _parseIso(_remoteDateString(raw)) ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  static String? _remoteDateString(Object? v) {
    if (v == null) return null;
    if (v is String) return v;
    // Firestore Timestamp
    try {
      // ignore: avoid_dynamic_calls
      final ts = (v as dynamic);
      final seconds = ts.seconds as int?;
      if (seconds != null) {
        return DateTime.fromMillisecondsSinceEpoch(seconds * 1000).toIso8601String();
      }
    } catch (_) {}
    return v.toString();
  }

  static DateTime? _parseIso(String? s) {
    if (s == null) return null;
    try {
      return DateTime.parse(s);
    } catch (_) {
      return null;
    }
  }
}
