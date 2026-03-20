import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../domain/chat_message.dart';
import '../domain/wound_analysis_result.dart';

/// Persists Bella AI chat conversations in Firestore for Pro users.
///
/// Storage layout:
///   users/{uid}/bellaChats/{chatId}          – chat metadata
///   users/{uid}/bellaChats/{chatId}/messages  – individual messages
class BellaChatRepository {
  BellaChatRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String? _uid;
  String? get _currentUid => _uid ?? _auth.currentUser?.uid;

  /// Override the UID (useful after sign-in before auth state propagates).
  set uid(String? value) => _uid = value;

  // ── Collection helpers ──────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> _chatsCol(String uid) =>
      _firestore.collection('users/$uid/bellaChats');

  CollectionReference<Map<String, dynamic>> _messagesCol(
    String uid,
    String chatId,
  ) =>
      _firestore.collection('users/$uid/bellaChats/$chatId/messages');

  // ── Chat lifecycle ──────────────────────────────────────────────────

  /// Creates a new chat document and returns its ID.
  Future<String> createChat() async {
    final uid = _currentUid;
    if (uid == null) throw StateError('Not signed in');

    final doc = await _chatsCol(uid).add({
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  /// Returns the ID of the most recent chat, or `null` if none exists.
  Future<String?> getLatestChatId() async {
    final uid = _currentUid;
    if (uid == null) return null;

    final snap = await _chatsCol(uid)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    return snap.docs.isEmpty ? null : snap.docs.first.id;
  }

  /// Touches the `updatedAt` timestamp on a chat document.
  Future<void> _touchChat(String chatId) async {
    final uid = _currentUid;
    if (uid == null) return;
    await _chatsCol(uid).doc(chatId).update({
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Messages ────────────────────────────────────────────────────────

  /// Persists a single message inside the given chat (fire-and-forget safe).
  Future<void> addMessage(
    String chatId, {
    required String role,
    required String text,
    required DateTime timestamp,
    WoundAnalysisResult? woundAnalysis,
  }) async {
    final uid = _currentUid;
    if (uid == null) return;

    final data = <String, dynamic>{
      'role': role,
      'text': text,
      'createdAt': timestamp.toUtc().toIso8601String(),
    };
    if (woundAnalysis != null) {
      data['woundAnalysis'] = woundAnalysis.toJson();
    }

    try {
      await _messagesCol(uid, chatId).add(data);
      // Update the chat's last-activity timestamp (best-effort).
      _touchChat(chatId).ignore();
    } catch (e) {
      debugPrint('[BellaChatRepo] addMessage failed: $e');
    }
  }

  /// Loads the last [limit] messages from [chatId], oldest-first.
  Future<List<ChatMessage>> loadMessages(
    String chatId, {
    int limit = 50,
  }) async {
    final uid = _currentUid;
    if (uid == null) return [];

    try {
      final snap = await _messagesCol(uid, chatId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      if (snap.docs.isEmpty) return [];

      return snap.docs.reversed.map((d) {
        final data = d.data();
        final rawAnalysis = data['woundAnalysis'];
        return ChatMessage(
          role: data['role'] == 'user' ? ChatRole.user : ChatRole.assistant,
          text: (data['text'] as String?) ?? '',
          timestamp: DateTime.tryParse(data['createdAt'] as String? ?? '') ??
              DateTime.now(),
          woundAnalysis: rawAnalysis is Map<String, dynamic>
              ? WoundAnalysisResult.fromJson(rawAnalysis)
              : null,
        );
      }).toList();
    } catch (e) {
      debugPrint('[BellaChatRepo] loadMessages failed: $e');
      return [];
    }
  }
}
