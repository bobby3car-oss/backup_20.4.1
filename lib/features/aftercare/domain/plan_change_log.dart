import 'package:cloud_firestore/cloud_firestore.dart';

/// Type of change recorded in a plan's audit trail.
enum PlanChangeType {
  /// Status transition (e.g. active → paused).
  statusChange,

  /// An existing item was modified.
  itemModified,

  /// A new item was added to the plan.
  itemAdded,

  /// An item was removed from the plan.
  itemRemoved,

  /// A phase was modified (title, timing).
  phaseModified,

  /// General plan fields changed (title, surgery date, etc.).
  planEdited;

  factory PlanChangeType.fromString(String? value) {
    for (final t in PlanChangeType.values) {
      if (t.name == value) return t;
    }
    return PlanChangeType.planEdited;
  }
}

/// An immutable audit log entry for a patient aftercare plan.
///
/// Stored at: `patient_aftercare_plans/{planId}/change_log/{logId}`
class PlanChangeLog {
  const PlanChangeLog({
    required this.id,
    required this.planId,
    required this.changedBy,
    required this.changedAt,
    required this.changeType,
    required this.description,
    this.details,
  });

  final String id;
  final String planId;

  /// UID of the user who made the change.
  final String changedBy;

  final DateTime changedAt;
  final PlanChangeType changeType;

  /// Human-readable description of the change.
  final String description;

  /// Optional structured data (e.g. field diffs, item IDs).
  final Map<String, dynamic>? details;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'planId': planId,
      'changedBy': changedBy,
      'changedAt': changedAt.toIso8601String(),
      'changeType': changeType.name,
      'description': description,
      if (details != null) 'details': details,
    };
  }

  factory PlanChangeLog.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return PlanChangeLog(
      id: (json['id'] ?? '').toString(),
      planId: (json['planId'] ?? '').toString(),
      changedBy: (json['changedBy'] ?? '').toString(),
      changedAt: _parseDateTime(json['changedAt']) ?? now,
      changeType:
          PlanChangeType.fromString(json['changeType']?.toString()),
      description: (json['description'] ?? '').toString(),
      details: json['details'] is Map
          ? Map<String, dynamic>.from(json['details'] as Map)
          : null,
    );
  }

  static DateTime? _parseDateTime(Object? raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is String && raw.trim().isNotEmpty) return DateTime.tryParse(raw);
    return null;
  }
}
