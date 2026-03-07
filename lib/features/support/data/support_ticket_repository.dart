import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/support_ticket.dart';

class SupportTicketRepository {
  SupportTicketRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _tickets =>
      _db.collection('supportTickets');

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  // ── User methods ─────────────────────────────────────────────

  /// Watch the current user's tickets.
  Stream<List<SupportTicket>> watchMyTickets() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return _tickets
        .where('userId', isEqualTo: uid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map(SupportTicket.fromFirestore).toList());
  }

  /// Create a new ticket.
  Future<String> createTicket({
    required String subject,
    required String message,
    required TicketCategory category,
  }) async {
    final uid = _uid;
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    if (uid == null) throw StateError('Not signed in');

    final ticket = SupportTicket(
      id: '',
      userId: uid,
      userEmail: email,
      category: category,
      status: TicketStatus.open,
      priority: TicketPriority.medium,
      subject: subject,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final docRef = await _tickets.add(ticket.toCreateMap());

    // Add the initial message.
    await docRef.collection('messages').add(TicketMessage(
          id: '',
          senderUid: uid,
          senderRole: 'user',
          text: message,
          timestamp: DateTime.now(),
        ).toMap());

    return docRef.id;
  }

  /// Send a message in a ticket (user or admin).
  Future<void> sendMessage({
    required String ticketId,
    required String text,
    required bool isAdmin,
  }) async {
    final uid = _uid;
    if (uid == null) throw StateError('Not signed in');

    final batch = _db.batch();

    final msgRef = _tickets.doc(ticketId).collection('messages').doc();
    batch.set(msgRef, TicketMessage(
      id: '',
      senderUid: uid,
      senderRole: isAdmin ? 'admin' : 'user',
      text: text,
      timestamp: DateTime.now(),
    ).toMap());

    // Update ticket metadata.
    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
      'lastMessageAt': FieldValue.serverTimestamp(),
    };
    if (isAdmin) {
      updates['unreadByUser'] = true;
      updates['unreadByAdmin'] = false;
    } else {
      updates['unreadByAdmin'] = true;
      updates['unreadByUser'] = false;
    }
    batch.update(_tickets.doc(ticketId), updates);

    await batch.commit();
  }

  /// Watch messages for a ticket.
  Stream<List<TicketMessage>> watchMessages(String ticketId) {
    return _tickets
        .doc(ticketId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map((snap) =>
            snap.docs.map(TicketMessage.fromFirestore).toList());
  }

  /// Mark a ticket as read (clear unread flag for the reader).
  Future<void> markRead(String ticketId, {required bool isAdmin}) {
    return _tickets.doc(ticketId).update({
      if (isAdmin) 'unreadByAdmin': false,
      if (!isAdmin) 'unreadByUser': false,
    });
  }

  /// Close a ticket (user or admin).
  Future<void> closeTicket(String ticketId) {
    return _tickets.doc(ticketId).update({
      'status': 'closed',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Admin methods ────────────────────────────────────────────

  /// Watch all tickets (admin).
  Stream<List<SupportTicket>> watchAllTickets() {
    return _tickets
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map(SupportTicket.fromFirestore).toList());
  }

  /// Count open tickets (admin badge).
  Stream<int> watchOpenTicketCount() {
    return _tickets
        .where('status', whereIn: ['open', 'inProgress'])
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  /// Update ticket status (admin).
  Future<void> updateStatus(String ticketId, TicketStatus status) {
    return _tickets.doc(ticketId).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update ticket priority (admin).
  Future<void> updatePriority(String ticketId, TicketPriority priority) {
    return _tickets.doc(ticketId).update({
      'priority': priority.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
