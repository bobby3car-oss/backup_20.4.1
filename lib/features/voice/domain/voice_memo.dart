enum VoiceSyncStatus { pending, synced, failed }

enum TranscriptionStatus { none, processing, done, failed }

/// Predefined tag constants for voice memos.
abstract final class VoiceMemoTags {
  static const String arztgespraech = 'Arztgespräch';
  static const String symptome = 'Symptome';
  static const String fragen = 'Fragen';
  static const String persoenlich = 'Persönlich';
  static const String erinnerung = 'Erinnerung';

  static const List<String> predefined = <String>[
    arztgespraech,
    symptome,
    fragen,
    persoenlich,
    erinnerung,
  ];
}

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
    this.transcript,
    this.transcriptionStatus = TranscriptionStatus.none,
    this.tags = const <String>[],
    this.linkedTimelineItemId,
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

  /// Transcribed text of the voice memo.
  final String? transcript;

  /// Current state of the transcription process.
  final TranscriptionStatus transcriptionStatus;

  /// User-assigned tags (predefined + custom).
  final List<String> tags;

  /// Optional link to a timeline item.
  final String? linkedTimelineItemId;

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
    String? transcript,
    bool clearTranscript = false,
    TranscriptionStatus? transcriptionStatus,
    List<String>? tags,
    String? linkedTimelineItemId,
    bool clearLinkedTimelineItemId = false,
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
      transcript: clearTranscript ? null : (transcript ?? this.transcript),
      transcriptionStatus: transcriptionStatus ?? this.transcriptionStatus,
      tags: tags ?? this.tags,
      linkedTimelineItemId: clearLinkedTimelineItemId
          ? null
          : (linkedTimelineItemId ?? this.linkedTimelineItemId),
    );
  }

  /// Whether this memo matches a search query (title or transcript).
  bool matchesSearch(String query) {
    if (query.isEmpty) return true;
    final lower = query.toLowerCase();
    if (title.toLowerCase().contains(lower)) return true;
    if (transcript != null && transcript!.toLowerCase().contains(lower)) {
      return true;
    }
    return false;
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
      'transcript': transcript,
      'transcriptionStatus': transcriptionStatus.name,
      'tags': tags,
      'linkedTimelineItemId': linkedTimelineItemId,
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
      transcript: _parseStringOrNull(json['transcript']),
      transcriptionStatus: _parseTranscriptionStatus(json['transcriptionStatus']),
      tags: _parseStringList(json['tags']),
      linkedTimelineItemId: _parseStringOrNull(json['linkedTimelineItemId']),
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

  static TranscriptionStatus _parseTranscriptionStatus(Object? raw) {
    final name = raw?.toString() ?? '';
    for (final status in TranscriptionStatus.values) {
      if (status.name == name) return status;
    }
    return TranscriptionStatus.none;
  }

  static List<String> _parseStringList(Object? raw) {
    if (raw is List) {
      return raw
          .whereType<Object>()
          .map((e) => e.toString())
          .where((s) => s.isNotEmpty)
          .toList(growable: false);
    }
    return const <String>[];
  }
}
