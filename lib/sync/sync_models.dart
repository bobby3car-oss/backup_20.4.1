enum SyncOpType { upsert, delete }

class SyncOp {
  const SyncOp({
    required this.id,
    required this.collectionPath,
    required this.docId,
    required this.type,
    required this.payload,
    required this.createdAt,
    this.retryCount = 0,
    this.lastError,
  });

  final String id;
  final String collectionPath;
  final String docId;
  final SyncOpType type;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final int retryCount;
  final String? lastError;

  String get fullDocPath => '$collectionPath/$docId';

  SyncOp copyWith({
    String? id,
    String? collectionPath,
    String? docId,
    SyncOpType? type,
    Map<String, dynamic>? payload,
    DateTime? createdAt,
    int? retryCount,
    String? lastError,
    bool clearLastError = false,
  }) {
    return SyncOp(
      id: id ?? this.id,
      collectionPath: collectionPath ?? this.collectionPath,
      docId: docId ?? this.docId,
      type: type ?? this.type,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      lastError: clearLastError ? null : (lastError ?? this.lastError),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'collectionPath': collectionPath,
      'docId': docId,
      'type': type.name,
      'payload': payload,
      'createdAt': createdAt.toIso8601String(),
      'retryCount': retryCount,
      'lastError': lastError,
    };
  }

  factory SyncOp.fromJson(Map<String, dynamic> json) {
    return SyncOp(
      id: (json['id'] ?? '').toString(),
      collectionPath: (json['collectionPath'] ?? '').toString(),
      docId: (json['docId'] ?? '').toString(),
      type: _parseType(json['type']),
      payload: _parsePayload(json['payload']),
      createdAt: _parseDateTime(json['createdAt']),
      retryCount: _parseInt(json['retryCount']),
      lastError: json['lastError']?.toString(),
    );
  }

  static SyncOpType _parseType(Object? raw) {
    final rawString = raw?.toString();
    if (rawString == SyncOpType.delete.name) {
      return SyncOpType.delete;
    }
    return SyncOpType.upsert;
  }

  static Map<String, dynamic> _parsePayload(Object? raw) {
    if (raw is Map<String, dynamic>) {
      return raw;
    }
    if (raw is Map) {
      return raw.map(
        (dynamic key, dynamic value) => MapEntry(key.toString(), value),
      );
    }
    return <String, dynamic>{};
  }

  static DateTime _parseDateTime(Object? raw) {
    if (raw is String) {
      final parsed = DateTime.tryParse(raw);
      if (parsed != null) {
        return parsed;
      }
    }
    return DateTime.now();
  }

  static int _parseInt(Object? raw) {
    if (raw is int) {
      return raw;
    }
    if (raw is num) {
      return raw.toInt();
    }
    if (raw is String) {
      return int.tryParse(raw) ?? 0;
    }
    return 0;
  }
}
