import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../sync/firestore_client.dart';
import '../../../sync/sync_models.dart';
import '../../../sync/sync_queue_local.dart';
import '../../../sync/sync_service.dart';
import '../domain/symptom_check_result.dart';
import 'symptom_check_repository_local.dart';

/// Sync layer for symptom check results.
///
/// Persists locally **and** to `patients/{uid}/symptom_checks/{id}` in Firestore.
class SymptomCheckRepositorySync {
  static final SymptomCheckRepositorySync instance =
      SymptomCheckRepositorySync._internal();

  factory SymptomCheckRepositorySync() => instance;

  SymptomCheckRepositorySync._internal({
    SymptomCheckRepositoryLocal? local,
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    SyncQueueLocal? queue,
    SyncService? syncService,
    FirestoreClient? firestoreClient,
  }) : _local = local ?? SymptomCheckRepositoryLocal.instance,
       _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _queue = queue ??
           SyncQueueLocal(fileName: 'symptom_checks_sync_queue.json'),
       _firestoreClient = firestoreClient ?? FirestoreClient() {
    _syncService =
        syncService ??
        SyncService(queue: _queue, firestoreClient: _firestoreClient);
  }

  final SymptomCheckRepositoryLocal _local;
  final FirebaseAuth _firebaseAuth;
  // ignore: unused_field
  final FirebaseFirestore _firestore;
  final SyncQueueLocal _queue;
  late final SyncService _syncService;
  // ignore: unused_field
  final FirestoreClient _firestoreClient;

  // ── Public API ────────────────────────────────────────────────────────

  Stream<List<SymptomCheckResult>> watchAll() => _local.watchAll();

  List<SymptomCheckResult> get cached => _local.cached;

  SymptomCheckResult? get latest => _local.latest;

  Future<void> loadFromDisk() => _local.loadFromDisk();

  Future<void> add(SymptomCheckResult result) async {
    await _local.add(result);

    final uid = _uid;
    if (uid == null) return;

    try {
      final now = DateTime.now();
      final payload = <String, dynamic>{
        ...result.toJson(),
        'ownerId': uid,
        'clientUpdatedAt': now.toIso8601String(),
      };
      await _queue.enqueue(
        SyncOp(
          id: 'symptom_check_${result.id}_${now.microsecondsSinceEpoch}',
          collectionPath: 'patients/$uid/symptom_checks',
          docId: result.id,
          type: SyncOpType.upsert,
          payload: payload,
          createdAt: now,
        ),
      );
      unawaited(_syncService.syncNow());
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '[SymptomCheckRepositorySync] enqueue failed: $error',
        );
        debugPrint('$stackTrace');
      }
    }
  }

  String? get _uid {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null || uid.trim().isEmpty) return null;
    return uid;
  }
}
