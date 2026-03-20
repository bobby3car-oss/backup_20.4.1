import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/bella_analyse.dart';

/// Reads daily Bella analyses from `users/{uid}/bellaAnalysen`.
class BellaAnalyseRepository {
  BellaAnalyseRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> _collection(String uid) =>
      _firestore.collection('users').doc(uid).collection('bellaAnalysen');

  /// Stream of today's analysis (or null).
  Stream<BellaAnalyse?> watchToday() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(null);

    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    return _collection(uid).doc(todayStr).snapshots().map((snap) {
      if (!snap.exists) return null;
      return BellaAnalyse.fromFirestore(snap);
    });
  }

  /// Fetch the latest analysis (most recent date).
  Stream<BellaAnalyse?> watchLatest() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(null);

    return _collection(uid)
        .orderBy('date', descending: true)
        .limit(1)
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return null;
      return BellaAnalyse.fromFirestore(snap.docs.first);
    });
  }
}
