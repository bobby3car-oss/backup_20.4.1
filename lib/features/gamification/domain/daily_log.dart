import 'package:cloud_firestore/cloud_firestore.dart';

/// A single day's activity log, stored at
/// `patients/{patientId}/gamification_log/{yyyy-MM-dd}`.
class DailyLog {
  const DailyLog({
    required this.date,
    this.tasksCompleted = 0,
    this.woundLogged = false,
    this.painLogged = false,
    this.vitalsLogged = false,
    this.medicationLogged = false,
    this.nutritionLogged = false,
    this.xpEarned = 0,
  });

  final String date; // yyyy-MM-dd
  final int tasksCompleted;
  final bool woundLogged;
  final bool painLogged;
  final bool vitalsLogged;
  final bool medicationLogged;
  final bool nutritionLogged;
  final int xpEarned;

  /// Number of distinct activity types logged today (0–5).
  int get activityCount {
    var count = 0;
    if (tasksCompleted > 0) count++;
    if (woundLogged) count++;
    if (painLogged) count++;
    if (vitalsLogged) count++;
    if (medicationLogged) count++;
    if (nutritionLogged) count++;
    return count;
  }

  DailyLog copyWith({
    String? date,
    int? tasksCompleted,
    bool? woundLogged,
    bool? painLogged,
    bool? vitalsLogged,
    bool? medicationLogged,
    bool? nutritionLogged,
    int? xpEarned,
  }) {
    return DailyLog(
      date: date ?? this.date,
      tasksCompleted: tasksCompleted ?? this.tasksCompleted,
      woundLogged: woundLogged ?? this.woundLogged,
      painLogged: painLogged ?? this.painLogged,
      vitalsLogged: vitalsLogged ?? this.vitalsLogged,
      medicationLogged: medicationLogged ?? this.medicationLogged,
      nutritionLogged: nutritionLogged ?? this.nutritionLogged,
      xpEarned: xpEarned ?? this.xpEarned,
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'tasksCompleted': tasksCompleted,
        'woundLogged': woundLogged,
        'painLogged': painLogged,
        'vitalsLogged': vitalsLogged,
        'medicationLogged': medicationLogged,
        'nutritionLogged': nutritionLogged,
        'xpEarned': xpEarned,
        'ownerId': '', // set by repository
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  factory DailyLog.fromJson(Map<String, dynamic> json) {
    return DailyLog(
      date: json['date'] as String? ?? '',
      tasksCompleted: (json['tasksCompleted'] as num?)?.toInt() ?? 0,
      woundLogged: json['woundLogged'] as bool? ?? false,
      painLogged: json['painLogged'] as bool? ?? false,
      vitalsLogged: json['vitalsLogged'] as bool? ?? false,
      medicationLogged: json['medicationLogged'] as bool? ?? false,
      nutritionLogged: json['nutritionLogged'] as bool? ?? false,
      xpEarned: (json['xpEarned'] as num?)?.toInt() ?? 0,
    );
  }
}
