import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/doctor_notification.dart';

class DoctorNotificationRepository {
  DoctorNotificationRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    this.overrideDoctorUid,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  /// If set, queries are resolved against this doctor UID (staff mode).
  final String? overrideDoctorUid;

  String? get _doctorUid => overrideDoctorUid ?? _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>>? get _collection {
    final uid = _doctorUid;
    if (uid == null) return null;
    return _db.collection('doctors/$uid/notifications');
  }

  /// Watch all notifications, newest first.
  Stream<List<DoctorNotification>> watchNotifications() {
    final col = _collection;
    if (col == null) return Stream.value([]);
    return col
        .orderBy('createdAt', descending: true)
        .limit(200)
        .snapshots()
        .map((snap) =>
            snap.docs.map(DoctorNotification.fromFirestore).toList());
  }

  /// Watch only the unread count.
  Stream<int> watchUnreadCount() {
    final col = _collection;
    if (col == null) return Stream.value(0);
    return col
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.size);
  }

  /// Mark a single notification as read.
  Future<void> markAsRead(String id) async {
    final col = _collection;
    if (col == null) return;
    await col.doc(id).update({'isRead': true});
  }

  /// Mark all unread notifications as read.
  Future<void> markAllAsRead() async {
    final col = _collection;
    if (col == null) return;

    final snap = await col
        .where('isRead', isEqualTo: false)
        .limit(500)
        .get();
    if (snap.docs.isEmpty) return;

    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}
