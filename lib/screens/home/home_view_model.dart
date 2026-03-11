import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;

import '../../domain/task_orchestrator.dart' show phaseTitle, phaseOrder;
import '../../domain/timeline_engine.dart';
import '../../ui/theme/app_icons.dart';

// ── Models ───────────────────────────────────────────────────────────────────

class TimelineTask {
  const TimelineTask({
    required this.id,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.milestone,
    this.routeKey,
    required this.state,
    required this.type,
  });

  final String id;
  final IconData icon;

  final Color iconColor;
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
    this.opOffsetLabel,
    this.sectionState = TaskState.planned,
  });

  final String offsetLabel;
  final String dateLabel;

  /// e.g. "-14" for 14 days before OP, "+3" for 3 days after
  final String? opOffsetLabel;
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

(IconData, Color) iconForType(TaskType type) {
  switch (type) {
    case TaskType.wound:
      return (AppIcons.photos, AppIcons.photosColor);
    case TaskType.meds:
      return (AppIcons.medication, AppIcons.medicationColor);
    case TaskType.checklist:
      return (AppIcons.done, AppIcons.doneColor);
    case TaskType.appointment:
      return (AppIcons.appointments, AppIcons.appointmentsColor);
    case TaskType.message:
      return (AppIcons.messages, AppIcons.messagesColor);
    case TaskType.custom:
      return (AppIcons.notes, AppIcons.notesColor);
    case TaskType.note:
      return (Icons.sticky_note_2_rounded, AppIcons.messagesColor);
    case TaskType.nutrition:
      return (AppIcons.nutrition, AppIcons.nutritionColor);
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
  const months = [
    'Jan.', 'Feb.', 'Mär.', 'Apr.', 'Mai', 'Jun.',
    'Jul.', 'Aug.', 'Sep.', 'Okt.', 'Nov.', 'Dez.',
  ];
  return '${date.day}. ${months[date.month - 1]}';
}

String _weekdayShort(DateTime date) {
  const weekdays = <String>['Mo.', 'Di.', 'Mi.', 'Do.', 'Fr.', 'Sa.', 'So.'];
  return weekdays[date.weekday - 1];
}

// ── Pure Functions ───────────────────────────────────────────────────────────

List<TimelineFeedEntry> buildTimelineEntries(
  List<TimelineItem> items, {
  DateTime? operationDate,
}) {
  final now = DateTime.now();
  final groupedByPhaseAndDay = <String, Map<String, List<TimelineItem>>>{};
  final todayDate = _dateOnly(now);
  final tomorrowDate = todayDate.add(const Duration(days: 1));
  final opDateOnly = operationDate != null ? _dateOnly(operationDate) : null;

  for (final item in items) {
    final computed = computeState(item, now);
    final normalized = item.copyWith(state: computed);
    final phase = (normalized.metadata['phase'] as String?) ??
        inferPhase(normalized.scheduledAt.toLocal(), operationDate);
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
    String? opOffsetLabel,
  }) {
    return TimelineSection(
      offsetLabel: dayLabel,
      dateLabel: dateLabel,
      opOffsetLabel: opOffsetLabel,
      sectionState: sectionState,
      tasks: source
          .map(
            (item) {
              final (icon, iconColor) = iconForType(item.type);
              return TimelineTask(
              id: item.id,
              icon: icon,
              iconColor: iconColor,
              title: item.title,
              subtitle: item.subtitle,
              milestone: item.metadata['milestone'] as String?,
              routeKey: item.deeplinkRoute,
              state: item.state,
              type: item.type,
            );
            },
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

      // Compute OP-relative offset label
      String? opOffset;
      if (opDateOnly != null) {
        final diff = day.difference(opDateOnly).inDays;
        opOffset = diff > 0 ? '+$diff' : '$diff';
      }

      final label = _isSameDay(day, todayDate)
          ? 'Heute'
          : _isSameDay(day, tomorrowDate)
              ? 'Morgen'
              : '${_weekdayShort(day)} ${_dateLabel(day)}';

      entries.add(
        TimelineFeedEntry.section(
          mapSection(
            dayLabel: label,
            dateLabel:
                '$dayDoneCount/${source.length} erledigt',
            sectionState: hasDue
                ? TaskState.due
                : _isSameDay(day, todayDate)
                    ? TaskState.inProgress
                    : TaskState.planned,
            source: source,
            opOffsetLabel: opOffset,
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
