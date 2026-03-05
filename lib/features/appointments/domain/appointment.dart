import 'appointment_enums.dart';

class Appointment {
  const Appointment({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.notes,
    required this.type,
    required this.status,
    required this.startAt,
    this.endAt,
    required this.allDay,
    this.locationName,
    this.locationDetails,
    required this.reminderPreset,
    this.reminderMinutes,
    required this.repeatRule,
    this.repeatUntil,
    required this.createdAt,
    required this.updatedAt,
    this.metadata = const <String, dynamic>{},
    this.priority = AppointmentPriority.medium,
    this.doctorName,
    this.preparation,
  });

  final String id;
  final String ownerId;
  final String title;
  final String notes;
  final AppointmentType type;
  final AppointmentStatus status;
  final DateTime startAt;
  final DateTime? endAt;
  final bool allDay;
  final String? locationName;
  final String? locationDetails;
  final ReminderPreset reminderPreset;
  final int? reminderMinutes;
  final RepeatRule repeatRule;
  final DateTime? repeatUntil;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;
  final AppointmentPriority priority;
  final String? doctorName;
  final String? preparation;

  Appointment copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? notes,
    AppointmentType? type,
    AppointmentStatus? status,
    DateTime? startAt,
    DateTime? endAt,
    bool clearEndAt = false,
    bool? allDay,
    String? locationName,
    bool clearLocationName = false,
    String? locationDetails,
    bool clearLocationDetails = false,
    ReminderPreset? reminderPreset,
    int? reminderMinutes,
    bool clearReminderMinutes = false,
    RepeatRule? repeatRule,
    DateTime? repeatUntil,
    bool clearRepeatUntil = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
    AppointmentPriority? priority,
    String? doctorName,
    bool clearDoctorName = false,
    String? preparation,
    bool clearPreparation = false,
  }) {
    return Appointment(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      type: type ?? this.type,
      status: status ?? this.status,
      startAt: startAt ?? this.startAt,
      endAt: clearEndAt ? null : (endAt ?? this.endAt),
      allDay: allDay ?? this.allDay,
      locationName: clearLocationName
          ? null
          : (locationName ?? this.locationName),
      locationDetails: clearLocationDetails
          ? null
          : (locationDetails ?? this.locationDetails),
      reminderPreset: reminderPreset ?? this.reminderPreset,
      reminderMinutes: clearReminderMinutes
          ? null
          : (reminderMinutes ?? this.reminderMinutes),
      repeatRule: repeatRule ?? this.repeatRule,
      repeatUntil: clearRepeatUntil ? null : (repeatUntil ?? this.repeatUntil),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
      priority: priority ?? this.priority,
      doctorName: clearDoctorName ? null : (doctorName ?? this.doctorName),
      preparation: clearPreparation ? null : (preparation ?? this.preparation),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'ownerId': ownerId,
      'title': title,
      'notes': notes,
      'type': type.name,
      'status': status.name,
      'startAt': startAt.toIso8601String(),
      'endAt': endAt?.toIso8601String(),
      'allDay': allDay,
      'locationName': locationName,
      'locationDetails': locationDetails,
      'reminderPreset': reminderPreset.name,
      'reminderMinutes': reminderMinutes,
      'repeatRule': repeatRule.name,
      'repeatUntil': repeatUntil?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'metadata': metadata,
      'priority': priority.name,
      'doctorName': doctorName,
      'preparation': preparation,
    };
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    final parsedStartAt = _parseDateTime(json['startAt']) ?? now;

    return Appointment(
      id: (json['id'] ?? '').toString(),
      ownerId: (json['ownerId'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      notes: (json['notes'] ?? '').toString(),
      type: _parseEnum<AppointmentType>(
        json['type'],
        AppointmentType.values,
        AppointmentType.other,
      ),
      status: _parseEnum<AppointmentStatus>(
        json['status'],
        AppointmentStatus.values,
        AppointmentStatus.planned,
      ),
      startAt: parsedStartAt,
      endAt: _parseDateTime(json['endAt']),
      allDay: _parseBool(json['allDay']),
      locationName: _parseStringOrNull(json['locationName']),
      locationDetails: _parseStringOrNull(json['locationDetails']),
      reminderPreset: _parseEnum<ReminderPreset>(
        json['reminderPreset'],
        ReminderPreset.values,
        ReminderPreset.none,
      ),
      reminderMinutes: _parseIntOrNull(json['reminderMinutes']),
      repeatRule: _parseEnum<RepeatRule>(
        json['repeatRule'],
        RepeatRule.values,
        RepeatRule.none,
      ),
      repeatUntil: _parseDateTime(json['repeatUntil']),
      createdAt: _parseDateTime(json['createdAt']) ?? parsedStartAt,
      updatedAt: _parseDateTime(json['updatedAt']) ?? parsedStartAt,
      metadata: _parseMetadata(json['metadata']),
      priority: _parseEnum<AppointmentPriority>(
        json['priority'],
        AppointmentPriority.values,
        AppointmentPriority.medium,
      ),
      doctorName: _parseStringOrNull(json['doctorName']),
      preparation: _parseStringOrNull(json['preparation']),
    );
  }

  static T _parseEnum<T>(Object? raw, List<T> values, T fallback) {
    final name = raw?.toString();
    for (final value in values) {
      if (value.toString().split('.').last == name) {
        return value;
      }
    }
    return fallback;
  }

  static DateTime? _parseDateTime(Object? raw) {
    if (raw is String && raw.trim().isNotEmpty) {
      return DateTime.tryParse(raw);
    }
    return null;
  }

  static bool _parseBool(Object? raw) {
    if (raw is bool) return raw;
    if (raw is String) return raw.toLowerCase() == 'true';
    return false;
  }

  static int? _parseIntOrNull(Object? raw) {
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
