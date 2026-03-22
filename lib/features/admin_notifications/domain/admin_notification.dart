import 'package:cloud_firestore/cloud_firestore.dart';

/// Category of admin notification.
enum AdminNotificationType {
  supportTicket,
  supportTicketMessage,
  doctorRegistration,
  orgRegistration,
  ;

  String get label => switch (this) {
    supportTicket => 'Support-Ticket',
    supportTicketMessage => 'Ticket-Nachricht',
    doctorRegistration => 'Arzt-Registrierung',
    orgRegistration => 'Organisations-Registrierung',
  };

  String get icon => switch (this) {
    supportTicket => '🎫',
    supportTicketMessage => '💬',
    doctorRegistration => '🩺',
    orgRegistration => '🏥',
  };
}

class AdminNotification {
  const AdminNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
    this.referenceId,
    this.actorEmail,
  });

  final String id;
  final AdminNotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;

  /// ID referencing the source entity (ticket ID, doctor UID, org UID).
  final String? referenceId;

  /// Email of the user who triggered the notification.
  final String? actorEmail;

  factory AdminNotification.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data()!;
    return AdminNotification(
      id: doc.id,
      type: _parseType(d['type'] as String?),
      title: d['title'] as String? ?? '',
      body: d['body'] as String? ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: d['isRead'] as bool? ?? false,
      referenceId: d['referenceId'] as String?,
      actorEmail: d['actorEmail'] as String?,
    );
  }

  static AdminNotificationType _parseType(String? value) {
    if (value == null) return AdminNotificationType.supportTicket;
    return AdminNotificationType.values.asNameMap()[value] ??
        AdminNotificationType.supportTicket;
  }

  Map<String, dynamic> toMap() => {
    'type': type.name,
    'title': title,
    'body': body,
    'createdAt': FieldValue.serverTimestamp(),
    'isRead': isRead,
    if (referenceId != null) 'referenceId': referenceId,
    if (actorEmail != null) 'actorEmail': actorEmail,
  };
}
