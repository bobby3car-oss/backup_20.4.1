enum ObservationSeverity { info, warning, critical }

class ObservationEntry {
  const ObservationEntry({
    required this.id,
    required this.patientId,
    required this.authorUid,
    required this.authorName,
    required this.text,
    this.severity = ObservationSeverity.info,
    this.attachmentUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String patientId;
  final String authorUid;
  final String authorName;
  final String text;
  final ObservationSeverity severity;
  final String? attachmentUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  ObservationEntry copyWith({
    String? id,
    String? patientId,
    String? authorUid,
    String? authorName,
    String? text,
    ObservationSeverity? severity,
    String? attachmentUrl,
    bool clearAttachmentUrl = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ObservationEntry(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      authorUid: authorUid ?? this.authorUid,
      authorName: authorName ?? this.authorName,
      text: text ?? this.text,
      severity: severity ?? this.severity,
      attachmentUrl:
          clearAttachmentUrl ? null : (attachmentUrl ?? this.attachmentUrl),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'ownerId': patientId,
      'patientId': patientId,
      'authorUid': authorUid,
      'authorName': authorName,
      'text': text,
      'severity': severity.name,
      'attachmentUrl': attachmentUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ObservationEntry.fromJson(Map<String, dynamic> json) {
    return ObservationEntry(
      id: json['id'] as String? ?? '',
      patientId:
          json['patientId'] as String? ?? json['ownerId'] as String? ?? '',
      authorUid: json['authorUid'] as String? ?? '',
      authorName: json['authorName'] as String? ?? '',
      text: json['text'] as String? ?? '',
      severity: _parseSeverity(json['severity']),
      attachmentUrl: json['attachmentUrl'] as String?,
      createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updatedAt']) ?? DateTime.now(),
    );
  }

  static ObservationSeverity _parseSeverity(Object? value) {
    final name = value?.toString() ?? '';
    for (final s in ObservationSeverity.values) {
      if (s.name == name) return s;
    }
    return ObservationSeverity.info;
  }

  static DateTime? _parseDate(Object? value) {
    if (value == null) return null;
    if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
    return null;
  }
}
