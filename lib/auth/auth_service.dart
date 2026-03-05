import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

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

  Future<void> signOut() => _auth.signOut();
}
