enum WarningLevel { green, yellow, red }

class WarningCheckAnswers {
  const WarningCheckAnswers({
    required this.feverHigh,
    required this.increasingRedness,
    required this.strongPain,
    required this.badSmellSecretion,
    required this.shortnessOfBreath,
    required this.strongBleeding,
  });

  final bool feverHigh;
  final bool increasingRedness;
  final bool strongPain;
  final bool badSmellSecretion;
  final bool shortnessOfBreath;
  final bool strongBleeding;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'feverHigh': feverHigh,
      'increasingRedness': increasingRedness,
      'strongPain': strongPain,
      'badSmellSecretion': badSmellSecretion,
      'shortnessOfBreath': shortnessOfBreath,
      'strongBleeding': strongBleeding,
    };
  }

  factory WarningCheckAnswers.fromJson(Map<String, dynamic> json) {
    return WarningCheckAnswers(
      feverHigh: _asBool(json['feverHigh']),
      increasingRedness: _asBool(json['increasingRedness']),
      strongPain: _asBool(json['strongPain']),
      badSmellSecretion: _asBool(json['badSmellSecretion']),
      shortnessOfBreath: _asBool(json['shortnessOfBreath']),
      strongBleeding: _asBool(json['strongBleeding']),
    );
  }

  static bool _asBool(Object? value) {
    if (value is bool) return value;
    if (value is String) return value.trim().toLowerCase() == 'true';
    return false;
  }
}

class WarningCheck {
  const WarningCheck({
    required this.id,
    required this.ownerId,
    required this.createdAt,
    required this.answers,
    required this.level,
    required this.actionText,
    this.metadata = const <String, dynamic>{},
  });

  final String id;
  final String ownerId;
  final DateTime createdAt;
  final WarningCheckAnswers answers;
  final WarningLevel level;
  final String actionText;
  final Map<String, dynamic> metadata;

  WarningCheck copyWith({
    String? id,
    String? ownerId,
    DateTime? createdAt,
    WarningCheckAnswers? answers,
    WarningLevel? level,
    String? actionText,
    Map<String, dynamic>? metadata,
  }) {
    return WarningCheck(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      answers: answers ?? this.answers,
      level: level ?? this.level,
      actionText: actionText ?? this.actionText,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'ownerId': ownerId,
      'createdAt': createdAt.toIso8601String(),
      'answers': answers.toJson(),
      'level': level.name,
      'actionText': actionText,
      'metadata': metadata,
    };
  }

  factory WarningCheck.fromJson(Map<String, dynamic> json) {
    return WarningCheck(
      id: (json['id'] ?? '').toString(),
      ownerId: (json['ownerId'] ?? '').toString(),
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
      answers: WarningCheckAnswers.fromJson(
        json['answers'] is Map
            ? Map<String, dynamic>.from(json['answers'] as Map)
            : const <String, dynamic>{},
      ),
      level: _parseLevel(json['level']),
      actionText: (json['actionText'] ?? '').toString(),
      metadata: _parseMetadata(json['metadata']),
    );
  }

  static DateTime? _parseDateTime(Object? value) {
    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  static WarningLevel _parseLevel(Object? value) {
    final raw = value?.toString() ?? '';
    for (final level in WarningLevel.values) {
      if (level.name == raw) return level;
    }
    return WarningLevel.green;
  }

  static Map<String, dynamic> _parseMetadata(Object? raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) {
      return raw.map(
        (dynamic key, dynamic value) => MapEntry(key.toString(), value),
      );
    }
    return const <String, dynamic>{};
  }
}

class WarningEngineResult {
  const WarningEngineResult({required this.level, required this.actionText});

  final WarningLevel level;
  final String actionText;
}

WarningEngineResult evaluateWarningCheck(WarningCheckAnswers answers) {
  final hasRedFlag =
      answers.shortnessOfBreath || answers.strongBleeding || answers.feverHigh;

  if (hasRedFlag) {
    return const WarningEngineResult(
      level: WarningLevel.red,
      actionText:
          'Sofort handeln: Ärztlichen Bereitschaftsdienst/Notruf kontaktieren '
          'und medizinische Hilfe einholen.',
    );
  }

  final moderateCount = <bool>[
    answers.increasingRedness,
    answers.strongPain,
    answers.badSmellSecretion,
  ].where((v) => v).length;

  if (moderateCount > 0) {
    return const WarningEngineResult(
      level: WarningLevel.yellow,
      actionText:
          'Bitte zeitnah ärztlich abklären und Symptome engmaschig beobachten.',
    );
  }

  return const WarningEngineResult(
    level: WarningLevel.green,
    actionText:
        'Aktuell unauffällig. Beobachte weiterhin deinen Verlauf und führe '
        'regelmäßige Checks durch.',
  );
}
