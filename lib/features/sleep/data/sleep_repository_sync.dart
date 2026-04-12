import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../sync/firestore_client.dart';
import '../../../sync/sync_models.dart';
import '../../../sync/sync_queue_local.dart';
import '../../../sync/sync_service.dart';
import '../domain/sleep_entry.dart';
import '../../gamification/gamification_service.dart';
import 'sleep_repository.dart';
import 'sleep_repository_local.dart';

class SleepRepositorySync implements SleepRepository {
  static final SleepRepositorySync instance = SleepRepositorySync._internal();

  factory SleepRepositorySync() => instance;

  SleepRepositorySync._internal({
    SleepRepositoryLocal? local,
    SyncQueueLocal? queue,
    SyncService? syncService,
    FirebaseAuth? firebaseAuth,
    FirestoreClient? firestoreClient,
  }) : _local = local ?? SleepRepositoryLocal.instance,
       _queue = queue ?? SyncQueueLocal(fileName: 'sleep_sync_queue.json'),
       _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestoreClient = firestoreClient ?? FirestoreClient() {
    _syncService =
        syncService ??
        SyncService(queue: _queue, firestoreClient: _firestoreClient);
  }

  final SleepRepositoryLocal _local;
  final SyncQueueLocal _queue;
  late final SyncService _syncService;
  final FirebaseAuth _firebaseAuth;
  final FirestoreClient _firestoreClient;

  // ── Gamification hook ──
  static GamificationService? _gamification;
  static set gamificationService(GamificationService? s) => _gamification = s;

  @override
  Stream<List<SleepEntry>> watchAll() => _local.watchAll();

  @override
  Future<void> upsert(SleepEntry entry) async {
    final now = DateTime.now();
    final updatedAtIso = now.toIso8601String();
    final normalized = entry.copyWith(
      updatedAt: now,
      metadata: <String, dynamic>{
        ...entry.metadata,
        'updatedAt': updatedAtIso,
        'clientUpdatedAt': updatedAtIso,
      },
    );

    // Offline-first: local write happens first.
    await _local.upsert(normalized);

    // ── Gamification: record sleep log ──
    if (_gamification != null) {
      unawaited(_gamification!.recordActivity(sleep: true));
    }

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
          id: 'sleep_upsert_${normalized.id}_${now.microsecondsSinceEpoch}',
          collectionPath: 'patients/$uid/sleep_entries',
          docId: normalized.id,
          type: SyncOpType.upsert,
          payload: payload,
          createdAt: now,
        ),
      );
      unawaited(_syncService.syncNow());
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[SleepRepositorySync] enqueue failed: $error');
        debugPrint('$stackTrace');
      }
    }
  }

  @override
  Future<void> delete(String id) async {
    // Soft-delete: mark entry as deleted locally so it stays hidden even if
    // pullLatest runs before the remote delete completes.
    final existing = await _local.getById(id);
    if (existing != null) {
      final now = DateTime.now();
      await _local.upsert(
        existing.copyWith(deletedAt: now, updatedAt: now),
      );
    } else {
      await _local.delete(id);
    }

    final uid = _patientId;
    if (uid == null) return;

    try {
      final now = DateTime.now();
      await _queue.enqueue(
        SyncOp(
          id: 'sleep_delete_${id}_${now.microsecondsSinceEpoch}',
          collectionPath: 'patients/$uid/sleep_entries',
          docId: id,
          type: SyncOpType.delete,
          payload: const <String, dynamic>{},
          createdAt: now,
        ),
      );
      unawaited(_syncService.syncNow());
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[SleepRepositorySync] delete enqueue failed: $error');
        debugPrint('$stackTrace');
      }
    }
  }

  @override
  Future<SleepEntry?> getById(String id) => _local.getById(id);

  @override
  Future<void> loadFromDisk() => _local.loadFromDisk();

  @override
  Future<void> saveToDisk() => _local.saveToDisk();

  Future<void> pullLatest() async {
    final uid = _patientId;
    if (uid == null) return;

    try {
      final remoteDocs = await _firestoreClient.fetchCollectionDocs(
        'patients/$uid/sleep_entries',
      );
      if (remoteDocs.isEmpty) return;

      final localItems = await _local.watchAll().first;
      final localById = <String, SleepEntry>{
        for (final item in localItems) item.id: item,
      };

      for (final remoteDoc in remoteDocs) {
        final remoteMap = <String, dynamic>{
          ...remoteDoc.data,
          'id': remoteDoc.id,
        };

        final remoteUpdatedAt = _readUpdatedAt(remoteMap);
        final local = localById[remoteDoc.id];
        final localUpdatedAt = local == null
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
            'clientUpdatedAt': _remoteDateString(remoteMap['clientUpdatedAt']),
        };

        final item = SleepEntry.fromJson(<String, dynamic>{
          ...remoteMap,
          'bedTime': _remoteDateString(remoteMap['bedTime']),
          'wakeTime': _remoteDateString(remoteMap['wakeTime']),
          'createdAt': _remoteDateString(remoteMap['createdAt']),
          'updatedAt': _remoteDateString(remoteMap['updatedAt']),
          'deletedAt': _remoteDateString(remoteMap['deletedAt']),
          'metadata': mergedMetadata,
        });

        await _local.upsert(item);
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[SleepRepositorySync] pullLatest failed: $error');
        debugPrint('$stackTrace');
      }
    }
  }

  String? get _patientId {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null || uid.trim().isEmpty) return null;
    return uid;
  }

  /// Flush the sync queue. Called by [ConnectivityService] on reconnect.
  Future<void> syncNow() => _syncService.syncNow();

  DateTime _readUpdatedAt(Map<String, dynamic> data) {
    return _parseRemoteDate(data['clientUpdatedAt']) ??
        _parseRemoteDate(data['updatedAt']) ??
        _parseRemoteDate(data['createdAt']) ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

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

  DateTime? _parseIso(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
