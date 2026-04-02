import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/entitlement.dart';

/// Provides the global Pro status by listening to the Firestore user document.
///
/// The single source of truth for the Pro status is:
///   `users/{uid}.isPro`  (set exclusively by Cloud Functions)
///
/// A local cache in SharedPreferences guarantees that Pro users keep their
/// status while offline. Without this, a Firestore error would silently
/// downgrade to [Entitlement.free].
class EntitlementService {
  EntitlementService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore,
      _auth = auth;

  factory EntitlementService.enabled() {
    return EntitlementService(
      firestore: FirebaseFirestore.instance,
      auth: FirebaseAuth.instance,
    );
  }

  factory EntitlementService.disabled() {
    return EntitlementService();
  }

  final FirebaseFirestore? _firestore;
  final FirebaseAuth? _auth;

  static const _cacheKey = 'cached_entitlement';

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _docSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _orgDocSub;
  StreamSubscription<User?>? _authSub;

  /// Current entitlement – always reflects Firestore state (or cached state
  /// when offline).
  final ValueNotifier<Entitlement> entitlement = ValueNotifier<Entitlement>(
    Entitlement.free(),
  );

  /// Whether Pro access is provided through the user's organisation.
  final ValueNotifier<bool> isOrgPro = ValueNotifier<bool>(false);

  /// Name of the organisation providing Pro (for "Bereitgestellt von" display).
  String? orgName;

  /// Convenience getter – considers expiry date AND org-level Pro.
  bool get isPro => entitlement.value.isActive || isOrgPro.value;

  // ── Lifecycle ──────────────────────────────────────────────────────

  /// Call once at app start after Firebase init.
  ///
  /// Loads the cached entitlement first so the UI never flickers for Pro users
  /// who start the app offline.
  Future<void> init() async {
    await _loadCache();
    final auth = _auth;
    if (auth == null) return;
    _authSub = auth.authStateChanges().listen(_onAuthChanged);
  }

  void dispose() {
    _authSub?.cancel();
    _docSub?.cancel();
    _orgDocSub?.cancel();
    entitlement.dispose();
    isOrgPro.dispose();
  }

  /// Force-refresh from Firestore (e.g. after a verified purchase).
  Future<void> refresh() async {
    final auth = _auth;
    final firestore = _firestore;
    final uid = auth?.currentUser?.uid;
    if (uid == null || firestore == null) return;
    final snap = await firestore.doc('users/$uid').get();
    _applySnapshot(snap);
  }

  // ── Cache helpers ──────────────────────────────────────────────────

  Future<void> _loadCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw != null) {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        entitlement.value = Entitlement.fromJson(json);
        if (kDebugMode) {
          debugPrint(
            '[EntitlementService] Loaded cached entitlement '
            '(isPro=${entitlement.value.isPro})',
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[EntitlementService] Cache load failed: $e');
      }
    }
  }

  Future<void> _saveCache(Entitlement ent) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(ent.toJson()));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[EntitlementService] Cache save failed: $e');
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
    _orgDocSub?.cancel();
    _orgDocSub = null;
    isOrgPro.value = false;
    orgName = null;

    if (user == null) {
      entitlement.value = Entitlement.free();
      _clearCache();
      return;
    }

    if (firestore == null) return;

    _docSub = firestore
        .doc('users/${user.uid}')
        .snapshots()
        .listen(
          (snap) {
            _applySnapshot(snap);

            // Start listening to the org document if the user belongs to one.
            final data = snap.data();
            final orgId = data?['orgId'] as String?;
            _listenToOrg(firestore, orgId);
          },
          onError: (Object e) {
            if (kDebugMode) {
              debugPrint('[EntitlementService] Firestore listen error: $e');
            }
            // Keep the current (possibly cached) value instead of downgrading to
            // free. This prevents Pro users from losing access while offline.
          },
        );
  }

  /// Starts (or stops) listening to the organisation document for Org Pro.
  void _listenToOrg(FirebaseFirestore firestore, String? orgId) {
    _orgDocSub?.cancel();
    _orgDocSub = null;

    if (orgId == null || orgId.isEmpty) {
      isOrgPro.value = false;
      orgName = null;
      return;
    }

    _orgDocSub = firestore
        .doc('organisations/$orgId')
        .snapshots()
        .listen(
          (snap) {
            final data = snap.data();
            if (snap.exists && data != null) {
              final orgIsPro = data['isPro'] as bool? ?? false;
              isOrgPro.value = orgIsPro;
              orgName = orgIsPro ? data['name'] as String? : null;
            } else {
              isOrgPro.value = false;
              orgName = null;
            }
          },
          onError: (Object e) {
            if (kDebugMode) {
              debugPrint(
                  '[EntitlementService] Org Firestore listen error: $e');
            }
            // Keep current org pro value on error.
          },
        );
  }

  void _applySnapshot(DocumentSnapshot<Map<String, dynamic>> snap) {
    if (!snap.exists || snap.data() == null) {
      entitlement.value = Entitlement.free();
      _clearCache();
      return;
    }
    final ent = Entitlement.fromFirestore(snap.data()!);
    entitlement.value = ent;
    _saveCache(ent);
  }
}
