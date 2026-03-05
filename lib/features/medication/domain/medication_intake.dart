class MedicationIntake {
  const MedicationIntake({
    required this.id,
    required this.ownerId,
    required this.name,
    this.dose,
    required this.takenAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.metadata = const <String, dynamic>{},
  });

  final String id;
  final String ownerId;
  final String name;
  final String? dose;
  final DateTime takenAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final Map<String, dynamic> metadata;

  MedicationIntake copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? dose,
    bool clearDose = false,
    DateTime? takenAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
    Map<String, dynamic>? metadata,
  }) {
    return MedicationIntake(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      dose: clearDose ? null : (dose ?? this.dose),
      takenAt: takenAt ?? this.takenAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'dose': dose,
      'takenAt': takenAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (deletedAt != null) 'deletedAt': deletedAt!.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory MedicationIntake.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    final takenAt = _parseDateTime(json['takenAt']) ?? now;
    return MedicationIntake(
      id: (json['id'] ?? '').toString(),
      ownerId: (json['ownerId'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      dose: _parseStringOrNull(json['dose']),
      takenAt: takenAt,
      createdAt: _parseDateTime(json['createdAt']) ?? takenAt,
      updatedAt: _parseDateTime(json['updatedAt']) ?? takenAt,
      deletedAt: _parseDateTime(json['deletedAt']),
      metadata: _parseMetadata(json['metadata']),
    );
  }

  bool get isDeleted => deletedAt != null;

  static DateTime? _parseDateTime(Object? raw) {
    if (raw is String && raw.trim().isNotEmpty) return DateTime.tryParse(raw);
    return null;
  }

  static String? _parseStringOrNull(Object? raw) {
    if (raw == null) return null;
    final value = raw.toString().trim();
    return value.isEmpty ? null : value;
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
