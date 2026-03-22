/// Overall mood level (1–5 scale).
enum MoodLevel {
  veryBad,
  bad,
  neutral,
  good,
  veryGood;

  String get label => switch (this) {
        MoodLevel.veryBad => 'Sehr schlecht',
        MoodLevel.bad => 'Schlecht',
        MoodLevel.neutral => 'Neutral',
        MoodLevel.good => 'Gut',
        MoodLevel.veryGood => 'Sehr gut',
      };

  String get emoji => switch (this) {
        MoodLevel.veryBad => '😢',
        MoodLevel.bad => '😞',
        MoodLevel.neutral => '😐',
        MoodLevel.good => '😊',
        MoodLevel.veryGood => '🤩',
      };

  /// Numeric value 1–5 for charts and persistence.
  int get value => index + 1;
}

/// Categories / factors that influence mood.
enum MoodCategory {
  angst,
  traurigkeit,
  motivation,
  schlaf,
  erschoepfung,
  dankbarkeit,
  sonstige;

  String get label => switch (this) {
        MoodCategory.angst => 'Angst',
        MoodCategory.traurigkeit => 'Traurigkeit',
        MoodCategory.motivation => 'Motivation',
        MoodCategory.schlaf => 'Schlaf',
        MoodCategory.erschoepfung => 'Erschöpfung',
        MoodCategory.dankbarkeit => 'Dankbarkeit',
        MoodCategory.sonstige => 'Sonstige',
      };

  String get emoji => switch (this) {
        MoodCategory.angst => '😰',
        MoodCategory.traurigkeit => '😢',
        MoodCategory.motivation => '💪',
        MoodCategory.schlaf => '😴',
        MoodCategory.erschoepfung => '🥱',
        MoodCategory.dankbarkeit => '🙏',
        MoodCategory.sonstige => '❓',
      };
}

class MoodEntry {
  const MoodEntry({
    required this.id,
    required this.ownerId,
    required this.moodLevel,
    this.categories = const <MoodCategory>[],
    this.note,
    this.sleepHours,
    this.sleepQuality,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.metadata = const <String, dynamic>{},
  });

  final String id;
  final String ownerId;
  final MoodLevel moodLevel;
  final List<MoodCategory> categories;
  final String? note;
  final double? sleepHours;
  final int? sleepQuality; // 1–5
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final Map<String, dynamic> metadata;

  bool get isDeleted => deletedAt != null;

  MoodEntry copyWith({
    String? id,
    String? ownerId,
    MoodLevel? moodLevel,
    List<MoodCategory>? categories,
    String? note,
    bool clearNote = false,
    double? sleepHours,
    bool clearSleepHours = false,
    int? sleepQuality,
    bool clearSleepQuality = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
    Map<String, dynamic>? metadata,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      moodLevel: moodLevel ?? this.moodLevel,
      categories: categories ?? this.categories,
      note: clearNote ? null : (note ?? this.note),
      sleepHours: clearSleepHours ? null : (sleepHours ?? this.sleepHours),
      sleepQuality:
          clearSleepQuality ? null : (sleepQuality ?? this.sleepQuality),
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
      'moodLevel': moodLevel.name,
      'categories': categories.map((c) => c.name).toList(growable: false),
      'note': note,
      'sleepHours': sleepHours,
      'sleepQuality': sleepQuality,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    final createdAt = _parseDateTime(json['createdAt']) ?? now;
    return MoodEntry(
      id: (json['id'] ?? '').toString(),
      ownerId: (json['ownerId'] ?? '').toString(),
      moodLevel: _parseMoodLevel(json['moodLevel']) ?? MoodLevel.neutral,
      categories: _parseCategories(json['categories']),
      note: _parseStringOrNull(json['note']),
      sleepHours: _parseDouble(json['sleepHours']),
      sleepQuality: _clampNullable(_parseInt(json['sleepQuality']), 1, 5),
      createdAt: createdAt,
      updatedAt: _parseDateTime(json['updatedAt']) ?? createdAt,
      deletedAt: _parseDateTime(json['deletedAt']),
      metadata: _parseMetadata(json['metadata']),
    );
  }

  // ── Private helpers ──────────────────────────────────────────────────────

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

  static int? _clampNullable(int? value, int min, int max) {
    if (value == null) return null;
    return value.clamp(min, max);
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

  static MoodLevel? _parseMoodLevel(Object? raw) {
    if (raw == null) return null;
    final name = raw.toString().trim();
    if (name.isEmpty) return null;
    return MoodLevel.values.where((e) => e.name == name).firstOrNull;
  }

  static List<MoodCategory> _parseCategories(Object? raw) {
    if (raw is! List) return const <MoodCategory>[];
    final result = <MoodCategory>[];
    for (final item in raw) {
      final name = item.toString().trim();
      final cat =
          MoodCategory.values.where((e) => e.name == name).firstOrNull;
      if (cat != null) result.add(cat);
    }
    return result;
  }
}
