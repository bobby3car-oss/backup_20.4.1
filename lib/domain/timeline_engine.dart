enum TaskState { planned, due, inProgress, done, skipped }

enum TaskType { wound, meds, checklist, appointment, message, custom }

enum TaskPriority { low, normal, high, critical }

class TimelineItem {
  const TimelineItem({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.scheduledAt,
    this.dueAt,
    required this.priority,
    required this.state,
    required this.deeplinkRoute,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.doneAt,
    this.skippedAt,
  });

  final String id;
  final TaskType type;
  final String title;
  final String subtitle;
  final DateTime scheduledAt;
  final DateTime? dueAt;
  final TaskPriority priority;
  final TaskState state;
  final String deeplinkRoute;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? doneAt;
  final DateTime? skippedAt;

  TimelineItem copyWith({
    String? id,
    TaskType? type,
    String? title,
    String? subtitle,
    DateTime? scheduledAt,
    DateTime? dueAt,
    bool clearDueAt = false,
    TaskPriority? priority,
    TaskState? state,
    String? deeplinkRoute,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? doneAt,
    bool clearDoneAt = false,
    DateTime? skippedAt,
    bool clearSkippedAt = false,
  }) {
    return TimelineItem(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      dueAt: clearDueAt ? null : (dueAt ?? this.dueAt),
      priority: priority ?? this.priority,
      state: state ?? this.state,
      deeplinkRoute: deeplinkRoute ?? this.deeplinkRoute,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      doneAt: clearDoneAt ? null : (doneAt ?? this.doneAt),
      skippedAt: clearSkippedAt ? null : (skippedAt ?? this.skippedAt),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'type': type.name,
      'title': title,
      'subtitle': subtitle,
      'scheduledAt': scheduledAt.toIso8601String(),
      'dueAt': dueAt?.toIso8601String(),
      'priority': priority.name,
      'state': state.name,
      'deeplinkRoute': deeplinkRoute,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'doneAt': doneAt?.toIso8601String(),
      'skippedAt': skippedAt?.toIso8601String(),
    };
  }

  factory TimelineItem.fromJson(Map<String, dynamic> json) {
    return TimelineItem(
      id: json['id'] as String,
      type: _taskTypeFromString(json['type'] as String?),
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      dueAt: _parseDateTime(json['dueAt']),
      priority: _taskPriorityFromString(json['priority'] as String?),
      state: _taskStateFromString(json['state'] as String?),
      deeplinkRoute: json['deeplinkRoute'] as String? ?? '',
      metadata: _metadataFrom(json['metadata']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      doneAt: _parseDateTime(json['doneAt']),
      skippedAt: _parseDateTime(json['skippedAt']),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimelineItem &&
        other.id == id &&
        other.type == type &&
        other.title == title &&
        other.subtitle == subtitle &&
        other.scheduledAt == scheduledAt &&
        other.dueAt == dueAt &&
        other.priority == priority &&
        other.state == state &&
        other.deeplinkRoute == deeplinkRoute &&
        _mapEquals(other.metadata, metadata) &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.doneAt == doneAt &&
        other.skippedAt == skippedAt;
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    title,
    subtitle,
    scheduledAt,
    dueAt,
    priority,
    state,
    deeplinkRoute,
    Object.hashAll(_stableMetadataEntries(metadata)),
    createdAt,
    updatedAt,
    doneAt,
    skippedAt,
  );
}

TaskState computeState(TimelineItem item, DateTime now) {
  if (item.state == TaskState.done) return TaskState.done;
  if (item.state == TaskState.skipped) return TaskState.skipped;

  final dueAt = item.dueAt;
  if (dueAt != null && !now.isBefore(dueAt)) {
    return TaskState.due;
  }

  if (dueAt != null && !now.isBefore(item.scheduledAt) && now.isBefore(dueAt)) {
    return TaskState.inProgress;
  }

  return TaskState.planned;
}

bool isDue(TimelineItem item, DateTime now) {
  if (item.state == TaskState.done || item.state == TaskState.skipped) {
    return false;
  }
  final dueAt = item.dueAt;
  return dueAt != null && !now.isBefore(dueAt);
}

List<TimelineItem> sortItems(List<TimelineItem> items) {
  final sorted = List<TimelineItem>.from(items);
  sorted.sort((a, b) {
    final bySchedule = a.scheduledAt.compareTo(b.scheduledAt);
    if (bySchedule != 0) return bySchedule;
    return _priorityWeight(b.priority).compareTo(_priorityWeight(a.priority));
  });
  return sorted;
}

int _priorityWeight(TaskPriority priority) {
  switch (priority) {
    case TaskPriority.low:
      return 0;
    case TaskPriority.normal:
      return 1;
    case TaskPriority.high:
      return 2;
    case TaskPriority.critical:
      return 3;
  }
}

TaskState _taskStateFromString(String? value) {
  switch (value) {
    case 'planned':
      return TaskState.planned;
    case 'due':
      return TaskState.due;
    case 'inProgress':
      return TaskState.inProgress;
    case 'done':
      return TaskState.done;
    case 'skipped':
      return TaskState.skipped;
    default:
      return TaskState.planned;
  }
}

TaskType _taskTypeFromString(String? value) {
  switch (value) {
    case 'wound':
      return TaskType.wound;
    case 'meds':
      return TaskType.meds;
    case 'checklist':
      return TaskType.checklist;
    case 'appointment':
      return TaskType.appointment;
    case 'message':
      return TaskType.message;
    case 'custom':
      return TaskType.custom;
    default:
      return TaskType.custom;
  }
}

TaskPriority _taskPriorityFromString(String? value) {
  switch (value) {
    case 'low':
      return TaskPriority.low;
    case 'normal':
      return TaskPriority.normal;
    case 'high':
      return TaskPriority.high;
    case 'critical':
      return TaskPriority.critical;
    default:
      return TaskPriority.normal;
  }
}

DateTime? _parseDateTime(Object? value) {
  if (value == null) return null;
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value);
}

Map<String, dynamic> _metadataFrom(Object? value) {
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return const <String, dynamic>{};
}

bool _mapEquals(Map<String, dynamic> a, Map<String, dynamic> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (final key in a.keys) {
    if (!b.containsKey(key)) return false;
    if (a[key] != b[key]) return false;
  }
  return true;
}

Iterable<Object?> _stableMetadataEntries(Map<String, dynamic> metadata) sync* {
  final keys = metadata.keys.toList()..sort();
  for (final key in keys) {
    yield key;
    yield metadata[key];
  }
}
