/// Persisted result of a Symptom-Check questionnaire.
///
/// Stored at `patients/{uid}/symptom_checks/{id}` in Firestore.
enum SymptomSeverity { none, mild, moderate, severe }

extension SymptomSeverityX on SymptomSeverity {
  String get label => switch (this) {
        SymptomSeverity.none => 'Keine',
        SymptomSeverity.mild => 'Leicht',
        SymptomSeverity.moderate => 'Mittel',
        SymptomSeverity.severe => 'Stark',
      };

  int get weight => switch (this) {
        SymptomSeverity.none => 0,
        SymptomSeverity.mild => 1,
        SymptomSeverity.moderate => 2,
        SymptomSeverity.severe => 3,
      };
}

enum SymptomCheckLevel { green, yellow, red }

extension SymptomCheckLevelX on SymptomCheckLevel {
  String get label => switch (this) {
        SymptomCheckLevel.green => 'Grün',
        SymptomCheckLevel.yellow => 'Gelb',
        SymptomCheckLevel.red => 'Rot',
      };

  String get recommendation => switch (this) {
        SymptomCheckLevel.green =>
          'Ihre Symptome sind unauffällig. Dokumentieren Sie weiterhin '
              'regelmäßig und halten Sie sich an Ihren Genesungsplan.',
        SymptomCheckLevel.yellow =>
          'Einzelne Symptome sind leicht auffällig. Beobachten Sie die '
              'Entwicklung in den nächsten 24 Stunden. Bei Verschlechterung '
              'kontaktieren Sie Ihren Arzt.',
        SymptomCheckLevel.red =>
          'Ihre Symptome deuten auf eine Komplikation hin. Kontaktieren '
              'Sie umgehend Ihren Arzt oder suchen Sie die nächste '
              'Notaufnahme auf.',
      };
}

class SymptomCheckResult {
  const SymptomCheckResult({
    required this.id,
    required this.ownerId,
    required this.answers,
    required this.overallLevel,
    required this.recommendation,
    required this.createdAt,
  });

  final String id;
  final String ownerId;

  /// Maps symptom id (e.g. 'pain', 'nausea') → severity.
  final Map<String, SymptomSeverity> answers;
  final SymptomCheckLevel overallLevel;
  final String recommendation;
  final DateTime createdAt;

  /// Human-readable list of symptoms that are moderate or severe.
  List<String> get criticalSymptoms => answers.entries
      .where((e) =>
          e.value == SymptomSeverity.moderate ||
          e.value == SymptomSeverity.severe)
      .map((e) => _symptomLabel(e.key))
      .toList();

  int get totalScore =>
      answers.values.fold<int>(0, (sum, s) => sum + s.weight);

  SymptomCheckResult copyWith({
    String? id,
    String? ownerId,
    Map<String, SymptomSeverity>? answers,
    SymptomCheckLevel? overallLevel,
    String? recommendation,
    DateTime? createdAt,
  }) {
    return SymptomCheckResult(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      answers: answers ?? this.answers,
      overallLevel: overallLevel ?? this.overallLevel,
      recommendation: recommendation ?? this.recommendation,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'ownerId': ownerId,
      'answers': answers.map((k, v) => MapEntry(k, v.name)),
      'overallLevel': overallLevel.name,
      'recommendation': recommendation,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SymptomCheckResult.fromJson(Map<String, dynamic> json) {
    return SymptomCheckResult(
      id: (json['id'] ?? '').toString(),
      ownerId: (json['ownerId'] ?? '').toString(),
      answers: _parseAnswers(json['answers']),
      overallLevel: _parseLevel(json['overallLevel']),
      recommendation: (json['recommendation'] ?? '').toString(),
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
    );
  }

  // ── Helpers ──

  static Map<String, SymptomSeverity> _parseAnswers(Object? raw) {
    if (raw is! Map) return const {};
    final result = <String, SymptomSeverity>{};
    for (final entry in raw.entries) {
      final key = entry.key.toString();
      final sev = _parseSeverity(entry.value);
      result[key] = sev;
    }
    return result;
  }

  static SymptomSeverity _parseSeverity(Object? raw) {
    final s = raw?.toString() ?? '';
    for (final v in SymptomSeverity.values) {
      if (v.name == s) return v;
    }
    return SymptomSeverity.none;
  }

  static SymptomCheckLevel _parseLevel(Object? raw) {
    final s = raw?.toString() ?? '';
    for (final v in SymptomCheckLevel.values) {
      if (v.name == s) return v;
    }
    return SymptomCheckLevel.green;
  }

  static DateTime? _parseDateTime(Object? raw) {
    if (raw is DateTime) return raw;
    if (raw is String) return DateTime.tryParse(raw);
    return null;
  }

  static String _symptomLabel(String id) => switch (id) {
        'pain' => 'Schmerzen',
        'nausea' => 'Übelkeit',
        'breathing' => 'Atmung',
        'dizziness' => 'Schwindel',
        'wound' => 'Wundstatus',
        _ => id,
      };
}
