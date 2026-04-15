import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

import '../../../firebase/firebase_paths.dart';
import '../../../security/field_encryption_service.dart';
import '../../../security/guest_profile_store.dart';
import '../domain/emergency_info.dart';

/// Loads [EmergencyInfo] from the local cache first (offline-ready),
/// then optionally refreshes from Firestore when online.
///
/// Uses [FlutterSecureStorage] for the local cache so that sensitive
/// medical data (blood type, allergies, insurance) is encrypted at rest.
class EmergencyRepository {
  EmergencyRepository({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _cacheKey = 'emergency_info_cache';

  final GuestProfileStore _guestStore = GuestProfileStore();

  /// Returns the cached local copy immediately (works offline).
  Future<EmergencyInfo> loadCached() async {
    final raw = await _storage.read(key: _cacheKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        return EmergencyInfo.fromMap(map);
      } catch (_) {}
    }
    return const EmergencyInfo();
  }

  /// Loads from Firestore (or GuestProfileStore) and updates cache.
  Future<EmergencyInfo> load() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    Map<String, dynamic>? data;

    if (uid != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .doc(FirestorePaths.userDoc(uid))
            .get();
        data = doc.data();
      } catch (_) {
        // Offline – fall back to cache.
        return loadCached();
      }
    } else {
      data = await _guestStore.load();
    }

    if (data == null) return const EmergencyInfo();

    // Decrypt identifying fields before parsing.
    if (uid != null) {
      data = FieldEncryptionService.instance
          .decryptFields(uid, data, kEncryptedUserFields);
    }

    final info = EmergencyInfo.fromMap(data);
    // Persist to local cache for offline access (encrypted at rest).
    await _storage.write(key: _cacheKey, value: jsonEncode(info.toMap()));
    return info;
  }

  /// Loads fresh data from Firestore (or GuestProfileStore) and updates the
  /// local cache. Unlike [load], this method does NOT catch connectivity
  /// errors — callers should handle them to distinguish "offline" from
  /// "no data". On success the cache is updated.
  Future<EmergencyInfo> refreshFromNetwork() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    Map<String, dynamic>? data;
    if (uid != null) {
      // Throws PlatformException / SocketException / FirebaseException on
      // network failure — intentionally not caught here.
      final doc = await FirebaseFirestore.instance
          .doc(FirestorePaths.userDoc(uid))
          .get();
      data = doc.data();
    } else {
      data = await _guestStore.load();
    }
    if (data == null) return const EmergencyInfo();

    // Decrypt identifying fields before parsing.
    if (uid != null) {
      data = FieldEncryptionService.instance
          .decryptFields(uid, data, kEncryptedUserFields);
    }

    final info = EmergencyInfo.fromMap(data);
    await _storage.write(key: _cacheKey, value: jsonEncode(info.toMap()));
    return info;
  }

  /// Updates the local cache directly (e.g. after profile save).
  /// Ensures consistency between profile data and emergency cache.
  Future<void> updateCache(EmergencyInfo info) async {
    await _storage.write(key: _cacheKey, value: jsonEncode(info.toMap()));
  }
}
