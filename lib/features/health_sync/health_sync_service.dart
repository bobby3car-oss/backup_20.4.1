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
  bool _syncing = false;

  static const _kLastSyncKey = 'health_sync_last';
  static const _kEnabledKey = 'health_sync_enabled';

  /// All health data types we read from the platform.
  static const _readTypes = <HealthDataType>[
    HealthDataType.HEART_RATE,
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    HealthDataType.STEPS,
    HealthDataType.BODY_TEMPERATURE,
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.WEIGHT,
  ];

  /// Types we can write back (manual vitals → platform health store).
  static const _writeTypes = <HealthDataType>[
    HealthDataType.HEART_RATE,
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    HealthDataType.BODY_TEMPERATURE,
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.WEIGHT,
  ];

  // ── Preferences ─────────────────────────────────────────────────────────

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
  bool get isSupported =>
      !kIsWeb && (Platform.isIOS || Platform.isAndroid);

  // ── Configuration ───────────────────────────────────────────────────────

  Future<void> _ensureConfigured() async {
    if (_configured) return;
    await _health.configure();
    _configured = true;
  }

  // ── Permissions ─────────────────────────────────────────────────────────

  /// Request authorization for reading and writing health data.
  /// Returns true if permissions were granted.
  Future<bool> requestAuthorization() async {
    if (!isSupported) return false;
    await _ensureConfigured();

    final allTypes = <HealthDataType>[..._readTypes, ..._writeTypes];
    final permissions = <HealthDataAccess>[
      ...List.filled(_readTypes.length, HealthDataAccess.READ),
      ...List.filled(_writeTypes.length, HealthDataAccess.WRITE),
    ];

    try {
      return await _health.requestAuthorization(
        allTypes,
        permissions: permissions,
      );
    } catch (e) {
      debugPrint('HealthSyncService: requestAuthorization error: $e');
      return false;
    }
  }

  /// Check if we already have the required read permissions.
  Future<bool> hasPermissions() async {
    if (!isSupported) return false;
    await _ensureConfigured();
    try {
      final result = await _health.hasPermissions(
        _readTypes,
        permissions: List.filled(
          _readTypes.length,
          HealthDataAccess.READ,
        ),
      );
      return result ?? false;
    } catch (e) {
      debugPrint('HealthSyncService: hasPermissions error: $e');
      return false;
    }
  }

  /// Check if Health Connect is available on Android (shows install prompt).
  Future<bool> checkHealthConnectAvailability() async {
    if (!Platform.isAndroid) return true;
    await _ensureConfigured();
    try {
      final status = await _health.getHealthConnectSdkStatus();
      if (status == HealthConnectSdkStatus.sdkUnavailable) {
        return false;
      }
      if (status == HealthConnectSdkStatus.sdkUnavailableProviderUpdateRequired) {
        await _health.installHealthConnect();
        return false; // user needs to install/update first
      }
      return true;
    } catch (e) {
      debugPrint('HealthSyncService: checkHealthConnect error: $e');
      return false;
    }
  }

  // ── Read / Sync ─────────────────────────────────────────────────────────

  /// Pull health data since last sync (or last 7 days on first sync)
  /// and store new vital entries in [VitalRepositoryLocal].
  ///
  /// Returns the number of new entries created.
  Future<int> sync({required String ownerId}) async {
    if (!isSupported) return 0;
    if (!(await isEnabled)) return 0;
    if (_syncing) return 0; // prevent concurrent syncs

    _syncing = true;
    try {
      return await _doSync(ownerId: ownerId);
    } finally {
      _syncing = false;
    }
  }

  Future<int> _doSync({required String ownerId}) async {
    await _ensureConfigured();

    final prefs = await SharedPreferences.getInstance();
    final lastMs = prefs.getInt(_kLastSyncKey);
    final now = DateTime.now();
    final startTime = lastMs != null
        ? DateTime.fromMillisecondsSinceEpoch(lastMs)
        : now.subtract(const Duration(days: 7));

    // Don't re-sync if last sync was < 60 seconds ago.
    if (lastMs != null && now.difference(startTime).inSeconds < 60) {
      return 0;
    }

    List<HealthDataPoint> points;
    try {
      points = await _health.getHealthDataFromTypes(
        types: _readTypes,
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

    // ── Group points by minute to create combined vital entries ──
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
        case HealthDataType.BODY_TEMPERATURE:
          bucket.temperature = value.toDouble();
        case HealthDataType.BLOOD_OXYGEN:
          // Health package returns O₂ as percentage (0-100).
          bucket.oxygenSaturation = value.toInt();
        case HealthDataType.WEIGHT:
          bucket.weight = value.toDouble();
        default:
          break;
      }
    }

    final repo = VitalRepositoryLocal.instance;

    // Load existing entries to deduplicate by stable ID.
    final existing = await repo.watchAll().first;
    final existingIds = <String>{for (final e in existing) e.id};

    var count = 0;

    for (final bucket in grouped.values) {
      // Only create a vital entry if we have at least one vital sign
      if (bucket.systolic == null &&
          bucket.diastolic == null &&
          bucket.pulse == null &&
          bucket.temperature == null &&
          bucket.oxygenSaturation == null &&
          bucket.weight == null) {
        continue;
      }

      // Stable ID based on timestamp ─ prevents duplicate entries on re-sync.
      final ts = bucket.timestamp;
      final entryId = 'hs_${ts.millisecondsSinceEpoch}';

      if (existingIds.contains(entryId)) continue;

      // Use actual values from health data ─ never fill in fake defaults.
      final hasBp = bucket.systolic != null || bucket.diastolic != null;

      final entry = VitalEntry(
        id: entryId,
        ownerId: ownerId,
        systolic: hasBp ? (bucket.systolic ?? 0) : (bucket.pulse != null ? 0 : 0),
        diastolic: hasBp ? (bucket.diastolic ?? 0) : 0,
        pulse: bucket.pulse ?? 0,
        temperature: bucket.temperature,
        oxygenSaturation: bucket.oxygenSaturation,
        weight: bucket.weight,
        createdAt: ts,
        updatedAt: ts,
        source: source,
        metadata: <String, dynamic>{
          if (bucket.steps != null) 'steps': bucket.steps,
          'synced_at': DateTime.now().toIso8601String(),
        },
      );

      await repo.upsert(entry);
      existingIds.add(entryId);
      count++;
    }

    await prefs.setInt(_kLastSyncKey, now.millisecondsSinceEpoch);
    debugPrint('HealthSyncService: Synced $count new entries from $source');
    return count;
  }

  // ── Write back ──────────────────────────────────────────────────────────

  /// Write a manually captured [VitalEntry] back to the platform health store.
  /// Only writes if sync is enabled and the entry was manually entered.
  Future<bool> writeVitalEntry(VitalEntry entry) async {
    if (!isSupported) return false;
    if (!(await isEnabled)) return false;
    // Don't write back entries that came from health sync.
    if (entry.source == 'healthkit' || entry.source == 'health_connect') {
      return false;
    }

    await _ensureConfigured();

    var ok = true;

    try {
      // Blood pressure
      if (entry.systolic > 0 && entry.diastolic > 0) {
        final bpOk = await _health.writeBloodPressure(
          systolic: entry.systolic,
          diastolic: entry.diastolic,
          startTime: entry.createdAt,
          endTime: entry.createdAt,
        );
        if (!bpOk) ok = false;
      }

      // Heart rate / pulse
      if (entry.pulse > 0) {
        final hrOk = await _health.writeHealthData(
          value: entry.pulse.toDouble(),
          type: HealthDataType.HEART_RATE,
          startTime: entry.createdAt,
          endTime: entry.createdAt,
        );
        if (!hrOk) ok = false;
      }

      // Body temperature
      if (entry.temperature != null) {
        final tempOk = await _health.writeHealthData(
          value: entry.temperature!,
          type: HealthDataType.BODY_TEMPERATURE,
          startTime: entry.createdAt,
          endTime: entry.createdAt,
        );
        if (!tempOk) ok = false;
      }

      // Blood oxygen / SpO₂
      if (entry.oxygenSaturation != null) {
        final o2Ok = await _health.writeBloodOxygen(
          saturation: entry.oxygenSaturation!.toDouble(),
          startTime: entry.createdAt,
          endTime: entry.createdAt,
        );
        if (!o2Ok) ok = false;
      }

      // Weight
      if (entry.weight != null) {
        final wOk = await _health.writeHealthData(
          value: entry.weight!,
          type: HealthDataType.WEIGHT,
          startTime: entry.createdAt,
          endTime: entry.createdAt,
        );
        if (!wOk) ok = false;
      }
    } catch (e) {
      debugPrint('HealthSyncService: writeVitalEntry error: $e');
      return false;
    }

    return ok;
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

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
  double? temperature;
  int? oxygenSaturation;
  double? weight;
}
