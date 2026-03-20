import 'package:cloud_firestore/cloud_firestore.dart';

/// Trend direction for the pain score relative to the previous day.
enum PainTrend {
  rising,
  falling,
  stable,
  noData;

  static PainTrend fromString(String? value) => switch (value) {
        'rising' => PainTrend.rising,
        'falling' => PainTrend.falling,
        'stable' => PainTrend.stable,
        _ => PainTrend.noData,
      };

  String get label => switch (this) {
        PainTrend.rising => 'Steigend',
        PainTrend.falling => 'Sinkend',
        PainTrend.stable => 'Stabil',
        PainTrend.noData => 'Keine Daten',
      };

  String get emoji => switch (this) {
        PainTrend.rising => '📈',
        PainTrend.falling => '📉',
        PainTrend.stable => '➡️',
        PainTrend.noData => '❓',
      };
}

/// A daily AI-generated analysis produced by the `dailyBellaAnalysis`
/// Cloud Function and stored under `users/{uid}/bellaAnalysen/{date}`.
class BellaAnalyse {
  const BellaAnalyse({
    required this.date,
    required this.summary,
    required this.painTrend,
    this.painNote,
    this.vitalsNote,
    required this.openTaskCount,
    this.openTaskNote,
    this.encouragement,
    this.createdAt,
  });

  final String date;
  final String summary;
  final PainTrend painTrend;
  final String? painNote;
  final String? vitalsNote;
  final int openTaskCount;
  final String? openTaskNote;
  final String? encouragement;
  final DateTime? createdAt;

  factory BellaAnalyse.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return BellaAnalyse(
      date: d['date'] as String? ?? doc.id,
      summary: d['summary'] as String? ?? '',
      painTrend: PainTrend.fromString(d['painTrend'] as String?),
      painNote: d['painNote'] as String?,
      vitalsNote: d['vitalsNote'] as String?,
      openTaskCount: (d['openTaskCount'] as num?)?.toInt() ?? 0,
      openTaskNote: d['openTaskNote'] as String?,
      encouragement: d['encouragement'] as String?,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
