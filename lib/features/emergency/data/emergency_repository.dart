import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../../firebase/firebase_paths.dart';
import '../../../security/guest_profile_store.dart';
import '../domain/emergency_info.dart';

/// Loads [EmergencyInfo] from the local cache first (offline-ready),
/// then optionally refreshes from Firestore when online.
class EmergencyRepository {
  EmergencyRepository({SharedPreferences? prefs}) : _prefs = prefs;

  SharedPreferences? _prefs;
  static const _cacheKey = 'emergency_info_cache';

  final GuestProfileStore _guestStore = GuestProfileStore();

  Future<void> _ensurePrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Returns the cached local copy immediately (works offline).
  Future<EmergencyInfo> loadCached() async {
    await _ensurePrefs();
    final raw = _prefs!.getString(_cacheKey);
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
    await _ensurePrefs();

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

    final info = EmergencyInfo.fromMap(data);
    // Persist to local cache for offline access.
    await _prefs!.setString(_cacheKey, jsonEncode(info.toMap()));
    return info;
  }

  /// Updates the local cache directly (e.g. after profile save).
  /// Ensures consistency between profile data and emergency cache.
  Future<void> updateCache(EmergencyInfo info) async {
    await _ensurePrefs();
    await _prefs!.setString(_cacheKey, jsonEncode(info.toMap()));
  }
}
