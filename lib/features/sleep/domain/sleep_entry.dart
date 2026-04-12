/// Sleep quality rating (1–5).
enum SleepQuality {
  veryPoor,
  poor,
  fair,
  good,
  excellent;

  int get value => index + 1;

  String get label => switch (this) {
        SleepQuality.veryPoor => 'Sehr schlecht',
        SleepQuality.poor => 'Schlecht',
        SleepQuality.fair => 'Mittelmäßig',
        SleepQuality.good => 'Gut',
        SleepQuality.excellent => 'Ausgezeichnet',
      };

  String get emoji => switch (this) {
        SleepQuality.veryPoor => '😫',
        SleepQuality.poor => '😴',
        SleepQuality.fair => '😐',
        SleepQuality.good => '😊',
        SleepQuality.excellent => '🌟',
      };

  static SleepQuality fromValue(int v) => switch (v.clamp(1, 5)) {
        1 => SleepQuality.veryPoor,
        2 => SleepQuality.poor,
        3 => SleepQuality.fair,
        4 => SleepQuality.good,
        _ => SleepQuality.excellent,
      };
}

class SleepEntry {
  const SleepEntry({
    required this.id,
    required this.ownerId,
    required this.bedTime,
    required this.wakeTime,
    required this.quality,
    this.disturbances = 0,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    this.metadata = const <String, dynamic>{},
    this.deletedAt,
  });

  final String id;
  final String ownerId;
  final DateTime bedTime;
  final DateTime wakeTime;
  final SleepQuality quality;
  final int disturbances;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  /// Computed sleep duration in minutes.
  int get durationMinutes {
    final diff = wakeTime.difference(bedTime).inMinutes;
    return diff < 0 ? 0 : diff;
  }

  /// Formatted duration string, e.g. "7h 30min".
  String get durationFormatted {
    final h = durationMinutes ~/ 60;
    final m = durationMinutes % 60;
    if (m == 0) return '${h}h';
    return '${h}h ${m}min';
  }

  SleepEntry copyWith({
    String? id,
    String? ownerId,
    DateTime? bedTime,
    DateTime? wakeTime,
    SleepQuality? quality,
    int? disturbances,
    String? note,
    bool clearNote = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return SleepEntry(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      bedTime: bedTime ?? this.bedTime,
      wakeTime: wakeTime ?? this.wakeTime,
      quality: quality ?? this.quality,
      disturbances: disturbances ?? this.disturbances,
      note: clearNote ? null : (note ?? this.note),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'ownerId': ownerId,
      'bedTime': bedTime.toIso8601String(),
      'wakeTime': wakeTime.toIso8601String(),
      'quality': quality.value,
      'disturbances': disturbances,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'metadata': metadata,
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  factory SleepEntry.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    final bedTime = _parseDateTime(json['bedTime']) ?? now;
    final wakeTime = _parseDateTime(json['wakeTime']) ?? now;
    return SleepEntry(
      id: (json['id'] ?? '').toString(),
      ownerId: (json['ownerId'] ?? '').toString(),
      bedTime: bedTime,
      wakeTime: wakeTime,
      quality: SleepQuality.fromValue(_parseInt(json['quality']) ?? 3),
      disturbances: (_parseInt(json['disturbances']) ?? 0).clamp(0, 99),
      note: _parseStringOrNull(json['note']),
      createdAt: _parseDateTime(json['createdAt']) ?? bedTime,
      updatedAt: _parseDateTime(json['updatedAt']) ?? bedTime,
      metadata: _parseMetadata(json['metadata']),
      deletedAt: _parseDateTime(json['deletedAt']),
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
