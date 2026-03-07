import 'package:cloud_firestore/cloud_firestore.dart';

enum TicketCategory { bug, feature, question, other }

enum TicketStatus { open, inProgress, resolved, closed }

enum TicketPriority { low, medium, high }

class SupportTicket {
  const SupportTicket({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.category,
    required this.status,
    required this.priority,
    required this.subject,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessageAt,
    this.unreadByAdmin = false,
    this.unreadByUser = false,
  });

  final String id;
  final String userId;
  final String userEmail;
  final TicketCategory category;
  final TicketStatus status;
  final TicketPriority priority;
  final String subject;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastMessageAt;
  final bool unreadByAdmin;
  final bool unreadByUser;

  factory SupportTicket.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return SupportTicket(
      id: doc.id,
      userId: d['userId'] as String? ?? '',
      userEmail: d['userEmail'] as String? ?? '',
      category: _parseCategory(d['category'] as String?),
      status: _parseStatus(d['status'] as String?),
      priority: _parsePriority(d['priority'] as String?),
      subject: d['subject'] as String? ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastMessageAt: (d['lastMessageAt'] as Timestamp?)?.toDate(),
      unreadByAdmin: d['unreadByAdmin'] as bool? ?? false,
      unreadByUser: d['unreadByUser'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toCreateMap() => {
        'userId': userId,
        'userEmail': userEmail,
        'category': category.name,
        'status': status.name,
        'priority': priority.name,
        'subject': subject,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'unreadByAdmin': true,
        'unreadByUser': false,
      };

  static TicketCategory _parseCategory(String? v) => switch (v) {
        'bug' => TicketCategory.bug,
        'feature' => TicketCategory.feature,
        'question' => TicketCategory.question,
        _ => TicketCategory.other,
      };

  static TicketStatus _parseStatus(String? v) => switch (v) {
        'open' => TicketStatus.open,
        'inProgress' => TicketStatus.inProgress,
        'resolved' => TicketStatus.resolved,
        'closed' => TicketStatus.closed,
        _ => TicketStatus.open,
      };

  static TicketPriority _parsePriority(String? v) => switch (v) {
        'low' => TicketPriority.low,
        'medium' => TicketPriority.medium,
        'high' => TicketPriority.high,
        _ => TicketPriority.medium,
      };
}

class TicketMessage {
  const TicketMessage({
    required this.id,
    required this.senderUid,
    required this.senderRole,
    required this.text,
    required this.timestamp,
  });

  final String id;
  final String senderUid;
  final String senderRole; // 'user' or 'admin'
  final String text;
  final DateTime timestamp;

  factory TicketMessage.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return TicketMessage(
      id: doc.id,
      senderUid: d['senderUid'] as String? ?? '',
      senderRole: d['senderRole'] as String? ?? 'user',
      text: d['text'] as String? ?? '',
      timestamp: (d['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'senderUid': senderUid,
        'senderRole': senderRole,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      };
}

// ── Display helpers ──────────────────────────────────────────────

extension TicketCategoryLabel on TicketCategory {
  String get label => switch (this) {
        TicketCategory.bug => 'Bug',
        TicketCategory.feature => 'Feature-Wunsch',
        TicketCategory.question => 'Frage',
        TicketCategory.other => 'Sonstiges',
      };

  String get icon => switch (this) {
        TicketCategory.bug => '🐛',
        TicketCategory.feature => '💡',
        TicketCategory.question => '❓',
        TicketCategory.other => '📌',
      };
}

extension TicketStatusLabel on TicketStatus {
  String get label => switch (this) {
        TicketStatus.open => 'Offen',
        TicketStatus.inProgress => 'In Bearbeitung',
        TicketStatus.resolved => 'Gelöst',
        TicketStatus.closed => 'Geschlossen',
      };
}

extension TicketPriorityLabel on TicketPriority {
  String get label => switch (this) {
        TicketPriority.low => 'Niedrig',
        TicketPriority.medium => 'Mittel',
        TicketPriority.high => 'Hoch',
      };
}
