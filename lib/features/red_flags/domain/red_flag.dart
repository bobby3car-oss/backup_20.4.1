/// Unified severity for the red-flag system.
///
/// Replaces the separate [WarningLevel], [ReportLight] and
/// [ObservationSeverity] hierarchies with a single, consistent scale.
enum RedFlagSeverity {
  green,
  yellow,
  orange,
  red;

  String get label => switch (this) {
        green => 'Grün',
        yellow => 'Gelb',
        orange => 'Orange',
        red => 'Rot',
      };
}

/// Workflow status of a red-flag case.
enum RedFlagStatus {
  /// Newly created, nobody has reacted yet.
  open,

  /// A doctor / caregiver has seen the flag.
  acknowledged,

  /// Under active observation (snoozed / monitoring).
  monitoring,

  /// Escalated to emergency level.
  escalated,

  /// Resolved – no further action needed.
  resolved;

  String get label => switch (this) {
        open => 'Offen',
        acknowledged => 'Gesehen',
        monitoring => 'Beobachtung',
        escalated => 'Eskaliert',
        resolved => 'Gelöst',
      };

  bool get isActive =>
      this == open || this == acknowledged || this == monitoring;
}

/// Which data source triggered the flag.
enum RedFlagSource {
  warningCheck,
  pain,
  vitals,
  observation,
  wound,
  timeline,
  manual;

  String get label => switch (this) {
        warningCheck => 'Warnzeichen-Check',
        pain => 'Schmerz',
        vitals => 'Vitalwerte',
        observation => 'Beobachtung',
        wound => 'Wunddaten',
        timeline => 'Timeline-Aufgabe',
        manual => 'Manuell',
      };

  String get emoji => switch (this) {
        warningCheck => '⚠️',
        pain => '😣',
        vitals => '💓',
        observation => '👁️',
        wound => '🩹',
        timeline => '📋',
        manual => '✏️',
      };
}

/// A single recommended action for the patient / doctor.
class RedFlagAction {
  const RedFlagAction({required this.label, required this.icon, this.route});

  final String label;
  final String icon; // emoji
  final String? route; // deeplink route or null

  Map<String, dynamic> toJson() => <String, dynamic>{
        'label': label,
        'icon': icon,
        if (route != null) 'route': route,
      };

  factory RedFlagAction.fromJson(Map<String, dynamic> json) {
    return RedFlagAction(
      label: (json['label'] ?? '').toString(),
      icon: (json['icon'] ?? '').toString(),
      route: json['route']?.toString(),
    );
  }
}

/// Core domain model for a red-flag case.
class RedFlag {
  const RedFlag({
    required this.id,
    required this.ownerId,
    required this.severity,
    required this.status,
    required this.source,
    required this.title,
    required this.summary,
    required this.recommendedAction,
    this.actions = const [],
    this.sourceRefId,
    this.assigneeUid,
    this.resolvedByUid,
    this.comment,
    required this.createdAt,
    required this.updatedAt,
    this.acknowledgedAt,
    this.resolvedAt,
    this.metadata = const <String, dynamic>{},
  });

  final String id;
  final String ownerId;
  final RedFlagSeverity severity;
  final RedFlagStatus status;
  final RedFlagSource source;
  final String title;
  final String summary;
  final String recommendedAction;
  final List<RedFlagAction> actions;
  final String? sourceRefId;
  final String? assigneeUid;
  final String? resolvedByUid;
  final String? comment;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? acknowledgedAt;
  final DateTime? resolvedAt;
  final Map<String, dynamic> metadata;

  RedFlag copyWith({
    String? id,
    String? ownerId,
    RedFlagSeverity? severity,
    RedFlagStatus? status,
    RedFlagSource? source,
    String? title,
    String? summary,
    String? recommendedAction,
    List<RedFlagAction>? actions,
    String? sourceRefId,
    bool clearSourceRefId = false,
    String? assigneeUid,
    bool clearAssigneeUid = false,
    String? resolvedByUid,
    bool clearResolvedByUid = false,
    String? comment,
    bool clearComment = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? acknowledgedAt,
    bool clearAcknowledgedAt = false,
    DateTime? resolvedAt,
    bool clearResolvedAt = false,
    Map<String, dynamic>? metadata,
  }) {
    return RedFlag(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      source: source ?? this.source,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      recommendedAction: recommendedAction ?? this.recommendedAction,
      actions: actions ?? this.actions,
      sourceRefId:
          clearSourceRefId ? null : (sourceRefId ?? this.sourceRefId),
      assigneeUid:
          clearAssigneeUid ? null : (assigneeUid ?? this.assigneeUid),
      resolvedByUid:
          clearResolvedByUid ? null : (resolvedByUid ?? this.resolvedByUid),
      comment: clearComment ? null : (comment ?? this.comment),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      acknowledgedAt: clearAcknowledgedAt
          ? null
          : (acknowledgedAt ?? this.acknowledgedAt),
      resolvedAt:
          clearResolvedAt ? null : (resolvedAt ?? this.resolvedAt),
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'ownerId': ownerId,
      'severity': severity.name,
      'status': status.name,
      'source': source.name,
      'title': title,
      'summary': summary,
      'recommendedAction': recommendedAction,
      'actions': actions.map((a) => a.toJson()).toList(),
      if (sourceRefId != null) 'sourceRefId': sourceRefId,
      if (assigneeUid != null) 'assigneeUid': assigneeUid,
      if (resolvedByUid != null) 'resolvedByUid': resolvedByUid,
      if (comment != null) 'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (acknowledgedAt != null)
        'acknowledgedAt': acknowledgedAt!.toIso8601String(),
      if (resolvedAt != null) 'resolvedAt': resolvedAt!.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory RedFlag.fromJson(Map<String, dynamic> json) {
    return RedFlag(
      id: (json['id'] ?? '').toString(),
      ownerId: (json['ownerId'] ?? '').toString(),
      severity: _parseSeverity(json['severity']),
      status: _parseStatus(json['status']),
      source: _parseSource(json['source']),
      title: (json['title'] ?? '').toString(),
      summary: (json['summary'] ?? '').toString(),
      recommendedAction: (json['recommendedAction'] ?? '').toString(),
      actions: _parseActions(json['actions']),
      sourceRefId: json['sourceRefId']?.toString(),
      assigneeUid: json['assigneeUid']?.toString(),
      resolvedByUid: json['resolvedByUid']?.toString(),
      comment: json['comment']?.toString(),
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDateTime(json['updatedAt']) ?? DateTime.now(),
      acknowledgedAt: _parseDateTime(json['acknowledgedAt']),
      resolvedAt: _parseDateTime(json['resolvedAt']),
      metadata: _parseMetadata(json['metadata']),
    );
  }

  // ── Parsers ──

  static RedFlagSeverity _parseSeverity(Object? raw) {
    final s = raw?.toString() ?? '';
    for (final v in RedFlagSeverity.values) {
      if (v.name == s) return v;
    }
    return RedFlagSeverity.green;
  }

  static RedFlagStatus _parseStatus(Object? raw) {
    final s = raw?.toString() ?? '';
    for (final v in RedFlagStatus.values) {
      if (v.name == s) return v;
    }
    return RedFlagStatus.open;
  }

  static RedFlagSource _parseSource(Object? raw) {
    final s = raw?.toString() ?? '';
    for (final v in RedFlagSource.values) {
      if (v.name == s) return v;
    }
    return RedFlagSource.manual;
  }

  static List<RedFlagAction> _parseActions(Object? raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((m) => RedFlagAction.fromJson(Map<String, dynamic>.from(m)))
        .toList();
  }

  static DateTime? _parseDateTime(Object? raw) {
    if (raw is String && raw.trim().isNotEmpty) return DateTime.tryParse(raw);
    return null;
  }

  static Map<String, dynamic> _parseMetadata(Object? raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) {
      return raw.map(
        (dynamic key, dynamic value) => MapEntry(key.toString(), value),
      );
    }
    return const <String, dynamic>{};
  }
}
