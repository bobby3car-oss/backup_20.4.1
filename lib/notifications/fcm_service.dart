import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../firebase/firebase_paths.dart';
import '../security/app_route_guard.dart';
import 'local_notifications.dart';

/// Manages FCM token registration, foreground message display,
/// and background tap routing.
class FcmService {
  factory FcmService({
    FirebaseMessaging? messaging,
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) {
    return _instance ??= FcmService._(
      messaging: messaging ?? FirebaseMessaging.instance,
      auth: auth ?? FirebaseAuth.instance,
      firestore: firestore ?? FirebaseFirestore.instance,
    );
  }

  FcmService._({
    required FirebaseMessaging messaging,
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) : _messaging = messaging,
       _auth = auth,
       _firestore = firestore;

  static FcmService? _instance;

  /// Singleton accessor.
  static FcmService get instance => _instance ??= FcmService();

  final FirebaseMessaging _messaging;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  bool _initialized = false;

  /// Initialise FCM: request permissions, get token, listen for refresh.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // Request permission (iOS / macOS).
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (kDebugMode) {
      debugPrint(
        '[FcmService] Permission status: ${settings.authorizationStatus}',
      );
    }

    // Only register token if permission was granted.
    if (settings.authorizationStatus != AuthorizationStatus.authorized &&
        settings.authorizationStatus != AuthorizationStatus.provisional) {
      if (kDebugMode) {
        debugPrint('[FcmService] Permission not granted – skipping token.');
      }
      return;
    }

    // Get initial token.
    final token = await _messaging.getToken();
    if (token != null) {
      await _saveToken(token);
    }

    // Listen for token refresh.
    _subscriptions.add(_messaging.onTokenRefresh.listen(_saveToken));

    // Foreground messages: show local notification.
    _subscriptions.add(
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage),
    );

    // Background tap: route to screen.
    _subscriptions.add(
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap),
    );

    // Check if app was opened from a terminated-state notification.
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageTap(initialMessage);
    }
  }

  /// Saves the FCM token to the current user's Firestore document.
  Future<void> _saveToken(String token) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.doc(FirestorePaths.userPushTokenDoc(user.uid)).set(
        <String, dynamic>{
          'token': token,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      await _firestore.doc(FirestorePaths.userDoc(user.uid)).set(
        <String, dynamic>{
          'fcmToken': FieldValue.delete(),
          'fcmTokenUpdatedAt': FieldValue.delete(),
        },
        SetOptions(merge: true),
      );
      if (kDebugMode) {
        debugPrint('[FcmService] Token registration updated.');
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[FcmService] Failed to save token: $error');
      }
    }
  }

  /// Handles messages received while the app is in the foreground.
  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    if (kDebugMode) {
      debugPrint('[FcmService] Foreground push received.');
    }

    final type = message.data['type'] as String?;

    // Bella trend notifications use a special payload instead of a route.
    if (type == 'bella_trend') {
      final trendMsg = message.data['trendMessage'] as String?;
      LocalNotifications.showFcmNotification(
        title: notification.title ?? '',
        body: notification.body ?? '',
        payload: '__bella_trend__',
      );
      if (trendMsg != null && trendMsg.isNotEmpty) {
        _pendingBellaTrendMessage = trendMsg;
      }
      return;
    }

    final route = sanitizeExternalRoute(message.data['route'] as String?);

    // Display via local notifications (already initialised).
    LocalNotifications.showFcmNotification(
      title: notification.title ?? '',
      body: notification.body ?? '',
      payload: route,
    );
  }

  /// Handles when user taps a notification (background/terminated).
  void _handleMessageTap(RemoteMessage message) {
    final type = message.data['type'] as String?;

    // Bella trend notifications open Bella with a prepared analysis.
    if (type == 'bella_trend') {
      final trendMsg = message.data['trendMessage'] as String?;
      if (trendMsg != null && trendMsg.isNotEmpty) {
        _pendingBellaTrendMessage = trendMsg;
      }
      _pendingRoute = '__bella_trend__';
      return;
    }

    final route = sanitizeExternalRoute(message.data['route'] as String?);
    if (route == null) {
      if (kDebugMode) {
        debugPrint('[FcmService] Rejected external notification route.');
      }
      return;
    }

    if (kDebugMode) {
      debugPrint('[FcmService] Accepted external notification route.');
    }

    // Route handling is done via the global navigator key.
    // The actual routing will be connected in main.dart.
    _pendingRoute = route;
  }

  /// Pending deep-link route from a notification tap.
  String? _pendingRoute;

  /// Pending Bella trend message from a trend notification.
  String? _pendingBellaTrendMessage;

  /// Sets a pending route (used by local notification tap handler).
  void setPendingRoute(String route) {
    _pendingRoute = route;
  }

  /// Consumes and returns any pending route from a notification tap.
  String? consumePendingRoute() {
    final route = _pendingRoute;
    _pendingRoute = null;
    return route;
  }

  /// Consumes and returns any pending Bella trend message.
  String? consumePendingBellaTrend() {
    final msg = _pendingBellaTrendMessage;
    _pendingBellaTrendMessage = null;
    return msg;
  }

  /// Cancels all stream subscriptions and resets state so [init] works again.
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
    _initialized = false;
  }
}
