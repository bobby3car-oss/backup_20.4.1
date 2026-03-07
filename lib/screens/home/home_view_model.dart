import '../../domain/task_orchestrator.dart' show phaseTitle, phaseOrder;
import '../../domain/timeline_engine.dart';

// ── Models ───────────────────────────────────────────────────────────────────

class TimelineTask {
  const TimelineTask({
    required this.id,
    required this.emoji,
    required this.title,
    this.subtitle,
    this.milestone,
    this.routeKey,
    required this.state,
    required this.type,
  });

  final String id;
  final String emoji;
  final String title;
  final String? subtitle;
  final String? milestone;
  final String? routeKey;
  final TaskState state;
  final TaskType type;

  bool get isDone => state == TaskState.done;
  bool get isSkipped => state == TaskState.skipped;
}

class TimelineSection {
  TimelineSection({
    required this.offsetLabel,
    required this.dateLabel,
    required this.tasks,
    this.sectionState = TaskState.planned,
  });

  final String offsetLabel;
  final String dateLabel;
  final TaskState sectionState;
  final List<TimelineTask> tasks;

  int get completedCount => tasks.where((t) => t.isDone).length;
  int get totalCount => tasks.length;
}

class PhaseHeaderData {
  const PhaseHeaderData({
    required this.title,
    required this.doneCount,
    required this.totalCount,
  });

  final String title;
  final int doneCount;
  final int totalCount;
}

class TimelineFeedEntry {
  const TimelineFeedEntry.phase(this.phase)
    : section = null,
      sectionIndex = -1;

  const TimelineFeedEntry.section(this.section, this.sectionIndex)
    : phase = null;

  final PhaseHeaderData? phase;
  final TimelineSection? section;
  final int sectionIndex;
}

class TimelineHeaderSummary {
  const TimelineHeaderSummary({
    required this.totalCount,
    required this.doneCount,
    required this.openCount,
    required this.todayCount,
    required this.dueCount,
    required this.focusLabel,
  });

  final int totalCount;
  final int doneCount;
  final int openCount;
  final int todayCount;
  final int dueCount;
  final String focusLabel;

  double get progress => totalCount == 0 ? 0 : doneCount / totalCount;
  int get progressPercent => (progress * 100).round();
}

// ── Helpers ──────────────────────────────────────────────────────────────────

String emojiForType(TaskType type) {
  switch (type) {
    case TaskType.wound:
      return '📸';
    case TaskType.meds:
      return '💊';
    case TaskType.checklist:
      return '✅';
    case TaskType.appointment:
      return '📅';
    case TaskType.message:
      return '💬';
    case TaskType.custom:
      return '📝';
  }
}

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

String _dayKey(DateTime value) {
  final d = _dateOnly(value);
  final mm = d.month.toString().padLeft(2, '0');
  final dd = d.day.toString().padLeft(2, '0');
  return '${d.year}-$mm-$dd';
}

DateTime _dayFromKey(String key) {
  final parts = key.split('-');
  return DateTime(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
  );
}

String _dateLabel(DateTime date) {
  final dd = date.day.toString().padLeft(2, '0');
  final mm = date.month.toString().padLeft(2, '0');
  return '$dd.$mm.';
}

String _weekdayLabel(DateTime date) {
  const weekdays = <String>[
    'Montag',
    'Dienstag',
    'Mittwoch',
    'Donnerstag',
    'Freitag',
    'Samstag',
    'Sonntag',
  ];
  return weekdays[date.weekday - 1];
}

// ── Pure Functions ───────────────────────────────────────────────────────────

List<TimelineFeedEntry> buildTimelineEntries(List<TimelineItem> items) {
  final now = DateTime.now();
  final groupedByPhaseAndDay = <String, Map<String, List<TimelineItem>>>{};
  final todayDate = _dateOnly(now);
  final tomorrowDate = todayDate.add(const Duration(days: 1));

  for (final item in items) {
    final computed = computeState(item, now);
    final normalized = item.copyWith(state: computed);
    final phase = (normalized.metadata['phase'] as String?) ?? 'followup';
    final dayKey = _dayKey(normalized.scheduledAt.toLocal());
    final byDay = groupedByPhaseAndDay.putIfAbsent(
      phase,
      () => <String, List<TimelineItem>>{},
    );
    byDay.putIfAbsent(dayKey, () => <TimelineItem>[]).add(normalized);
  }

  TimelineSection mapSection({
    required String dayLabel,
    required String dateLabel,
    required TaskState sectionState,
    required List<TimelineItem> source,
  }) {
    return TimelineSection(
      offsetLabel: dayLabel,
      dateLabel: dateLabel,
      sectionState: sectionState,
      tasks: source
          .map(
            (item) => TimelineTask(
              id: item.id,
              emoji: emojiForType(item.type),
              title: item.title,
              subtitle: item.subtitle,
              milestone: item.metadata['milestone'] as String?,
              routeKey: item.deeplinkRoute,
              state: item.state,
              type: item.type,
            ),
          )
          .toList(),
    );
  }

  final entries = <TimelineFeedEntry>[];
  var sectionIndex = 0;

  final sortedPhases = groupedByPhaseAndDay.keys.toList()
    ..sort((a, b) => phaseOrder(a).compareTo(phaseOrder(b)));

  for (final phase in sortedPhases) {
    final byDay =
        groupedByPhaseAndDay[phase] ?? const <String, List<TimelineItem>>{};
    final allPhaseItems = byDay.values.expand((e) => e);
    final totalCount = allPhaseItems.length;
    final doneCount =
        allPhaseItems.where((item) => item.state == TaskState.done).length;
    final title = phaseTitle(phase);

    entries.add(
      TimelineFeedEntry.phase(
        PhaseHeaderData(
          title: title,
          doneCount: doneCount,
          totalCount: totalCount,
        ),
      ),
    );

    final sortedDayKeys = byDay.keys.toList()
      ..sort((a, b) => _dayFromKey(a).compareTo(_dayFromKey(b)));

    for (final key in sortedDayKeys) {
      final day = _dayFromKey(key);
      final source = sortItems(byDay[key] ?? const <TimelineItem>[]);
      final dayDoneCount =
          source.where((task) => task.state == TaskState.done).length;
      final hasDue = source.any((task) => task.state == TaskState.due);
      final label = _isSameDay(day, todayDate)
          ? 'Heute'
          : _isSameDay(day, tomorrowDate)
              ? 'Morgen'
              : '${_weekdayLabel(day)} · ${_dateLabel(day)}';

      entries.add(
        TimelineFeedEntry.section(
          mapSection(
            dayLabel: label,
            dateLabel:
                '${_dateLabel(day)} · $dayDoneCount/${source.length} erledigt',
            sectionState: hasDue
                ? TaskState.due
                : _isSameDay(day, todayDate)
                    ? TaskState.inProgress
                    : TaskState.planned,
            source: source,
          ),
          sectionIndex++,
        ),
      );
    }
  }
  return entries;
}

TimelineHeaderSummary buildHeaderSummary(List<TimelineItem> items) {
  final now = DateTime.now();
  final todayDate = _dateOnly(now);
  var doneCount = 0;
  var skippedCount = 0;
  var todayCount = 0;
  var dueCount = 0;
  TimelineItem? nextRelevant;

  for (final item in items) {
    final computed = computeState(item, now);
    final scheduledAt = item.scheduledAt.toLocal();

    if (_isSameDay(scheduledAt, todayDate)) {
      todayCount++;
    }

    switch (computed) {
      case TaskState.done:
        doneCount++;
        break;
      case TaskState.skipped:
        skippedCount++;
        break;
      case TaskState.due:
      case TaskState.inProgress:
        dueCount++;
        break;
      case TaskState.planned:
        break;
    }

    final isRelevant =
        computed != TaskState.done && computed != TaskState.skipped;
    if (!isRelevant) continue;

    if (nextRelevant == null ||
        scheduledAt.isBefore(nextRelevant.scheduledAt)) {
      nextRelevant = item;
    }
  }

  final openCount = (items.length - doneCount - skippedCount).clamp(
    0,
    items.length,
  );
  final focusLabel = switch ((dueCount, todayCount, nextRelevant)) {
    (> 0, _, _) => '$dueCount brauchen heute Aufmerksamkeit',
    (0, > 0, _) => '$todayCount Aufgaben fuer heute eingeplant',
    (0, 0, TimelineItem item) => 'Als Naechstes: ${item.title}',
    _ => 'Dein Plan ist aktuell komplett erledigt',
  };

  return TimelineHeaderSummary(
    totalCount: items.length,
    doneCount: doneCount,
    openCount: openCount,
    todayCount: todayCount,
    dueCount: dueCount,
    focusLabel: focusLabel,
  );
}
