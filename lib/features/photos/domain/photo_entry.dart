enum PhotoCategory { wound, consent, other }

enum PhotoStatus { pending, synced }

class PhotoEntry {
  const PhotoEntry({
    required this.id,
    required this.ownerId,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    required this.note,
    this.localPath,
    this.storagePath,
    this.deletedAt,
    this.status = PhotoStatus.pending,
  });

  final String id;
  final String ownerId;
  final PhotoCategory category;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String note;
  final String? localPath;
  final String? storagePath;
  final DateTime? deletedAt;
  final PhotoStatus status;

  PhotoEntry copyWith({
    String? id,
    String? ownerId,
    PhotoCategory? category,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? note,
    String? localPath,
    bool clearLocalPath = false,
    String? storagePath,
    bool clearStoragePath = false,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
    PhotoStatus? status,
  }) {
    return PhotoEntry(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      note: note ?? this.note,
      localPath: clearLocalPath ? null : (localPath ?? this.localPath),
      storagePath: clearStoragePath ? null : (storagePath ?? this.storagePath),
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'ownerId': ownerId,
      'category': category.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'note': note,
      'localPath': localPath,
      'storagePath': storagePath,
      'deletedAt': deletedAt?.toIso8601String(),
      'status': status.name,
    };
  }

  factory PhotoEntry.fromJson(Map<String, dynamic> json) {
    return PhotoEntry(
      id: (json['id'] ?? '').toString(),
      ownerId: (json['ownerId'] ?? '').toString(),
      category: _parseCategory(json['category']),
      createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updatedAt']) ?? DateTime.now(),
      note: (json['note'] ?? '').toString(),
      localPath: _stringOrNull(json['localPath']),
      storagePath: _stringOrNull(json['storagePath']),
      deletedAt: _parseDate(json['deletedAt']),
      status: _parseStatus(json['status']),
    );
  }

  static String generateId([DateTime? when]) {
    return 'photo_${(when ?? DateTime.now()).millisecondsSinceEpoch}';
  }
}

PhotoCategory _parseCategory(Object? raw) {
  final value = raw?.toString();
  for (final item in PhotoCategory.values) {
    if (item.name == value) return item;
  }
  return PhotoCategory.other;
}

PhotoStatus _parseStatus(Object? raw) {
  final value = raw?.toString();
  for (final item in PhotoStatus.values) {
    if (item.name == value) return item;
  }
  return PhotoStatus.pending;
}

DateTime? _parseDate(Object? raw) {
  if (raw is String && raw.trim().isNotEmpty) {
    return DateTime.tryParse(raw);
  }
  if (raw is int) {
    return DateTime.fromMillisecondsSinceEpoch(raw);
  }
  return null;
}

String? _stringOrNull(Object? raw) {
  if (raw == null) return null;
  final value = raw.toString().trim();
  return value.isEmpty ? null : value;
}
