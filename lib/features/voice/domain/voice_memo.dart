enum VoiceSyncStatus { pending, synced, failed }

class VoiceMemo {
  const VoiceMemo({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.localFilePath,
    this.remoteUrl,
    required this.durationMs,
    required this.recordedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    this.metadata = const <String, dynamic>{},
  });

  final String id;
  final String ownerId;
  final String title;
  final String localFilePath;
  final String? remoteUrl;
  final int durationMs;
  final DateTime recordedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final VoiceSyncStatus syncStatus;
  final Map<String, dynamic> metadata;

  VoiceMemo copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? localFilePath,
    String? remoteUrl,
    bool clearRemoteUrl = false,
    int? durationMs,
    DateTime? recordedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    VoiceSyncStatus? syncStatus,
    Map<String, dynamic>? metadata,
  }) {
    return VoiceMemo(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      localFilePath: localFilePath ?? this.localFilePath,
      remoteUrl: clearRemoteUrl ? null : (remoteUrl ?? this.remoteUrl),
      durationMs: durationMs ?? this.durationMs,
      recordedAt: recordedAt ?? this.recordedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'ownerId': ownerId,
      'title': title,
      'localFilePath': localFilePath,
      'remoteUrl': remoteUrl,
      'durationMs': durationMs,
      'recordedAt': recordedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'syncStatus': syncStatus.name,
      'metadata': metadata,
    };
  }

  factory VoiceMemo.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    final recordedAt = _parseDateTime(json['recordedAt']) ?? now;
    return VoiceMemo(
      id: (json['id'] ?? '').toString(),
      ownerId: (json['ownerId'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      localFilePath: (json['localFilePath'] ?? '').toString(),
      remoteUrl: _parseStringOrNull(json['remoteUrl']),
      durationMs: _parseInt(json['durationMs']) ?? 0,
      recordedAt: recordedAt,
      createdAt: _parseDateTime(json['createdAt']) ?? recordedAt,
      updatedAt: _parseDateTime(json['updatedAt']) ?? recordedAt,
      syncStatus: _parseSyncStatus(json['syncStatus']),
      metadata: _parseMetadata(json['metadata']),
    );
  }

  static VoiceSyncStatus _parseSyncStatus(Object? raw) {
    final name = raw?.toString() ?? '';
    for (final status in VoiceSyncStatus.values) {
      if (status.name == name) return status;
    }
    return VoiceSyncStatus.pending;
  }

  static DateTime? _parseDateTime(Object? raw) {
    if (raw is String && raw.trim().isNotEmpty) {
      return DateTime.tryParse(raw);
    }
    return null;
  }

  static String? _parseStringOrNull(Object? raw) {
    if (raw == null) return null;
    final value = raw.toString().trim();
    return value.isEmpty ? null : value;
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
