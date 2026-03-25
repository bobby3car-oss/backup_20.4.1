class WoundEntry {
  const WoundEntry({
    required this.id,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    this.bodyLocation,
    required this.pain,
    required this.note,
    this.photoPath,
    this.relatedTaskId,
    this.metadata = const <String, dynamic>{},
  });

  final String id;
  final String ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? bodyLocation;
  final int pain;
  final String note;
  final String? photoPath;
  final String? relatedTaskId;
  final Map<String, dynamic> metadata;

  WoundEntry copyWith({
    String? id,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? bodyLocation,
    bool clearBodyLocation = false,
    int? pain,
    String? note,
    String? photoPath,
    bool clearPhotoPath = false,
    String? relatedTaskId,
    bool clearRelatedTaskId = false,
    Map<String, dynamic>? metadata,
  }) {
    return WoundEntry(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      bodyLocation: clearBodyLocation
          ? null
          : (bodyLocation ?? this.bodyLocation),
      pain: pain ?? this.pain,
      note: note ?? this.note,
      photoPath: clearPhotoPath ? null : (photoPath ?? this.photoPath),
      relatedTaskId: clearRelatedTaskId
          ? null
          : (relatedTaskId ?? this.relatedTaskId),
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'ownerId': ownerId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'bodyLocation': bodyLocation,
      'pain': pain,
      'note': note,
      'photoPath': photoPath,
      'relatedTaskId': relatedTaskId,
      'metadata': metadata,
    };
  }

  factory WoundEntry.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return WoundEntry(
      id: json['id'] as String? ?? generateId(),
      ownerId: (json['ownerId'] ?? '').toString(),
      createdAt: _parseDateTime(json['createdAt']) ?? now,
      updatedAt: _parseDateTime(json['updatedAt']) ?? now,
      bodyLocation: json['bodyLocation'] as String?,
      pain: (json['pain'] as num?)?.toInt().clamp(0, 10) ?? 0,
      note: json['note'] as String? ?? '',
      photoPath: json['photoPath'] as String?,
      relatedTaskId: json['relatedTaskId'] as String?,
      metadata: _metadataFrom(json['metadata']),
    );
  }

  static String generateId([DateTime? timestamp]) {
    final now = (timestamp ?? DateTime.now()).toLocal();
    final yyyy = now.year.toString().padLeft(4, '0');
    final mm = now.month.toString().padLeft(2, '0');
    final dd = now.day.toString().padLeft(2, '0');
    final hh = now.hour.toString().padLeft(2, '0');
    final min = now.minute.toString().padLeft(2, '0');
    final sec = now.second.toString().padLeft(2, '0');
    final datePart = yyyy + mm + dd;
    final timePart = hh + min + sec;
    return 'wound_${datePart}_$timePart';
  }
}

DateTime? _parseDateTime(Object? value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value);
}

Map<String, dynamic> _metadataFrom(Object? value) {
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return const <String, dynamic>{};
}
