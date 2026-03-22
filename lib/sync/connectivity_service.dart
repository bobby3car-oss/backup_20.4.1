import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Singleton service that monitors network connectivity and triggers
/// registered callbacks when the device comes back online.
class ConnectivityService {
  ConnectivityService._();
  static final ConnectivityService instance = ConnectivityService._();

  final ValueNotifier<bool> isOnline = ValueNotifier<bool>(true);
  final List<Future<void> Function()> _onReconnectCallbacks = [];
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _initialized = false;

  /// Initialise once from [main].
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    try {
      final result = await Connectivity().checkConnectivity();
      isOnline.value = _hasConnection(result);
    } catch (e) {
      if (kDebugMode) debugPrint('[ConnectivityService] initial check: $e');
    }

    _subscription = Connectivity().onConnectivityChanged.listen((result) {
      final nowOnline = _hasConnection(result);
      final wasOffline = !isOnline.value;
      isOnline.value = nowOnline;

      if (nowOnline && wasOffline) {
        _fireReconnectCallbacks();
      }
    });
  }

  /// Register a callback that is called whenever the device reconnects.
  void onReconnect(Future<void> Function() callback) {
    _onReconnectCallbacks.add(callback);
  }

  /// Explicitly re-check connectivity (e.g. on app resume).
  Future<void> recheckNow() async {
    try {
      final result = await Connectivity().checkConnectivity();
      final nowOnline = _hasConnection(result);
      final wasOffline = !isOnline.value;
      isOnline.value = nowOnline;
      if (nowOnline && wasOffline) {
        _fireReconnectCallbacks();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[ConnectivityService] recheckNow: $e');
    }
  }

  void _fireReconnectCallbacks() {
    if (kDebugMode) {
      debugPrint('[ConnectivityService] back online – syncing…');
    }
    for (final cb in List<Future<void> Function()>.of(_onReconnectCallbacks)) {
      unawaited(cb().catchError((Object e) {
        if (kDebugMode) {
          debugPrint('[ConnectivityService] reconnect callback error: $e');
        }
      }));
    }
  }

  static bool _hasConnection(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none)) return false;
    return results.isNotEmpty;
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _onReconnectCallbacks.clear();
    isOnline.dispose();
  }
}
