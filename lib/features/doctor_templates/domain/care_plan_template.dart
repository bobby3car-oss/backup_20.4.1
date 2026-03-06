import '../../../domain/timeline_engine.dart';

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
  });

  final String id;
  final String doctorUid;
  final String name;
  final String description;
  final List<TemplateTask> tasks;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'doctorUid': doctorUid,
        'name': name,
        'description': description,
        'tasks': tasks.map((t) => t.toJson()).toList(growable: false),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
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
}

/// A single task definition within a care plan template.
class TemplateTask {
  const TemplateTask({
    required this.title,
    this.subtitle = '',
    required this.type,
    required this.priority,
    this.relativeDayOffset = 0,
    this.dueHours = 24,
  });

  final String title;
  final String subtitle;
  final TaskType type;
  final TaskPriority priority;
  /// Days relative to assignment date (0 = same day, 1 = next day, etc.)
  final int relativeDayOffset;
  /// Hours after scheduled time until the task is due.
  final int dueHours;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'title': title,
        'subtitle': subtitle,
        'type': type.name,
        'priority': priority.name,
        'relativeDayOffset': relativeDayOffset,
        'dueHours': dueHours,
      };

  factory TemplateTask.fromJson(Map<String, dynamic> json) {
    return TemplateTask(
      title: (json['title'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      type: _parseType(json['type']?.toString()),
      priority: _parsePriority(json['priority']?.toString()),
      relativeDayOffset: (json['relativeDayOffset'] as int?) ?? 0,
      dueHours: (json['dueHours'] as int?) ?? 24,
    );
  }

  static TaskType _parseType(String? raw) => switch (raw) {
        'wound' => TaskType.wound,
        'meds' => TaskType.meds,
        'checklist' => TaskType.checklist,
        'appointment' => TaskType.appointment,
        'message' => TaskType.message,
        'custom' => TaskType.custom,
        _ => TaskType.checklist,
      };

  static TaskPriority _parsePriority(String? raw) => switch (raw) {
        'low' => TaskPriority.low,
        'normal' => TaskPriority.normal,
        'high' => TaskPriority.high,
        'critical' => TaskPriority.critical,
        _ => TaskPriority.normal,
      };
}
