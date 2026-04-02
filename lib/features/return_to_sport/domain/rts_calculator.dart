import 'dart:math' as math;

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
