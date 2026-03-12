/// A practice-internal event that belongs to a doctor (not tied to a patient).
class DoctorEvent {
  const DoctorEvent({
    required this.id,
    required this.title,
    this.notes = '',
    required this.startAt,
    this.endAt,
    this.allDay = false,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String notes;
  final DateTime startAt;
  final DateTime? endAt;
  final bool allDay;
  final DateTime createdAt;
  final DateTime updatedAt;

  DoctorEvent copyWith({
    String? id,
    String? title,
    String? notes,
    DateTime? startAt,
    DateTime? endAt,
    bool clearEndAt = false,
    bool? allDay,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DoctorEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      startAt: startAt ?? this.startAt,
      endAt: clearEndAt ? null : (endAt ?? this.endAt),
      allDay: allDay ?? this.allDay,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'notes': notes,
      'startAt': startAt.toIso8601String(),
      'endAt': endAt?.toIso8601String(),
      'allDay': allDay,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory DoctorEvent.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    final parsedStart = DateTime.tryParse(
            (json['startAt'] ?? '').toString()) ??
        now;
    return DoctorEvent(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      notes: (json['notes'] ?? '').toString(),
      startAt: parsedStart,
      endAt: DateTime.tryParse((json['endAt'] ?? '').toString()),
      allDay: json['allDay'] == true,
      createdAt: DateTime.tryParse(
              (json['createdAt'] ?? '').toString()) ??
          parsedStart,
      updatedAt: DateTime.tryParse(
              (json['updatedAt'] ?? '').toString()) ??
          parsedStart,
    );
  }
}
