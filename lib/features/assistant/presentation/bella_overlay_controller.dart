import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../auth/user_profile_service.dart';
import '../../../firebase/firebase_paths.dart';
import '../../../sync/connectivity_service.dart';
import '../domain/assistant_service.dart';
import '../domain/bella_action.dart';
import '../domain/bella_action_executor.dart';
import '../domain/chat_message.dart';

/// Manages global Bella AI overlay state: open/close, messages, loading.
///
/// Lives above the navigator so the chat persists across route changes.
class BellaOverlayController extends ChangeNotifier {
  BellaOverlayController();

  final _service = AssistantService();
  final _executor = const BellaActionExecutor();

  final messages = <ChatMessage>[];

  bool _isOpen = false;
  bool get isOpen => _isOpen;

  bool _isTyping = false;
  bool get isTyping => _isTyping;

  AppUserRole _role = AppUserRole.patient;
  AppUserRole get role => _role;
  String? _roleUid;

  /// Whether the current user has Pro. Set externally by the overlay wrapper.
  bool isPro = false;

  /// Dynamic follow-up suggestions from the server.
  List<String> dynamicSuggestions = [];

  bool _historyLoaded = false;
  String? _historyUid;

  /// Load persisted chat history from Firestore (once per UID).
  Future<void> loadChatHistory() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    if (_historyLoaded && uid == _historyUid) return;
    _historyLoaded = true;
    _historyUid = uid;

    try {
      final snap = await FirebaseFirestore.instance
          .collection(FirestorePaths.bellaChatCollection(uid))
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      if (snap.docs.isEmpty) return;

      final restored = snap.docs.reversed.map((d) {
        final data = d.data();
        return ChatMessage(
          role: data['role'] == 'user' ? ChatRole.user : ChatRole.assistant,
          text: (data['text'] as String?) ?? '',
          timestamp: DateTime.tryParse(data['createdAt'] as String? ?? '') ??
              DateTime.now(),
        );
      }).toList();

      messages.insertAll(0, restored);
      notifyListeners();
    } catch (e) {
      debugPrint('[Bella] Failed to load chat history: $e');
    }
  }

  /// Loads the current user's role from Firestore (once per UID).
  Future<void> loadRole() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    if (uid == _roleUid) return;
    try {
      _role = await UserProfileService().getMyRole();
      _roleUid = uid;
      notifyListeners();
    } catch (_) {}
  }

  void toggle() {
    _isOpen = !_isOpen;
    notifyListeners();
  }

  void close() {
    if (!_isOpen) return;
    _isOpen = false;
    notifyListeners();
  }

  void open() {
    if (_isOpen) return;
    _isOpen = true;
    notifyListeners();
  }

  /// Confirm and execute a pending action on a message.
  Future<void> confirmAction(ChatMessage msg) async {
    final action = msg.pendingAction;
    if (action == null || msg.actionStatus != BellaActionStatus.pending) return;

    try {
      await _executor.execute(action);
      msg.actionStatus = BellaActionStatus.confirmed;
    } catch (e) {
      debugPrint('[BellaAction] Execution failed: $e');
      msg.actionStatus = BellaActionStatus.failed;
    }
    notifyListeners();
  }

  /// Cancel a pending action.
  void cancelAction(ChatMessage msg) {
    if (msg.actionStatus != BellaActionStatus.pending) return;
    msg.actionStatus = BellaActionStatus.cancelled;
    notifyListeners();
  }

  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    messages.add(ChatMessage(
      role: ChatRole.user,
      text: trimmed,
      timestamp: DateTime.now(),
    ));

    // Snapshot history before adding the assistant placeholder.
    final historySnapshot = List<ChatMessage>.of(messages);

    // Add empty assistant message that will be filled progressively.
    final assistantMsg = ChatMessage(
      role: ChatRole.assistant,
      text: '',
      timestamp: DateTime.now(),
    );
    messages.add(assistantMsg);
    _isTyping = true;
    notifyListeners();

    try {
      if (ConnectivityService.instance.isOnline.value) {
        dynamicSuggestions = [];
        await for (final event
            in _service.askStream(trimmed, historySnapshot)) {
          switch (event) {
            case BellaTextChunk(:final accumulated):
              assistantMsg.text = accumulated;
              notifyListeners();
            case BellaActionEvent(:final action):
              if (isPro) {
                assistantMsg.pendingAction = action;
                assistantMsg.actionStatus = BellaActionStatus.pending;
                notifyListeners();
              } else {
                // Free user got an action → trigger paywall.
                assistantMsg.showProUpsell = true;
                notifyListeners();
              }
            case BellaSuggestionsEvent(:final suggestions):
              dynamicSuggestions = suggestions;
              notifyListeners();
            case BellaProUpsellEvent():
              assistantMsg.showProUpsell = true;
              notifyListeners();
          }
        }
      } else {
        assistantMsg.text = _service.askOffline(trimmed, role: _role.name);
      }
      _isTyping = false;
    } catch (_) {
      _isTyping = false;
      if (assistantMsg.text.isEmpty) {
        assistantMsg.text =
            'Es ist ein Fehler aufgetreten. Bitte versuche es erneut.';
      }
    }
    notifyListeners();

    // Persist user + assistant messages to Firestore (fire-and-forget).
    _persistMessage('user', trimmed, DateTime.now());
    if (assistantMsg.text.isNotEmpty) {
      _persistMessage('assistant', assistantMsg.text, DateTime.now());
    }
  }

  void _persistMessage(String role, String text, DateTime ts) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final col = FirebaseFirestore.instance
        .collection(FirestorePaths.bellaChatCollection(uid));
    unawaited(col.add({
      'role': role,
      'text': text,
      'createdAt': ts.toUtc().toIso8601String(),
    }));
  }
}
