import 'package:cloud_firestore/cloud_firestore.dart';

/// A daily challenge (Pro feature), stored at
/// `patients/{patientId}/daily_challenges/{yyyy-MM-dd}`.
class DailyChallenge {
  const DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.xpReward,
    required this.type,
    this.completed = false,
  });

  final String id;
  final String title;
  final String description;
  final int xpReward;
  final ChallengeType type;
  final bool completed;

  DailyChallenge copyWith({bool? completed}) => DailyChallenge(
        id: id,
        title: title,
        description: description,
        xpReward: xpReward,
        type: type,
        completed: completed ?? this.completed,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'xpReward': xpReward,
        'type': type.name,
        'completed': completed,
      };

  factory DailyChallenge.fromJson(Map<String, dynamic> json) {
    return DailyChallenge(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      xpReward: (json['xpReward'] as num?)?.toInt() ?? 25,
      type: ChallengeType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => ChallengeType.task,
      ),
      completed: json['completed'] as bool? ?? false,
    );
  }
}

enum ChallengeType { wound, pain, vitals, medication, task, mixed, supplement }

/// Container for one day's challenges.
class DailyChallengeSet {
  const DailyChallengeSet({
    required this.date,
    required this.challenges,
    required this.generatedAt,
  });

  final String date; // yyyy-MM-dd
  final List<DailyChallenge> challenges;
  final DateTime generatedAt;

  bool get allCompleted => challenges.every((c) => c.completed);
  int get completedCount => challenges.where((c) => c.completed).length;

  Map<String, dynamic> toJson() => {
        'date': date,
        'challenges': challenges.map((c) => c.toJson()).toList(),
        'generatedAt': Timestamp.fromDate(generatedAt),
        'ownerId': '', // set by repository
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  factory DailyChallengeSet.fromJson(Map<String, dynamic> json) {
    return DailyChallengeSet(
      date: json['date'] as String? ?? '',
      challenges: (json['challenges'] as List<dynamic>?)
              ?.map((e) =>
                  DailyChallenge.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      generatedAt: _parseTimestamp(json['generatedAt']) ?? DateTime.now(),
    );
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

/// Pool of challenge templates used for daily generation.
abstract final class ChallengeTemplates {
  static const List<DailyChallenge> pool = [
    DailyChallenge(
      id: 'ch_wound_photo',
      title: 'Wundfoto machen',
      description: 'Dokumentiere deine Wunde mit einem Foto',
      xpReward: 25,
      type: ChallengeType.wound,
    ),
    DailyChallenge(
      id: 'ch_pain_log',
      title: 'Schmerz dokumentieren',
      description: 'Trage deinen aktuellen Schmerzlevel ein',
      xpReward: 15,
      type: ChallengeType.pain,
    ),
    DailyChallenge(
      id: 'ch_vitals_log',
      title: 'Vitalwerte messen',
      description: 'Miss und notiere Blutdruck & Puls',
      xpReward: 15,
      type: ChallengeType.vitals,
    ),
    DailyChallenge(
      id: 'ch_medication',
      title: 'Medikamente eintragen',
      description: 'Dokumentiere deine Medikamenteneinnahme',
      xpReward: 20,
      type: ChallengeType.medication,
    ),
    DailyChallenge(
      id: 'ch_3_tasks',
      title: '3 Tasks erledigen',
      description: 'Schließe mindestens 3 Aufgaben ab',
      xpReward: 30,
      type: ChallengeType.task,
    ),
    DailyChallenge(
      id: 'ch_all_meds',
      title: 'Alle Medikamente nehmen',
      description: 'Vergiss keine Medikamenteneinnahme heute',
      xpReward: 25,
      type: ChallengeType.medication,
    ),
    DailyChallenge(
      id: 'ch_wound_note',
      title: 'Wundzustand beschreiben',
      description: 'Notiere eine Beobachtung zur Wundheilung',
      xpReward: 20,
      type: ChallengeType.wound,
    ),
    DailyChallenge(
      id: 'ch_complete_all',
      title: 'Alles dokumentieren',
      description: 'Trage in allen Bereichen mindestens einen Eintrag ein',
      xpReward: 40,
      type: ChallengeType.mixed,
    ),
    DailyChallenge(
      id: 'ch_pain_twice',
      title: 'Schmerz 2× dokumentieren',
      description: 'Trage morgens und abends deinen Schmerzlevel ein',
      xpReward: 20,
      type: ChallengeType.pain,
    ),
    DailyChallenge(
      id: 'ch_5_tasks',
      title: '5 Tasks erledigen',
      description: 'Schließe mindestens 5 Aufgaben ab',
      xpReward: 35,
      type: ChallengeType.task,
    ),
  ];
}
