import '../domain/timeline_engine.dart';
import '../security/app_route_guard.dart';
import '../features/appointments/domain/appointment.dart';
import '../features/appointments/domain/appointment_enums.dart';
import 'notification_model.dart';
import 'notification_preferences.dart';
import 'notification_repository.dart';

/// Centralized service for creating in-app notifications automatically
/// and manually. Acts as the single entry-point so that trigger logic
/// is kept out of individual repositories.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  factory NotificationService() => instance;

  NotificationRepository get _repo => NotificationRepository.instance;
  NotificationPreferences get _prefs => NotificationPreferences.instance;

  // ── Auto-generation: Timeline ────────────────────────────────────────────

  /// Called when a timeline task becomes due or changes state.
  Future<void> onTimelineItemChanged(TimelineItem item) async {
    if (!_prefs.globalEnabled || !_prefs.taskReminders) return;
    final notifId = 'task_${item.id}';

    // If item is done → create completion notification, remove due one.
    if (item.state == TaskState.done) {
      await _repo.deleteBySourceId(item.id);
      await _repo.upsert(
        InAppNotification(
          id: '${notifId}_done',
          type: NotificationType.taskCompleted,
          title: '${item.title} erledigt',
          body: item.subtitle.trim().isNotEmpty ? item.subtitle : null,
          emoji: '✅',
          deeplinkRoute: item.deeplinkRoute.isNotEmpty
              ? item.deeplinkRoute
              : null,
          priority: NotificationPriority.low,
          sourceId: item.id,
          expiresAt: DateTime.now().add(const Duration(hours: 24)),
        ),
      );
      return;
    }

    // If skipped → just clean up.
    if (item.state == TaskState.skipped) {
      await _repo.deleteBySourceId(item.id);
      return;
    }

    // If due → create / update a "due" notification.
    if (item.state == TaskState.due && item.dueAt != null) {
      final dueLocal = item.dueAt!.toLocal();
      final hhmm =
          '${dueLocal.hour.toString().padLeft(2, '0')}:${dueLocal.minute.toString().padLeft(2, '0')}';

      final isOverdue = item.dueAt!.isBefore(DateTime.now());
      final body = isOverdue
          ? 'Überfällig seit $hhmm'
          : '${item.subtitle.trim().isNotEmpty ? '${item.subtitle} · ' : ''}fällig $hhmm';

      await _repo.upsert(
        InAppNotification(
          id: notifId,
          type: NotificationType.taskDue,
          title: item.title,
          body: body,
          emoji: _emojiForTaskType(item.type),
          deeplinkRoute: item.deeplinkRoute.isNotEmpty
              ? item.deeplinkRoute
              : null,
          priority: isOverdue
              ? NotificationPriority.high
              : NotificationPriority.normal,
          sourceId: item.id,
        ),
      );
      return;
    }
  }

  // ── Auto-generation: Appointments ────────────────────────────────────────

  /// Called when an appointment is created or updated.
  Future<void> onAppointmentChanged(Appointment appointment) async {
    if (!_prefs.globalEnabled || !_prefs.appointmentReminders) return;
    final notifId = 'appt_${appointment.id}';

    // Finalized → clean up.
    if (appointment.status == AppointmentStatus.done ||
        appointment.status == AppointmentStatus.canceled) {
      await _repo.deleteBySourceId(appointment.id);
      return;
    }

    // Upcoming appointment: create a reminder notification visible 1 day before.
    final startLocal = appointment.startAt.toLocal();
    final hhmm =
        '${startLocal.hour.toString().padLeft(2, '0')}:${startLocal.minute.toString().padLeft(2, '0')}';

    final body = appointment.locationName?.trim().isNotEmpty == true
        ? '${appointment.locationName} · $hhmm'
        : 'Start: $hhmm';

    await _repo.upsert(
      InAppNotification(
        id: notifId,
        type: NotificationType.appointmentReminder,
        title: appointment.title,
        body: body,
        emoji: '📅',
        deeplinkRoute: '/appointments',
        priority: NotificationPriority.normal,
        sourceId: appointment.id,
        // Only show notification 24h before appointment.
        scheduledAt: appointment.startAt.subtract(const Duration(hours: 24)),
        expiresAt: appointment.startAt.add(const Duration(hours: 2)),
      ),
    );
  }

  // ── Auto-generation: Observations / Wound Warnings ───────────────────────

  /// Called when a new observation is created.
  Future<void> onObservationCreated({
    required String observationId,
    required String authorName,
    required String text,
    required String severity,
  }) async {
    if (!_prefs.globalEnabled || !_prefs.observations) return;
    final emoji = switch (severity) {
      'critical' => '🔴',
      'warning' => '🟡',
      _ => 'ℹ️',
    };
    final priority = switch (severity) {
      'critical' => NotificationPriority.critical,
      'warning' => NotificationPriority.high,
      _ => NotificationPriority.normal,
    };

    await _repo.upsert(
      InAppNotification(
        id: 'obs_$observationId',
        type: NotificationType.observation,
        title: 'Beobachtung von $authorName',
        body: text,
        emoji: emoji,
        deeplinkRoute: '/alerts',
        priority: priority,
        sourceId: observationId,
      ),
    );
  }

  /// Called when a wound warning turns red.
  Future<void> onWoundWarningRed({required String warningId}) async {
    if (!_prefs.globalEnabled || !_prefs.woundWarnings) return;
    await _repo.upsert(
      InAppNotification(
        id: 'wound_$warningId',
        type: NotificationType.woundWarning,
        title: 'Wundalarm',
        body: 'Wundkontrolle zeigt ROT – bitte prüfen',
        emoji: '🚨',
        deeplinkRoute: '/wound',
        priority: NotificationPriority.critical,
        sourceId: warningId,
      ),
    );
  }

  // ── Manual creation ──────────────────────────────────────────────────────

  /// Creates a user-defined custom notification/reminder.
  Future<void> createCustom({
    required String title,
    String? body,
    DateTime? scheduledAt,
    String? deeplinkRoute,
  }) async {
    final id = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    await _repo.upsert(
      InAppNotification(
        id: id,
        type: NotificationType.custom,
        title: title,
        body: body,
        emoji: '📌',
        deeplinkRoute: sanitizeExternalRoute(deeplinkRoute),
        priority: NotificationPriority.normal,
        scheduledAt: scheduledAt,
      ),
    );
  }

  /// Creates a system-level notification.
  Future<void> createSystem({
    required String id,
    required String title,
    String? body,
  }) async {
    await _repo.upsert(
      InAppNotification(
        id: 'sys_$id',
        type: NotificationType.system,
        title: title,
        body: body,
        emoji: '🔔',
        priority: NotificationPriority.normal,
      ),
    );
  }

  /// Called when a doctor answers a patient's question.
  Future<void> onQuestionAnswered({
    required String questionId,
    required String doctorName,
    required String questionText,
  }) async {
    if (!_prefs.globalEnabled) return;
    await _repo.upsert(
      InAppNotification(
        id: 'question_answered_$questionId',
        type: NotificationType.questionAnswered,
        title: 'Dr. $doctorName hat deine Frage beantwortet',
        body: questionText,
        emoji: '💬',
        deeplinkRoute: '/questions',
        priority: NotificationPriority.normal,
        sourceId: questionId,
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  static String _emojiForTaskType(TaskType type) {
    return switch (type) {
      TaskType.wound => '🩹',
      TaskType.meds => '💊',
      TaskType.checklist => '✅',
      TaskType.appointment => '📅',
      TaskType.message => '💬',
      TaskType.custom => '📋',
      TaskType.note => '📝',
      TaskType.nutrition => '🥗',
      TaskType.aftercare => '🧾',
    };
  }
}
