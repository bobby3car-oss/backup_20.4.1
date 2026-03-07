import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../sync/firestore_client.dart';
import '../../../sync/sync_models.dart';
import '../../../sync/sync_queue_local.dart';
import '../../../sync/sync_service.dart';
import '../domain/medication_intake.dart';
import '../../gamification/gamification_service.dart';
import 'medication_repository.dart';
import 'medication_repository_local.dart';

class MedicationRepositorySync implements MedicationRepository {
  static final MedicationRepositorySync instance =
      MedicationRepositorySync._internal(
        firebaseAuth: _safeFirebaseAuth(),
      );

  factory MedicationRepositorySync() => instance;

  MedicationRepositorySync._internal({
    MedicationRepositoryLocal? local,
    SyncQueueLocal? queue,
    SyncService? syncService,
    FirebaseAuth? firebaseAuth,
    FirestoreClient? firestoreClient,
  }) : _local = local ?? MedicationRepositoryLocal.instance,
       _queue = queue ?? SyncQueueLocal(fileName: 'medication_sync_queue.json'),
       _firebaseAuth = firebaseAuth,
       _firestoreClient = firestoreClient ?? FirestoreClient() {
    _syncService =
        syncService ??
        SyncService(queue: _queue, firestoreClient: _firestoreClient);
  }

  final MedicationRepositoryLocal _local;
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
  Stream<List<MedicationIntake>> watchAll() => _local.watchAll();

  @override
  Future<void> upsert(MedicationIntake entry) async {
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

    // ── Gamification: record medication log ──
    if (_gamification != null) {
      unawaited(_gamification!.recordActivity(medication: true));
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
          id: 'med_upsert_${normalized.id}_${now.microsecondsSinceEpoch}',
          collectionPath: 'patients/$uid/medication_intakes',
          docId: normalized.id,
          type: SyncOpType.upsert,
          payload: payload,
          createdAt: now,
        ),
      );
      unawaited(_syncService.syncNow());
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[MedicationRepoSync] enqueue failed: $error');
        debugPrint('$stackTrace');
      }
    }
  }

  @override
  Future<void> delete(String id) async {
    await _local.delete(id);

    final uid = _patientId;
    if (uid == null) return;

    try {
      final now = DateTime.now();
      await _queue.enqueue(
        SyncOp(
          id: 'med_delete_${id}_${now.microsecondsSinceEpoch}',
          collectionPath: 'patients/$uid/medication_intakes',
          docId: id,
          type: SyncOpType.delete,
          payload: const <String, dynamic>{},
          createdAt: now,
        ),
      );
      unawaited(_syncService.syncNow());
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[MedicationRepoSync] delete enqueue failed: $error');
        debugPrint('$stackTrace');
      }
    }
  }

  @override
  Future<MedicationIntake?> getById(String id) => _local.getById(id);

  @override
  Future<void> loadFromDisk() => _local.loadFromDisk();

  @override
  Future<void> saveToDisk() => _local.saveToDisk();

  Future<void> pullLatest() async {
    final uid = _patientId;
    if (uid == null) return;

    try {
      final remoteDocs = await _firestoreClient.fetchCollectionDocs(
        'patients/$uid/medication_intakes',
      );
      if (remoteDocs.isEmpty) return;

      final localItems = await _local.watchAll().first;
      final localById = <String, MedicationIntake>{
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

        final item = MedicationIntake.fromJson(<String, dynamic>{
          ...remoteMap,
          'takenAt': _remoteDateString(remoteMap['takenAt']),
          'createdAt': _remoteDateString(remoteMap['createdAt']),
          'updatedAt': _remoteDateString(remoteMap['updatedAt']),
          if (remoteMap['deletedAt'] != null)
            'deletedAt': _remoteDateString(remoteMap['deletedAt']),
          'metadata': mergedMetadata,
        });

        await _local.upsert(item);
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[MedicationRepoSync] pullLatest failed: $error');
        debugPrint('$stackTrace');
      }
    }
  }

  String? get _patientId {
    final uid = _firebaseAuth?.currentUser?.uid;
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
