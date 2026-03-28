import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';


/// Manages admin-generated keys (Pro & Doctor).
///
/// **Security model (V2 – Cloud Function backed):**
///
///  1. Client marks `adminKeys/{keyId}.status = "used"` with strict rule
///     enforcement (only `active → used`, `usedByUid == auth.uid`).
///  2. Client writes `keyRedemptions/{auto}` with `{uid, keyId, type, status: "pending"}`.
///  3. Cloud Function `onKeyRedemptionCreated` picks up the request, validates
///     the key doc, and applies the effect (sets `users/{uid}.isPro` or `.role`).
///  4. Client polls `keyRedemptions/{id}` until `status == "completed"`.
///
/// The client **never** writes to `users/{uid}.isPro`, `.role`, or `.doctorVerified`.
class AdminKeyService {
  AdminKeyService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const _keysCollection = 'adminKeys';
  static const _redemptionsCollection = 'keyRedemptions';
  static const _eventsCollection = 'adminEvents';
  static const _base32Chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  // ── Key generation (superAdmin only) ──────────────────────────

  /// Generate a human-friendly code (12 chars Base32, no 0/1/O/I).
  String _generateCode({int length = 12}) {
    final rng = Random.secure();
    return List.generate(
      length,
      (_) => _base32Chars[rng.nextInt(_base32Chars.length)],
    ).join();
  }

  /// Format a raw code into groups: XXXX-XXXX-XXXX
  String _formatCode(String code) {
    final buf = StringBuffer();
    for (var i = 0; i < code.length; i++) {
      if (i > 0 && i % 4 == 0) buf.write('-');
      buf.write(code[i]);
    }
    return buf.toString();
  }

  /// Normalize: uppercase, remove dashes/spaces.
  static String normalizeCode(String raw) {
    return raw.toUpperCase().replaceAll(RegExp(r'[\s\-]'), '');
  }

  /// Compute the docId = sha256("KEY_V1:" + normalizedCode) in hex.
  static String computeKeyId(String normalizedCode) {
    final bytes = utf8.encode('KEY_V1:$normalizedCode');
    return sha256.convert(bytes).toString();
  }

  // ── Create key (superAdmin) ───────────────────────────────────

  /// Create a single key. Returns the plaintext code (formatted).
  Future<String> createKey({
    required String type, // 'PRO' | 'DOCTOR'
    DateTime? expiresAt,
    String? label,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Not authenticated');

    final rawCode = _generateCode();
    final normalized = normalizeCode(rawCode);
    final keyId = computeKeyId(normalized);

    await _firestore.doc('$_keysCollection/$keyId').set({
      'keyId': keyId,
      'type': type.toUpperCase(),
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
      'createdByUid': uid,
      if (expiresAt != null) 'expiresAt': Timestamp.fromDate(expiresAt),
      if (label != null && label.isNotEmpty) 'label': label,
    });

    // Log admin event.
    await _firestore.collection(_eventsCollection).add({
      'actorUid': uid,
      'action': 'KEY_CREATED',
      'createdAt': FieldValue.serverTimestamp(),
      'metadata': {
        'keyType': type.toUpperCase(),
        'label': label ?? '',
      },
    });

    // Increment stats counter.
    await _firestore.doc('adminStats/global').set(
      {'keysCreatedTotal': FieldValue.increment(1)},
      SetOptions(merge: true),
    );

    return _formatCode(normalized);
  }

  /// Create a batch of keys. Returns plaintext codes.
  Future<List<String>> createBatch({
    required String type,
    required int count,
    DateTime? expiresAt,
    String? label,
  }) async {
    final codes = <String>[];
    for (var i = 0; i < count; i++) {
      final code = await createKey(
        type: type,
        expiresAt: expiresAt,
        label: label,
      );
      codes.add(code);
    }
    return codes;
  }

  // ── List / Watch keys (superAdmin) ────────────────────────────

  /// Stream keys for real-time updates (superAdmin only).
  Stream<List<Map<String, dynamic>>> watchKeys({String? typeFilter}) {
    Query<Map<String, dynamic>> query = _firestore
        .collection(_keysCollection)
        .orderBy('createdAt', descending: true);

    if (typeFilter != null) {
      query = query.where('type', isEqualTo: typeFilter.toUpperCase());
    }

    return query.limit(100).snapshots().map(
          (snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
        );
  }

  // ── Revoke key (superAdmin) ───────────────────────────────────

  Future<void> revokeKey(String keyId) async {
    await _firestore.doc('$_keysCollection/$keyId').update({
      'status': 'revoked',
    });

    final uid = _auth.currentUser?.uid;
    await _firestore.collection(_eventsCollection).add({
      'actorUid': uid ?? 'unknown',
      'action': 'KEY_REVOKED',
      'createdAt': FieldValue.serverTimestamp(),
      'metadata': {'keyId': keyId},
    });
  }

  // ── Key redemption (any authenticated user) ───────────────────

  /// Redeem a key.
  ///
  /// Returns `(success: bool, message: String)`.
  ///
  /// Flow:
  ///  1. Normalize → hash → GET adminKeys/{keyId}.
  ///  2. Validate: status == active, not expired.
  ///  3. UPDATE adminKeys/{keyId}: status → used, usedByUid, usedAt.
  ///  4. CREATE keyRedemptions/{auto}: {uid, keyId, type, status: pending}.
  ///  5. Poll keyRedemptions until completed or failed.
  Future<({bool success, String message})> redeemKey(String rawCode) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return (success: false, message: 'Du musst angemeldet sein.');
    }

    final normalized = normalizeCode(rawCode);
    if (normalized.isEmpty) {
      return (success: false, message: 'Bitte gib einen Key ein.');
    }

    final keyId = computeKeyId(normalized);
    final keyRef = _firestore.doc('$_keysCollection/$keyId');

    try {
      // 1. Read key doc.
      final keySnap = await keyRef.get();
      if (!keySnap.exists) {
        return (success: false, message: 'Key nicht gefunden.');
      }

      final keyData = keySnap.data()!;
      final status = keyData['status']?.toString() ?? '';
      final type = keyData['type']?.toString() ?? '';

      if (status != 'active') {
        return (
          success: false,
          message: status == 'used'
              ? 'Dieser Key wurde bereits eingelöst.'
              : status == 'revoked'
                  ? 'Dieser Key wurde widerrufen.'
                  : 'Dieser Key ist nicht gültig.',
        );
      }

      // Check expiry.
      final expiresAt = keyData['expiresAt'];
      if (expiresAt != null && expiresAt is Timestamp) {
        if (DateTime.now().isAfter(expiresAt.toDate())) {
          return (success: false, message: 'Dieser Key ist abgelaufen.');
        }
      }

      // 2. Mark key as used (rules enforce strict transition).
      await keyRef.update({
        'status': 'used',
        'usedByUid': uid,
        'usedAt': FieldValue.serverTimestamp(),
      });

      // 3. Write keyRedemption request for Cloud Function.
      final redemptionRef =
          await _firestore.collection(_redemptionsCollection).add({
        'uid': uid,
        'keyId': keyId,
        'type': type,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 4. Also write a KEY_USED admin event (allowed by rules).
      await _firestore.collection(_eventsCollection).add({
        'actorUid': uid,
        'action': 'KEY_USED',
        'createdAt': FieldValue.serverTimestamp(),
        'metadata': {
          'keyId': keyId.substring(0, 16),
          'keyType': type,
        },
      });

      // 5. Poll for completion (max ~10 seconds).
      final effectMsg = await _waitForRedemption(redemptionRef, type);

      return (success: true, message: effectMsg);
    } catch (e) {
      if (kDebugMode) debugPrint('[AdminKeyService] redeem error: $e');
      return (
        success: false,
        message: 'Fehler beim Einlösen. Bitte versuche es erneut.',
      );
    }
  }

  /// Poll the redemption doc until Cloud Function completes it.
  Future<String> _waitForRedemption(
    DocumentReference ref,
    String type,
  ) async {
    for (var i = 0; i < 20; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      final snap = await ref.get();
      if (!snap.exists) continue;
      final data = snap.data() as Map<String, dynamic>?;
      if (data == null) continue;

      final status = data['status']?.toString() ?? '';
      if (status == 'completed') {
        return type.toUpperCase() == 'PRO'
            ? 'Pro aktiviert'
            : 'Arztzugang aktiviert';
      }
      if (status == 'failed') {
        final error = data['error']?.toString() ?? 'Unbekannter Fehler';
        throw Exception(error);
      }
    }

    // If Cloud Functions haven't processed yet, assume success
    // (effect will be applied async).
    return type.toUpperCase() == 'PRO'
        ? 'Pro wird aktiviert…'
        : 'Arztzugang wird aktiviert…';
  }
}
