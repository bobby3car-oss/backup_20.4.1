import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../sync/firestore_client.dart';
import '../../../sync/sync_models.dart';
import '../../../sync/sync_queue_local.dart';
import '../../../sync/sync_service.dart';
import '../domain/wound_entry.dart';
import '../../gamification/gamification_service.dart';
import 'wound_repository.dart';
import 'wound_repository_local.dart';

class WoundRepositorySync implements WoundRepository {
  static final WoundRepositorySync instance = WoundRepositorySync._internal();

  factory WoundRepositorySync() => instance;

  WoundRepositorySync._internal({
    WoundRepositoryLocal? local,
    SyncQueueLocal? queue,
    SyncService? syncService,
    FirebaseAuth? firebaseAuth,
    FirestoreClient? firestoreClient,
  }) : _local = local ?? WoundRepositoryLocal.instance,
       _queue = queue ?? SyncQueueLocal(fileName: 'wound_sync_queue.json'),
       _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestoreClient = firestoreClient ?? FirestoreClient() {
    _syncService =
        syncService ??
        SyncService(queue: _queue, firestoreClient: _firestoreClient);
    if (!_initialPullTriggered) {
      _initialPullTriggered = true;
      unawaited(pullLatest());
    }
  }

  final WoundRepositoryLocal _local;
  final SyncQueueLocal _queue;
  late final SyncService _syncService;
  final FirebaseAuth _firebaseAuth;
  final FirestoreClient _firestoreClient;
  bool _initialPullTriggered = false;

  // ── Gamification hook ──
  static GamificationService? _gamification;
  static set gamificationService(GamificationService? s) => _gamification = s;

  @override
  Stream<List<WoundEntry>> watchAll() => _local.watchAll();

  @override
  Future<void> upsert(WoundEntry entry) async {
    final now = DateTime.now();
    final updatedAtIso = now.toIso8601String();
    final localEntry = entry.copyWith(
      metadata: <String, dynamic>{
        ...entry.metadata,
        'updatedAt': updatedAtIso,
        'clientUpdatedAt': updatedAtIso,
      },
    );
    await _local.upsert(localEntry);

    // ── Gamification: record wound photo ──
    if (_gamification != null) {
      unawaited(_gamification!.recordActivity(wound: true));
    }

    try {
      final patientId = _patientId;
      if (patientId == null) return;
      final payload = <String, dynamic>{
        ...localEntry.toJson(),
        'updatedAt': updatedAtIso,
        'clientUpdatedAt': updatedAtIso,
      };

      await _queue.enqueue(
        SyncOp(
          id: 'wound_upsert_${localEntry.id}_${now.microsecondsSinceEpoch}',
          collectionPath: 'patients/$patientId/wounds',
          docId: localEntry.id,
          type: SyncOpType.upsert,
          payload: payload,
          createdAt: now,
        ),
      );
      unawaited(_syncService.syncNow());
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[WoundRepositorySync] upsert enqueue failed: $error');
        debugPrint('$stackTrace');
      }
    }
  }

  @override
  Future<void> delete(String id) async {
    await _local.delete(id);

    try {
      final now = DateTime.now();
      final patientId = _patientId;
      if (patientId == null) return;
      await _queue.enqueue(
        SyncOp(
          id: 'wound_delete_${id}_${now.microsecondsSinceEpoch}',
          collectionPath: 'patients/$patientId/wounds',
          docId: id,
          type: SyncOpType.delete,
          payload: const <String, dynamic>{},
          createdAt: now,
        ),
      );
      unawaited(_syncService.syncNow());
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[WoundRepositorySync] delete enqueue failed: $error');
        debugPrint('$stackTrace');
      }
    }
  }

  @override
  Future<void> loadFromDisk() => _local.loadFromDisk();

  @override
  Future<void> saveToDisk() => _local.saveToDisk();

  Future<void> pullLatest({int? limit}) async {
    final patientId = _patientId;
    if (patientId == null) {
      return;
    }

    try {
      final remoteDocs = await _firestoreClient.fetchCollectionDocs(
        'patients/$patientId/wounds',
        limit: limit,
      );
      if (remoteDocs.isEmpty) return;

      final localEntries = await _local.watchAll().first;
      final localById = <String, WoundEntry>{
        for (final entry in localEntries) entry.id: entry,
      };

      for (final remoteDoc in remoteDocs) {
        final remoteData = <String, dynamic>{
          ...remoteDoc.data,
          'id': remoteDoc.id,
        };
        final remoteUpdatedAt = _readUpdatedAt(remoteData);
        final localEntry = localById[remoteDoc.id];
        final localUpdatedAt = _entryUpdatedAt(localEntry);

        if (localEntry != null && !remoteUpdatedAt.isAfter(localUpdatedAt)) {
          continue;
        }

        final mergedMetadata = <String, dynamic>{
          ...(remoteData['metadata'] is Map
              ? Map<String, dynamic>.from(remoteData['metadata'] as Map)
              : const <String, dynamic>{}),
          if (remoteData['updatedAt'] != null)
            'updatedAt': remoteData['updatedAt'].toString(),
          if (remoteData['clientUpdatedAt'] != null)
            'clientUpdatedAt': remoteData['clientUpdatedAt'].toString(),
        };

        final remoteEntry = WoundEntry.fromJson(<String, dynamic>{
          ...remoteData,
          'metadata': mergedMetadata,
        });
        await _local.upsert(remoteEntry);
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[WoundRepositorySync] pullLatest failed: $error');
        debugPrint('$stackTrace');
      }
    }
  }

  String? get _patientId {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null || uid.trim().isEmpty) return null;
    return uid;
  }

  DateTime _entryUpdatedAt(WoundEntry? entry) {
    if (entry == null) return DateTime.fromMillisecondsSinceEpoch(0);
    return _parseIso(entry.metadata['clientUpdatedAt']?.toString()) ??
        _parseIso(entry.metadata['updatedAt']?.toString()) ??
        entry.createdAt;
  }

  DateTime _readUpdatedAt(Map<String, dynamic> data) {
    return _parseIso(data['clientUpdatedAt']?.toString()) ??
        _parseIso(data['updatedAt']?.toString()) ??
        _parseIso(data['createdAt']?.toString()) ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  DateTime? _parseIso(String? iso) {
    if (iso == null || iso.trim().isEmpty) return null;
    return DateTime.tryParse(iso);
  }
}
