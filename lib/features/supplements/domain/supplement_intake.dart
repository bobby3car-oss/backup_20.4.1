import 'supplement_category.dart';

/// A single supplement intake log entry.
class SupplementIntake {
  const SupplementIntake({
    required this.id,
    required this.ownerId,
    required this.name,
    this.supplementId,
    this.dose,
    required this.category,
    required this.takenAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.metadata = const <String, dynamic>{},
  });

  final String id;
  final String ownerId;
  final String name;

  /// Optional reference to a [Supplement] reminder this intake belongs to.
  final String? supplementId;
  final String? dose;
  final SupplementCategory category;
  final DateTime takenAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final Map<String, dynamic> metadata;

  bool get isDeleted => deletedAt != null;

  SupplementIntake copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? supplementId,
    bool clearSupplementId = false,
    String? dose,
    bool clearDose = false,
    SupplementCategory? category,
    DateTime? takenAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
    Map<String, dynamic>? metadata,
  }) {
    return SupplementIntake(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      supplementId:
          clearSupplementId ? null : (supplementId ?? this.supplementId),
      dose: clearDose ? null : (dose ?? this.dose),
      category: category ?? this.category,
      takenAt: takenAt ?? this.takenAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'ownerId': ownerId,
      'name': name,
      if (supplementId != null) 'supplementId': supplementId,
      'dose': dose,
      'category': category.name,
      'takenAt': takenAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (deletedAt != null) 'deletedAt': deletedAt!.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory SupplementIntake.fromJson(Map<String, dynamic> json) {
    final takenAt = _parseDateTime(json['takenAt']);
    final createdAt = _parseDateTime(json['createdAt']);
    final effectiveTakenAt = takenAt ?? createdAt ?? DateTime.now();
    return SupplementIntake(
      id: (json['id'] ?? '').toString(),
      ownerId: (json['ownerId'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      supplementId: _parseStringOrNull(json['supplementId']),
      dose: _parseStringOrNull(json['dose']),
      category: SupplementCategory.fromName(json['category']?.toString()),
      takenAt: effectiveTakenAt,
      createdAt: createdAt ?? effectiveTakenAt,
      updatedAt: _parseDateTime(json['updatedAt']) ?? effectiveTakenAt,
      deletedAt: _parseDateTime(json['deletedAt']),
      metadata: _parseMetadata(json['metadata']),
    );
  }

  static DateTime? _parseDateTime(Object? raw) {
    if (raw is String && raw.trim().isNotEmpty) return DateTime.tryParse(raw);
    return null;
  }

  static String? _parseStringOrNull(Object? raw) {
    if (raw == null) return null;
    final value = raw.toString().trim();
    return value.isEmpty ? null : value;
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

