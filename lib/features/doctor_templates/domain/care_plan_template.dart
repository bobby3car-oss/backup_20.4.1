import '../../../domain/timeline_engine.dart';

// ── Enums & helper classes ──────────────────────────────────────────────────

/// Time-of-day slot for template tasks.
enum TaskTimeOfDay {
  morning,  // 08:00
  noon,     // 12:00
  evening,  // 18:00
  night;    // 22:00

  int get hour => switch (this) {
        morning => 8,
        noon => 12,
        evening => 18,
        night => 22,
      };

  String get label => switch (this) {
        morning => 'Morgens',
        noon => 'Mittags',
        evening => 'Abends',
        night => 'Nachts',
      };
}

/// Recurrence type for repeating tasks.
enum RecurrenceType { daily, weekdays, everyNDays }

/// Defines how a task repeats across multiple days.
class TaskRecurrence {
  const TaskRecurrence({
    required this.type,
    this.intervalDays = 1,
    required this.count,
  });

  final RecurrenceType type;
  /// Only used when [type] is [RecurrenceType.everyNDays].
  final int intervalDays;
  /// Total number of occurrences.
  final int count;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'type': type.name,
        'intervalDays': intervalDays,
        'count': count,
      };

  factory TaskRecurrence.fromJson(Map<String, dynamic> json) {
    return TaskRecurrence(
      type: _parseType(json['type']?.toString()),
      intervalDays: (json['intervalDays'] as int?) ?? 1,
      count: (json['count'] as int?) ?? 1,
    );
  }

  static RecurrenceType _parseType(String? raw) => switch (raw) {
        'daily' => RecurrenceType.daily,
        'weekdays' => RecurrenceType.weekdays,
        'everyNDays' => RecurrenceType.everyNDays,
        _ => RecurrenceType.daily,
      };
}

/// A named phase within a care plan template (e.g. "Vorbereitung", "Post-OP Woche 1").
class TemplatePhase {
  const TemplatePhase({
    required this.id,
    required this.name,
    required this.order,
  });

  final String id;
  final String name;
  final int order;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'order': order,
      };

  factory TemplatePhase.fromJson(Map<String, dynamic> json) {
    return TemplatePhase(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      order: (json['order'] as int?) ?? 0,
    );
  }
}

// ── CarePlanTemplate ────────────────────────────────────────────────────────

/// A reusable care plan template created by a doctor.
/// Contains a list of task definitions that can be applied to a patient.
class CarePlanTemplate {
  const CarePlanTemplate({
    required this.id,
    required this.doctorUid,
    required this.name,
    required this.description,
    required this.tasks,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
    this.phases = const [],
  });

  final String id;
  final String doctorUid;
  final String name;
  final String description;
  final List<TemplateTask> tasks;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;
  final List<TemplatePhase> phases;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'doctorUid': doctorUid,
        'name': name,
        'description': description,
        'tasks': tasks.map((t) => t.toJson()).toList(growable: false),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'tags': tags,
        'phases': phases.map((p) => p.toJson()).toList(growable: false),
      };

  factory CarePlanTemplate.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return CarePlanTemplate(
      id: (json['id'] ?? '').toString(),
      doctorUid: (json['doctorUid'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      tasks: _parseTasks(json['tasks']),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? now,
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? now,
      tags: _parseTags(json['tags']),
      phases: _parsePhases(json['phases']),
    );
  }

  static List<TemplateTask> _parseTasks(Object? raw) {
    if (raw is List) {
      return raw
          .whereType<Map<String, dynamic>>()
          .map(TemplateTask.fromJson)
          .toList(growable: false);
    }
    return const [];
  }

  static List<String> _parseTags(Object? raw) {
    if (raw is List) {
      return raw.whereType<String>().toList(growable: false);
    }
    return const [];
  }

  static List<TemplatePhase> _parsePhases(Object? raw) {
    if (raw is List) {
      return raw
          .whereType<Map<String, dynamic>>()
          .map(TemplatePhase.fromJson)
          .toList(growable: false);
    }
    return const [];
  }
}

// ── TemplateTask ────────────────────────────────────────────────────────────

/// A single task definition within a care plan template.
class TemplateTask {
  const TemplateTask({
    required this.title,
    this.subtitle = '',
    required this.type,
    required this.priority,
    this.relativeDayOffset = 0,
    this.dueHours = 24,
    this.phaseId,
    this.timeOfDay,
    this.recurrence,
  });

  final String title;
  final String subtitle;
  final TaskType type;
  final TaskPriority priority;
  /// Days relative to assignment date (0 = same day, 1 = next day, etc.)
  final int relativeDayOffset;
  /// Hours after scheduled time until the task is due.
  final int dueHours;
  /// Optional phase this task belongs to.
  final String? phaseId;
  /// Optional specific time of day.
  final TaskTimeOfDay? timeOfDay;
  /// Optional recurrence (null = one-time).
  final TaskRecurrence? recurrence;

  TemplateTask copyWith({
    String? title,
    String? subtitle,
    TaskType? type,
    TaskPriority? priority,
    int? relativeDayOffset,
    int? dueHours,
    String? phaseId,
    bool clearPhaseId = false,
    TaskTimeOfDay? timeOfDay,
    bool clearTimeOfDay = false,
    TaskRecurrence? recurrence,
    bool clearRecurrence = false,
  }) {
    return TemplateTask(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      relativeDayOffset: relativeDayOffset ?? this.relativeDayOffset,
      dueHours: dueHours ?? this.dueHours,
      phaseId: clearPhaseId ? null : (phaseId ?? this.phaseId),
      timeOfDay: clearTimeOfDay ? null : (timeOfDay ?? this.timeOfDay),
      recurrence: clearRecurrence ? null : (recurrence ?? this.recurrence),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'title': title,
        'subtitle': subtitle,
        'type': type.name,
        'priority': priority.name,
        'relativeDayOffset': relativeDayOffset,
        'dueHours': dueHours,
        if (phaseId != null) 'phaseId': phaseId,
        if (timeOfDay != null) 'timeOfDay': timeOfDay!.name,
        if (recurrence != null) 'recurrence': recurrence!.toJson(),
      };

  factory TemplateTask.fromJson(Map<String, dynamic> json) {
    return TemplateTask(
      title: (json['title'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      type: _parseType(json['type']?.toString()),
      priority: _parsePriority(json['priority']?.toString()),
      relativeDayOffset: (json['relativeDayOffset'] as int?) ?? 0,
      dueHours: (json['dueHours'] as int?) ?? 24,
      phaseId: json['phaseId']?.toString(),
      timeOfDay: _parseTimeOfDay(json['timeOfDay']?.toString()),
      recurrence: json['recurrence'] is Map<String, dynamic>
          ? TaskRecurrence.fromJson(json['recurrence'] as Map<String, dynamic>)
          : null,
    );
  }

  static TaskType _parseType(String? raw) => switch (raw) {
        'wound' => TaskType.wound,
        'meds' => TaskType.meds,
        'checklist' => TaskType.checklist,
        'appointment' => TaskType.appointment,
        'message' => TaskType.message,
        'custom' => TaskType.custom,
        'note' => TaskType.note,
        'nutrition' => TaskType.nutrition,
        _ => TaskType.checklist,
      };

  static TaskPriority _parsePriority(String? raw) => switch (raw) {
        'low' => TaskPriority.low,
        'normal' => TaskPriority.normal,
        'high' => TaskPriority.high,
        'critical' => TaskPriority.critical,
        _ => TaskPriority.normal,
      };

  static TaskTimeOfDay? _parseTimeOfDay(String? raw) => switch (raw) {
        'morning' => TaskTimeOfDay.morning,
        'noon' => TaskTimeOfDay.noon,
        'evening' => TaskTimeOfDay.evening,
        'night' => TaskTimeOfDay.night,
        _ => null,
      };
}
