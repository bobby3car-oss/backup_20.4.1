import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../auth/user_profile_service.dart';
import '../../../sync/connectivity_service.dart';
import '../domain/assistant_service.dart';
import '../domain/chat_message.dart';

/// Manages global Bella AI overlay state: open/close, messages, loading.
///
/// Lives above the navigator so the chat persists across route changes.
class BellaOverlayController extends ChangeNotifier {
  BellaOverlayController();

  final _service = AssistantService();

  final messages = <ChatMessage>[];

  bool _isOpen = false;
  bool get isOpen => _isOpen;

  bool _isTyping = false;
  bool get isTyping => _isTyping;

  AppUserRole _role = AppUserRole.patient;
  AppUserRole get role => _role;
  String? _roleUid;

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
        await for (final accumulated
            in _service.askStream(trimmed, historySnapshot)) {
          assistantMsg.text = accumulated;
          notifyListeners();
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
  }
}
