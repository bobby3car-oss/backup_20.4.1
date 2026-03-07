import 'package:cloud_firestore/cloud_firestore.dart';

/// The type / source of an in-app notification.
enum NotificationType {
  /// Automatically generated when a timeline task becomes due.
  taskDue,

  /// Automatically generated when a task is completed.
  taskCompleted,

  /// Automatically generated for upcoming appointments.
  appointmentReminder,

  /// Automatically generated when a new observation is recorded.
  observation,

  /// Automatically generated for wound-warning state changes.
  woundWarning,

  /// Automatically generated for medication reminders.
  medication,

  /// User-created custom notification / reminder.
  custom,

  /// System-level notification (e.g. pro expiry, updates).
  system,
}

/// Priority level that controls visual prominence and sort weight.
enum NotificationPriority { low, normal, high, critical }

/// A persistent in-app notification stored locally and optionally in Firestore.
class InAppNotification {
  InAppNotification({
    required this.id,
    required this.type,
    required this.title,
    this.body,
    this.emoji,
    this.deeplinkRoute,
    this.priority = NotificationPriority.normal,
    this.isRead = false,
    this.isDismissed = false,
    DateTime? createdAt,
    this.scheduledAt,
    this.expiresAt,
    this.sourceId,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final NotificationType type;
  final String title;
  final String? body;
  final String? emoji;
  final String? deeplinkRoute;
  final NotificationPriority priority;
  final bool isRead;
  final bool isDismissed;
  final DateTime createdAt;

  /// Optional future date — notification only becomes visible after this time.
  final DateTime? scheduledAt;

  /// Optional expiry — auto-dismiss after this time.
  final DateTime? expiresAt;

  /// ID of the originating entity (timeline item, appointment, etc.).
  final String? sourceId;

  // ── Derived helpers ──────────────────────────────────────────────────────

  bool get isVisible {
    if (isDismissed) return false;
    if (expiresAt != null && DateTime.now().isAfter(expiresAt!)) return false;
    if (scheduledAt != null && DateTime.now().isBefore(scheduledAt!)) {
      return false;
    }
    return true;
  }

  // ── Copy ─────────────────────────────────────────────────────────────────

  InAppNotification copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? body,
    String? emoji,
    String? deeplinkRoute,
    NotificationPriority? priority,
    bool? isRead,
    bool? isDismissed,
    DateTime? createdAt,
    DateTime? scheduledAt,
    DateTime? expiresAt,
    String? sourceId,
    bool clearScheduledAt = false,
    bool clearExpiresAt = false,
    bool clearSourceId = false,
  }) {
    return InAppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      emoji: emoji ?? this.emoji,
      deeplinkRoute: deeplinkRoute ?? this.deeplinkRoute,
      priority: priority ?? this.priority,
      isRead: isRead ?? this.isRead,
      isDismissed: isDismissed ?? this.isDismissed,
      createdAt: createdAt ?? this.createdAt,
      scheduledAt: clearScheduledAt ? null : (scheduledAt ?? this.scheduledAt),
      expiresAt: clearExpiresAt ? null : (expiresAt ?? this.expiresAt),
      sourceId: clearSourceId ? null : (sourceId ?? this.sourceId),
    );
  }

  // ── Serialisation ────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'title': title,
    if (body != null) 'body': body,
    if (emoji != null) 'emoji': emoji,
    if (deeplinkRoute != null) 'deeplinkRoute': deeplinkRoute,
    'priority': priority.name,
    'isRead': isRead,
    'isDismissed': isDismissed,
    'createdAt': createdAt.toIso8601String(),
    if (scheduledAt != null) 'scheduledAt': scheduledAt!.toIso8601String(),
    if (expiresAt != null) 'expiresAt': expiresAt!.toIso8601String(),
    if (sourceId != null) 'sourceId': sourceId,
  };

  factory InAppNotification.fromJson(Map<String, dynamic> json) {
    return InAppNotification(
      id: json['id'] as String,
      type: _parseType(json['type'] as String?),
      title: json['title'] as String,
      body: json['body'] as String?,
      emoji: json['emoji'] as String?,
      deeplinkRoute: json['deeplinkRoute'] as String?,
      priority: _parsePriority(json['priority'] as String?),
      isRead: json['isRead'] as bool? ?? false,
      isDismissed: json['isDismissed'] as bool? ?? false,
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
      scheduledAt: _parseDateTime(json['scheduledAt']),
      expiresAt: _parseDateTime(json['expiresAt']),
      sourceId: json['sourceId'] as String?,
    );
  }

  // ── Parse helpers ────────────────────────────────────────────────────────

  static NotificationType _parseType(String? value) {
    if (value == null) return NotificationType.system;
    return NotificationType.values.asNameMap()[value] ??
        NotificationType.system;
  }

  static NotificationPriority _parsePriority(String? value) {
    if (value == null) return NotificationPriority.normal;
    return NotificationPriority.values.asNameMap()[value] ??
        NotificationPriority.normal;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
