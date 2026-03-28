import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../sync/user_scoped_storage.dart';
import '../features/widget/widget_data_service.dart';


/// Thin wrapper around [FirebaseAuth] supporting Email/Password,
/// Apple Sign-In, and Google Sign-In.
class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  Stream<User?> get currentUser => _auth.authStateChanges();

  User? get user => _auth.currentUser;

  // ── Web Redirect Result (call once on app startup) ──────────────

  /// On web, if a previous sign-in used redirect flow (e.g. popup was
  /// blocked), the result is available on the next page load. Call this
  /// once during app initialisation.
  static Future<void> handleWebRedirectResult() async {
    if (!kIsWeb) return;
    try {
      final result = await FirebaseAuth.instance.getRedirectResult();
      if (kDebugMode && result.user != null) {
        debugPrint(
            '[AuthService] Redirect sign-in completed: ${result.user?.uid}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AuthService] getRedirectResult error (safe to ignore): $e');
      }
    }
  }

  // ── Web Popup Sign-In (with redirect fallback) ──────────────────

  /// Tries popup-based sign-in first. If the browser blocks the popup,
  /// falls back to a full-page redirect.
  Future<UserCredential> _webPopupSignIn(
    AuthProvider provider,
    String providerName,
  ) async {
    try {
      final credential = await _auth.signInWithPopup(provider);
      if (kDebugMode) {
        debugPrint(
            '[AuthService] $providerName web popup sign-in succeeded: '
            '${credential.user?.uid}');
      }
      return credential;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
            '[AuthService] $providerName web popup failed: $e');
      }

      // If popup was blocked or closed, try redirect flow.
      final msg = e.toString().toLowerCase();
      if (msg.contains('popup') ||
          msg.contains('blocked') ||
          msg.contains('closed') ||
          msg.contains('cancelled') ||
          msg.contains('canceled') ||
          msg.contains('popup-closed-by-user') ||
          msg.contains('popup-blocked')) {
        if (kDebugMode) {
          debugPrint(
              '[AuthService] Falling back to redirect flow for $providerName');
        }
        await _auth.signInWithRedirect(provider);
        // After redirect the page reloads; getRedirectResult picks up
        // the credential. We'll never reach this next line, but the
        // compiler needs a return value.
        return _auth.getRedirectResult();
      }

      // Re-throw non-popup errors so the UI can handle them.
      rethrow;
    }
  }

  // ── Email / Password ────────────────────────────────────────────

  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await credential.user?.updateDisplayName(displayName.trim());
    return credential;
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // ── Apple Sign-In ───────────────────────────────────────────────

  Future<UserCredential> signInWithApple() async {
    final appleProvider = AppleAuthProvider()
      ..addScope('email')
      ..addScope('name');

    if (kIsWeb) {
      return _webPopupSignIn(appleProvider, 'Apple');
    }

    final credential = await _auth.signInWithProvider(appleProvider);

    if (kDebugMode) {
      debugPrint(
          '[AuthService] Apple sign-in succeeded: ${credential.user?.uid}');
    }

    return credential;
  }

  // ── Google Sign-In ──────────────────────────────────────────────

  Future<UserCredential> signInWithGoogle() async {
    // On web, use popup-based flow with redirect fallback.
    if (kIsWeb) {
      final googleProvider = GoogleAuthProvider()
        ..addScope('email')
        ..addScope('profile');
      return _webPopupSignIn(googleProvider, 'Google');
    }

    // On macOS, use Firebase's built-in provider flow.
    if (defaultTargetPlatform == TargetPlatform.macOS) {
      final googleProvider = GoogleAuthProvider()
        ..addScope('email')
        ..addScope('profile');
      final credential = await _auth.signInWithProvider(googleProvider);
      if (kDebugMode) {
        debugPrint(
            '[AuthService] Google sign-in succeeded: ${credential.user?.uid}');
      }
      return credential;
    }

    // On mobile (iOS/Android), try native Google Sign-In first.
    // Falls back to provider flow if native fails (e.g. simulator).
    try {
      final googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw FirebaseAuthException(
          code: 'sign-in-cancelled',
          message: 'Google sign-in was cancelled by the user.',
        );
      }

      final googleAuth = await googleUser.authentication;
      final oauthCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final credential = await _auth.signInWithCredential(oauthCredential);

      if (kDebugMode) {
        debugPrint(
            '[AuthService] Google sign-in succeeded: ${credential.user?.uid}');
      }

      return credential;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AuthService] Native Google sign-in failed: $e');
        debugPrint('[AuthService] Falling back to provider-based flow...');
      }
      // Fallback: provider-based flow (works on simulator too).
      final googleProvider = GoogleAuthProvider()
        ..addScope('email')
        ..addScope('profile');
      return _auth.signInWithProvider(googleProvider);
    }
  }

  // ── Account Linking ─────────────────────────────────────────────

  /// Links an additional auth provider to the current account.
  Future<UserCredential> linkWithApple() async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('No user signed in');

    final appleProvider = AppleAuthProvider()
      ..addScope('email')
      ..addScope('name');

    return user.linkWithProvider(appleProvider);
  }

  Future<UserCredential> linkWithGoogle() async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('No user signed in');

    if (kIsWeb || defaultTargetPlatform == TargetPlatform.macOS) {
      final googleProvider = GoogleAuthProvider()
        ..addScope('email')
        ..addScope('profile');
      return user.linkWithProvider(googleProvider);
    }

    try {
      final googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw FirebaseAuthException(
          code: 'sign-in-cancelled',
          message: 'Google sign-in was cancelled by the user.',
        );
      }

      final googleAuth = await googleUser.authentication;
      final oauthCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return user.linkWithCredential(oauthCredential);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AuthService] Native Google link failed: $e');
      }
      final googleProvider = GoogleAuthProvider()
        ..addScope('email')
        ..addScope('profile');
      return user.linkWithProvider(googleProvider);
    }
  }

  // ── Sign Out ────────────────────────────────────────────────────

  /// Signs out and removes all locally cached user data so nothing
  /// remains on the device after logout.
  Future<void> signOut() async {
    final uid = _auth.currentUser?.uid;

    // 0. Stop active data listeners (homescreen widgets, etc.).
    try {
      WidgetDataService.instance.stopListening();
    } catch (_) {}

    // 1. Delete user-scoped files (JSON data for all local repos).
    if (uid != null) {
      try {
        await UserScopedStorage.instance.clearUserData(uid);
      } catch (e) {
        if (kDebugMode) debugPrint('[AuthService] clearUserData: $e');
      }
    }

    // 2. Clear SharedPreferences (preserve device-level language setting).
    try {
      final prefs = await SharedPreferences.getInstance();
      final locale = prefs.getString('app_locale');
      await prefs.clear();
      if (locale != null) {
        await prefs.setString('app_locale', locale);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[AuthService] clearPrefs: $e');
    }

    // 3. Clear Flutter Secure Storage (guest profile, etc.).
    try {
      const storage = FlutterSecureStorage();
      await storage.deleteAll();
    } catch (e) {
      if (kDebugMode) debugPrint('[AuthService] clearSecureStorage: $e');
    }

    // 4. Sign out from Firebase Auth and Google Sign-In.
    await _auth.signOut();
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}

    // 5. Clear Firestore offline persistence cache.
    //    Must happen after signOut so no active listeners remain.
    //    clearPersistence() is called separately on next app start to avoid
    //    timing issues with remaining Firestore listeners.
    try {
      await FirebaseFirestore.instance.terminate();
      // Small delay to let pending operations settle before clearing.
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await FirebaseFirestore.instance.clearPersistence();
    } catch (e) {
      if (kDebugMode) debugPrint('[AuthService] clearPersistence: $e');
    }
  }
}
