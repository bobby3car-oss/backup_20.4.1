/// Structured result of a Bella AI wound analysis.
class WoundAnalysisResult {
  const WoundAnalysisResult({
    required this.status,
    required this.statusLabel,
    required this.observations,
    required this.recommendation,
    this.comparisonNote,
    required this.analyzedAt,
  });

  /// Traffic-light status: green | yellow | red.
  final String status;

  /// Human-readable label, e.g. "Gute Heilung".
  final String statusLabel;

  /// List of individual observations from the AI.
  final List<String> observations;

  /// Overall recommendation text.
  final String recommendation;

  /// Optional note about comparison with previous photos.
  final String? comparisonNote;

  /// When the analysis was performed.
  final DateTime analyzedAt;

  /// Emoji for the traffic-light status.
  String get statusEmoji => switch (status) {
        'green' => '🟢',
        'yellow' => '🟡',
        'red' => '🔴',
        _ => '⚪',
      };

  factory WoundAnalysisResult.fromJson(Map<String, dynamic> json) {
    return WoundAnalysisResult(
      status: (json['status'] as String?) ?? 'yellow',
      statusLabel: (json['statusLabel'] as String?) ?? 'Analyse',
      observations: (json['observations'] as List?)
              ?.whereType<String>()
              .toList() ??
          const [],
      recommendation: (json['recommendation'] as String?) ?? '',
      comparisonNote: json['comparisonNote'] as String?,
      analyzedAt: DateTime.tryParse(
              (json['analyzedAt'] as String?) ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'statusLabel': statusLabel,
        'observations': observations,
        'recommendation': recommendation,
        if (comparisonNote != null) 'comparisonNote': comparisonNote,
        'analyzedAt': analyzedAt.toIso8601String(),
      };
}
