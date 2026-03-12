import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../sync/user_scoped_storage.dart';

/// Thin wrapper around [FirebaseAuth] supporting Email/Password,
/// Apple Sign-In, and Google Sign-In.
class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  Stream<User?> get currentUser => _auth.authStateChanges();

  User? get user => _auth.currentUser;

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

    final credential = await _auth.signInWithProvider(appleProvider);

    if (kDebugMode) {
      debugPrint(
          '[AuthService] Apple sign-in succeeded: ${credential.user?.uid}');
    }

    return credential;
  }

  // ── Google Sign-In ──────────────────────────────────────────────

  Future<UserCredential> signInWithGoogle() async {
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

    final googleProvider = GoogleAuthProvider()
      ..addScope('email')
      ..addScope('profile');

    return user.linkWithProvider(googleProvider);
  }

  // ── Sign Out ────────────────────────────────────────────────────

  /// Signs out and removes all locally cached user data so nothing
  /// remains on the device after logout.
  Future<void> signOut() async {
    final uid = _auth.currentUser?.uid;

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

    // 4. Sign out from Firebase Auth.
    await _auth.signOut();

    // 5. Clear Firestore offline persistence cache.
    //    Must happen after signOut so no active listeners remain.
    try {
      await FirebaseFirestore.instance.terminate();
      await FirebaseFirestore.instance.clearPersistence();
    } catch (e) {
      if (kDebugMode) debugPrint('[AuthService] clearPersistence: $e');
    }
  }
}
