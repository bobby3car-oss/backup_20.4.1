import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Provides user-scoped file paths so each Firebase account gets its own
/// local data directory. Listens to auth state changes and notifies all
/// registered repositories to clear in-memory state and reload from the
/// correct user directory.
class UserScopedStorage {
  UserScopedStorage._();
  static final UserScopedStorage instance = UserScopedStorage._();

  String? _currentUid;
  StreamSubscription<User?>? _authSub;
  final List<VoidCallback> _onUserChanged = [];

  /// The current user's UID (null if signed out).
  String? get currentUid => _currentUid;

  /// Initialise once from [main]. Listens to auth changes.
  void init() {
    _currentUid = FirebaseAuth.instance.currentUser?.uid;
    _authSub?.cancel();
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      final newUid = user?.uid;
      if (newUid == _currentUid) return;
      _currentUid = newUid;
      _notifyAll();
    });
  }

  /// Register a callback invoked when the active user changes.
  /// Repositories should clear their in-memory state and reload from disk.
  void addListener(VoidCallback callback) {
    _onUserChanged.add(callback);
  }

  void removeListener(VoidCallback callback) {
    _onUserChanged.remove(callback);
  }

  /// Returns the user-scoped storage directory. Creates it if missing.
  /// Falls back to a shared `_anonymous` directory when no user is signed in.
  Future<Directory> userDirectory() async {
    final docs = await getApplicationDocumentsDirectory();
    final uid = _currentUid ?? '_anonymous';
    final dir = Directory('${docs.path}/user_$uid');
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Convenience: returns a [File] inside the user-scoped directory.
  Future<File> file(String fileName) async {
    final dir = await userDirectory();
    return File('${dir.path}/$fileName');
  }

  void _notifyAll() {
    for (final cb in List<VoidCallback>.of(_onUserChanged)) {
      try {
        cb();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[UserScopedStorage] listener error: $e');
        }
      }
    }
  }

  void dispose() {
    _authSub?.cancel();
    _authSub = null;
    _onUserChanged.clear();
  }
}
