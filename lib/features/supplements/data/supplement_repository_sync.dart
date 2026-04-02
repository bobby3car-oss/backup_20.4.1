import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../domain/supplement.dart';
import 'supplement_repository.dart';
import 'supplement_repository_local.dart';

class SupplementRepositorySync implements SupplementRepository {
  static final SupplementRepositorySync instance =
      SupplementRepositorySync._internal(
        firebaseAuth: _safeFirebaseAuth(),
        firestore: _safeFirestore(),
      );

  factory SupplementRepositorySync() => instance;

  SupplementRepositorySync._internal({
    SupplementRepositoryLocal? local,
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _local = local ?? SupplementRepositoryLocal.instance,
       _firebaseAuth = firebaseAuth,
       _firestore = firestore;

  final SupplementRepositoryLocal _local;
  final FirebaseAuth? _firebaseAuth;
  final FirebaseFirestore? _firestore;

  static FirebaseAuth? _safeFirebaseAuth() {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  static FirebaseFirestore? _safeFirestore() {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<List<Supplement>> watchAll() => _local.watchAll();

  @override
  Future<void> upsert(Supplement supplement) async {
    final now = DateTime.now();
    final updatedAtIso = now.toIso8601String();
    final normalized = supplement.copyWith(
      updatedAt: now,
      metadata: <String, dynamic>{
        ...supplement.metadata,
        'updatedAt': updatedAtIso,
        'clientUpdatedAt': updatedAtIso,
      },
    );

    await _local.upsert(normalized);

    final uid = _patientId;
    if (uid == null || _firestore == null) return;

    try {
      await _docRef(uid, normalized.id).set(<String, dynamic>{
        ...normalized.toJson(),
        'updatedAt': updatedAtIso,
        'clientUpdatedAt': updatedAtIso,
      });
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[SupplementRepoSync] remote upsert failed: $error');
        debugPrint('$stackTrace');
      }
    }
  }

  @override
  Future<void> delete(String id) async {
    // Soft-delete: mark deletedAt instead of hard-removing.
    final existing = await _local.getById(id);
    if (existing != null) {
      final now = DateTime.now();
      final softDeleted = existing.copyWith(deletedAt: now, updatedAt: now);
      await _local.upsert(softDeleted);
    } else {
      await _local.delete(id);
    }

    final uid = _patientId;
    if (uid == null || _firestore == null) return;

    try {
      await _docRef(uid, id).delete();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[SupplementRepoSync] remote delete failed: $error');
        debugPrint('$stackTrace');
      }
    }
  }

  @override
  Future<Supplement?> getById(String id) => _local.getById(id);

  @override
  Future<void> loadFromDisk() => _local.loadFromDisk();

  @override
  Future<void> saveToDisk() => _local.saveToDisk();

  Future<void> pullLatest() async {
    final uid = _patientId;
    final fs = _firestore;
    if (uid == null || fs == null) return;

    try {
      final snapshot =
          await fs.collection('patients/$uid/supplement_reminders').get();
      if (snapshot.docs.isEmpty) return;

      final localItems = await _local.watchAll().first;
      final localById = <String, Supplement>{
        for (final item in localItems) item.id: item,
      };

      for (final doc in snapshot.docs) {
        final remoteMap = <String, dynamic>{...doc.data(), 'id': doc.id};
        final remoteUpdatedAt = _readUpdatedAt(remoteMap);
        final local = localById[doc.id];
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

        final item = Supplement.fromJson(<String, dynamic>{
          ...remoteMap,
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
        debugPrint('[SupplementRepoSync] pullLatest failed: $error');
        debugPrint('$stackTrace');
      }
    }
  }

  String? get _patientId {
    final uid = _firebaseAuth?.currentUser?.uid;
    if (uid == null || uid.trim().isEmpty) return null;
    return uid;
  }

  DocumentReference<Map<String, dynamic>> _docRef(String uid, String id) {
    return _firestore!
        .collection('patients/$uid/supplement_reminders')
        .doc(id);
  }

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

