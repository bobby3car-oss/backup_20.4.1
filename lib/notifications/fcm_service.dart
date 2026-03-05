import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../firebase/firebase_paths.dart';
import 'local_notifications.dart';

/// Manages FCM token registration, foreground message display,
/// and background tap routing.
class FcmService {
  FcmService({
    FirebaseMessaging? messaging,
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _messaging = messaging ?? FirebaseMessaging.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseMessaging _messaging;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  /// Initialise FCM: request permissions, get token, listen for refresh.
  Future<void> init() async {
    // Request permission (iOS / macOS).
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (kDebugMode) {
      debugPrint(
          '[FcmService] Permission status: ${settings.authorizationStatus}');
    }

    // Get initial token.
    final token = await _messaging.getToken();
    if (token != null) {
      await _saveToken(token);
    }

    // Listen for token refresh.
    _messaging.onTokenRefresh.listen(_saveToken);

    // Foreground messages: show local notification.
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Background tap: route to screen.
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);

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
      await _firestore.doc(FirestorePaths.userDoc(user.uid)).set(
        <String, dynamic>{
          'fcmToken': token,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      if (kDebugMode) {
        debugPrint('[FcmService] Token saved for ${user.uid}');
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
      debugPrint(
          '[FcmService] Foreground message: ${notification.title}');
    }

    // Display via local notifications (already initialised).
    LocalNotifications.showFcmNotification(
      title: notification.title ?? '',
      body: notification.body ?? '',
      payload: message.data['route'] as String?,
    );
  }

  /// Handles when user taps a notification (background/terminated).
  void _handleMessageTap(RemoteMessage message) {
    final route = message.data['route'] as String?;
    if (route == null || route.isEmpty) return;

    if (kDebugMode) {
      debugPrint('[FcmService] Notification tap → route: $route');
    }

    // Route handling is done via the global navigator key.
    // The actual routing will be connected in main.dart.
    _pendingRoute = route;
  }

  /// Pending deep-link route from a notification tap.
  String? _pendingRoute;

  /// Consumes and returns any pending route from a notification tap.
  String? consumePendingRoute() {
    final route = _pendingRoute;
    _pendingRoute = null;
    return route;
  }
}
