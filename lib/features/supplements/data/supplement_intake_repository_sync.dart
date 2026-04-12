import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../sync/firestore_client.dart';
import '../../../sync/sync_models.dart';
import '../../../sync/sync_queue_local.dart';
import '../../../sync/sync_service.dart';
import '../domain/supplement_intake.dart';
import '../../gamification/domain/badge_rules.dart';
import '../../gamification/gamification_service.dart';
import 'supplement_intake_repository.dart';
import 'supplement_intake_repository_local.dart';

class SupplementIntakeRepositorySync implements SupplementIntakeRepository {
  static final SupplementIntakeRepositorySync instance =
      SupplementIntakeRepositorySync._internal();

  factory SupplementIntakeRepositorySync() => instance;

  SupplementIntakeRepositorySync._internal({
    SupplementIntakeRepositoryLocal? local,
    SyncQueueLocal? queue,
    SyncService? syncService,
    FirebaseAuth? firebaseAuth,
    FirestoreClient? firestoreClient,
  })  : _local = local ?? SupplementIntakeRepositoryLocal.instance,
        _queue =
            queue ?? SyncQueueLocal(fileName: 'supplement_intake_sync_queue.json'),
        _firebaseAuth = firebaseAuth ?? _safeFirebaseAuth(),
        _firestoreClient = firestoreClient ?? FirestoreClient() {
    _syncService =
        syncService ??
        SyncService(queue: _queue, firestoreClient: _firestoreClient);
  }

  final SupplementIntakeRepositoryLocal _local;
  final SyncQueueLocal _queue;
  late final SyncService _syncService;
  final FirebaseAuth? _firebaseAuth;
  final FirestoreClient _firestoreClient;

  static FirebaseAuth? _safeFirebaseAuth() {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  // ── Gamification hook ──
  static GamificationService? _gamification;
  static set gamificationService(GamificationService? s) => _gamification = s;

  @override
  Stream<List<SupplementIntake>> watchAll() => _local.watchAll();

  @override
  Future<void> upsert(SupplementIntake entry) async {
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

    // ── Gamification: record supplement log ──
    if (_gamification != null) {
      final allIntakes = await _local.watchAll().first;
      unawaited(
        _gamification!.recordActivity(
          supplement: true,
          activityCounts: ActivityCounts(
            totalSupplementEntries: allIntakes.length,
          ),
        ),
      );
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
          id: 'supplement_upsert_${normalized.id}_${now.microsecondsSinceEpoch}',
          collectionPath: 'patients/$uid/supplement_intakes',
          docId: normalized.id,
          type: SyncOpType.upsert,
          payload: payload,
          createdAt: now,
        ),
      );
      unawaited(_syncService.syncNow());
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[SupplementIntakeRepoSync] enqueue failed: $error');
        debugPrint('$stackTrace');
      }
    }
  }

  @override
  Future<void> delete(String id) async {
    // Soft-delete: mark deletedAt to prevent data loss on sync failure.
    final existing = await _local.getById(id);
    if (existing != null) {
      final now = DateTime.now();
      final softDeleted = existing.copyWith(deletedAt: now, updatedAt: now);
      await _local.upsert(softDeleted);
    } else {
      await _local.delete(id);
    }

    final uid = _patientId;
    if (uid == null) return;

    try {
      final now = DateTime.now();
      await _queue.enqueue(
        SyncOp(
          id: 'supplement_delete_${id}_${now.microsecondsSinceEpoch}',
          collectionPath: 'patients/$uid/supplement_intakes',
          docId: id,
          type: SyncOpType.delete,
          payload: const <String, dynamic>{},
          createdAt: now,
        ),
      );
      unawaited(_syncService.syncNow());
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[SupplementIntakeRepoSync] delete enqueue failed: $error');
        debugPrint('$stackTrace');
      }
    }
  }

  @override
  Future<SupplementIntake?> getById(String id) => _local.getById(id);

  @override
  Future<void> loadFromDisk() => _local.loadFromDisk();

  @override
  Future<void> saveToDisk() => _local.saveToDisk();

  Future<void> pullLatest() async {
    final uid = _patientId;
    if (uid == null) return;

    try {
      final remoteDocs = await _firestoreClient.fetchCollectionDocs(
        'patients/$uid/supplement_intakes',
      );
      if (remoteDocs.isEmpty) return;

      final localItems = await _local.watchAll().first;
      final localById = <String, SupplementIntake>{
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
            'clientUpdatedAt':
                _remoteDateString(remoteMap['clientUpdatedAt']),
        };

        final item = SupplementIntake.fromJson(<String, dynamic>{
          ...remoteMap,
          'takenAt': _remoteDateString(remoteMap['takenAt']),
          'createdAt': _remoteDateString(remoteMap['createdAt']),
          'updatedAt': _remoteDateString(remoteMap['updatedAt']),
          'metadata': mergedMetadata,
        });

        await _local.upsert(item);
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[SupplementIntakeRepoSync] pullLatest failed: $error');
        debugPrint('$stackTrace');
      }
    }
  }

  String? get _patientId {
    final uid = _firebaseAuth?.currentUser?.uid;
    if (uid == null || uid.trim().isEmpty) return null;
    return uid;
  }

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

