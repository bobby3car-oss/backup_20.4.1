import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../domain/packing_item.dart';
import 'packing_repository_local.dart';

class PackingRepositorySync {
  static final PackingRepositorySync instance =
      PackingRepositorySync._internal();

  factory PackingRepositorySync() => instance;

  PackingRepositorySync._internal({
    PackingRepositoryLocal? local,
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : _local = local ?? PackingRepositoryLocal.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  final PackingRepositoryLocal _local;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<List<PackingItem>> watchAll() => _local.watchAll();

  Future<void> loadFromDisk() => _local.loadFromDisk();

  // ── Hospital mode ──────────────────────────────────────────
  Future<HospitalMode?> getMode() => _local.getMode();
  Future<void> setMode(HospitalMode mode) => _local.setMode(mode);
  Future<void> clearMode() => _local.clearMode();

  Future<void> seedDefaultsIfEmpty(HospitalMode mode) async {
    final uid = _uid;
    if (uid == null) return;
    await _local.seedDefaultsIfEmpty(uid, mode);
  }

  /// Deletes all local + remote items and re-seeds with [mode].
  Future<void> resetAndReseed(HospitalMode mode) async {
    final uid = _uid;
    if (uid == null) return;
    // Delete all remote items
    try {
      final snapshot = await _collection(uid).get();
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[PackingRepositorySync] remote reset failed: $error');
      }
    }
    await _local.resetAndReseed(uid, mode);
  }

  Future<void> upsert(PackingItem item) async {
    final now = DateTime.now();
    final normalized = item.copyWith(
      updatedAt: now,
      metadata: <String, dynamic>{
        ...item.metadata,
        'clientUpdatedAt': now.toIso8601String(),
      },
    );
    await _local.upsert(normalized);

    final uid = _uid;
    if (uid == null) return;
    try {
      await _docRef(uid, normalized.id).set(<String, dynamic>{
        ...normalized.toJson(),
        'updatedAt': normalized.updatedAt.toIso8601String(),
      });
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[PackingRepositorySync] remote upsert failed: $error');
        debugPrint('$stackTrace');
      }
    }
  }

  Future<void> delete(String id) async {
    await _local.delete(id);

    final uid = _uid;
    if (uid == null) return;
    try {
      await _docRef(uid, id).delete();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[PackingRepositorySync] remote delete failed: $error');
        debugPrint('$stackTrace');
      }
    }
  }

  Future<void> pullLatest() async {
    final uid = _uid;
    if (uid == null) return;

    try {
      final snapshot = await _collection(uid).get();
      if (snapshot.docs.isEmpty) return;

      final local = await _local.watchAll().first;
      final localById = <String, PackingItem>{
        for (final item in local) item.id: item,
      };

      for (final doc in snapshot.docs) {
        final remote = <String, dynamic>{...doc.data(), 'id': doc.id};
        final remoteUpdatedAt =
            _parseRemoteDate(remote['updatedAt']) ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final localItem = localById[doc.id];
        final localUpdatedAt =
            localItem?.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        if (localItem != null && !remoteUpdatedAt.isAfter(localUpdatedAt)) {
          continue;
        }
        final merged = PackingItem.fromJson(<String, dynamic>{
          ...remote,
          'createdAt': _remoteDateString(remote['createdAt']),
          'updatedAt': _remoteDateString(remote['updatedAt']),
        });
        await _local.upsert(merged);
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[PackingRepositorySync] pullLatest failed: $error');
        debugPrint('$stackTrace');
      }
    }
  }

  String? get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.trim().isEmpty) return null;
    return uid;
  }

  CollectionReference<Map<String, dynamic>> _collection(String uid) {
    return _firestore.collection('patients/$uid/packing');
  }

  DocumentReference<Map<String, dynamic>> _docRef(String uid, String id) {
    return _collection(uid).doc(id);
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
}
