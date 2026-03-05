enum QuestionCategory { surgeon, anesthetist }

extension QuestionCategoryLabel on QuestionCategory {
  String get label {
    return switch (this) {
      QuestionCategory.surgeon => 'Operateur',
      QuestionCategory.anesthetist => 'Anästhesist',
    };
  }
}

enum QuestionStatus { open, asked, answered }

extension QuestionStatusLabel on QuestionStatus {
  String get label {
    return switch (this) {
      QuestionStatus.open => 'offen',
      QuestionStatus.asked => 'gestellt',
      QuestionStatus.answered => 'beantwortet',
    };
  }
}

class DoctorQuestion {
  const DoctorQuestion({
    required this.id,
    required this.ownerId,
    required this.text,
    required this.category,
    required this.status,
    required this.favorite,
    required this.createdAt,
    required this.updatedAt,
    required this.isDefault,
    this.metadata = const <String, dynamic>{},
  });

  final String id;
  final String ownerId;
  final String text;
  final QuestionCategory category;
  final QuestionStatus status;
  final bool favorite;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDefault;
  final Map<String, dynamic> metadata;

  DoctorQuestion copyWith({
    String? id,
    String? ownerId,
    String? text,
    QuestionCategory? category,
    QuestionStatus? status,
    bool? favorite,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDefault,
    Map<String, dynamic>? metadata,
  }) {
    return DoctorQuestion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      text: text ?? this.text,
      category: category ?? this.category,
      status: status ?? this.status,
      favorite: favorite ?? this.favorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDefault: isDefault ?? this.isDefault,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'ownerId': ownerId,
      'text': text,
      'category': category.name,
      'status': status.name,
      'favorite': favorite,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDefault': isDefault,
      'metadata': metadata,
    };
  }

  factory DoctorQuestion.fromJson(Map<String, dynamic> json) {
    final createdAt = _parseDateTime(json['createdAt']) ?? DateTime.now();
    return DoctorQuestion(
      id: (json['id'] ?? '').toString(),
      ownerId: (json['ownerId'] ?? '').toString(),
      text: (json['text'] ?? '').toString(),
      category: _parseCategory(json['category']),
      status: _parseStatus(json['status']),
      favorite: _asBool(json['favorite']),
      createdAt: createdAt,
      updatedAt: _parseDateTime(json['updatedAt']) ?? createdAt,
      isDefault: _asBool(json['isDefault']),
      metadata: _parseMetadata(json['metadata']),
    );
  }

  static QuestionCategory _parseCategory(Object? raw) {
    final value = raw?.toString() ?? '';
    for (final category in QuestionCategory.values) {
      if (category.name == value) return category;
    }
    return QuestionCategory.surgeon;
  }

  static QuestionStatus _parseStatus(Object? raw) {
    final value = raw?.toString() ?? '';
    for (final status in QuestionStatus.values) {
      if (status.name == value) return status;
    }
    return QuestionStatus.open;
  }

  static bool _asBool(Object? value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  static DateTime? _parseDateTime(Object? value) {
    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  static Map<String, dynamic> _parseMetadata(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map(
        (dynamic key, dynamic val) => MapEntry(key.toString(), val),
      );
    }
    return const <String, dynamic>{};
  }
}
