import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../domain/timeline_engine.dart';
import '../sync/sync_models.dart';
import '../sync/sync_queue_local.dart';
import '../sync/sync_service.dart';
import '../sync/firestore_client.dart';
import 'firebase_paths.dart';

/// Cloud-synced timeline repository.
///
/// Offline-first: writes go to local queue first, then flush to Firestore.
/// Reads come from Firestore real-time stream with a local fallback.
class TimelineRepository {
  TimelineRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirestoreClient? firestoreClient,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance {
    final client = firestoreClient ?? FirestoreClient();
    _syncQueue = SyncQueueLocal(fileName: 'timeline_sync_queue.json');
    _syncService = SyncService(
      queue: _syncQueue,
      firestoreClient: client,
    );
  }

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  late final SyncQueueLocal _syncQueue;
  late final SyncService _syncService;

  String? get _uid => _auth.currentUser?.uid;

  /// Real-time stream of all timeline items for the given patient,
  /// optionally filtered by date range.
  Stream<List<TimelineItem>> watchTimeline(
    String patientId, {
    DateTime? from,
    DateTime? to,
  }) {
    Query<Map<String, dynamic>> query = _firestore
        .collection(FirestorePaths.timelineCollection(patientId))
        .orderBy('scheduledAt');

    if (from != null) {
      query = query.where('scheduledAt',
          isGreaterThanOrEqualTo: from.toIso8601String());
    }
    if (to != null) {
      query = query.where('scheduledAt',
          isLessThanOrEqualTo: to.toIso8601String());
    }

    return query.snapshots().map((snapshot) {
      final now = DateTime.now();
      final items = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        final item = TimelineItem.fromJson(data);
        final nextState = computeState(item, now);
        if (nextState != item.state) {
          return item.copyWith(state: nextState);
        }
        return item;
      }).toList();
      return sortItems(items);
    });
  }

  /// Upserts a timeline item to Firestore (offline-first via sync queue).
  Future<void> upsertItem(TimelineItem item) async {
    final uid = _uid;
    if (uid == null) return;

    final now = DateTime.now();
    final updated = item.copyWith(updatedAt: now);
    final payload = updated.toJson();
    payload['ownerId'] = uid;
    payload['clientUpdatedAt'] = now.toIso8601String();

    final collectionPath = FirestorePaths.timelineCollection(uid);

    await _syncQueue.enqueue(SyncOp(
      id: 'timeline_${updated.id}',
      collectionPath: collectionPath,
      docId: updated.id,
      type: SyncOpType.upsert,
      payload: payload,
      createdAt: now,
    ));

    // Attempt immediate flush.
    unawaited(_syncService.syncNow());
  }

  /// Sets the state of a timeline item.
  Future<void> setItemState(String itemId, TaskState state) async {
    final uid = _uid;
    if (uid == null) return;

    final now = DateTime.now();
    final payload = <String, dynamic>{
      'state': state.name,
      'updatedAt': now.toIso8601String(),
      'clientUpdatedAt': now.toIso8601String(),
      'ownerId': uid,
    };

    if (state == TaskState.done) {
      payload['doneAt'] = now.toIso8601String();
      payload['skippedAt'] = null;
    } else if (state == TaskState.skipped) {
      payload['skippedAt'] = now.toIso8601String();
      payload['doneAt'] = null;
    } else {
      payload['doneAt'] = null;
      payload['skippedAt'] = null;
    }

    final collectionPath = FirestorePaths.timelineCollection(uid);

    await _syncQueue.enqueue(SyncOp(
      id: 'timeline_state_${itemId}_${now.millisecondsSinceEpoch}',
      collectionPath: collectionPath,
      docId: itemId,
      type: SyncOpType.upsert,
      payload: payload,
      createdAt: now,
    ));

    unawaited(_syncService.syncNow());
  }

  /// Deletes a timeline item from Firestore (offline-first via sync queue).
  Future<void> deleteItem(String itemId) async {
    final uid = _uid;
    if (uid == null) return;

    final now = DateTime.now();
    final collectionPath = FirestorePaths.timelineCollection(uid);

    await _syncQueue.enqueue(SyncOp(
      id: 'timeline_delete_${itemId}_${now.millisecondsSinceEpoch}',
      collectionPath: collectionPath,
      docId: itemId,
      type: SyncOpType.delete,
      payload: const <String, dynamic>{},
      createdAt: now,
    ));

    unawaited(_syncService.syncNow());
  }

  /// Uploads all local timeline items to Firestore (one-time migration).
  ///
  /// Firestore batches are limited to 500 operations, so items are
  /// split into chunks.
  Future<void> migrateLocalItems(List<TimelineItem> items) async {
    final uid = _uid;
    if (uid == null) return;

    final collectionPath = FirestorePaths.timelineCollection(uid);
    const batchLimit = 499; // leave headroom

    for (var start = 0; start < items.length; start += batchLimit) {
      final end = (start + batchLimit < items.length)
          ? start + batchLimit
          : items.length;
      final chunk = items.sublist(start, end);

      final batch = _firestore.batch();
      for (final item in chunk) {
        final docRef = _firestore.collection(collectionPath).doc(item.id);
        final payload = item.toJson();
        payload['ownerId'] = uid;
        payload['clientUpdatedAt'] = item.updatedAt.toIso8601String();
        batch.set(docRef, payload, SetOptions(merge: true));
      }
      await batch.commit();
    }

    if (kDebugMode) {
      debugPrint(
          '[TimelineRepository] Migrated ${items.length} items to Firestore');
    }
  }

  /// Flushes any pending sync operations.
  Future<void> syncPending() async {
    await _syncService.syncNow();
  }
}
