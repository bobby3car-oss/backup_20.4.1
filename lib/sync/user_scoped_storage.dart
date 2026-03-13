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
  /// On web, returns a dummy directory (file I/O is not supported).
  Future<Directory> userDirectory() async {
    if (kIsWeb) return Directory('');
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
    if (kIsWeb) return File('');
    final dir = await userDirectory();
    return File('${dir.path}/$fileName');
  }

  // ── Guest data migration helpers ────────────────────────────────

  /// Returns `true` if the anonymous user directory contains data files.
  Future<bool> hasAnonymousData() async {
    if (kIsWeb) return false;
    final docs = await getApplicationDocumentsDirectory();
    final anonDir = Directory('${docs.path}/user__anonymous');
    if (!anonDir.existsSync()) return false;
    final entries = anonDir.listSync();
    return entries.any((e) => e is File);
  }

  /// Copies all data files from the anonymous directory into the
  /// authenticated user's directory. Files that already exist in the
  /// target directory are **not** overwritten to prevent data loss.
  Future<void> migrateGuestDataTo(String uid) async {
    if (kIsWeb) return;
    final docs = await getApplicationDocumentsDirectory();
    final anonDir = Directory('${docs.path}/user__anonymous');
    if (!anonDir.existsSync()) return;

    final targetDir = Directory('${docs.path}/user_$uid');
    if (!targetDir.existsSync()) {
      await targetDir.create(recursive: true);
    }

    for (final entity in anonDir.listSync()) {
      if (entity is File) {
        final name = entity.uri.pathSegments.last;
        final targetFile = File('${targetDir.path}/$name');
        if (!targetFile.existsSync()) {
          await entity.copy(targetFile.path);
        }
      }
    }
  }

  /// Deletes the anonymous user directory and all files inside it.
  Future<void> clearAnonymousData() async {
    if (kIsWeb) return;
    final docs = await getApplicationDocumentsDirectory();
    final anonDir = Directory('${docs.path}/user__anonymous');
    if (anonDir.existsSync()) {
      await anonDir.delete(recursive: true);
    }
  }

  /// Deletes all local data files for the given [uid].
  /// Also removes root-level legacy files that are not user-scoped.
  Future<void> clearUserData(String uid) async {
    if (kIsWeb) return;
    final docs = await getApplicationDocumentsDirectory();

    // Delete user-scoped directory.
    final userDir = Directory('${docs.path}/user_$uid');
    if (userDir.existsSync()) {
      await userDir.delete(recursive: true);
    }

    // Delete root-level legacy files that may contain user data.
    const legacyFiles = [
      'packing_items.json',
      'notification_preferences.json',
      'in_app_notifications.json',
      'timeline_items.json',
    ];
    for (final name in legacyFiles) {
      final file = File('${docs.path}/$name');
      if (file.existsSync()) {
        await file.delete();
      }
    }
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
