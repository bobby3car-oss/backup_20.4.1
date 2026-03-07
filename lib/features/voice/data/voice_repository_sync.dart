import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../../../sync/storage_upload_queue.dart';
import '../domain/voice_memo.dart';
import 'voice_repository_local.dart';

class VoiceRepositorySync {
  static final VoiceRepositorySync instance = VoiceRepositorySync._internal();

  factory VoiceRepositorySync() => instance;

  VoiceRepositorySync._internal({
    VoiceRepositoryLocal? local,
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  }) : _local = local ?? VoiceRepositoryLocal.instance,
       _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance;

  final VoiceRepositoryLocal _local;
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  Stream<List<VoiceMemo>> watchAll() => _local.watchAll();

  Future<String> recordingPathFor(String memoId) =>
      _local.recordingPathFor(memoId);

  Future<VoiceMemo?> getById(String id) => _local.getById(id);

  Future<void> loadFromDisk() => _local.loadFromDisk();

  Future<void> upsert(VoiceMemo memo) async {
    final now = DateTime.now();
    final localMemo = memo.copyWith(
      updatedAt: now,
      syncStatus: VoiceSyncStatus.pending,
      metadata: <String, dynamic>{
        ...memo.metadata,
        'clientUpdatedAt': now.toIso8601String(),
      },
    );
    await _local.upsert(localMemo);
    await _uploadAndSync(localMemo);
  }

  Future<void> updateTitle(VoiceMemo memo, String newTitle) async {
    final trimmed = newTitle.trim();
    if (trimmed.isEmpty) return;
    await upsert(memo.copyWith(title: trimmed));
  }

  Future<void> delete(VoiceMemo memo) async {
    await _local.delete(memo.id);
    await _local.deleteLocalAudioFile(memo.localFilePath);

    final uid = _patientId;
    if (uid == null) return;

    try {
      await _collection(uid).doc(memo.id).delete();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[VoiceRepositorySync] firestore delete failed: $error');
        debugPrint('$stackTrace');
      }
    }

    try {
      await _storageRef(uid, memo.id).delete();
    } catch (_) {
      // Ignore storage missing-file errors.
    }
  }

  Future<void> pullLatest() async {
    final uid = _patientId;
    if (uid == null) return;

    try {
      final snapshot = await _collection(uid).get();
      if (snapshot.docs.isEmpty) return;

      final localItems = await _local.watchAll().first;
      final localById = <String, VoiceMemo>{
        for (final item in localItems) item.id: item,
      };

      for (final doc in snapshot.docs) {
        final remote = <String, dynamic>{...doc.data(), 'id': doc.id};

        final remoteUpdatedAt =
            _parseRemoteDate(remote['updatedAt']) ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final local = localById[doc.id];
        final localUpdatedAt =
            local?.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        if (local != null && !remoteUpdatedAt.isAfter(localUpdatedAt)) {
          continue;
        }

        final merged = VoiceMemo.fromJson(<String, dynamic>{
          ...remote,
          'recordedAt': _toIso(remote['recordedAt']),
          'createdAt': _toIso(remote['createdAt']),
          'updatedAt': _toIso(remote['updatedAt']),
          'syncStatus': VoiceSyncStatus.synced.name,
          'localFilePath': local?.localFilePath ?? '',
        });
        await _local.upsert(merged);
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[VoiceRepositorySync] pullLatest failed: $error');
        debugPrint('$stackTrace');
      }
    }
  }

  Future<void> _uploadAndSync(VoiceMemo memo) async {
    final uid = _patientId;
    if (uid == null) return;

    try {
      String? downloadUrl = memo.remoteUrl;
      final file = File(memo.localFilePath);
      if (await file.exists()) {
        final upload = await _storageRef(
          uid,
          memo.id,
        ).putFile(file, SettableMetadata(contentType: 'audio/m4a'));
        downloadUrl = await upload.ref.getDownloadURL();
      }

      final synced = memo.copyWith(
        remoteUrl: downloadUrl,
        syncStatus: VoiceSyncStatus.synced,
        updatedAt: DateTime.now(),
      );

      await _collection(uid).doc(memo.id).set(<String, dynamic>{
        ...synced.toJson(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      await _local.upsert(synced);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[VoiceRepositorySync] upload/sync failed: $error');
        debugPrint('$stackTrace');
      }
      // Queue for retry when back online
      if (memo.localFilePath.isNotEmpty) {
        StorageUploadQueue.instance.enqueue(StorageUploadOp(
          id: 'voice_${memo.id}',
          localFilePath: memo.localFilePath,
          remoteStoragePath: 'patients/$uid/voice_memos/${memo.id}.m4a',
          contentType: 'audio/m4a',
          createdAt: DateTime.now(),
        ));
      }
      await _local.upsert(
        memo.copyWith(
          syncStatus: VoiceSyncStatus.failed,
          updatedAt: DateTime.now(),
        ),
      );
    }
  }

  String? get _patientId {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null || uid.trim().isEmpty) return null;
    return uid;
  }

  CollectionReference<Map<String, dynamic>> _collection(String uid) {
    return _firestore.collection('patients/$uid/voice_memos');
  }

  Reference _storageRef(String uid, String memoId) {
    return _storage.ref('patients/$uid/voice_memos/$memoId.m4a');
  }

  DateTime? _parseRemoteDate(Object? raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is String && raw.trim().isNotEmpty) return DateTime.tryParse(raw);
    return null;
  }

  String? _toIso(Object? raw) {
    if (raw == null) return null;
    if (raw is Timestamp) return raw.toDate().toIso8601String();
    return raw.toString();
  }
}
