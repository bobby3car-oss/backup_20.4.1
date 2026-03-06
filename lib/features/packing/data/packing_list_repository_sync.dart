import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../domain/packing_item.dart';
import '../domain/packing_list.dart';
import 'packing_list_repository_local.dart';

/// Syncs [PackingList]s and their [PackingItem]s between local storage and
/// Firestore.
///
/// Firestore paths:
///   Lists → `patients/{uid}/packing_lists/{listId}`
///   Items → `patients/{uid}/packing_lists/{listId}/items/{itemId}`
class PackingListRepositorySync {
  static final PackingListRepositorySync instance =
      PackingListRepositorySync._internal();

  factory PackingListRepositorySync() => instance;

  PackingListRepositorySync._internal({
    PackingListRepositoryLocal? local,
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _local = local ?? PackingListRepositoryLocal.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final PackingListRepositoryLocal _local;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  // ── Delegated local methods ────────────────────────────────

  Stream<List<PackingList>> watchLists() => _local.watchLists();
  List<PackingList> get currentLists => _local.currentLists;

  Stream<List<PackingItem>> watchItems(String listId) =>
      _local.watchItems(listId);
  List<PackingItem> getItems(String listId) => _local.getItems(listId);

  Future<void> loadFromDisk() => _local.loadFromDisk();

  Future<HospitalMode?> getMode() => _local.getMode();
  Future<void> setMode(HospitalMode mode) => _local.setMode(mode);
  Future<void> clearMode() => _local.clearMode();

  // ── Bootstrap ──────────────────────────────────────────────

  Future<void> bootstrap() async {
    await _local.loadFromDisk();
    final uid = _uid;
    if (uid == null) return;
    await _local.migrateFromV1(uid);
    await pullLatest();
  }

  // ── Lists ──────────────────────────────────────────────────

  Future<PackingList> createListWithDefaults({
    required String title,
    required PackingListType type,
    HospitalMode? mode,
    String? icon,
  }) async {
    final uid = _uid;
    if (uid == null) throw StateError('Not signed in');

    final list = await _local.createListWithDefaults(
      ownerId: uid,
      title: title,
      type: type,
      mode: mode,
      icon: icon,
    );

    // Push list doc.
    try {
      await _listDoc(uid, list.id).set(list.toJson());
      // Push seed items.
      final items = _local.getItems(list.id);
      final batch = _firestore.batch();
      for (final item in items) {
        batch.set(_itemDoc(uid, list.id, item.id), item.toJson());
      }
      await batch.commit();
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[PackingListSync] remote create failed: $error');
      }
    }

    return list;
  }

  Future<void> upsertList(PackingList list) async {
    final updated = list.copyWith(updatedAt: DateTime.now());
    await _local.upsertList(updated);

    final uid = _uid;
    if (uid == null) return;
    try {
      await _listDoc(uid, updated.id).set(updated.toJson());
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[PackingListSync] remote upsert list failed: $error');
      }
    }
  }

  Future<void> deleteList(String listId) async {
    // Delete items first.
    final items = _local.getItems(listId);
    await _local.deleteList(listId);

    final uid = _uid;
    if (uid == null) return;
    try {
      final batch = _firestore.batch();
      for (final item in items) {
        batch.delete(_itemDoc(uid, listId, item.id));
      }
      batch.delete(_listDoc(uid, listId));
      await batch.commit();
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[PackingListSync] remote delete list failed: $error');
      }
    }
  }

  Future<void> archiveList(String listId) async {
    await _local.archiveList(listId);
    final list = await _local.getListById(listId);
    if (list == null) return;

    final uid = _uid;
    if (uid == null) return;
    try {
      await _listDoc(uid, listId).update(<String, dynamic>{
        'archivedAt': list.archivedAt?.toIso8601String(),
        'updatedAt': list.updatedAt.toIso8601String(),
      });
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[PackingListSync] remote archive failed: $error');
      }
    }
  }

  // ── Items ──────────────────────────────────────────────────

  Future<void> upsertItem(PackingItem item) async {
    final now = DateTime.now();
    final normalized = item.copyWith(
      updatedAt: now,
      metadata: <String, dynamic>{
        ...item.metadata,
        'clientUpdatedAt': now.toIso8601String(),
      },
    );
    await _local.upsertItem(normalized);

    final uid = _uid;
    final listId = normalized.listId;
    if (uid == null || listId == null) return;
    try {
      await _itemDoc(uid, listId, normalized.id).set(normalized.toJson());
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[PackingListSync] remote upsert item failed: $error');
      }
    }
  }

  Future<void> deleteItem(String listId, String itemId) async {
    await _local.deleteItem(listId, itemId);

    final uid = _uid;
    if (uid == null) return;
    try {
      await _itemDoc(uid, listId, itemId).delete();
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[PackingListSync] remote delete item failed: $error');
      }
    }
  }

  Future<void> toggleItem(
      String listId, PackingItem item, bool value) async {
    final uid = _uid;
    await _local.toggleItem(listId, item, value, byUid: uid);
    final items = _local.getItems(listId);
    final updated = items.firstWhere((i) => i.id == item.id,
        orElse: () => item);

    if (uid == null || item.listId == null) return;
    try {
      await _itemDoc(uid, listId, item.id).set(updated.toJson());
      // Also update list counters remotely.
      final list = await _local.getListById(listId);
      if (list != null) {
        await _listDoc(uid, listId).update(<String, dynamic>{
          'checkedCount': list.checkedCount,
          'itemCount': list.itemCount,
          'updatedAt': list.updatedAt.toIso8601String(),
        });
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[PackingListSync] remote toggle failed: $error');
      }
    }
  }

  // ── Pull ───────────────────────────────────────────────────

  Future<void> pullLatest() async {
    final uid = _uid;
    if (uid == null) return;

    try {
      final listsSnap = await _listsCollection(uid).get();
      for (final doc in listsSnap.docs) {
        final remote = <String, dynamic>{...doc.data(), 'id': doc.id};
        final remoteList = PackingList.fromJson(remote);
        final localList = await _local.getListById(doc.id);
        if (localList != null &&
            !remoteList.updatedAt.isAfter(localList.updatedAt)) {
          continue;
        }
        await _local.upsertList(remoteList);

        // Pull items for this list.
        final itemsSnap = await _itemsCollection(uid, doc.id).get();
        for (final itemDoc in itemsSnap.docs) {
          final remoteItem = <String, dynamic>{
            ...itemDoc.data(),
            'id': itemDoc.id,
          };
          await _local.upsertItem(PackingItem.fromJson(remoteItem));
        }
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[PackingListSync] pullLatest failed: $error');
        debugPrint('$stackTrace');
      }
    }
  }

  // ── Firestore references ───────────────────────────────────

  String? get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.trim().isEmpty) return null;
    return uid;
  }

  CollectionReference<Map<String, dynamic>> _listsCollection(String uid) =>
      _firestore.collection('patients/$uid/packing_lists');

  DocumentReference<Map<String, dynamic>> _listDoc(
          String uid, String listId) =>
      _listsCollection(uid).doc(listId);

  CollectionReference<Map<String, dynamic>> _itemsCollection(
          String uid, String listId) =>
      _firestore.collection('patients/$uid/packing_lists/$listId/items');

  DocumentReference<Map<String, dynamic>> _itemDoc(
          String uid, String listId, String itemId) =>
      _itemsCollection(uid, listId).doc(itemId);
}
