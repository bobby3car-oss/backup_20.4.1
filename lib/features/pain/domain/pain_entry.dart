/// Describes the quality / type of pain.
enum PainType {
  stechend,   // stabbing
  dumpf,      // dull
  brennend,   // burning
  ziehend,    // pulling
  pochend,    // throbbing
  drueckend,  // pressing
  kramphaft,  // crampy
  sonstige;   // other

  String get label => switch (this) {
        PainType.stechend => 'Stechend',
        PainType.dumpf => 'Dumpf',
        PainType.brennend => 'Brennend',
        PainType.ziehend => 'Ziehend',
        PainType.pochend => 'Pochend',
        PainType.drueckend => 'Drückend',
        PainType.kramphaft => 'Krampfartig',
        PainType.sonstige => 'Sonstige',
      };

  String get emoji => switch (this) {
        PainType.stechend => '🔪',
        PainType.dumpf => '😶',
        PainType.brennend => '🔥',
        PainType.ziehend => '↔️',
        PainType.pochend => '💓',
        PainType.drueckend => '👊',
        PainType.kramphaft => '⚡',
        PainType.sonstige => '❓',
      };
}

/// Body region where pain is located.
enum BodyRegion {
  kopf,
  hals,
  schulter,
  brust,
  oberarm,
  unterarm,
  hand,
  bauch,
  ruecken,
  huefteLbr,
  oberschenkel,
  knie,
  unterschenkel,
  fuss,
  sonstige;

  String get label => switch (this) {
        BodyRegion.kopf => 'Kopf',
        BodyRegion.hals => 'Hals / Nacken',
        BodyRegion.schulter => 'Schulter',
        BodyRegion.brust => 'Brust',
        BodyRegion.oberarm => 'Oberarm',
        BodyRegion.unterarm => 'Unterarm',
        BodyRegion.hand => 'Hand',
        BodyRegion.bauch => 'Bauch',
        BodyRegion.ruecken => 'Rücken',
        BodyRegion.huefteLbr => 'Hüfte',
        BodyRegion.oberschenkel => 'Oberschenkel',
        BodyRegion.knie => 'Knie',
        BodyRegion.unterschenkel => 'Unterschenkel',
        BodyRegion.fuss => 'Fuß',
        BodyRegion.sonstige => 'Sonstige',
      };

  String get emoji => switch (this) {
        BodyRegion.kopf => '🧠',
        BodyRegion.hals => '🦒',
        BodyRegion.schulter => '💪',
        BodyRegion.brust => '🫁',
        BodyRegion.oberarm => '💪',
        BodyRegion.unterarm => '🦾',
        BodyRegion.hand => '🤚',
        BodyRegion.bauch => '🫃',
        BodyRegion.ruecken => '🔙',
        BodyRegion.huefteLbr => '🦴',
        BodyRegion.oberschenkel => '🦵',
        BodyRegion.knie => '🦵',
        BodyRegion.unterschenkel => '🦶',
        BodyRegion.fuss => '🦶',
        BodyRegion.sonstige => '📍',
      };
}

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
    this.painType,
    this.bodyRegion,
    this.durationMinutes,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
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
  final PainType? painType;
  final BodyRegion? bodyRegion;
  final int? durationMinutes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final Map<String, dynamic> metadata;

  bool get isDeleted => deletedAt != null;

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
    PainType? painType,
    bool clearPainType = false,
    BodyRegion? bodyRegion,
    bool clearBodyRegion = false,
    int? durationMinutes,
    bool clearDurationMinutes = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
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
      painType: clearPainType ? null : (painType ?? this.painType),
      bodyRegion: clearBodyRegion ? null : (bodyRegion ?? this.bodyRegion),
      durationMinutes: clearDurationMinutes
          ? null
          : (durationMinutes ?? this.durationMinutes),
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
      'occurredAt': occurredAt.toIso8601String(),
      'painLevel': painLevel,
      'location': location,
      'note': note,
      'trigger': trigger,
      'medicationTaken': medicationTaken,
      'painType': painType?.name,
      'bodyRegion': bodyRegion?.name,
      'durationMinutes': durationMinutes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
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
      painType: _parsePainType(json['painType']),
      bodyRegion: _parseBodyRegion(json['bodyRegion']),
      durationMinutes: _parseInt(json['durationMinutes']),
      createdAt: _parseDateTime(json['createdAt']) ?? occurredAt,
      updatedAt: _parseDateTime(json['updatedAt']) ?? occurredAt,
      deletedAt: _parseDateTime(json['deletedAt']),
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

  static PainType? _parsePainType(Object? raw) {
    if (raw == null) return null;
    final name = raw.toString().trim();
    if (name.isEmpty) return null;
    return PainType.values.where((e) => e.name == name).firstOrNull;
  }

  static BodyRegion? _parseBodyRegion(Object? raw) {
    if (raw == null) return null;
    final name = raw.toString().trim();
    if (name.isEmpty) return null;
    return BodyRegion.values.where((e) => e.name == name).firstOrNull;
  }
}
