class VitalEntry {
  const VitalEntry({
    required this.id,
    required this.ownerId,
    required this.systolic,
    required this.diastolic,
    required this.pulse,
    required this.createdAt,
    required this.updatedAt,
    this.metadata = const <String, dynamic>{},
  });

  final String id;
  final String ownerId;
  final int systolic;
  final int diastolic;
  final int pulse;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  VitalEntry copyWith({
    String? id,
    String? ownerId,
    int? systolic,
    int? diastolic,
    int? pulse,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return VitalEntry(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      systolic: systolic ?? this.systolic,
      diastolic: diastolic ?? this.diastolic,
      pulse: pulse ?? this.pulse,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'ownerId': ownerId,
      'systolic': systolic,
      'diastolic': diastolic,
      'pulse': pulse,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory VitalEntry.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return VitalEntry(
      id: (json['id'] ?? '').toString(),
      ownerId: (json['ownerId'] ?? '').toString(),
      systolic: _parseInt(json['systolic']) ?? 120,
      diastolic: _parseInt(json['diastolic']) ?? 80,
      pulse: _parseInt(json['pulse']) ?? 70,
      createdAt: _parseDateTime(json['createdAt']) ?? now,
      updatedAt: _parseDateTime(json['updatedAt']) ?? now,
      metadata: _parseMetadata(json['metadata']),
    );
  }

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
