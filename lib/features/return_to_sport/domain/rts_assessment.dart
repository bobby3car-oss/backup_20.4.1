import 'package:flutter/foundation.dart';

/// Clearance level based on overall RTS score.
enum RtsClearanceLevel {
  cleared,     // >= 80 -> freigegeben
  almostReady, // 60-79 -> fast bereit
  notReady,    // < 60  -> noch nicht bereit
}

extension RtsClearanceLevelX on RtsClearanceLevel {
  String get label {
    switch (this) {
      case RtsClearanceLevel.cleared:    return 'Freigegeben';
      case RtsClearanceLevel.almostReady: return 'Fast bereit';
      case RtsClearanceLevel.notReady:   return 'Noch nicht bereit';
    }
  }

  String get emoji {
    switch (this) {
      case RtsClearanceLevel.cleared:    return '';
      case RtsClearanceLevel.almostReady: return '';
      case RtsClearanceLevel.notReady:   return '';
    }
  }
}

/// LSI unit used for the bilateral strength comparison test.
enum RtsLsiUnit { seconds, reps }

extension RtsLsiUnitX on RtsLsiUnit {
  String get label {
    switch (this) {
      case RtsLsiUnit.seconds: return 'Sekunden';
      case RtsLsiUnit.reps:    return 'Wiederholungen';
    }
  }

  String get shortLabel {
    switch (this) {
      case RtsLsiUnit.seconds: return 's';
      case RtsLsiUnit.reps:    return 'Wdh.';
    }
  }
}

/// Sport type for contextualising the RTS assessment.
enum SportType {
  running,
  soccer,
  strength,
  cycling,
  swimming,
  martialArts,
  other,
}

extension SportTypeX on SportType {
  String get emoji {
    switch (this) {
      case SportType.running:     return '🏃';
      case SportType.soccer:      return '⚽';
      case SportType.strength:    return '🏋️';
      case SportType.cycling:     return '🚴';
      case SportType.swimming:    return '🏊';
      case SportType.martialArts: return '🥋';
      case SportType.other:       return '🏅';
    }
  }
}

/// A single Return-to-Sport assessment consisting of six functional tests.
@immutable
class RtsAssessment {
  const RtsAssessment({
    required this.id,
    required this.ownerId,
    required this.performedAt,
    required this.overallScore,
    required this.clearanceLevel,
    required this.createdAt,
    required this.updatedAt,
    this.sportType,
    this.lsiAffected,
    this.lsiHealthy,
    this.lsiUnit = RtsLsiUnit.seconds,
    this.lsiScore,
    this.hopAffectedCm,
    this.hopHealthyCm,
    this.hopScore,
    this.balanceSeconds,
    this.balanceScore,
    this.tugSeconds,
    this.tugScore,
    this.stabilityRating,
    this.stabilityScore,
    this.painLevel,
    this.painScore,
    this.notes,
    this.metadata = const <String, dynamic>{},
    this.deletedAt,
  });

  final String id;
  final String ownerId;
  final SportType? sportType;

  final double? lsiAffected;
  final double? lsiHealthy;
  final RtsLsiUnit lsiUnit;
  final double? lsiScore;

  final double? hopAffectedCm;
  final double? hopHealthyCm;
  final double? hopScore;

  final double? balanceSeconds;
  final double? balanceScore;

  final double? tugSeconds;
  final double? tugScore;

  final int? stabilityRating;
  final double? stabilityScore;

  final int? painLevel;
  final double? painScore;

  final double overallScore;
  final RtsClearanceLevel clearanceLevel;
  final String? notes;
  final DateTime performedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  RtsAssessment copyWith({
    String? id,
    String? ownerId,
    DateTime? performedAt,
    SportType? sportType,
    bool clearSportType = false,
    double? lsiAffected,  bool clearLsiAffected = false,
    double? lsiHealthy,   bool clearLsiHealthy = false,
    RtsLsiUnit? lsiUnit,
    double? lsiScore,     bool clearLsiScore = false,
    double? hopAffectedCm, bool clearHopAffectedCm = false,
    double? hopHealthyCm,  bool clearHopHealthyCm = false,
    double? hopScore,      bool clearHopScore = false,
    double? balanceSeconds, bool clearBalanceSeconds = false,
    double? balanceScore,   bool clearBalanceScore = false,
    double? tugSeconds,  bool clearTugSeconds = false,
    double? tugScore,    bool clearTugScore = false,
    int? stabilityRating, bool clearStabilityRating = false,
    double? stabilityScore, bool clearStabilityScore = false,
    int? painLevel,    bool clearPainLevel = false,
    double? painScore, bool clearPainScore = false,
    double? overallScore,
    RtsClearanceLevel? clearanceLevel,
    String? notes, bool clearNotes = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) => RtsAssessment(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    performedAt: performedAt ?? this.performedAt,
    sportType: clearSportType ? null : (sportType ?? this.sportType),
    lsiAffected: clearLsiAffected ? null : (lsiAffected ?? this.lsiAffected),
    lsiHealthy: clearLsiHealthy ? null : (lsiHealthy ?? this.lsiHealthy),
    lsiUnit: lsiUnit ?? this.lsiUnit,
    lsiScore: clearLsiScore ? null : (lsiScore ?? this.lsiScore),
    hopAffectedCm: clearHopAffectedCm ? null : (hopAffectedCm ?? this.hopAffectedCm),
    hopHealthyCm: clearHopHealthyCm ? null : (hopHealthyCm ?? this.hopHealthyCm),
    hopScore: clearHopScore ? null : (hopScore ?? this.hopScore),
    balanceSeconds: clearBalanceSeconds ? null : (balanceSeconds ?? this.balanceSeconds),
    balanceScore: clearBalanceScore ? null : (balanceScore ?? this.balanceScore),
    tugSeconds: clearTugSeconds ? null : (tugSeconds ?? this.tugSeconds),
    tugScore: clearTugScore ? null : (tugScore ?? this.tugScore),
    stabilityRating: clearStabilityRating ? null : (stabilityRating ?? this.stabilityRating),
    stabilityScore: clearStabilityScore ? null : (stabilityScore ?? this.stabilityScore),
    painLevel: clearPainLevel ? null : (painLevel ?? this.painLevel),
    painScore: clearPainScore ? null : (painScore ?? this.painScore),
    overallScore: overallScore ?? this.overallScore,
    clearanceLevel: clearanceLevel ?? this.clearanceLevel,
    notes: clearNotes ? null : (notes ?? this.notes),
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    metadata: metadata ?? this.metadata,
    deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'ownerId': ownerId,
    'performedAt': performedAt.toIso8601String(),
    if (sportType != null) 'sportType': sportType!.name,
    if (lsiAffected != null) 'lsiAffected': lsiAffected,
    if (lsiHealthy != null) 'lsiHealthy': lsiHealthy,
    'lsiUnit': lsiUnit.name,
    if (lsiScore != null) 'lsiScore': lsiScore,
    if (hopAffectedCm != null) 'hopAffectedCm': hopAffectedCm,
    if (hopHealthyCm != null) 'hopHealthyCm': hopHealthyCm,
    if (hopScore != null) 'hopScore': hopScore,
    if (balanceSeconds != null) 'balanceSeconds': balanceSeconds,
    if (balanceScore != null) 'balanceScore': balanceScore,
    if (tugSeconds != null) 'tugSeconds': tugSeconds,
    if (tugScore != null) 'tugScore': tugScore,
    if (stabilityRating != null) 'stabilityRating': stabilityRating,
    if (stabilityScore != null) 'stabilityScore': stabilityScore,
    if (painLevel != null) 'painLevel': painLevel,
    if (painScore != null) 'painScore': painScore,
    'overallScore': overallScore,
    'clearanceLevel': clearanceLevel.name,
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'metadata': metadata,
    'deletedAt': deletedAt?.toIso8601String(),
  };

  factory RtsAssessment.fromJson(Map<String, dynamic> json) => RtsAssessment(
    id: json['id'] as String? ?? '',
    ownerId: json['ownerId'] as String? ?? '',
    performedAt: _parseDateTime(json['performedAt']) ?? DateTime.now(),
    sportType: _parseSportType(json['sportType']),
    lsiAffected: _parseDouble(json['lsiAffected']),
    lsiHealthy: _parseDouble(json['lsiHealthy']),
    lsiUnit: _parseLsiUnit(json['lsiUnit']),
    lsiScore: _parseDouble(json['lsiScore']),
    hopAffectedCm: _parseDouble(json['hopAffectedCm']),
    hopHealthyCm: _parseDouble(json['hopHealthyCm']),
    hopScore: _parseDouble(json['hopScore']),
    balanceSeconds: _parseDouble(json['balanceSeconds']),
    balanceScore: _parseDouble(json['balanceScore']),
    tugSeconds: _parseDouble(json['tugSeconds']),
    tugScore: _parseDouble(json['tugScore']),
    stabilityRating: _parseInt(json['stabilityRating']),
    stabilityScore: _parseDouble(json['stabilityScore']),
    painLevel: _parseInt(json['painLevel']),
    painScore: _parseDouble(json['painScore']),
    overallScore: _parseDouble(json['overallScore']) ?? 0.0,
    clearanceLevel: _parseClearanceLevel(json['clearanceLevel']),
    notes: json['notes'] as String?,
    createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
    updatedAt: _parseDateTime(json['updatedAt']) ?? DateTime.now(),
    metadata: json['metadata'] is Map
        ? Map<String, dynamic>.from(json['metadata'] as Map)
        : const <String, dynamic>{},
    deletedAt: _parseDateTime(json['deletedAt']),
  );

  static DateTime? _parseDateTime(Object? v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String) { try { return DateTime.parse(v); } catch (_) { return null; } }
    return null;
  }

  static double? _parseDouble(Object? v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  static int? _parseInt(Object? v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.round();
    if (v is String) return int.tryParse(v);
    return null;
  }

  static RtsLsiUnit _parseLsiUnit(Object? v) {
    if (v is String) {
      return RtsLsiUnit.values.firstWhere((e) => e.name == v, orElse: () => RtsLsiUnit.seconds);
    }
    return RtsLsiUnit.seconds;
  }

  static SportType? _parseSportType(Object? v) {
    if (v is String) {
      return SportType.values.firstWhere((e) => e.name == v, orElse: () => SportType.other);
    }
    return null;
  }

  static RtsClearanceLevel _parseClearanceLevel(Object? v) {
    if (v is String) {
      return RtsClearanceLevel.values.firstWhere((e) => e.name == v, orElse: () => RtsClearanceLevel.notReady);
    }
    return RtsClearanceLevel.notReady;
  }
}
