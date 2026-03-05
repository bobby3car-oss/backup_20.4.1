import 'package:cloud_firestore/cloud_firestore.dart';

/// Persistent gamification state stored as a single Firestore document
/// at `patients/{patientId}/gamification/state`.
class GamificationState {
  const GamificationState({
    this.xp = 0,
    this.level = 1,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActiveDate,
    this.totalTasksDone = 0,
    this.totalDaysActive = 0,
    this.badges = const [],
  });

  final int xp;
  final int level;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActiveDate;
  final int totalTasksDone;
  final int totalDaysActive;
  final List<EarnedBadge> badges;

  /// XP required to reach the *next* level. Formula: 100 * level.
  int get xpForNextLevel => 100 * level;

  /// XP already earned within the current level.
  int get xpInCurrentLevel {
    var accumulated = 0;
    for (var l = 1; l < level; l++) {
      accumulated += 100 * l;
    }
    return xp - accumulated;
  }

  /// Progress within the current level as 0.0 – 1.0.
  double get levelProgress {
    final needed = xpForNextLevel;
    if (needed <= 0) return 1.0;
    return (xpInCurrentLevel / needed).clamp(0.0, 1.0);
  }

  GamificationState copyWith({
    int? xp,
    int? level,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActiveDate,
    bool clearLastActiveDate = false,
    int? totalTasksDone,
    int? totalDaysActive,
    List<EarnedBadge>? badges,
  }) {
    return GamificationState(
      xp: xp ?? this.xp,
      level: level ?? this.level,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActiveDate:
          clearLastActiveDate ? null : (lastActiveDate ?? this.lastActiveDate),
      totalTasksDone: totalTasksDone ?? this.totalTasksDone,
      totalDaysActive: totalDaysActive ?? this.totalDaysActive,
      badges: badges ?? this.badges,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'xp': xp,
      'level': level,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActiveDate': lastActiveDate != null
          ? Timestamp.fromDate(lastActiveDate!)
          : null,
      'totalTasksDone': totalTasksDone,
      'totalDaysActive': totalDaysActive,
      'badges': badges.map((b) => b.toJson()).toList(),
    };
  }

  factory GamificationState.fromJson(Map<String, dynamic> json) {
    return GamificationState(
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      level: (json['level'] as num?)?.toInt() ?? 1,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
      lastActiveDate: _parseTimestamp(json['lastActiveDate']),
      totalTasksDone: (json['totalTasksDone'] as num?)?.toInt() ?? 0,
      totalDaysActive: (json['totalDaysActive'] as num?)?.toInt() ?? 0,
      badges: (json['badges'] as List<dynamic>?)
              ?.whereType<Map>()
              .map((e) =>
                  EarnedBadge.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          const [],
    );
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

/// A badge that the user has earned, stored inside [GamificationState.badges].
class EarnedBadge {
  const EarnedBadge({required this.id, required this.earnedAt});

  final String id;
  final DateTime earnedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'earnedAt': Timestamp.fromDate(earnedAt),
      };

  factory EarnedBadge.fromJson(Map<String, dynamic> json) {
    return EarnedBadge(
      id: json['id'] as String,
      earnedAt: GamificationState._parseTimestamp(json['earnedAt']) ??
          DateTime.now(),
    );
  }
}
