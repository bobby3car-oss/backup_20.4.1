class PainEntry {
  const PainEntry({
    required this.id,
    required this.ownerId,
    required this.occurredAt,
    required this.painLevel,
    this.location,
    required this.note,
    this.trigger,
    this.medicationTaken,
    required this.createdAt,
    required this.updatedAt,
    this.metadata = const <String, dynamic>{},
  });

  final String id;
  final String ownerId;
  final DateTime occurredAt;
  final int painLevel; // 0..10
  final String? location;
  final String note;
  final String? trigger;
  final bool? medicationTaken;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  PainEntry copyWith({
    String? id,
    String? ownerId,
    DateTime? occurredAt,
    int? painLevel,
    String? location,
    bool clearLocation = false,
    String? note,
    String? trigger,
    bool clearTrigger = false,
    bool? medicationTaken,
    bool clearMedicationTaken = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return PainEntry(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      occurredAt: occurredAt ?? this.occurredAt,
      painLevel: painLevel ?? this.painLevel,
      location: clearLocation ? null : (location ?? this.location),
      note: note ?? this.note,
      trigger: clearTrigger ? null : (trigger ?? this.trigger),
      medicationTaken: clearMedicationTaken
          ? null
          : (medicationTaken ?? this.medicationTaken),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'ownerId': ownerId,
      'occurredAt': occurredAt.toIso8601String(),
      'painLevel': painLevel,
      'location': location,
      'note': note,
      'trigger': trigger,
      'medicationTaken': medicationTaken,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory PainEntry.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    final occurredAt = _parseDateTime(json['occurredAt']) ?? now;
    return PainEntry(
      id: (json['id'] ?? '').toString(),
      ownerId: (json['ownerId'] ?? '').toString(),
      occurredAt: occurredAt,
      painLevel: _clampPain(_parseInt(json['painLevel']) ?? 0),
      location: _parseStringOrNull(json['location']),
      note: (json['note'] ?? '').toString(),
      trigger: _parseStringOrNull(json['trigger']),
      medicationTaken: _parseNullableBool(json['medicationTaken']),
      createdAt: _parseDateTime(json['createdAt']) ?? occurredAt,
      updatedAt: _parseDateTime(json['updatedAt']) ?? occurredAt,
      metadata: _parseMetadata(json['metadata']),
    );
  }

  static int _clampPain(int value) => value.clamp(0, 10);

  static DateTime? _parseDateTime(Object? raw) {
    if (raw is String && raw.trim().isNotEmpty) {
      return DateTime.tryParse(raw);
    }
    return null;
  }

  static int? _parseInt(Object? raw) {
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw);
    return null;
  }

  static String? _parseStringOrNull(Object? raw) {
    if (raw == null) return null;
    final value = raw.toString().trim();
    return value.isEmpty ? null : value;
  }

  static bool? _parseNullableBool(Object? raw) {
    if (raw == null) return null;
    if (raw is bool) return raw;
    if (raw is String) {
      final normalized = raw.trim().toLowerCase();
      if (normalized == 'true') return true;
      if (normalized == 'false') return false;
    }
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
