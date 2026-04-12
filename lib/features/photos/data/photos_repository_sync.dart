import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../../../firebase/firebase_paths.dart';
import '../../../sync/storage_upload_queue.dart';
import '../domain/photo_entry.dart';
import 'photos_repository_local.dart';

class PhotosRepositorySync {
  static final PhotosRepositorySync instance = PhotosRepositorySync._internal();

  factory PhotosRepositorySync() => instance;

  PhotosRepositorySync._internal({
    PhotosRepositoryLocal? local,
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  }) : _local = local ?? PhotosRepositoryLocal.instance,
       _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance {
    if (!_initialLoadDone) {
      _initialLoadDone = true;
      loadFromDisk();
      pullLatest();
    }
  }

  final PhotosRepositoryLocal _local;
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  bool _initialLoadDone = false;

  Stream<List<PhotoEntry>> watchAll() => _local.watchAll();

  Future<void> loadFromDisk() => _local.loadFromDisk();

  Future<void> createFromPickedFile({
    required PhotoCategory category,
    required String sourcePath,
    String note = '',
  }) async {
    final uid = _patientId;
    if (uid == null) {
      throw Exception('Nicht eingeloggt.');
    }
    final now = DateTime.now();
    final photoId = PhotoEntry.generateId(now);
    final localPath = await _local.storeImageFromPath(sourcePath, photoId);
    final entry = PhotoEntry(
      id: photoId,
      ownerId: uid,
      category: category,
      createdAt: now,
      updatedAt: now,
      note: note.trim(),
      localPath: localPath,
      status: PhotoStatus.pending,
    );
    await upsert(entry);
  }

  Future<void> upsert(PhotoEntry entry) async {
    final now = DateTime.now();
    final localEntry = entry.copyWith(
      updatedAt: now,
      status: PhotoStatus.pending,
    );
    await _local.upsert(localEntry);
    await _syncEntry(localEntry);
  }

  Future<void> retryPending() async {
    final items = await _local.watchAll().first;
    for (final item in items.where((e) => e.status == PhotoStatus.pending)) {
      await _syncEntry(item);
    }
  }

  Future<void> pullLatest({int limit = 150}) async {
    final uid = _patientId;
    if (uid == null) return;

    try {
      final snapshot = await _collection(uid).limit(limit).get();
      if (snapshot.docs.isEmpty) return;

      final localItems = await _local.watchAll().first;
      final localById = <String, PhotoEntry>{
        for (final item in localItems) item.id: item,
      };

      for (final doc in snapshot.docs) {
        final remoteRaw = <String, dynamic>{...doc.data(), 'id': doc.id};
        final remote = PhotoEntry.fromJson(_normalizeTimestamps(remoteRaw));
        final local = localById[remote.id];
        if (local != null && !remote.updatedAt.isAfter(local.updatedAt)) {
          continue;
        }
        await _local.upsert(
          remote.copyWith(
            localPath: local?.localPath,
            status: remote.storagePath == null
                ? PhotoStatus.pending
                : PhotoStatus.synced,
          ),
        );
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[PhotosRepositorySync] pullLatest failed: $error');
        debugPrint('$stackTrace');
      }
    }
  }

  Future<void> _syncEntry(PhotoEntry entry) async {
    final uid = _patientId;
    if (uid == null) return;

    try {
      final pendingAt = DateTime.now();
      final pendingDoc = entry.copyWith(
        updatedAt: pendingAt,
        status: PhotoStatus.pending,
      );
      await _collection(uid).doc(entry.id).set(<String, dynamic>{
        ...pendingDoc.toJson(),
        'updatedAt': pendingAt.toIso8601String(),
      }, SetOptions(merge: true));

      var storagePath = entry.storagePath;
      if (entry.localPath != null && entry.localPath!.trim().isNotEmpty) {
        final file = File(entry.localPath!);
        if (await file.exists()) {
          storagePath = StoragePaths.photoImage(uid, entry.id);
          final contentType = _contentTypeFromPath(entry.localPath!);
          await _storage
              .ref(storagePath)
              .putFile(file, SettableMetadata(contentType: contentType));
        }
      }

      final syncedAt = DateTime.now();
      final synced = entry.copyWith(
        storagePath: storagePath,
        updatedAt: syncedAt,
        status: storagePath == null ? PhotoStatus.pending : PhotoStatus.synced,
      );

      await _collection(uid).doc(entry.id).set(<String, dynamic>{
        ...synced.toJson(),
        'updatedAt': syncedAt.toIso8601String(),
      }, SetOptions(merge: true));
      await _local.upsert(synced);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[PhotosRepositorySync] sync failed: $error');
        debugPrint('$stackTrace');
      }
      // Queue file upload for retry when back online
      if (entry.localPath != null && entry.localPath!.trim().isNotEmpty) {
        StorageUploadQueue.instance.enqueue(StorageUploadOp(
          id: 'photo_${entry.id}',
          localFilePath: entry.localPath!,
          remoteStoragePath: StoragePaths.photoImage(uid, entry.id),
          contentType: _contentTypeFromPath(entry.localPath!),
          createdAt: DateTime.now(),
        ));
      }
      await _local.upsert(
        entry.copyWith(status: PhotoStatus.pending, updatedAt: DateTime.now()),
      );
    }
  }

  Map<String, dynamic> _normalizeTimestamps(Map<String, dynamic> raw) {
    return <String, dynamic>{
      ...raw,
      'createdAt': _toIso(raw['createdAt']),
      'updatedAt': _toIso(raw['updatedAt']),
      'deletedAt': _toIso(raw['deletedAt']),
    };
  }

  String? _toIso(Object? raw) {
    if (raw == null) return null;
    if (raw is Timestamp) return raw.toDate().toIso8601String();
    return raw.toString();
  }

  String? get _patientId {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null || uid.trim().isEmpty) return null;
    return uid;
  }

  CollectionReference<Map<String, dynamic>> _collection(String uid) {
    return _firestore.collection(FirestorePaths.photosCollection(uid));
  }

  static String _contentTypeFromPath(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.heic') || lower.endsWith('.heif')) return 'image/heic';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }
}
