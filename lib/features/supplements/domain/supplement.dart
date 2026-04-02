import '../../medication/domain/medication_reminder.dart';
import 'supplement_category.dart';

/// A supplement reminder (scheduled supplement with time slots).
///
/// Reuses [MedicationTimeSlot], [SlotConfig], and [RepeatPattern]
/// from the medication module for consistency.
class Supplement {
  const Supplement({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.category,
    required this.slots,
    required this.isEnabled,
    required this.createdAt,
    required this.updatedAt,
    this.brand,
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
  final String name;
  final SupplementCategory category;

  /// Optional brand / manufacturer.
  final String? brand;

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

  /// Total stock count (e.g. number of capsules in the package).
  final int? totalCount;

  /// Remaining stock count.
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

  /// Display label combining name + optional brand.
  String get displayName {
    if (brand != null && brand!.isNotEmpty) {
      return '$name ($brand)';
    }
    return name;
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

  /// Whether the supplement should be taken on [date] given its repeat pattern.
  bool occursOn(DateTime date) {
    if (isDeleted || !isEnabled) return false;
    if (endDate != null &&
        date.isAfter(
          DateTime(endDate!.year, endDate!.month, endDate!.day, 23, 59, 59),
        )) {
      return false;
    }

    final dateOnly = DateTime(date.year, date.month, date.day);
    final originOnly =
        DateTime(createdAt.year, createdAt.month, createdAt.day);
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
      'name': name,
      'category': category.name,
      if (brand != null) 'brand': brand,
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

  factory Supplement.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    final createdAt = _parseDateTime(json['createdAt']) ?? now;
    final slots = _parseSlots(json);
    return Supplement(
      id: (json['id'] ?? '').toString(),
      ownerId: (json['ownerId'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      category: SupplementCategory.fromName(json['category']?.toString()),
      brand: _parseStringOrNull(json['brand']),
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
    // Default: morning slot enabled.
    return {
      MedicationTimeSlot.morgens:
          SlotConfig.defaultFor(MedicationTimeSlot.morgens),
    };
  }

  Supplement copyWith({
    String? id,
    String? ownerId,
    String? name,
    SupplementCategory? category,
    String? brand,
    bool clearBrand = false,
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
    return Supplement(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      category: category ?? this.category,
      brand: clearBrand ? null : (brand ?? this.brand),
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

