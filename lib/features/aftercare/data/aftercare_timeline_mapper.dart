import '../../../domain/timeline_engine.dart';
import '../domain/aftercare_item.dart';
import '../domain/aftercare_item_category.dart';
import '../domain/aftercare_item_progress.dart';
import '../domain/aftercare_phase.dart';
import '../domain/patient_aftercare_plan.dart';
import '../domain/plan_status.dart';

/// Maps [AftercareItem]s from a [PatientAftercarePlan] into
/// [TimelineItem]s that integrate into the existing timeline feed.
///
/// Only items with `showInTimeline == true` AND a resolvable date
/// (via `exactDate`, `startDayOffset`, or phase offset) are included.
class AftercareTimelineMapper {
  const AftercareTimelineMapper._();

  /// Converts all timeline-eligible items from [plan] into
  /// [TimelineItem]s.
  ///
  /// If [progress] is provided, items marked as completed will have
  /// their state set to [TaskState.done].
  ///
  /// If [planStatus] is [PlanStatus.paused], all items are mapped
  /// with [TaskState.skipped] to indicate the plan is paused.
  static List<TimelineItem> mapPlanToTimelineItems(
    PatientAftercarePlan plan, {
    AftercareItemProgress? progress,
    PlanStatus? planStatus,
  }) {
    final effectiveStatus = planStatus ?? plan.status;
    if (effectiveStatus == PlanStatus.completed ||
        effectiveStatus == PlanStatus.cancelled ||
        effectiveStatus == PlanStatus.archived) {
      return const [];
    }

    final anchor = plan.surgeryDate;
    final now = DateTime.now();
    final items = <TimelineItem>[];

    for (final phase in plan.phases) {
      for (final item in phase.items) {
        if (!item.showInTimeline) continue;

        final dates = _resolveDates(item, phase, anchor);
        if (dates == null) continue;

        final (scheduledAt, dueAt) = dates;

        final metadata = <String, dynamic>{
          'source': 'aftercare_plan',
          'aftercarePlanId': plan.id,
          'aftercareItemId': item.id,
          'phaseId': phase.id,
          'phaseTitle': phase.title,
          'aftercareCategory': item.category.name,
          // Phase key for timeline grouping — resolve from day offset.
          'phase': _inferPhaseKey(scheduledAt, anchor),
        };

        final id = 'acp_${plan.id}_${phase.id}_${item.id}';

        // If patient has marked this item as completed, use TaskState.done.
        // If the plan is paused, all items get TaskState.skipped.
        final isCompleted = progress?.isCompleted(item.id) ?? false;
        final isPaused = effectiveStatus == PlanStatus.paused;

        final resolvedState = isPaused
            ? TaskState.skipped
            : isCompleted
            ? TaskState.done
            : computeState(
            TimelineItem(
              id: id,
              type: TaskType.aftercare,
              title: item.title,
              subtitle: '',
              scheduledAt: scheduledAt,
              dueAt: dueAt,
              priority: TaskPriority.normal,
              state: TaskState.planned,
              deeplinkRoute: '',
              metadata: const {},
              createdAt: now,
              updatedAt: now,
            ),
            now,
          );

        final timelineItem = TimelineItem(
          id: id,
          type: TaskType.aftercare,
          title: item.title,
          subtitle: item.description.isNotEmpty
              ? item.description
              : _subtitleForCategory(item.category),
          scheduledAt: scheduledAt,
          dueAt: dueAt,
          priority: _priorityForCategory(item.category),
          state: resolvedState,
          deeplinkRoute: '/aftercare-plan',
          metadata: metadata,
          createdAt: now,
          updatedAt: now,
        );

        items.add(timelineItem);
      }
    }

    return sortItems(items);
  }

  /// Resolves the scheduled-at and due-at dates for an aftercare item.
  ///
  /// Returns `null` if no date can be determined (item is not time-bound
  /// AND has no day offset or exact date).
  static (DateTime scheduledAt, DateTime? dueAt)? _resolveDates(
    AftercareItem item,
    AftercarePhase phase,
    DateTime anchor,
  ) {
    final normalizedAnchor = DateTime(anchor.year, anchor.month, anchor.day);

    // 1. Exact date takes priority.
    if (item.exactDate != null) {
      final scheduled = item.exactDate!;
      final dueAt = item.endDayOffset != null
          ? normalizedAnchor
                .add(Duration(days: item.endDayOffset!))
                .add(const Duration(hours: 18))
          : scheduled.add(const Duration(hours: 12));
      return (scheduled, dueAt);
    }

    // 2. Item-level day offset.
    if (item.startDayOffset != null) {
      final scheduled = normalizedAnchor
          .add(Duration(days: item.startDayOffset!))
          .add(const Duration(hours: 9)); // default morning
      final dueAt = item.endDayOffset != null
          ? normalizedAnchor
                .add(Duration(days: item.endDayOffset!))
                .add(const Duration(hours: 18))
          : scheduled.add(const Duration(hours: 12));
      return (scheduled, dueAt);
    }

    // 3. Fall back to phase start offset (only for time-bound items).
    if (item.isTimeBound) {
      final scheduled = normalizedAnchor
          .add(Duration(days: phase.startDayOffset))
          .add(const Duration(hours: 9));
      final dueAt = phase.endDayOffset != null
          ? normalizedAnchor
                .add(Duration(days: phase.endDayOffset!))
                .add(const Duration(hours: 18))
          : scheduled.add(const Duration(hours: 12));
      return (scheduled, dueAt);
    }

    return null;
  }

  /// Maps [scheduledAt] to a phase key for timeline grouping,
  /// using the same logic as `inferPhase` from `timeline_engine.dart`.
  static String _inferPhaseKey(DateTime scheduledAt, DateTime anchor) {
    final day = DateTime(scheduledAt.year, scheduledAt.month, scheduledAt.day);
    final opDay = DateTime(anchor.year, anchor.month, anchor.day);
    final diff = day.difference(opDay).inDays;
    if (diff < 0) return 'preop';
    if (diff == 0) return 'opday';
    if (diff <= 7) return 'week1';
    if (diff <= 14) return 'week2';
    return 'followup';
  }

  static String _subtitleForCategory(AftercareItemCategory category) {
    return switch (category) {
      AftercareItemCategory.wound => 'Wundkontrolle laut Behandlungsplan',
      AftercareItemCategory.dressing => 'Verbandwechsel laut Behandlungsplan',
      AftercareItemCategory.sutureRemoval => 'Fäden / Klammern entfernen',
      AftercareItemCategory.weightBearing => 'Belastungswechsel laut Plan',
      AftercareItemCategory.rom => 'Bewegungsumfang-Änderung',
      AftercareItemCategory.physio => 'Physiotherapie laut Behandlungsplan',
      AftercareItemCategory.cpm => 'CPM-Schiene laut Behandlungsplan',
      AftercareItemCategory.aid => 'Hilfsmittel laut Behandlungsplan',
      AftercareItemCategory.medication => 'Medikation laut Behandlungsplan',
      AftercareItemCategory.supplement => 'Supplemente laut Behandlungsplan',
      AftercareItemCategory.custom => 'Maßnahme laut Behandlungsplan',
    };
  }

  static TaskPriority _priorityForCategory(AftercareItemCategory category) {
    return switch (category) {
      AftercareItemCategory.sutureRemoval => TaskPriority.high,
      AftercareItemCategory.medication => TaskPriority.high,
      AftercareItemCategory.weightBearing => TaskPriority.high,
      AftercareItemCategory.wound => TaskPriority.normal,
      AftercareItemCategory.dressing => TaskPriority.normal,
      AftercareItemCategory.rom => TaskPriority.normal,
      AftercareItemCategory.physio => TaskPriority.normal,
      AftercareItemCategory.cpm => TaskPriority.normal,
      AftercareItemCategory.aid => TaskPriority.normal,
      AftercareItemCategory.supplement => TaskPriority.low,
      AftercareItemCategory.custom => TaskPriority.normal,
    };
  }
}
