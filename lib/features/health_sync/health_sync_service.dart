import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../vitals/data/vital_repository_local.dart';
import '../vitals/domain/vital_entry.dart';

/// Syncs health data from Apple Health / Google Health Connect
/// into the local VitalEntry repository.
class HealthSyncService {
  HealthSyncService._();
  static final HealthSyncService instance = HealthSyncService._();

  final Health _health = Health();
  bool _configured = false;

  static const _kLastSyncKey = 'health_sync_last';
  static const _kEnabledKey = 'health_sync_enabled';

  static const _types = <HealthDataType>[
    HealthDataType.HEART_RATE,
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    HealthDataType.STEPS,
  ];

  /// Whether health sync is enabled by the user.
  Future<bool> get isEnabled async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kEnabledKey) ?? false;
  }

  /// Enable or disable health sync.
  Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEnabledKey, value);
  }

  /// Check if the platform supports health data.
  bool get isSupported => Platform.isIOS || Platform.isAndroid;

  /// Configure the health plugin. Must be called once.
  Future<void> _ensureConfigured() async {
    if (_configured) return;
    await _health.configure();
    _configured = true;
  }

  /// Request authorization from the user.
  /// Returns true if permissions were granted.
  Future<bool> requestAuthorization() async {
    if (!isSupported) return false;
    await _ensureConfigured();
    return _health.requestAuthorization(_types);
  }

  /// Check if we already have the required permissions.
  Future<bool> hasPermissions() async {
    if (!isSupported) return false;
    await _ensureConfigured();
    final result = await _health.hasPermissions(_types);
    return result ?? false;
  }

  /// Pull health data since last sync (or last 30 days on first sync)
  /// and store new vitals entries in [VitalRepositoryLocal].
  Future<int> sync({required String ownerId}) async {
    if (!isSupported) return 0;
    if (!(await isEnabled)) return 0;

    await _ensureConfigured();

    final prefs = await SharedPreferences.getInstance();
    final lastMs = prefs.getInt(_kLastSyncKey);
    final now = DateTime.now();
    final startTime = lastMs != null
        ? DateTime.fromMillisecondsSinceEpoch(lastMs)
        : now.subtract(const Duration(days: 30));

    List<HealthDataPoint> points;
    try {
      points = await _health.getHealthDataFromTypes(
        types: _types,
        startTime: startTime,
        endTime: now,
      );
    } catch (e) {
      debugPrint('HealthSyncService: Error fetching health data: $e');
      return 0;
    }

    if (points.isEmpty) {
      await prefs.setInt(_kLastSyncKey, now.millisecondsSinceEpoch);
      return 0;
    }

    // Group points by minute to create combined vital entries
    final grouped = <String, _HealthBucket>{};
    final source = Platform.isIOS ? 'healthkit' : 'health_connect';

    for (final point in points) {
      if (point.value is! NumericHealthValue) continue;
      final value = (point.value as NumericHealthValue).numericValue;
      final minuteKey = _minuteKey(point.dateFrom);

      grouped.putIfAbsent(minuteKey, () => _HealthBucket(point.dateFrom));
      final bucket = grouped[minuteKey]!;

      switch (point.type) {
        case HealthDataType.HEART_RATE:
          bucket.pulse = value.toInt();
        case HealthDataType.BLOOD_PRESSURE_SYSTOLIC:
          bucket.systolic = value.toInt();
        case HealthDataType.BLOOD_PRESSURE_DIASTOLIC:
          bucket.diastolic = value.toInt();
        case HealthDataType.STEPS:
          bucket.steps = value.toInt();
        default:
          break;
      }
    }

    final repo = VitalRepositoryLocal.instance;
    var count = 0;
    var idx = 0;

    for (final bucket in grouped.values) {
      // Only create a vital entry if we have blood pressure or pulse data
      if (bucket.systolic == null &&
          bucket.diastolic == null &&
          bucket.pulse == null) {
        continue;
      }

      final ts = bucket.timestamp;
      final entryId =
          'hs_${ts.millisecondsSinceEpoch}_${idx++}';

      final entry = VitalEntry(
        id: entryId,
        ownerId: ownerId,
        systolic: bucket.systolic ?? 120,
        diastolic: bucket.diastolic ?? 80,
        pulse: bucket.pulse ?? 70,
        createdAt: bucket.timestamp,
        updatedAt: bucket.timestamp,
        source: source,
        metadata: <String, dynamic>{
          if (bucket.steps != null) 'steps': bucket.steps,
        },
      );

      await repo.upsert(entry);
      count++;
    }

    await prefs.setInt(_kLastSyncKey, now.millisecondsSinceEpoch);
    debugPrint('HealthSyncService: Synced $count vital entries from $source');
    return count;
  }

  String _minuteKey(DateTime dt) =>
      '${dt.year}-${dt.month}-${dt.day}-${dt.hour}-${dt.minute}';
}

class _HealthBucket {
  _HealthBucket(this.timestamp);
  final DateTime timestamp;
  int? systolic;
  int? diastolic;
  int? pulse;
  int? steps;
}
