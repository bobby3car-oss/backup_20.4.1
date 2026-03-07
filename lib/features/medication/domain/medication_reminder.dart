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
      metadata: metadata ?? this.metadata,
    );
  }

  bool get isDeleted => deletedAt != null;

  String get timeLabel {
    final hh = hour.toString().padLeft(2, '0');
    final mm = minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  DateTime nextOccurrence([DateTime? from]) {
    final now = from ?? DateTime.now();
    var candidate = DateTime(now.year, now.month, now.day, hour, minute);
    if (!candidate.isAfter(now)) {
      candidate = candidate.add(const Duration(days: 1));
    }
    return candidate;
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
