import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../domain/entitlement.dart';

/// Provides the global Pro status by listening to the Firestore user document.
///
/// The single source of truth for the Pro status is:
///   `users/{uid}.isPro`  (set exclusively by Cloud Functions)
///
/// Nothing is cached locally.
class EntitlementService {
  EntitlementService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _docSub;
  StreamSubscription<User?>? _authSub;

  /// Current entitlement – always reflects Firestore state.
  final ValueNotifier<Entitlement> entitlement =
      ValueNotifier<Entitlement>(Entitlement.free());

  /// Convenience getter.
  bool get isPro => entitlement.value.isPro;

  // ── Lifecycle ──────────────────────────────────────────────────────

  /// Call once at app start after Firebase init.
  void init() {
    _authSub = _auth.authStateChanges().listen(_onAuthChanged);
  }

  void dispose() {
    _authSub?.cancel();
    _docSub?.cancel();
    entitlement.dispose();
  }

  /// Force-refresh from Firestore (e.g. after a verified purchase).
  Future<void> refresh() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final snap = await _firestore.doc('users/$uid').get();
    _applySnapshot(snap);
  }

  // ── Internal ───────────────────────────────────────────────────────

  void _onAuthChanged(User? user) {
    _docSub?.cancel();
    _docSub = null;

    if (user == null) {
      entitlement.value = Entitlement.free();
      return;
    }

    _docSub = _firestore
        .doc('users/${user.uid}')
        .snapshots()
        .listen(_applySnapshot, onError: (Object e) {
      if (kDebugMode) {
        debugPrint('[EntitlementService] Firestore listen error: $e');
      }
      entitlement.value = Entitlement.free();
    });
  }

  void _applySnapshot(DocumentSnapshot<Map<String, dynamic>> snap) {
    if (!snap.exists || snap.data() == null) {
      entitlement.value = Entitlement.free();
      return;
    }
    entitlement.value = Entitlement.fromFirestore(snap.data()!);
  }
}
