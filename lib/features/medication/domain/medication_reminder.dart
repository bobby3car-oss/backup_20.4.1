/// The four named intake windows used in the EMP-style medication plan.
enum MedicationTimeSlot {
  morgens,
  mittags,
  abends,
  nachts;

  String get label => switch (this) {
    morgens => 'Morgens',
    mittags => 'Mittags',
    abends => 'Abends',
    nachts => 'Nachts',
  };

  String get emoji => switch (this) {
    morgens => '☀️',
    mittags => '🌤',
    abends => '🌙',
    nachts => '🌑',
  };

  int get defaultHour => switch (this) {
    morgens => 8,
    mittags => 12,
    abends => 18,
    nachts => 22,
  };

  /// Maps a 24-hour value to the closest time slot.
  /// 5–10 → morgens, 11–15 → mittags, 16–20 → abends, else → nachts.
  static MedicationTimeSlot fromHour(int hour) {
    if (hour >= 5 && hour < 11) return morgens;
    if (hour >= 11 && hour < 16) return mittags;
    if (hour >= 16 && hour < 21) return abends;
    return nachts;
  }

  static MedicationTimeSlot fromName(String? name) {
    if (name == null) return morgens;
    return MedicationTimeSlot.values.firstWhere(
      (e) => e.name == name,
      orElse: () => morgens,
    );
  }
}

/// Per-slot timing and optional dose override.
class SlotConfig {
  const SlotConfig({
    required this.isEnabled,
    this.dose,
    required this.hour,
    required this.minute,
  });

  final bool isEnabled;

  /// Slot-specific dose; if null, falls back to [MedicationReminder.dose].
  final String? dose;
  final int hour;
  final int minute;

  String get timeLabel =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  SlotConfig copyWith({
    bool? isEnabled,
    String? dose,
    bool clearDose = false,
    int? hour,
    int? minute,
  }) {
    return SlotConfig(
      isEnabled: isEnabled ?? this.isEnabled,
      dose: clearDose ? null : (dose ?? this.dose),
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'isEnabled': isEnabled,
    if (dose != null) 'dose': dose,
    'hour': hour,
    'minute': minute,
  };

  factory SlotConfig.fromJson(Map<String, dynamic> json) {
    return SlotConfig(
      isEnabled: json['isEnabled'] as bool? ?? true,
      dose: _parseStringOrNull(json['dose']),
      hour: _parseInt(json['hour']),
      minute: _parseInt(json['minute']),
    );
  }

  factory SlotConfig.defaultFor(MedicationTimeSlot slot) {
    return SlotConfig(isEnabled: true, hour: slot.defaultHour, minute: 0);
  }

  static String? _parseStringOrNull(Object? raw) {
    if (raw == null) return null;
    final v = raw.toString().trim();
    return v.isEmpty ? null : v;
  }

  static int _parseInt(Object? raw) {
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw) ?? 0;
    return 0;
  }
}

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
    required this.slots,
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

  /// Default dose label. Individual slots may override this.
  final String? dose;
  final String? note;

  /// The four time-slot configurations. At least one should be enabled.
  final Map<MedicationTimeSlot, SlotConfig> slots;

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

  // ── Convenience getters ──────────────────────────────────────────────

  bool get isDeleted => deletedAt != null;

  bool get isExpired {
    if (endDate == null) return false;
    return DateTime.now().isAfter(
      DateTime(endDate!.year, endDate!.month, endDate!.day, 23, 59, 59),
    );
  }

  bool get isStockEmpty => remainingCount != null && remainingCount! <= 0;

  bool get isStockLow =>
      remainingCount != null && remainingCount! > 0 && remainingCount! < 5;

  /// All time slots that are currently enabled, ordered by day position.
  List<MedicationTimeSlot> get enabledSlots =>
      MedicationTimeSlot.values
          .where((s) => slots[s]?.isEnabled == true)
          .toList();

  /// Time label of the earliest active slot, or '--:--' if none.
  String get timeLabel {
    final first = enabledSlots.firstOrNull;
    if (first == null) return '--:--';
    return slots[first]!.timeLabel;
  }

  String get repeatLabel {
    if (repeatPattern == RepeatPattern.custom &&
        repeatDays != null &&
        repeatDays!.isNotEmpty) {
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

  // ── Next-occurrence helpers ──────────────────────────────────────────

  /// Returns the next scheduled intake across all enabled slots.
  DateTime nextOccurrence([DateTime? from]) {
    final now = from ?? DateTime.now();
    DateTime? earliest;
    for (final slot in MedicationTimeSlot.values) {
      final next = nextOccurrenceForSlot(slot, now);
      if (next != null && (earliest == null || next.isBefore(earliest))) {
        earliest = next;
      }
    }
    return earliest ?? now.add(const Duration(days: 1));
  }

  /// Returns the next scheduled occurrence for a specific [slot], or null
  /// if the slot is not active.
  DateTime? nextOccurrenceForSlot(MedicationTimeSlot slot, [DateTime? from]) {
    final config = slots[slot];
    if (config == null || !config.isEnabled) return null;

    final now = from ?? DateTime.now();
    final h = config.hour;
    final m = config.minute;

    if (repeatPattern == RepeatPattern.asNeeded) {
      var candidate = DateTime(now.year, now.month, now.day, h, m);
      if (!candidate.isAfter(now)) {
        candidate = candidate.add(const Duration(days: 1));
      }
      return _clampToEnd(candidate, h, m);
    }

    if (repeatPattern == RepeatPattern.custom &&
        repeatDays != null &&
        repeatDays!.isNotEmpty) {
      return _nextForCustomDays(now, h, m);
    }

    final stepDays = switch (repeatPattern) {
      RepeatPattern.everyOtherDay => 2,
      RepeatPattern.weekly => 7,
      _ => 1,
    };

    var candidate = DateTime(now.year, now.month, now.day, h, m);

    if (stepDays == 1) {
      if (!candidate.isAfter(now)) {
        candidate = candidate.add(const Duration(days: 1));
      }
      return _clampToEnd(candidate, h, m);
    }

    final origin = DateTime(createdAt.year, createdAt.month, createdAt.day);
    final daysSinceOrigin =
        DateTime(now.year, now.month, now.day).difference(origin).inDays;
    final remainder = daysSinceOrigin % stepDays;

    if (remainder == 0) {
      if (candidate.isAfter(now)) return _clampToEnd(candidate, h, m);
      candidate = candidate.add(Duration(days: stepDays));
    } else {
      candidate = candidate.add(Duration(days: stepDays - remainder));
    }
    return _clampToEnd(candidate, h, m);
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
        return true;
      case RepeatPattern.custom:
        if (repeatDays == null || repeatDays!.isEmpty) return false;
        return repeatDays!.contains(date.weekday);
    }
  }

  DateTime _nextForCustomDays(DateTime now, int hour, int minute) {
    final sorted = List<int>.from(repeatDays!)..sort();
    final candidate = DateTime(now.year, now.month, now.day, hour, minute);
    for (var offset = 0; offset < 14; offset++) {
      final test = candidate.add(Duration(days: offset));
      if (sorted.contains(test.weekday) && test.isAfter(now)) {
        return _clampToEnd(test, hour, minute);
      }
    }
    return _clampToEnd(candidate.add(const Duration(days: 1)), hour, minute);
  }

  DateTime _clampToEnd(DateTime dt, int hour, int minute) {
    if (endDate == null) return dt;
    final lastSlot = DateTime(
      endDate!.year,
      endDate!.month,
      endDate!.day,
      hour,
      minute,
    );
    return dt.isAfter(lastSlot) ? lastSlot : dt;
  }

  // ── Serialisation ────────────────────────────────────────────────────

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'ownerId': ownerId,
      'medicationName': medicationName,
      'dose': dose,
      'note': note,
      'slots': <String, dynamic>{
        for (final entry in slots.entries) entry.key.name: entry.value.toJson(),
      },
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
    final slots = _parseSlots(json);
    return MedicationReminder(
      id: (json['id'] ?? '').toString(),
      ownerId: (json['ownerId'] ?? '').toString(),
      medicationName: (json['medicationName'] ?? json['name'] ?? '').toString(),
      dose: _parseStringOrNull(json['dose']),
      note: _parseStringOrNull(json['note']),
      slots: slots,
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

  /// Parses slots from JSON, automatically migrating from the legacy
  /// single-time format (had top-level `hour`/`minute`).
  static Map<MedicationTimeSlot, SlotConfig> _parseSlots(
    Map<String, dynamic> json,
  ) {
    final raw = json['slots'];
    if (raw is Map && raw.isNotEmpty) {
      final mapped = <MedicationTimeSlot, SlotConfig>{};
      for (final entry in raw.entries) {
        final slotKey = MedicationTimeSlot.values.firstWhere(
          (e) => e.name == entry.key,
          orElse: () => MedicationTimeSlot.morgens,
        );
        if (entry.value is Map) {
          mapped[slotKey] = SlotConfig.fromJson(
            Map<String, dynamic>.from(entry.value as Map),
          );
        }
      }
      if (mapped.isNotEmpty) return mapped;
    }
    // ── Migration: derive a single slot from the old hour/minute fields ──
    final hour = _parseInt(json['hour']);
    final minute = _parseInt(json['minute']);
    final dose = _parseStringOrNull(json['dose']);
    final slot = MedicationTimeSlot.fromHour(hour);
    return {
      slot: SlotConfig(
        isEnabled: json['isEnabled'] as bool? ?? true,
        dose: dose,
        hour: hour,
        minute: minute,
      ),
    };
  }

  MedicationReminder copyWith({
    String? id,
    String? ownerId,
    String? medicationName,
    String? dose,
    bool clearDose = false,
    String? note,
    bool clearNote = false,
    Map<MedicationTimeSlot, SlotConfig>? slots,
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
      slots: slots ?? this.slots,
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
