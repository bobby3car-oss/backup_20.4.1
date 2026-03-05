import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../domain/warning_check.dart';
import 'warnings_repository_local.dart';

class WarningsRepositorySync {
  static final WarningsRepositorySync instance =
      WarningsRepositorySync._internal();

  factory WarningsRepositorySync() => instance;

  WarningsRepositorySync._internal({
    WarningsRepositoryLocal? local,
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _local = local ?? WarningsRepositoryLocal.instance,
       _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  final WarningsRepositoryLocal _local;
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  Future<WarningCheck?> loadLatest() async {
    final localLatest = await _local.loadLatest();
    final uid = _uid;
    if (uid == null) return localLatest;

    try {
      final query = await _collection(
        uid,
      ).orderBy('createdAt', descending: true).limit(1).get();
      if (query.docs.isEmpty) return localLatest;
      final doc = query.docs.first;
      final data = doc.data();
      final remote = WarningCheck.fromJson(<String, dynamic>{
        ...data,
        'id': doc.id,
        'createdAt': _remoteDateString(data['createdAt']),
      });
      final localDate =
          localLatest?.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      if (remote.createdAt.isAfter(localDate)) {
        await _local.saveLatest(remote);
        return remote;
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[WarningsRepositorySync] loadLatest remote failed: $error');
        debugPrint('$stackTrace');
      }
    }
    return localLatest;
  }

  Future<void> saveLatest(WarningCheck check) async {
    await _local.saveLatest(check);
    final uid = _uid;
    if (uid == null) return;

    try {
      await _docRef(uid, check.id).set(<String, dynamic>{
        ...check.toJson(),
        'createdAt': check.createdAt.toIso8601String(),
      });
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[WarningsRepositorySync] saveLatest remote failed: $error');
        debugPrint('$stackTrace');
      }
    }
  }

  String? get _uid {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null || uid.trim().isEmpty) return null;
    return uid;
  }

  CollectionReference<Map<String, dynamic>> _collection(String uid) {
    return _firestore.collection('patients/$uid/warnings');
  }

  DocumentReference<Map<String, dynamic>> _docRef(String uid, String id) {
    return _collection(uid).doc(id);
  }

  String? _remoteDateString(Object? raw) {
    if (raw == null) return null;
    if (raw is Timestamp) return raw.toDate().toIso8601String();
    return raw.toString();
  }
}
