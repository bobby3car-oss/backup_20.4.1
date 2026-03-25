import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/admin_notification.dart';

class AdminNotificationRepository {
  AdminNotificationRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _db.collection('admin_notifications');

  /// Watch all admin notifications, newest first.
  Stream<List<AdminNotification>> watchAll() {
    return _collection
        .orderBy('createdAt', descending: true)
        .limit(200)
        .snapshots()
        .map((snap) =>
            snap.docs.map(AdminNotification.fromFirestore).toList());
  }

  /// Watch only unread notifications count.
  Stream<int> watchUnreadCount() {
    return _collection
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.size);
  }

  /// Mark a single notification as read.
  Future<void> markRead(String id) {
    return _collection.doc(id).update({'isRead': true});
  }

  /// Mark all notifications as read.
  Future<void> markAllRead() async {
    final snap = await _collection
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

  /// Delete a single notification.
  Future<void> delete(String id) {
    return _collection.doc(id).delete();
  }

  /// Write a manual test notification to verify the system works.
  Future<void> createTestNotification() {
    return _collection.add({
      'type': 'supportTicket',
      'title': '🔔 Test-Benachrichtigung',
      'body': 'Das Admin-Benachrichtigungssystem ist aktiv und funktioniert korrekt.',
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }
}
