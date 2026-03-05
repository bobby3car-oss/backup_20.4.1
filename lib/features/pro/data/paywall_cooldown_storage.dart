import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists paywall trigger timestamps & counters in [SharedPreferences]
/// so that frequency caps survive app restarts.
class PaywallCooldownStorage {
  PaywallCooldownStorage({SharedPreferences? prefs}) : _prefs = prefs;

  SharedPreferences? _prefs;

  // ── Keys ───────────────────────────────────────────────────────────

  static const _kLastShownAt = 'paywall_last_shown_at';
  static const _kLastDismissedAt = 'paywall_last_dismissed_at';
  static const _kLastMaybeLaterAt = 'paywall_last_maybe_later_at';
  static const _kLastPurchaseAttemptAt = 'paywall_last_purchase_attempt_at';
  static const _kTimelineOpenCount = 'paywall_timeline_open_count';
  static const _kTimelineOpenSessionId = 'paywall_timeline_session_id';
  static const _kActiveDays = 'paywall_active_days';
  static const _kDashboardUpsellShown = 'paywall_dashboard_upsell_shown';

  // ── Init ───────────────────────────────────────────────────────────

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // ── Last Shown ─────────────────────────────────────────────────────

  DateTime? get lastPaywallShownAt => _readDateTime(_kLastShownAt);

  Future<void> setLastPaywallShownAt(DateTime value) =>
      _writeDateTime(_kLastShownAt, value);

  // ── Last Dismissed ─────────────────────────────────────────────────

  DateTime? get lastPaywallDismissedAt => _readDateTime(_kLastDismissedAt);

  Future<void> setLastPaywallDismissedAt(DateTime value) =>
      _writeDateTime(_kLastDismissedAt, value);

  // ── Last "Maybe Later" ─────────────────────────────────────────────

  DateTime? get lastMaybeLaterAt => _readDateTime(_kLastMaybeLaterAt);

  Future<void> setLastMaybeLaterAt(DateTime value) =>
      _writeDateTime(_kLastMaybeLaterAt, value);

  // ── Last Purchase Attempt ──────────────────────────────────────────

  DateTime? get lastPurchaseAttemptAt =>
      _readDateTime(_kLastPurchaseAttemptAt);

  Future<void> setLastPurchaseAttemptAt(DateTime value) =>
      _writeDateTime(_kLastPurchaseAttemptAt, value);

  // ── Timeline open counter (per session) ────────────────────────────

  /// Increments the timeline-open counter if the [sessionId] matches.
  /// Resets the counter when a new session starts.
  Future<int> incrementTimelineOpen(String sessionId) async {
    final stored = _prefs?.getString(_kTimelineOpenSessionId);
    if (stored != sessionId) {
      await _prefs?.setString(_kTimelineOpenSessionId, sessionId);
      await _prefs?.setInt(_kTimelineOpenCount, 1);
      return 1;
    }
    final current = _prefs?.getInt(_kTimelineOpenCount) ?? 0;
    final next = current + 1;
    await _prefs?.setInt(_kTimelineOpenCount, next);
    return next;
  }

  int get timelineOpenCount => _prefs?.getInt(_kTimelineOpenCount) ?? 0;

  // ── Active days ────────────────────────────────────────────────────

  /// Records today as an active day and returns the total distinct active days.
  Future<int> recordActiveDay() async {
    final today = _todayKey();
    final days = _prefs?.getStringList(_kActiveDays) ?? [];
    if (!days.contains(today)) {
      days.add(today);
      await _prefs?.setStringList(_kActiveDays, days);
    }
    return days.length;
  }

  int get activeDayCount =>
      (_prefs?.getStringList(_kActiveDays) ?? []).length;

  // ── Dashboard upsell shown flag ────────────────────────────────────

  bool get dashboardUpsellShown =>
      _prefs?.getBool(_kDashboardUpsellShown) ?? false;

  Future<void> setDashboardUpsellShown(bool value) async {
    await _prefs?.setBool(_kDashboardUpsellShown, value);
  }

  // ── Helpers ────────────────────────────────────────────────────────

  DateTime? _readDateTime(String key) {
    final ms = _prefs?.getInt(key);
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<void> _writeDateTime(String key, DateTime value) async {
    await _prefs?.setInt(key, value.millisecondsSinceEpoch);
    if (kDebugMode) {
      debugPrint('[PaywallCooldown] $key = $value');
    }
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}'
        '-${now.day.toString().padLeft(2, '0')}';
  }
}
