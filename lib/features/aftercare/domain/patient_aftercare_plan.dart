import 'package:cloud_firestore/cloud_firestore.dart';

import 'aftercare_item_category.dart';
import 'aftercare_phase.dart';
import 'plan_status.dart';

/// A concrete aftercare plan assigned to a patient.
///
/// Always created as a **snapshot/copy** of an [AftercareTemplate].
/// Subsequent changes to the source template do NOT affect existing plans.
///
/// Stored at: `patient_aftercare_plans/{planId}`
class PatientAftercarePlan {
  const PatientAftercarePlan({
    required this.id,
    required this.patientId,
    required this.doctorId,
    this.organizationId,
    required this.sourceTemplateId,
    required this.sourceTemplateType,
    this.sourceTemplateVersion = 1,
    required this.title,
    required this.surgeryDate,
    required this.effectiveFrom,
    this.version = 1,
    this.phases = const [],
    this.status = PlanStatus.draft,
    this.activationMode = ActivationMode.opDate,
    this.scheduledActivationDate,
    this.preparedBy,
    this.approvedBy,
    this.activatedBy,
    this.archivedBy,
    this.archivedAt,
    this.archivedReason,
    this.pausedAt,
    this.pausedBy,
    this.pauseReason,
    this.resumedAt,
    this.completedAt,
    this.completedBy,
    this.completionSummary,
    this.cancelledAt,
    this.cancelledBy,
    this.cancelReason,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String patientId;
  final String doctorId;
  final String? organizationId;

  /// ID of the template this plan was created from.
  final String sourceTemplateId;

  /// Type of the source template at creation time.
  final AftercareTemplateType sourceTemplateType;

  /// Version of the source template at snapshot time.
  final int sourceTemplateVersion;

  /// Plan title (copied from template, editable per patient).
  final String title;

  /// The patient's surgery date — used to resolve day offsets.
  final DateTime surgeryDate;

  /// Date from which this plan takes effect.
  final DateTime effectiveFrom;

  /// Version number (incremented on plan updates).
  final int version;

  /// Complete copy of the template phases at assignment time.
  final List<AftercarePhase> phases;

  /// Lifecycle status of this plan.
  final PlanStatus status;

  /// How the activation date is determined.
  final ActivationMode activationMode;

  /// Future activation date (only when [status] == [PlanStatus.scheduled]).
  final DateTime? scheduledActivationDate;

  // ── Audit trail ──────────────────────────────────────────────────────

  /// UID of the user who initially prepared/drafted this plan.
  final String? preparedBy;

  /// UID of the doctor who approved a staff-prepared plan.
  final String? approvedBy;

  /// UID of the user who activated this plan.
  final String? activatedBy;

  /// UID of the user who archived this plan.
  final String? archivedBy;

  /// When this plan was archived.
  final DateTime? archivedAt;

  /// Optional reason for archiving (e.g. "Neuer Plan zugewiesen").
  final String? archivedReason;

  // ── Pause ──────────────────────────────────────────────────────────

  /// When this plan was paused.
  final DateTime? pausedAt;

  /// UID of the user who paused this plan.
  final String? pausedBy;

  /// Optional reason for pausing.
  final String? pauseReason;

  /// When this plan was last resumed from pause.
  final DateTime? resumedAt;

  // ── Completion ─────────────────────────────────────────────────────

  /// When this plan was completed.
  final DateTime? completedAt;

  /// UID of the doctor who completed this plan.
  final String? completedBy;

  /// Optional free-text summary at completion.
  final String? completionSummary;

  // ── Cancellation ───────────────────────────────────────────────────

  /// When this plan was cancelled.
  final DateTime? cancelledAt;

  /// UID of the user who cancelled this plan.
  final String? cancelledBy;

  /// Optional reason for cancellation.
  final String? cancelReason;

  final DateTime createdAt;
  final DateTime updatedAt;

  /// Backward-compatible getter: plan is active if status == active.
  bool get isActive => status == PlanStatus.active;

  PatientAftercarePlan copyWith({
    String? id,
    String? patientId,
    String? doctorId,
    String? organizationId,
    bool clearOrganizationId = false,
    String? sourceTemplateId,
    AftercareTemplateType? sourceTemplateType,
    int? sourceTemplateVersion,
    String? title,
    DateTime? surgeryDate,
    DateTime? effectiveFrom,
    int? version,
    List<AftercarePhase>? phases,
    PlanStatus? status,
    ActivationMode? activationMode,
    DateTime? scheduledActivationDate,
    bool clearScheduledActivationDate = false,
    String? preparedBy,
    bool clearPreparedBy = false,
    String? approvedBy,
    bool clearApprovedBy = false,
    String? activatedBy,
    bool clearActivatedBy = false,
    String? archivedBy,
    bool clearArchivedBy = false,
    DateTime? archivedAt,
    bool clearArchivedAt = false,
    String? archivedReason,
    bool clearArchivedReason = false,
    DateTime? pausedAt,
    bool clearPausedAt = false,
    String? pausedBy,
    bool clearPausedBy = false,
    String? pauseReason,
    bool clearPauseReason = false,
    DateTime? resumedAt,
    bool clearResumedAt = false,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    String? completedBy,
    bool clearCompletedBy = false,
    String? completionSummary,
    bool clearCompletionSummary = false,
    DateTime? cancelledAt,
    bool clearCancelledAt = false,
    String? cancelledBy,
    bool clearCancelledBy = false,
    String? cancelReason,
    bool clearCancelReason = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PatientAftercarePlan(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      organizationId: clearOrganizationId
          ? null
          : (organizationId ?? this.organizationId),
      sourceTemplateId: sourceTemplateId ?? this.sourceTemplateId,
      sourceTemplateType: sourceTemplateType ?? this.sourceTemplateType,
      sourceTemplateVersion:
          sourceTemplateVersion ?? this.sourceTemplateVersion,
      title: title ?? this.title,
      surgeryDate: surgeryDate ?? this.surgeryDate,
      effectiveFrom: effectiveFrom ?? this.effectiveFrom,
      version: version ?? this.version,
      phases: phases ?? this.phases,
      status: status ?? this.status,
      activationMode: activationMode ?? this.activationMode,
      scheduledActivationDate: clearScheduledActivationDate
          ? null
          : (scheduledActivationDate ?? this.scheduledActivationDate),
      preparedBy: clearPreparedBy ? null : (preparedBy ?? this.preparedBy),
      approvedBy: clearApprovedBy ? null : (approvedBy ?? this.approvedBy),
      activatedBy: clearActivatedBy ? null : (activatedBy ?? this.activatedBy),
      archivedBy: clearArchivedBy ? null : (archivedBy ?? this.archivedBy),
      archivedAt: clearArchivedAt ? null : (archivedAt ?? this.archivedAt),
      archivedReason:
          clearArchivedReason ? null : (archivedReason ?? this.archivedReason),
      pausedAt: clearPausedAt ? null : (pausedAt ?? this.pausedAt),
      pausedBy: clearPausedBy ? null : (pausedBy ?? this.pausedBy),
      pauseReason:
          clearPauseReason ? null : (pauseReason ?? this.pauseReason),
      resumedAt: clearResumedAt ? null : (resumedAt ?? this.resumedAt),
      completedAt:
          clearCompletedAt ? null : (completedAt ?? this.completedAt),
      completedBy:
          clearCompletedBy ? null : (completedBy ?? this.completedBy),
      completionSummary: clearCompletionSummary
          ? null
          : (completionSummary ?? this.completionSummary),
      cancelledAt:
          clearCancelledAt ? null : (cancelledAt ?? this.cancelledAt),
      cancelledBy:
          clearCancelledBy ? null : (cancelledBy ?? this.cancelledBy),
      cancelReason:
          clearCancelReason ? null : (cancelReason ?? this.cancelReason),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      if (organizationId != null) 'organizationId': organizationId,
      'sourceTemplateId': sourceTemplateId,
      'sourceTemplateType': sourceTemplateType.name,
      'sourceTemplateVersion': sourceTemplateVersion,
      'title': title,
      'surgeryDate': surgeryDate.toIso8601String(),
      'effectiveFrom': effectiveFrom.toIso8601String(),
      'version': version,
      'phases': phases.map((p) => p.toJson()).toList(growable: false),
      'status': status.name,
      'isActive': isActive, // backward compat for queries
      'activationMode': activationMode.name,
      if (scheduledActivationDate != null)
        'scheduledActivationDate':
            scheduledActivationDate!.toIso8601String(),
      if (preparedBy != null) 'preparedBy': preparedBy,
      if (approvedBy != null) 'approvedBy': approvedBy,
      if (activatedBy != null) 'activatedBy': activatedBy,
      if (archivedBy != null) 'archivedBy': archivedBy,
      if (archivedAt != null) 'archivedAt': archivedAt!.toIso8601String(),
      if (archivedReason != null) 'archivedReason': archivedReason,
      if (pausedAt != null) 'pausedAt': pausedAt!.toIso8601String(),
      if (pausedBy != null) 'pausedBy': pausedBy,
      if (pauseReason != null) 'pauseReason': pauseReason,
      if (resumedAt != null) 'resumedAt': resumedAt!.toIso8601String(),
      if (completedAt != null)
        'completedAt': completedAt!.toIso8601String(),
      if (completedBy != null) 'completedBy': completedBy,
      if (completionSummary != null) 'completionSummary': completionSummary,
      if (cancelledAt != null)
        'cancelledAt': cancelledAt!.toIso8601String(),
      if (cancelledBy != null) 'cancelledBy': cancelledBy,
      if (cancelReason != null) 'cancelReason': cancelReason,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory PatientAftercarePlan.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();

    // Backward compat: derive status from isActive if status field is absent.
    PlanStatus status;
    if (json.containsKey('status')) {
      status = PlanStatus.fromString(json['status']?.toString());
    } else {
      status = json['isActive'] == false
          ? PlanStatus.archived
          : PlanStatus.active;
    }

    return PatientAftercarePlan(
      id: (json['id'] ?? '').toString(),
      patientId: (json['patientId'] ?? '').toString(),
      doctorId: (json['doctorId'] ?? '').toString(),
      organizationId: json['organizationId'] as String?,
      sourceTemplateId: (json['sourceTemplateId'] ?? '').toString(),
      sourceTemplateType: AftercareTemplateType.fromString(
          json['sourceTemplateType']?.toString()),
      sourceTemplateVersion:
          _parseInt(json['sourceTemplateVersion']) ??
          _parseInt(json['version']) ??
          1,
      title: (json['title'] ?? '').toString(),
      surgeryDate: _parseDateTime(json['surgeryDate']) ?? now,
      effectiveFrom: _parseDateTime(json['effectiveFrom']) ?? now,
      version: _parseInt(json['version']) ?? 1,
      phases: _parsePhases(json['phases']),
      status: status,
      activationMode:
          ActivationMode.fromString(json['activationMode']?.toString()),
      scheduledActivationDate:
          _parseDateTime(json['scheduledActivationDate']),
      preparedBy: json['preparedBy'] as String?,
      approvedBy: json['approvedBy'] as String?,
      activatedBy: json['activatedBy'] as String?,
      archivedBy: json['archivedBy'] as String?,
      archivedAt: _parseDateTime(json['archivedAt']),
      archivedReason: json['archivedReason'] as String?,
      pausedAt: _parseDateTime(json['pausedAt']),
      pausedBy: json['pausedBy'] as String?,
      pauseReason: json['pauseReason'] as String?,
      resumedAt: _parseDateTime(json['resumedAt']),
      completedAt: _parseDateTime(json['completedAt']),
      completedBy: json['completedBy'] as String?,
      completionSummary: json['completionSummary'] as String?,
      cancelledAt: _parseDateTime(json['cancelledAt']),
      cancelledBy: json['cancelledBy'] as String?,
      cancelReason: json['cancelReason'] as String?,
      createdAt: _parseDateTime(json['createdAt']) ?? now,
      updatedAt: _parseDateTime(json['updatedAt']) ?? now,
    );
  }

  static int? _parseInt(Object? raw) {
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw);
    return null;
  }

  static DateTime? _parseDateTime(Object? raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is String && raw.trim().isNotEmpty) return DateTime.tryParse(raw);
    return null;
  }

  static List<AftercarePhase> _parsePhases(Object? raw) {
    if (raw is List) {
      return raw
          .whereType<Map<String, dynamic>>()
          .map(AftercarePhase.fromJson)
          .toList(growable: false);
    }
    return const [];
  }
}
