enum DocumentType { arztbrief, aufklaerung, rezept, befunde, sonstiges }

class DocumentItem {
  const DocumentItem({
    required this.id,
    required this.ownerId,
    required this.type,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.localPath,
    this.storagePath,
    this.downloadUrl,
    this.mimeType,
    this.sizeBytes,
    this.tags = const <String>[],
    this.metadata = const <String, dynamic>{},
  });

  final String id;
  final String ownerId;
  final DocumentType type;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? localPath;
  final String? storagePath;
  final String? downloadUrl;
  final String? mimeType;
  final int? sizeBytes;
  final List<String> tags;
  final Map<String, dynamic> metadata;

  DocumentItem copyWith({
    String? id,
    String? ownerId,
    DocumentType? type,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? localPath,
    bool clearLocalPath = false,
    String? storagePath,
    bool clearStoragePath = false,
    String? downloadUrl,
    bool clearDownloadUrl = false,
    String? mimeType,
    bool clearMimeType = false,
    int? sizeBytes,
    bool clearSizeBytes = false,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) {
    return DocumentItem(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      type: type ?? this.type,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      localPath: clearLocalPath ? null : (localPath ?? this.localPath),
      storagePath: clearStoragePath ? null : (storagePath ?? this.storagePath),
      downloadUrl: clearDownloadUrl ? null : (downloadUrl ?? this.downloadUrl),
      mimeType: clearMimeType ? null : (mimeType ?? this.mimeType),
      sizeBytes: clearSizeBytes ? null : (sizeBytes ?? this.sizeBytes),
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'ownerId': ownerId,
      'type': type.name,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'localPath': localPath,
      'storagePath': storagePath,
      'downloadUrl': downloadUrl,
      'mimeType': mimeType,
      'sizeBytes': sizeBytes,
      'tags': tags,
      'metadata': metadata,
    };
  }

  factory DocumentItem.fromJson(Map<String, dynamic> json) {
    return DocumentItem(
      id: (json['id'] ?? '').toString(),
      ownerId: (json['ownerId'] ?? '').toString(),
      type: _parseType(json['type']),
      title: (json['title'] ?? '').toString(),
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
      updatedAt:
          _parseDateTime(json['updatedAt']) ??
          _parseDateTime(json['createdAt']) ??
          DateTime.now(),
      localPath: _asStringOrNull(json['localPath']),
      storagePath: _asStringOrNull(json['storagePath']),
      downloadUrl: _asStringOrNull(json['downloadUrl']),
      mimeType: _asStringOrNull(json['mimeType']),
      sizeBytes: _parseIntOrNull(json['sizeBytes']),
      tags: _parseTags(json['tags']),
      metadata: _parseMetadata(json['metadata']),
    );
  }

  static DocumentType _parseType(Object? raw) {
    final value = raw?.toString();
    for (final type in DocumentType.values) {
      if (type.name == value) return type;
    }
    return DocumentType.sonstiges;
  }

  static DateTime? _parseDateTime(Object? raw) {
    if (raw is String && raw.trim().isNotEmpty) {
      return DateTime.tryParse(raw);
    }
    return null;
  }

  static String? _asStringOrNull(Object? raw) {
    if (raw == null) return null;
    final value = raw.toString().trim();
    return value.isEmpty ? null : value;
  }

  static int? _parseIntOrNull(Object? raw) {
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw);
    return null;
  }

  static List<String> _parseTags(Object? raw) {
    if (raw is List) {
      return raw.map((value) => value.toString()).toList(growable: false);
    }
    return const <String>[];
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
