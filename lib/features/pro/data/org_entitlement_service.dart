import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/org_entitlement.dart';

/// Provides the global Org Pro status by listening to the Firestore
/// organisation document.
///
/// The single source of truth for the Org Pro status is:
///   `organisations/{orgUid}.isPro`  (set exclusively by Cloud Functions)
///
/// A local cache in SharedPreferences guarantees that Org Pro users keep their
/// status while offline.
class OrgEntitlementService {
  OrgEntitlementService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore,
      _auth = auth;

  factory OrgEntitlementService.enabled() {
    return OrgEntitlementService(
      firestore: FirebaseFirestore.instance,
      auth: FirebaseAuth.instance,
    );
  }

  factory OrgEntitlementService.disabled() {
    return OrgEntitlementService();
  }

  final FirebaseFirestore? _firestore;
  final FirebaseAuth? _auth;

  static const _cacheKey = 'cached_org_entitlement';

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _docSub;
  StreamSubscription<User?>? _authSub;

  /// Current org entitlement – always reflects Firestore state (or cached
  /// state when offline).
  final ValueNotifier<OrgEntitlement> entitlement =
      ValueNotifier<OrgEntitlement>(OrgEntitlement.free());

  /// When `true`, the organisation has Pro regardless of subscription state.
  bool _roleBasedPro = false;

  /// Grant permanent Pro access based on the user's role.
  void setRoleBasedPro(bool value) => _roleBasedPro = value;

  /// Convenience getter – considers role override and expiry date.
  bool get isPro => _roleBasedPro || entitlement.value.isActive;

  // ── Lifecycle ──────────────────────────────────────────────────────

  /// Call once at app start after Firebase init.
  ///
  /// Loads the cached entitlement first so the UI never flickers for Org Pro
  /// users who start the app offline.
  Future<void> init() async {
    await _loadCache();
    final auth = _auth;
    if (auth == null) return;
    _authSub = auth.authStateChanges().listen(_onAuthChanged);
  }

  void dispose() {
    _authSub?.cancel();
    _docSub?.cancel();
    entitlement.dispose();
  }

  /// Force-refresh from Firestore (e.g. after a verified purchase).
  Future<void> refresh() async {
    final auth = _auth;
    final firestore = _firestore;
    final uid = auth?.currentUser?.uid;
    if (uid == null || firestore == null) return;
    final snap = await firestore.doc('organisations/$uid').get();
    _applySnapshot(snap);
  }

  // ── Cache helpers ──────────────────────────────────────────────────

  Future<void> _loadCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw != null) {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        entitlement.value = OrgEntitlement.fromJson(json);
        if (kDebugMode) {
          debugPrint(
            '[OrgEntitlementService] Loaded cached org entitlement '
            '(isPro=${entitlement.value.isPro})',
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[OrgEntitlementService] Cache load failed: $e');
      }
    }
  }

  Future<void> _saveCache(OrgEntitlement ent) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(ent.toJson()));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[OrgEntitlementService] Cache save failed: $e');
      }
    }
  }

  Future<void> _clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
    } catch (e) {
      // Non-critical – ignore.
    }
  }

  // ── Internal ───────────────────────────────────────────────────────

  void _onAuthChanged(User? user) {
    final firestore = _firestore;
    _docSub?.cancel();
    _docSub = null;

    if (user == null) {
      entitlement.value = OrgEntitlement.free();
      _clearCache();
      return;
    }

    if (firestore == null) return;

    _docSub = firestore
        .doc('organisations/${user.uid}')
        .snapshots()
        .listen(
          _applySnapshot,
          onError: (Object e) {
            if (kDebugMode) {
              debugPrint(
                  '[OrgEntitlementService] Firestore listen error: $e');
            }
            // Keep the current (possibly cached) value instead of downgrading
            // to free. This prevents Org Pro users from losing access offline.
          },
        );
  }

  void _applySnapshot(DocumentSnapshot<Map<String, dynamic>> snap) {
    if (!snap.exists || snap.data() == null) {
      entitlement.value = OrgEntitlement.free();
      _clearCache();
      return;
    }
    final ent = OrgEntitlement.fromFirestore(snap.data()!);
    entitlement.value = ent;
    _saveCache(ent);
  }
}
