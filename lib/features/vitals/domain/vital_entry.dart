class VitalEntry {
  const VitalEntry({
    required this.id,
    required this.ownerId,
    required this.systolic,
    required this.diastolic,
    required this.pulse,
    required this.createdAt,
    required this.updatedAt,
    this.temperature,
    this.oxygenSaturation,
    this.weight,
    this.note,
    this.source = 'manual',
    this.deletedAt,
    this.metadata = const <String, dynamic>{},
  });

  final String id;
  final String ownerId;
  final int systolic;
  final int diastolic;
  final int pulse;
  final double? temperature;
  final int? oxygenSaturation;
  final double? weight;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  /// 'manual', 'healthkit', or 'health_connect'
  final String source;
  final DateTime? deletedAt;
  final Map<String, dynamic> metadata;

  bool get isDeleted => deletedAt != null;

  VitalEntry copyWith({
    String? id,
    String? ownerId,
    int? systolic,
    int? diastolic,
    int? pulse,
    double? Function()? temperature,
    int? Function()? oxygenSaturation,
    double? Function()? weight,
    String? Function()? note,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? source,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
    Map<String, dynamic>? metadata,
  }) {
    return VitalEntry(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      systolic: systolic ?? this.systolic,
      diastolic: diastolic ?? this.diastolic,
      pulse: pulse ?? this.pulse,
      temperature: temperature != null ? temperature() : this.temperature,
      oxygenSaturation: oxygenSaturation != null ? oxygenSaturation() : this.oxygenSaturation,
      weight: weight != null ? weight() : this.weight,
      note: note != null ? note() : this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      source: source ?? this.source,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
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
      if (temperature != null) 'temperature': temperature,
      if (oxygenSaturation != null) 'oxygenSaturation': oxygenSaturation,
      if (weight != null) 'weight': weight,
      if (note != null && note!.isNotEmpty) 'note': note,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'source': source,
      'deletedAt': deletedAt?.toIso8601String(),
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
      temperature: _parseDouble(json['temperature']),
      oxygenSaturation: _parseInt(json['oxygenSaturation']),
      weight: _parseDouble(json['weight']),
      note: json['note'] as String?,
      createdAt: _parseDateTime(json['createdAt']) ?? now,
      updatedAt: _parseDateTime(json['updatedAt']) ?? now,
      source: (json['source'] as String?) ?? 'manual',
      deletedAt: _parseDateTime(json['deletedAt']),
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

  static double? _parseDouble(Object? raw) {
    if (raw is double) return raw;
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw);
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
