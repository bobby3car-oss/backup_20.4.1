"""Write the updated RTS feature files for Phase 2 enhancements."""
import pathlib

BASE = pathlib.Path("/Users/jan/projects/operationsbegleiter_v3/lib/features/return_to_sport")

# ── rts_assessment.dart ──────────────────────────────────────────────────────

ASSESSMENT_MODEL = r"""import 'package:flutter/foundation.dart';

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
"""

# ── rts_calculator.dart ──────────────────────────────────────────────────────

CALCULATOR = r"""import 'dart:math' as math;

import 'rts_assessment.dart';

/// Scoring engine for Return-to-Sport assessments.
///
/// Six sub-tests yield a score 0–100. The overall score is a weighted average.
///
/// Weights:
///   Hop-Test (Sprungkraft-LSI)   25 %
///   LSI Kraftseitenvergleich     20 %
///   Timed Up and Go              20 %
///   Balance (Einbeinstand)       15 %
///   Stability (Kniebeuge)        10 %
///   Pain (Schmerzfreiheit)       10 %
///
/// Clearance thresholds:
///   ≥ 80 → cleared (freigegeben)
///   60–79 → almost ready (fast bereit)
///   < 60 → not ready (noch nicht bereit)
abstract final class RtsCalculator {
  static const double hopWeight = 0.25;
  static const double lsiWeight = 0.20;
  static const double tugWeight = 0.20;
  static const double balanceWeight = 0.15;
  static const double stabilityWeight = 0.10;
  static const double painWeight = 0.10;

  static const double _clearedThreshold = 80.0;
  static const double _almostThreshold = 60.0;

  // ── Sub-scores ─────────────────────────────────────────────────────────

  /// Limb Symmetry Index sub-score (shared by LSI and Hop tests).
  ///
  /// Returns null if [healthy] ≤ 0. LSI 90 %+ → 100 pts, linear from 50–90 %.
  static double? computeLsiScore(double affected, double healthy) {
    if (healthy <= 0) return null;
    final lsi = (affected / healthy) * 100.0;
    if (lsi >= 90) return 100.0;
    if (lsi >= 50) return (lsi - 50.0) / 40.0 * 100.0;
    return 0.0;
  }

  /// Single-leg hop test LSI sub-score (same formula as [computeLsiScore]).
  static double? computeHopScore(double affected, double healthy) =>
      computeLsiScore(affected, healthy);

  /// Balance/Einbeinstand sub-score. 30 s → 100 pts.
  static double computeBalanceScore(double seconds) =>
      (math.min(seconds, 30.0) / 30.0 * 100.0).clamp(0.0, 100.0);

  /// Timed Up and Go (TUG) sub-score.
  /// ≤ 8 s → 100 pts; 25 s → 0 pts; linear in between.
  static double computeTugScore(double seconds) =>
      (math.max(0.0, (25.0 - seconds) / 17.0 * 100.0)).clamp(0.0, 100.0);

  /// Stability/Kniebeuge sub-score. Rating 1–5 → score 0–100.
  static double computeStabilityScore(int rating) {
    final clamped = rating.clamp(1, 5);
    return (clamped - 1) / 4.0 * 100.0;
  }

  /// Pain-under-load sub-score. NRS 0 → 100 pts, NRS 10 → 0 pts.
  static double computePainScore(int painLevel) {
    final clamped = painLevel.clamp(0, 10);
    return (10 - clamped) / 10.0 * 100.0;
  }

  // ── Overall ────────────────────────────────────────────────────────────

  /// Computes the weighted overall score. Null sub-scores are excluded so
  /// partial assessments still yield meaningful results.
  static double computeOverallScore({
    double? hopScore,
    double? lsiScore,
    double? tugScore,
    double? balanceScore,
    double? stabilityScore,
    double? painScore,
  }) {
    double total = 0;
    double weightSum = 0;

    void add(double? score, double weight) {
      if (score != null) {
        total += score * weight;
        weightSum += weight;
      }
    }

    add(hopScore, hopWeight);
    add(lsiScore, lsiWeight);
    add(tugScore, tugWeight);
    add(balanceScore, balanceWeight);
    add(stabilityScore, stabilityWeight);
    add(painScore, painWeight);

    if (weightSum <= 0) return 0.0;
    return (total / weightSum).clamp(0.0, 100.0);
  }

  static RtsClearanceLevel computeClearanceLevel(double score) {
    if (score >= _clearedThreshold) return RtsClearanceLevel.cleared;
    if (score >= _almostThreshold) return RtsClearanceLevel.almostReady;
    return RtsClearanceLevel.notReady;
  }

  /// Convenience: compute all sub-scores and return an updated [RtsAssessment].
  static RtsAssessment applyScores(RtsAssessment a) {
    final hopScore = (a.hopAffectedCm != null && a.hopHealthyCm != null)
        ? computeHopScore(a.hopAffectedCm!, a.hopHealthyCm!)
        : null;
    final lsiScore = (a.lsiAffected != null && a.lsiHealthy != null)
        ? computeLsiScore(a.lsiAffected!, a.lsiHealthy!)
        : null;
    final tugScore =
        a.tugSeconds != null ? computeTugScore(a.tugSeconds!) : null;
    final balanceScore = a.balanceSeconds != null
        ? computeBalanceScore(a.balanceSeconds!)
        : null;
    final stabilityScore = a.stabilityRating != null
        ? computeStabilityScore(a.stabilityRating!)
        : null;
    final painScore =
        a.painLevel != null ? computePainScore(a.painLevel!) : null;

    final overall = computeOverallScore(
      hopScore: hopScore,
      lsiScore: lsiScore,
      tugScore: tugScore,
      balanceScore: balanceScore,
      stabilityScore: stabilityScore,
      painScore: painScore,
    );

    return a.copyWith(
      hopScore: hopScore,
      lsiScore: lsiScore,
      tugScore: tugScore,
      balanceScore: balanceScore,
      stabilityScore: stabilityScore,
      painScore: painScore,
      overallScore: overall,
      clearanceLevel: computeClearanceLevel(overall),
    );
  }
}
"""

# ── rts_assessment_screen.dart ───────────────────────────────────────────────

ASSESSMENT_SCREEN = r"""import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../data/rts_repository_sync.dart';
import '../domain/rts_assessment.dart';
import '../domain/rts_calculator.dart';
import 'rts_result_screen.dart';

class RtsAssessmentScreen extends StatefulWidget {
  const RtsAssessmentScreen({super.key});

  @override
  State<RtsAssessmentScreen> createState() => _RtsAssessmentScreenState();
}

class _RtsAssessmentScreenState extends State<RtsAssessmentScreen> {
  static final RtsRepositorySync _repository = RtsRepositorySync.instance;

  final _pageController = PageController();
  int _currentStep = 0;
  bool _saving = false;

  static const int _totalSteps = 7;

  // ── Step 0: Sportart ────────────────────────────────────────────────────
  SportType? _sportType;

  // ── Step 1: Kraftseitenvergleich (LSI) ─────────────────────────────────
  final _lsiAffectedCtrl = TextEditingController();
  final _lsiHealthyCtrl = TextEditingController();
  RtsLsiUnit _lsiUnit = RtsLsiUnit.seconds;

  // ── Step 2: Hop-Test ────────────────────────────────────────────────────
  final _hopAffectedCtrl = TextEditingController();
  final _hopHealthyCtrl = TextEditingController();

  // ── Step 3: Einbeinstand-Balance (Timer) ────────────────────────────────
  double? _balanceSeconds;

  // ── Step 4: Timed Up and Go (Timer) ────────────────────────────────────
  double? _tugSeconds;

  // ── Step 5: Stabilität ──────────────────────────────────────────────────
  int _stabilityRating = 3;

  // ── Step 6: Schmerz + Notizen ───────────────────────────────────────────
  int _painLevel = 5;
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _lsiAffectedCtrl.dispose();
    _lsiHealthyCtrl.dispose();
    _hopAffectedCtrl.dispose();
    _hopHealthyCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  bool get _currentStepValid {
    switch (_currentStep) {
      case 0:
        return _sportType != null;
      case 1:
        final a = double.tryParse(_lsiAffectedCtrl.text.trim());
        final h = double.tryParse(_lsiHealthyCtrl.text.trim());
        return a != null && h != null && h > 0 && a >= 0;
      case 2:
        final a = double.tryParse(_hopAffectedCtrl.text.trim());
        final h = double.tryParse(_hopHealthyCtrl.text.trim());
        return a != null && h != null && h > 0 && a >= 0;
      case 3:
        return _balanceSeconds != null && _balanceSeconds! >= 0;
      case 4:
        return _tugSeconds != null && _tugSeconds! >= 0;
      case 5:
      case 6:
        return true;
      default:
        return true;
    }
  }

  void _nextStep() {
    if (!_currentStepValid) {
      _showValidationHint();
      return;
    }
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _showValidationHint() {
    final l = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l.rtsValidationHint),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _finish() async {
    setState(() => _saving = true);
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final now = DateTime.now();

    final draft = RtsAssessment(
      id: 'rts_${now.millisecondsSinceEpoch}',
      ownerId: uid,
      performedAt: now,
      sportType: _sportType,
      lsiAffected: double.tryParse(_lsiAffectedCtrl.text.trim()),
      lsiHealthy: double.tryParse(_lsiHealthyCtrl.text.trim()),
      lsiUnit: _lsiUnit,
      hopAffectedCm: double.tryParse(_hopAffectedCtrl.text.trim()),
      hopHealthyCm: double.tryParse(_hopHealthyCtrl.text.trim()),
      balanceSeconds: _balanceSeconds,
      tugSeconds: _tugSeconds,
      stabilityRating: _stabilityRating,
      painLevel: _painLevel,
      overallScore: 0,
      clearanceLevel: RtsClearanceLevel.notReady,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      createdAt: now,
      updatedAt: now,
    );

    final scored = RtsCalculator.applyScores(draft);
    await _repository.upsert(scored);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => RtsResultScreen(assessment: scored, isNew: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ───────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: _prevStep,
                    ),
                    Expanded(
                      child: Text(
                        l.rtsAssessmentTitle,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Text(
                      l.rtsStepOf(
                        (_currentStep + 1).toString(),
                        _totalSteps.toString(),
                      ),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.grey500,
                          ),
                    ),
                  ],
                ),
              ),

              // ── Progress bar ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: LinearProgressIndicator(
                  value: (_currentStep + 1) / _totalSteps,
                  color: AppColors.primary,
                  backgroundColor: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                  minHeight: 6,
                ),
              ),

              // ── Page content ─────────────────────────────────────────────
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    // 0: Sport type
                    _SportTypeStep(
                      l: l,
                      selected: _sportType,
                      onChanged: (s) => setState(() => _sportType = s),
                    ),
                    // 1: LSI / Kraftseitenvergleich
                    _LsiStep(
                      l: l,
                      affectedCtrl: _lsiAffectedCtrl,
                      healthyCtrl: _lsiHealthyCtrl,
                      unit: _lsiUnit,
                      onUnitChanged: (u) => setState(() => _lsiUnit = u),
                    ),
                    // 2: Hop-Test
                    _HopStep(
                      l: l,
                      affectedCtrl: _hopAffectedCtrl,
                      healthyCtrl: _hopHealthyCtrl,
                    ),
                    // 3: Einbeinstand-Balance (Timer)
                    _TimerStep(
                      l: l,
                      icon: Icons.accessibility_new_rounded,
                      iconColor: AppColors.accent,
                      title: l.rtsTestBalanceTitle,
                      description: l.rtsTestBalanceDesc,
                      hint: l.rtsTestBalanceHint,
                      unitLabel: 's',
                      initialValue: _balanceSeconds,
                      onChanged: (v) => setState(() => _balanceSeconds = v),
                    ),
                    // 4: Timed Up and Go (Timer)
                    _TimerStep(
                      l: l,
                      icon: Icons.directions_walk_rounded,
                      iconColor: const Color(0xFF5856D6),
                      title: l.rtsTestTugTitle,
                      description: l.rtsTestTugDesc,
                      hint: l.rtsTestTugHint,
                      unitLabel: 's',
                      initialValue: _tugSeconds,
                      onChanged: (v) => setState(() => _tugSeconds = v),
                    ),
                    // 5: Stabilität
                    _StabilityStep(
                      l: l,
                      rating: _stabilityRating,
                      onChanged: (v) => setState(() => _stabilityRating = v),
                    ),
                    // 6: Schmerz + Notizen
                    _PainStep(
                      l: l,
                      painLevel: _painLevel,
                      notesCtrl: _notesCtrl,
                      onChanged: (v) => setState(() => _painLevel = v),
                    ),
                  ],
                ),
              ),

              // ── Navigation buttons ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        flex: 1,
                        child: OutlinedButton(
                          onPressed: _prevStep,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            foregroundColor: AppColors.grey600,
                            side: const BorderSide(color: AppColors.grey300),
                          ),
                          child: Text(l.back),
                        ),
                      ),
                    if (_currentStep > 0) const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: _saving ? null : _nextStep,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                _currentStep < _totalSteps - 1
                                    ? l.next
                                    : l.rtsFinishAssessment,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Step 0: Sportart ──────────────────────────────────────────────────────────

class _SportTypeStep extends StatelessWidget {
  const _SportTypeStep({
    required this.l,
    required this.selected,
    required this.onChanged,
  });

  final AppLocalizations l;
  final SportType? selected;
  final ValueChanged<SportType> onChanged;

  @override
  Widget build(BuildContext context) {
    final sports = [
      (SportType.running,    l.rtsSportRunning),
      (SportType.soccer,     l.rtsSportSoccer),
      (SportType.strength,   l.rtsSportStrength),
      (SportType.cycling,    l.rtsSportCycling),
      (SportType.swimming,   l.rtsSportSwimming),
      (SportType.martialArts, l.rtsSportMartialArts),
      (SportType.other,      l.rtsSportOther),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepHeader(
            icon: Icons.sports_rounded,
            iconColor: AppColors.primary,
            title: l.rtsSportTypeTitle,
            description: l.rtsSportTypeDesc,
          ),
          const SizedBox(height: 28),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: sports.map((entry) {
              final (type, label) = entry;
              final isSelected = selected == type;
              return GestureDetector(
                onTap: () => onChanged(type),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.primary.withOpacity(0.25),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        type.emoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.white
                              : AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── Step 1: Kraftseitenvergleich (LSI) ────────────────────────────────────────

class _LsiStep extends StatelessWidget {
  const _LsiStep({
    required this.l,
    required this.affectedCtrl,
    required this.healthyCtrl,
    required this.unit,
    required this.onUnitChanged,
  });

  final AppLocalizations l;
  final TextEditingController affectedCtrl;
  final TextEditingController healthyCtrl;
  final RtsLsiUnit unit;
  final ValueChanged<RtsLsiUnit> onUnitChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepHeader(
            icon: Icons.compare_arrows_rounded,
            iconColor: AppColors.primary,
            title: l.rtsTestLsiTitle,
            description: l.rtsTestLsiDesc,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _UnitChip(
                label: l.rtsLsiSeconds,
                selected: unit == RtsLsiUnit.seconds,
                onTap: () => onUnitChanged(RtsLsiUnit.seconds),
              ),
              const SizedBox(width: 10),
              _UnitChip(
                label: l.rtsLsiReps,
                selected: unit == RtsLsiUnit.reps,
                onTap: () => onUnitChanged(RtsLsiUnit.reps),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _NumericField(
            controller: affectedCtrl,
            label: l.rtsLsiAffected(unit.shortLabel),
            hint: '0',
          ),
          const SizedBox(height: 14),
          _NumericField(
            controller: healthyCtrl,
            label: l.rtsLsiHealthy(unit.shortLabel),
            hint: '0',
          ),
          const SizedBox(height: 16),
          _InfoBox(text: l.rtsTestLsiHint),
        ],
      ),
    );
  }
}

// ── Step 2: Hop-Test ──────────────────────────────────────────────────────────

class _HopStep extends StatelessWidget {
  const _HopStep({
    required this.l,
    required this.affectedCtrl,
    required this.healthyCtrl,
  });

  final AppLocalizations l;
  final TextEditingController affectedCtrl;
  final TextEditingController healthyCtrl;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepHeader(
            icon: Icons.directions_run_rounded,
            iconColor: const Color(0xFF34C759),
            title: l.rtsTestHopTitle,
            description: l.rtsTestHopDesc,
          ),
          const SizedBox(height: 24),
          _NumericField(
            controller: affectedCtrl,
            label: l.rtsHopAffected,
            hint: '0',
          ),
          const SizedBox(height: 14),
          _NumericField(
            controller: healthyCtrl,
            label: l.rtsHopHealthy,
            hint: '0',
          ),
          const SizedBox(height: 16),
          _InfoBox(text: l.rtsTestHopHint),
        ],
      ),
    );
  }
}

// ── Steps 3 & 4: Timer (Balance + TUG) ───────────────────────────────────────

class _TimerStep extends StatefulWidget {
  const _TimerStep({
    required this.l,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.hint,
    required this.unitLabel,
    required this.onChanged,
    this.initialValue,
  });

  final AppLocalizations l;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final String hint;
  final String unitLabel;
  final double? initialValue;
  final ValueChanged<double?> onChanged;

  @override
  State<_TimerStep> createState() => _TimerStepState();
}

class _TimerStepState extends State<_TimerStep> {
  final _stopwatch = Stopwatch();
  Timer? _ticker;
  double? _result;
  late final TextEditingController _manualCtrl;

  @override
  void initState() {
    super.initState();
    _result = widget.initialValue;
    _manualCtrl = TextEditingController(
      text: _result != null ? _result!.toStringAsFixed(1) : '',
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _stopwatch.stop();
    _manualCtrl.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
      _ticker?.cancel();
      final secs = _stopwatch.elapsedMilliseconds / 1000.0;
      _manualCtrl.text = secs.toStringAsFixed(1);
      setState(() => _result = secs);
      widget.onChanged(secs);
    } else {
      _stopwatch.reset();
      _stopwatch.start();
      _ticker = Timer.periodic(
        const Duration(milliseconds: 100),
        (_) { if (mounted) setState(() {}); },
      );
      setState(() {});
    }
  }

  void _reset() {
    _ticker?.cancel();
    _stopwatch
      ..stop()
      ..reset();
    _manualCtrl.clear();
    setState(() => _result = null);
    widget.onChanged(null);
  }

  String get _elapsed {
    final ms = _stopwatch.elapsedMilliseconds;
    final s = ms ~/ 1000;
    final tenths = (ms % 1000) ~/ 100;
    return '${s.toString().padLeft(2, '0')}.${tenths}';
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.l;
    final isRunning = _stopwatch.isRunning;
    final hasResult = _result != null && !isRunning;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepHeader(
            icon: widget.icon,
            iconColor: widget.iconColor,
            title: widget.title,
            description: widget.description,
          ),
          const SizedBox(height: 24),

          // ── Stopwatch display ───────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28),
            decoration: BoxDecoration(
              color: isRunning
                  ? widget.iconColor.withOpacity(0.12)
                  : hasResult
                      ? AppColors.success.withOpacity(0.08)
                      : AppColors.grey50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isRunning
                    ? widget.iconColor.withOpacity(0.4)
                    : hasResult
                        ? AppColors.success.withOpacity(0.3)
                        : AppColors.grey200,
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Text(
                  isRunning
                      ? _elapsed
                      : hasResult
                          ? '${_result!.toStringAsFixed(1)} ${widget.unitLabel}'
                          : '- - -',
                  style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    color: isRunning
                        ? widget.iconColor
                        : hasResult
                            ? AppColors.success
                            : AppColors.grey400,
                  ),
                ),
                if (isRunning)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      widget.unitLabel,
                      style: TextStyle(
                        color: widget.iconColor.withOpacity(0.6),
                        fontSize: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Stopwatch buttons ───────────────────────────────────────────
          Row(
            children: [
              Expanded(
                flex: 3,
                child: FilledButton.icon(
                  onPressed: _toggle,
                  icon: Icon(
                    isRunning
                        ? Icons.stop_rounded
                        : Icons.play_arrow_rounded,
                  ),
                  label: Text(
                    isRunning
                        ? l.rtsTimerStop
                        : hasResult
                            ? l.rtsTimerRestart
                            : l.rtsTimerStart,
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        isRunning ? AppColors.error : widget.iconColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              if (isRunning || hasResult) ...[
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: _reset,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      foregroundColor: AppColors.grey600,
                      side: const BorderSide(color: AppColors.grey300),
                    ),
                    child: Text(l.rtsTimerReset),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),

          // ── Manual fallback ─────────────────────────────────────────────
          Text(
            l.rtsTimerOrManual,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.grey500,
                ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _manualCtrl,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            decoration: InputDecoration(
              labelText: l.rtsTimerManualLabel,
              suffixText: widget.unitLabel,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: AppColors.glassFill,
            ),
            onChanged: (v) {
              if (_stopwatch.isRunning) return;
              final normalized = v.replaceAll(',', '.');
              final parsed = double.tryParse(normalized);
              if (parsed != null) {
                setState(() => _result = parsed);
                widget.onChanged(parsed);
              } else if (v.isEmpty) {
                setState(() => _result = null);
                widget.onChanged(null);
              }
            },
          ),
          const SizedBox(height: 16),
          _InfoBox(text: widget.hint),
        ],
      ),
    );
  }
}

// ── Step 5: Stabilität ────────────────────────────────────────────────────────

class _StabilityStep extends StatelessWidget {
  const _StabilityStep({
    required this.l,
    required this.rating,
    required this.onChanged,
  });

  final AppLocalizations l;
  final int rating;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final descriptions = [
      '',
      l.rtsStability1,
      l.rtsStability2,
      l.rtsStability3,
      l.rtsStability4,
      l.rtsStability5,
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepHeader(
            icon: Icons.sports_gymnastics_rounded,
            iconColor: AppColors.warning,
            title: l.rtsTestStabilityTitle,
            description: l.rtsTestStabilityDesc,
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              5,
              (i) => _RatingButton(
                value: i + 1,
                selected: rating == i + 1,
                onTap: () => onChanged(i + 1),
              ),
            ),
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Container(
              key: ValueKey(rating),
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.warning.withOpacity(0.3),
                ),
              ),
              child: Text(
                descriptions[rating],
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.grey800,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step 6: Schmerz unter Belastung ──────────────────────────────────────────

class _PainStep extends StatelessWidget {
  const _PainStep({
    required this.l,
    required this.painLevel,
    required this.notesCtrl,
    required this.onChanged,
  });

  final AppLocalizations l;
  final int painLevel;
  final TextEditingController notesCtrl;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final color = painLevel <= 2
        ? AppColors.success
        : painLevel <= 5
            ? AppColors.warning
            : AppColors.error;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepHeader(
            icon: Icons.fitness_center_rounded,
            iconColor: AppColors.error,
            title: l.rtsTestPainTitle,
            description: l.rtsTestPainDesc,
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l.rtsPainNoKein,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.grey500,
                    ),
              ),
              Text(
                l.rtsPainSevere,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.grey500,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 8,
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 14),
              activeTrackColor: color,
              inactiveTrackColor: color.withOpacity(0.2),
              thumbColor: color,
              overlayColor: color.withOpacity(0.2),
            ),
            child: Slider(
              value: painLevel.toDouble(),
              min: 0,
              max: 10,
              divisions: 10,
              label: painLevel.toString(),
              onChanged: (v) => onChanged(v.round()),
            ),
          ),
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: Text(
                '$painLevel / 10',
                key: ValueKey(painLevel),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: notesCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: l.rtsNotesLabel,
              hintText: l.rtsNotesHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: AppColors.glassFill,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _StepHeader extends StatelessWidget {
  const _StepHeader({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 28),
        ),
        const SizedBox(height: 14),
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.grey600,
                height: 1.5,
              ),
        ),
      ],
    );
  }
}

class _NumericField extends StatelessWidget {
  const _NumericField({
    required this.controller,
    required this.label,
    required this.hint,
  });

  final TextEditingController controller;
  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: AppColors.glassFill,
      ),
    );
  }
}

class _UnitChip extends StatelessWidget {
  const _UnitChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.primary.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.white : AppColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _RatingButton extends StatelessWidget {
  const _RatingButton({
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final int value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected
              ? AppColors.warning
              : AppColors.warning.withOpacity(0.10),
          border: Border.all(
            color: selected
                ? AppColors.warning
                : AppColors.warning.withOpacity(0.3),
            width: selected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            '$value',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: selected ? AppColors.white : AppColors.warning,
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.grey700,
                    height: 1.5,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
"""

# ── write files ───────────────────────────────────────────────────────────────

(BASE / "domain" / "rts_assessment.dart").write_text(ASSESSMENT_MODEL)
print("wrote rts_assessment.dart")

(BASE / "domain" / "rts_calculator.dart").write_text(CALCULATOR)
print("wrote rts_calculator.dart")

(BASE / "presentation" / "rts_assessment_screen.dart").write_text(ASSESSMENT_SCREEN)
print("wrote rts_assessment_screen.dart")

print("done")
