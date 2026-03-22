import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

import '../../../ui/theme/app_icons.dart';

/// The type of a recovery feed event.
enum RecoveryEventType {
  /// A timeline task was completed.
  taskDone,

  /// A wound photo was documented.
  woundLogged,

  /// A pain entry was recorded.
  painLogged,

  /// Vitals were logged.
  vitalsLogged,

  /// Medication was taken / logged.
  medicationLogged,

  /// A rehab exercise was completed.
  rehabDone,

  /// A mood entry was recorded.
  moodLogged,

  /// A sleep entry was recorded.
  sleepLogged,

  /// A daily challenge was completed.
  challengeDone,

  /// A badge was earned.
  badgeEarned,

  /// A milestone was reached.
  milestoneReached,

  /// A new level was reached.
  levelUp,

  /// A streak threshold was hit (7, 14, 30 …).
  streakRecord,

  /// Daily complete bonus – all 5 activity types logged.
  dailyComplete,

  /// Weekly summary (generated at end-of-week).
  weeklySummary,
}

/// Relevance tier – determines visual prominence in the feed.
enum EventRelevance {
  /// Background info, small card.
  low,

  /// Standard feed card.
  normal,

  /// Highlighted card with accent colour.
  high,

  /// Hero-level celebration (overlay-worthy).
  epic,
}

/// A single event in the patient's recovery feed.
///
/// Stored at `patients/{patientId}/recovery_feed/{id}`.
class RecoveryEvent {
  const RecoveryEvent({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    required this.createdAt,
    this.xpDelta = 0,
    this.relevance = EventRelevance.normal,
    this.relatedItemId,
    this.relatedBadgeId,
    this.relatedMilestoneId,
    this.ctaRoute,
    this.metadata = const {},
  });

  final String id;
  final RecoveryEventType type;
  final String title;
  final String? subtitle;
  final DateTime createdAt;
  final int xpDelta;
  final EventRelevance relevance;

  /// Optional reference to the timeline item that triggered this event.
  final String? relatedItemId;

  /// Optional reference to the badge that was earned.
  final String? relatedBadgeId;

  /// Optional reference to the milestone that was reached.
  final String? relatedMilestoneId;

  /// Optional deep-link route for a CTA button.
  final String? ctaRoute;

  /// Extra payload (e.g. weekly summary stats).
  final Map<String, dynamic> metadata;

  // ── Icon helpers ──

  IconData get icon => switch (type) {
        RecoveryEventType.taskDone => AppIcons.taskDone,
        RecoveryEventType.woundLogged => AppIcons.woundLogged,
        RecoveryEventType.painLogged => AppIcons.painLogged,
        RecoveryEventType.vitalsLogged => AppIcons.vitalsLogged,
        RecoveryEventType.medicationLogged => AppIcons.medicationLogged,
        RecoveryEventType.rehabDone => AppIcons.rehabDone,
        RecoveryEventType.moodLogged => AppIcons.mood,
        RecoveryEventType.sleepLogged => AppIcons.sleep,
        RecoveryEventType.challengeDone => AppIcons.challengeDone,
        RecoveryEventType.badgeEarned => AppIcons.badgeEarned,
        RecoveryEventType.milestoneReached => AppIcons.milestoneReached,
        RecoveryEventType.levelUp => AppIcons.levelUp,
        RecoveryEventType.streakRecord => AppIcons.streakRecord,
        RecoveryEventType.dailyComplete => AppIcons.dailyComplete,
        RecoveryEventType.weeklySummary => AppIcons.weeklySummary,
      };

  Color get iconColor => switch (type) {
        RecoveryEventType.taskDone => AppIcons.taskDoneColor,
        RecoveryEventType.woundLogged => AppIcons.woundLoggedColor,
        RecoveryEventType.painLogged => AppIcons.painLoggedColor,
        RecoveryEventType.vitalsLogged => AppIcons.vitalsLoggedColor,
        RecoveryEventType.medicationLogged => AppIcons.medicationLoggedColor,
        RecoveryEventType.rehabDone => AppIcons.rehabDoneColor,
        RecoveryEventType.moodLogged => AppIcons.moodColor,
        RecoveryEventType.sleepLogged => AppIcons.sleepColor,
        RecoveryEventType.challengeDone => AppIcons.challengeDoneColor,
        RecoveryEventType.badgeEarned => AppIcons.badgeEarnedColor,
        RecoveryEventType.milestoneReached => AppIcons.milestoneReachedColor,
        RecoveryEventType.levelUp => AppIcons.levelUpColor,
        RecoveryEventType.streakRecord => AppIcons.streakRecordColor,
        RecoveryEventType.dailyComplete => AppIcons.dailyCompleteColor,
        RecoveryEventType.weeklySummary => AppIcons.weeklySummaryColor,
      };

  // ── Emoji helper (kept for notification text) ──

  String get emoji => switch (type) {
        RecoveryEventType.taskDone => '✅',
        RecoveryEventType.woundLogged => '📸',
        RecoveryEventType.painLogged => '😣',
        RecoveryEventType.vitalsLogged => '❤️',
        RecoveryEventType.medicationLogged => '💊',
        RecoveryEventType.rehabDone => '🏋️',
        RecoveryEventType.moodLogged => '😊',
        RecoveryEventType.sleepLogged => '😴',
        RecoveryEventType.challengeDone => '⚡',
        RecoveryEventType.badgeEarned => '🏅',
        RecoveryEventType.milestoneReached => '🏆',
        RecoveryEventType.levelUp => '🎉',
        RecoveryEventType.streakRecord => '🔥',
        RecoveryEventType.dailyComplete => '⭐',
        RecoveryEventType.weeklySummary => '📊',
      };

  // ── Serialisation ──

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'title': title,
        'subtitle': subtitle,
        'createdAt': createdAt.toIso8601String(),
        'xpDelta': xpDelta,
        'relevance': relevance.name,
        'relatedItemId': relatedItemId,
        'relatedBadgeId': relatedBadgeId,
        'relatedMilestoneId': relatedMilestoneId,
        'ctaRoute': ctaRoute,
        'metadata': metadata,
      };

  factory RecoveryEvent.fromJson(Map<String, dynamic> json) {
    return RecoveryEvent(
      id: json['id'] as String? ?? '',
      type: RecoveryEventType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => RecoveryEventType.taskDone,
      ),
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String?,
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
      xpDelta: (json['xpDelta'] as num?)?.toInt() ?? 0,
      relevance: EventRelevance.values.firstWhere(
        (r) => r.name == json['relevance'],
        orElse: () => EventRelevance.normal,
      ),
      relatedItemId: json['relatedItemId'] as String?,
      relatedBadgeId: json['relatedBadgeId'] as String?,
      relatedMilestoneId: json['relatedMilestoneId'] as String?,
      ctaRoute: json['ctaRoute'] as String?,
      metadata: _mapFrom(json['metadata']),
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
    return null;
  }

  static Map<String, dynamic> _mapFrom(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    return const {};
  }
}
