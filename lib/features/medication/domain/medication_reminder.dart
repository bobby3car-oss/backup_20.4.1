enum RepeatPattern {
  daily,
  everyOtherDay,
  weekly,
  asNeeded,
  custom;

  String get label => switch (this) {
    daily => 'Täglich',
    everyOtherDay => 'Jeden 2. Tag',
    weekly => 'Wöchentlich',
    asNeeded => 'Bei Bedarf',
    custom => 'Benutzerdefiniert',
  };

  static RepeatPattern fromName(String? name) {
    if (name == null || name.isEmpty) return daily;
    return RepeatPattern.values.firstWhere(
      (e) => e.name == name,
      orElse: () => daily,
    );
  }
}

class MedicationReminder {
  const MedicationReminder({
    required this.id,
    required this.ownerId,
    required this.medicationName,
    required this.hour,
    required this.minute,
    required this.isEnabled,
    required this.createdAt,
    required this.updatedAt,
    this.dose,
    this.note,
    this.deletedAt,
    this.repeatPattern = RepeatPattern.daily,
    this.repeatDays,
    this.endDate,
    this.totalCount,
    this.remainingCount,
    this.metadata = const <String, dynamic>{},
  });

  final String id;
  final String ownerId;
  final String medicationName;
  final String? dose;
  final String? note;
  final int hour;
  final int minute;
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final RepeatPattern repeatPattern;
  final List<int>? repeatDays; // 1=Mo .. 7=So (ISO weekday)
  final DateTime? endDate;
  final int? totalCount;
  final int? remainingCount;
  final Map<String, dynamic> metadata;

  MedicationReminder copyWith({
    String? id,
    String? ownerId,
    String? medicationName,
    String? dose,
    bool clearDose = false,
    String? note,
    bool clearNote = false,
    int? hour,
    int? minute,
    bool? isEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
    RepeatPattern? repeatPattern,
    List<int>? repeatDays,
    bool clearRepeatDays = false,
    DateTime? endDate,
    bool clearEndDate = false,
    int? totalCount,
    bool clearTotalCount = false,
    int? remainingCount,
    bool clearRemainingCount = false,
    Map<String, dynamic>? metadata,
  }) {
    return MedicationReminder(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      medicationName: medicationName ?? this.medicationName,
      dose: clearDose ? null : (dose ?? this.dose),
      note: clearNote ? null : (note ?? this.note),
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
      repeatPattern: repeatPattern ?? this.repeatPattern,
      repeatDays: clearRepeatDays ? null : (repeatDays ?? this.repeatDays),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      totalCount: clearTotalCount ? null : (totalCount ?? this.totalCount),
      remainingCount:
          clearRemainingCount ? null : (remainingCount ?? this.remainingCount),
      metadata: metadata ?? this.metadata,
    );
  }

  bool get isDeleted => deletedAt != null;

  /// True when [endDate] is set and already in the past.
  bool get isExpired {
    if (endDate == null) return false;
    return DateTime.now().isAfter(
      DateTime(endDate!.year, endDate!.month, endDate!.day, 23, 59, 59),
    );
  }

  /// True when stock tracking is active and supply is completely gone.
  bool get isStockEmpty => remainingCount != null && remainingCount! <= 0;

  /// True when stock tracking is active and remaining count is low but not zero.
  bool get isStockLow => remainingCount != null && remainingCount! > 0 && remainingCount! < 5;

  String get timeLabel {
    final hh = hour.toString().padLeft(2, '0');
    final mm = minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  /// Returns a human-readable label for the repeat pattern + days.
  String get repeatLabel {
    if (repeatPattern == RepeatPattern.custom && repeatDays != null && repeatDays!.isNotEmpty) {
      const dayNames = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
      final sorted = List<int>.from(repeatDays!)..sort();
      final names = sorted
          .where((d) => d >= 1 && d <= 7)
          .map((d) => dayNames[d - 1])
          .toList();
      return names.join(', ');
    }
    return repeatPattern.label;
  }

  /// Computes the next occurrence respecting [repeatPattern], [repeatDays] and [endDate].
  DateTime nextOccurrence([DateTime? from]) {
    final now = from ?? DateTime.now();

    if (repeatPattern == RepeatPattern.asNeeded) {
      // "Bei Bedarf" – show the next time slot but don't enforce recurrence.
      var candidate = DateTime(now.year, now.month, now.day, hour, minute);
      if (!candidate.isAfter(now)) {
        candidate = candidate.add(const Duration(days: 1));
      }
      return _clampToEnd(candidate);
    }

    if (repeatPattern == RepeatPattern.custom && repeatDays != null && repeatDays!.isNotEmpty) {
      return _nextForCustomDays(now);
    }

    final stepDays = switch (repeatPattern) {
      RepeatPattern.everyOtherDay => 2,
      RepeatPattern.weekly => 7,
      _ => 1,
    };

    var candidate = DateTime(now.year, now.month, now.day, hour, minute);

    if (stepDays == 1) {
      // Daily: just check if today's time has passed.
      if (!candidate.isAfter(now)) {
        candidate = candidate.add(const Duration(days: 1));
      }
      return _clampToEnd(candidate);
    }

    // For everyOtherDay / weekly: find the next aligned day from today.
    final origin = DateTime(createdAt.year, createdAt.month, createdAt.day);
    final daysSinceOrigin =
        DateTime(now.year, now.month, now.day).difference(origin).inDays;
    final remainder = daysSinceOrigin % stepDays;

    if (remainder == 0) {
      // Today is an aligned day.
      if (candidate.isAfter(now)) return _clampToEnd(candidate);
      // Time already passed — advance to the next aligned day.
      candidate = candidate.add(Duration(days: stepDays));
    } else {
      // Today is not aligned — advance to the next aligned day.
      candidate = candidate.add(Duration(days: stepDays - remainder));
    }
    return _clampToEnd(candidate);
  }

  /// Whether the reminder should fire on [date] given its repeat pattern.
  bool occursOn(DateTime date) {
    if (isDeleted || !isEnabled) return false;
    if (endDate != null && date.isAfter(
      DateTime(endDate!.year, endDate!.month, endDate!.day, 23, 59, 59),
    )) {
      return false;
    }

    final dateOnly = DateTime(date.year, date.month, date.day);
    final originOnly = DateTime(createdAt.year, createdAt.month, createdAt.day);
    if (dateOnly.isBefore(originOnly)) return false;

    switch (repeatPattern) {
      case RepeatPattern.daily:
        return true;
      case RepeatPattern.everyOtherDay:
        return dateOnly.difference(originOnly).inDays % 2 == 0;
      case RepeatPattern.weekly:
        return dateOnly.difference(originOnly).inDays % 7 == 0;
      case RepeatPattern.asNeeded:
        return true; // shown every day, user decides
      case RepeatPattern.custom:
        if (repeatDays == null || repeatDays!.isEmpty) return false;
        return repeatDays!.contains(date.weekday);
    }
  }

  DateTime _nextForCustomDays(DateTime now) {
    final sorted = List<int>.from(repeatDays!)..sort();
    // Try today first if time hasn't passed, then check the next 2 weeks.
    final candidate = DateTime(now.year, now.month, now.day, hour, minute);
    for (var offset = 0; offset < 14; offset++) {
      final test = candidate.add(Duration(days: offset));
      if (sorted.contains(test.weekday) && test.isAfter(now)) {
        return _clampToEnd(test);
      }
    }
    // Should never reach here with valid repeatDays, but safe fallback.
    return _clampToEnd(candidate.add(const Duration(days: 1)));
  }

  DateTime _clampToEnd(DateTime dt) {
    if (endDate == null) return dt;
    final lastSlot = DateTime(endDate!.year, endDate!.month, endDate!.day, hour, minute);
    return dt.isAfter(lastSlot) ? lastSlot : dt;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'ownerId': ownerId,
      'medicationName': medicationName,
      'dose': dose,
      'note': note,
      'hour': hour,
      'minute': minute,
      'isEnabled': isEnabled,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (deletedAt != null) 'deletedAt': deletedAt!.toIso8601String(),
      'repeatPattern': repeatPattern.name,
      if (repeatDays != null) 'repeatDays': repeatDays,
      if (endDate != null) 'endDate': endDate!.toIso8601String(),
      if (totalCount != null) 'totalCount': totalCount,
      if (remainingCount != null) 'remainingCount': remainingCount,
      'metadata': metadata,
    };
  }

  factory MedicationReminder.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    final createdAt = _parseDateTime(json['createdAt']) ?? now;
    return MedicationReminder(
      id: (json['id'] ?? '').toString(),
      ownerId: (json['ownerId'] ?? '').toString(),
      medicationName: (json['medicationName'] ?? json['name'] ?? '').toString(),
      dose: _parseStringOrNull(json['dose']),
      note: _parseStringOrNull(json['note']),
      hour: _parseInt(json['hour']),
      minute: _parseInt(json['minute']),
      isEnabled: json['isEnabled'] as bool? ?? true,
      createdAt: createdAt,
      updatedAt: _parseDateTime(json['updatedAt']) ?? createdAt,
      deletedAt: _parseDateTime(json['deletedAt']),
      repeatPattern: RepeatPattern.fromName(json['repeatPattern']?.toString()),
      repeatDays: _parseIntList(json['repeatDays']),
      endDate: _parseDateTime(json['endDate']),
      totalCount: _parseIntOrNull(json['totalCount']),
      remainingCount: _parseIntOrNull(json['remainingCount']),
      metadata: _parseMetadata(json['metadata']),
    );
  }

  static DateTime? _parseDateTime(Object? raw) {
    if (raw is String && raw.trim().isNotEmpty) return DateTime.tryParse(raw);
    return null;
  }

  static String? _parseStringOrNull(Object? raw) {
    if (raw == null) return null;
    final value = raw.toString().trim();
    return value.isEmpty ? null : value;
  }

  static int _parseInt(Object? raw) {
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw) ?? 0;
    return 0;
  }

  static int? _parseIntOrNull(Object? raw) {
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw);
    return null;
  }

  static List<int>? _parseIntList(Object? raw) {
    if (raw == null) return null;
    if (raw is List) {
      final list = raw
          .map((dynamic e) {
            if (e is int) return e;
            if (e is num) return e.toInt();
            if (e is String) return int.tryParse(e);
            return null;
          })
          .whereType<int>()
          .toList();
      return list.isEmpty ? null : list;
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
