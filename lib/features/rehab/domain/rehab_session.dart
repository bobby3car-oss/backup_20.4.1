/// A completed rehabilitation exercise session.
class RehabSession {
  const RehabSession({
    required this.id,
    required this.ownerId,
    required this.exerciseId,
    required this.exerciseTitle,
    required this.completedSets,
    required this.totalSets,
    required this.totalDurationSeconds,
    required this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    this.notes = '',
    this.metadata = const <String, dynamic>{},
    this.deletedAt,
  });

  final String id;
  final String ownerId;
  final String exerciseId;
  final String exerciseTitle;
  final int completedSets;
  final int totalSets;
  final int totalDurationSeconds;
  final DateTime completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String notes;
  final Map<String, dynamic> metadata;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  RehabSession copyWith({
    String? id,
    String? ownerId,
    String? exerciseId,
    String? exerciseTitle,
    int? completedSets,
    int? totalSets,
    int? totalDurationSeconds,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
    Map<String, dynamic>? metadata,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return RehabSession(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseTitle: exerciseTitle ?? this.exerciseTitle,
      completedSets: completedSets ?? this.completedSets,
      totalSets: totalSets ?? this.totalSets,
      totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'ownerId': ownerId,
      'exerciseId': exerciseId,
      'exerciseTitle': exerciseTitle,
      'completedSets': completedSets,
      'totalSets': totalSets,
      'totalDurationSeconds': totalDurationSeconds,
      'completedAt': completedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'notes': notes,
      'metadata': metadata,
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  factory RehabSession.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return RehabSession(
      id: (json['id'] ?? '').toString(),
      ownerId: (json['ownerId'] ?? '').toString(),
      exerciseId: (json['exerciseId'] ?? '').toString(),
      exerciseTitle: (json['exerciseTitle'] ?? '').toString(),
      completedSets: _parseInt(json['completedSets']) ?? 0,
      totalSets: _parseInt(json['totalSets']) ?? 0,
      totalDurationSeconds: _parseInt(json['totalDurationSeconds']) ?? 0,
      completedAt: _parseDateTime(json['completedAt']) ?? now,
      createdAt: _parseDateTime(json['createdAt']) ?? now,
      updatedAt: _parseDateTime(json['updatedAt']) ?? now,
      notes: (json['notes'] ?? '').toString(),
      metadata: _parseMetadata(json['metadata']),
      deletedAt: _parseDateTime(json['deletedAt']),
    );
  }

  static DateTime? _parseDateTime(Object? raw) {
    if (raw is String && raw.trim().isNotEmpty) {
      return DateTime.tryParse(raw);
    }
    return null;
  }

  static int? _parseInt(Object? raw) {
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw);
    return null;
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
