import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'connectivity_service.dart';
import 'sync_queue_local.dart';

/// Possible sync states for the UI indicator.
enum SyncStatus { synced, syncing, offline }

/// Tracks overall sync status (connectivity + pending ops + last-sync time).
///
/// Widgets can listen to [status] and [pendingCount] for real-time updates.
class SyncStatusService {
  SyncStatusService._();
  static final SyncStatusService instance = SyncStatusService._();

  static const _lastSyncKey = 'sync_last_timestamp';

  final ValueNotifier<SyncStatus> status =
      ValueNotifier<SyncStatus>(SyncStatus.synced);
  final ValueNotifier<int> pendingCount = ValueNotifier<int>(0);
  final ValueNotifier<DateTime?> lastSyncTime = ValueNotifier<DateTime?>(null);

  SyncQueueLocal? _queue;
  Timer? _pollTimer;
  bool _initialized = false;

  /// Call once from [main] after ConnectivityService is initialised.
  Future<void> init({SyncQueueLocal? queue}) async {
    if (_initialized) return;
    _initialized = true;

    _queue = queue ?? SyncQueueLocal();

    // Load persisted last-sync timestamp.
    try {
      final prefs = await SharedPreferences.getInstance();
      final millis = prefs.getInt(_lastSyncKey);
      if (millis != null) {
        lastSyncTime.value =
            DateTime.fromMillisecondsSinceEpoch(millis);
      }
    } catch (_) {}

    ConnectivityService.instance.isOnline.addListener(_recalculate);

    // Poll pending count every 5 s so the badge stays fresh.
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _refreshPendingCount();
    });
    await _refreshPendingCount();
    _recalculate();
  }

  /// Call after a successful sync round to persist the timestamp.
  Future<void> markSynced() async {
    final now = DateTime.now();
    lastSyncTime.value = now;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastSyncKey, now.millisecondsSinceEpoch);
    } catch (_) {}
    await _refreshPendingCount();
    _recalculate();
  }

  /// Call when a sync round starts.
  void markSyncing() {
    if (status.value != SyncStatus.offline) {
      status.value = SyncStatus.syncing;
    }
  }

  Future<void> _refreshPendingCount() async {
    try {
      final ops = await _queue?.pending() ?? [];
      pendingCount.value = ops.length;
    } catch (_) {
      // Keep previous count on error.
    }
  }

  void _recalculate() {
    final online = ConnectivityService.instance.isOnline.value;
    if (!online) {
      status.value = SyncStatus.offline;
    } else if (pendingCount.value > 0) {
      status.value = SyncStatus.syncing;
    } else {
      status.value = SyncStatus.synced;
    }
  }

  void dispose() {
    _pollTimer?.cancel();
    ConnectivityService.instance.isOnline.removeListener(_recalculate);
    status.dispose();
    pendingCount.dispose();
    lastSyncTime.dispose();
  }
}
