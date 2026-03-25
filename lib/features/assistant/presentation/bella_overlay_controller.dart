import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../auth/user_profile_service.dart';
import '../../../domain/task_orchestrator_sync.dart';
import '../../../firebase/firebase_paths.dart';
import '../../../sync/connectivity_service.dart';
import '../data/bella_chat_repository.dart';
import '../data/bella_consent_service.dart';
import '../domain/assistant_service.dart';
import '../domain/bella_action.dart';
import '../domain/bella_action_executor.dart';
import '../domain/bella_mode.dart';
import '../domain/chat_message.dart';
import '../domain/patient_context.dart';
import '../domain/wound_analysis_result.dart';
import '../domain/wound_analysis_upload_service.dart';

/// Manages global Bella AI overlay state: open/close, messages, loading.
///
/// Lives above the navigator so the chat persists across route changes.
class BellaOverlayController extends ChangeNotifier {
  BellaOverlayController() {
    _instance = this;
  }

  /// The most recently created controller instance (set in constructor).
  /// Used by wound/detail screens to trigger analyses without InheritedWidget plumbing.
  static BellaOverlayController? _instance;
  static BellaOverlayController? get instance => _instance;

  final _service = AssistantService();
  final _executor = const BellaActionExecutor();
  final _chatRepo = BellaChatRepository();

  final messages = <ChatMessage>[];

  /// The active Pro chat ID in Firestore (null for free users / no chat yet).
  String? _activeChatId;

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

  /// Daily usage tracking: messages used today.
  int dailyUsed = 0;

  /// Daily usage tracking: messages limit for current tier.
  int dailyLimit = 15;

  bool _historyLoaded = false;
  String? _historyUid;

  /// Whether the consent dialog should be shown before sending.
  bool needsConsent = true;

  /// Whether wound photos are currently being uploaded.
  bool isUploadingImages = false;

  /// Current Bella operating mode (normal vs. symptom-check triage).
  BellaMode bellaMode = BellaMode.normal;

  /// The latest triage assessment received from the symptom-check mode.
  Map<String, dynamic>? lastTriageAssessment;

  /// Start a symptom-check triage session (Pro-only).
  void startSymptomCheck() {
    if (!isPro) return;
    bellaMode = BellaMode.symptomCheck;
    lastTriageAssessment = null;
    // Open the chat and send an introductory user message.
    if (!_isOpen) open();
    notifyListeners();
    send('Symptom-Check starten');
  }

  /// End the symptom-check triage mode and return to normal.
  void endSymptomCheck() {
    bellaMode = BellaMode.normal;
    notifyListeners();
  }

  /// Check if the user has already consented to Bella AI data processing.
  Future<void> checkConsent() async {
    needsConsent = !(await BellaConsentService.instance.hasConsented);
    notifyListeners();
  }

  /// Records that the user has given Bella AI consent.
  Future<void> grantConsent() async {
    await BellaConsentService.instance.grantConsent();
    needsConsent = false;
    notifyListeners();
  }

  /// Completer used to await the user's in-chat consent decision.
  Completer<bool>? _consentCompleter;

  /// Injects a consent request message into the chat and waits for the
  /// user to tap "Ja" or "Nein". Returns `true` if accepted.
  Future<bool> _requestConsent() async {
    // Already waiting for consent → return existing future.
    if (_consentCompleter != null && !_consentCompleter!.isCompleted) {
      return _consentCompleter!.future;
    }

    _consentCompleter = Completer<bool>();

    messages.add(ChatMessage(
      role: ChatRole.assistant,
      text: 'Bevor ich loslegen kann, brauche ich kurz deine Einwilligung '
          'zur Datenverarbeitung. 🐰',
      timestamp: DateTime.now(),
      isConsentRequest: true,
    ));
    notifyListeners();

    return _consentCompleter!.future;
  }

  /// Called when the user taps "Ja" on the in-chat consent card.
  Future<void> acceptConsent(ChatMessage msg) async {
    msg.consentAnswer = true;
    await grantConsent();
    _consentCompleter?.complete(true);
    _consentCompleter = null;
  }

  /// Called when the user taps "Nein" on the in-chat consent card.
  void declineConsent(ChatMessage msg) {
    msg.consentAnswer = false;
    notifyListeners();
    _consentCompleter?.complete(false);
    _consentCompleter = null;
  }

  /// Clears all in-memory chat state. Called on sign-out so no data
  /// from the previous user leaks to the next session.
  void clearChat() {
    messages.clear();
    dynamicSuggestions = [];
    dailyUsed = 0;
    dailyLimit = 15;
    _isOpen = false;
    _isTyping = false;
    _historyLoaded = false;
    _historyUid = null;
    _roleUid = null;
    _role = AppUserRole.patient;
    isPro = false;
    needsConsent = true;
    bellaMode = BellaMode.normal;
    lastTriageAssessment = null;
    _activeChatId = null;
    notifyListeners();
  }

  /// Load persisted chat history from Firestore (once per UID).
  ///
  /// Pro users: loads from `users/{uid}/bellaChats/{chatId}/messages`.
  /// Free users: loads from legacy `patients/{uid}/bella_chat`.
  Future<void> loadChatHistory() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    if (_historyLoaded && uid == _historyUid) return;
    _historyLoaded = true;
    _historyUid = uid;

    // Clear any leftover messages from a previous session.
    messages.clear();

    try {
      if (isPro) {
        // Pro path: structured chat conversations.
        final chatId = await _chatRepo.getLatestChatId();
        if (chatId != null) {
          _activeChatId = chatId;
          final restored = await _chatRepo.loadMessages(chatId);
          messages.insertAll(0, restored);
        }
      } else {
        // Free path: legacy flat collection.
        final snap = await FirebaseFirestore.instance
            .collection(FirestorePaths.bellaChatCollection(uid))
            .orderBy('createdAt', descending: true)
            .limit(20)
            .get();

        if (snap.docs.isEmpty) return;

        final restored = snap.docs.reversed.map((d) {
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

        messages.insertAll(0, restored);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('[Bella] Failed to load chat history: $e');
    }
  }

  /// Start a brand-new chat conversation (Pro only).
  ///
  /// Clears the in-memory messages and creates a fresh Firestore chat doc.
  Future<void> startNewChat() async {
    if (!isPro) return;
    messages.clear();
    dynamicSuggestions = [];
    lastTriageAssessment = null;
    bellaMode = BellaMode.normal;
    _activeChatId = null;
    notifyListeners();
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
    } catch (e) {
      debugPrint('[BellaOverlay] loadRole failed: $e');
    }
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
    _injectProactiveGreeting();
  }

  /// If the chat is empty (fresh session), gather patient context
  /// and inject a personalised greeting from Bella.
  Future<void> _injectProactiveGreeting() async {
    // Only inject when there are no existing messages.
    if (messages.isNotEmpty) return;
    try {
      final ctx = await PatientContext.gather(
        TaskOrchestratorSync.instance.orchestrator,
      );
      final greeting = ctx.proactiveGreeting();
      if (greeting != null && messages.isEmpty) {
        messages.add(ChatMessage(
          role: ChatRole.assistant,
          text: greeting,
          timestamp: DateTime.now(),
        ));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[Bella] Proactive greeting failed: $e');
    }
  }

  /// Opens Bella with a prepared health-trend analysis message.
  ///
  /// Called when the user taps a Bella trend push notification.
  /// The trend observation is injected as an assistant message and
  /// a follow-up analysis request is sent automatically.
  void openWithTrendAnalysis(String trendMessage) {
    if (!isPro) return;

    // Show the trend observation as a Bella message.
    messages.add(ChatMessage(
      role: ChatRole.assistant,
      text: trendMessage,
      timestamp: DateTime.now(),
    ));
    _isOpen = true;
    notifyListeners();

    // Auto-send a follow-up request so Bella elaborates on the trend.
    send('Bitte analysiere diesen Trend genauer und gib mir Empfehlungen.');
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

    // Ensure DSGVO consent before sending data.
    if (needsConsent) {
      if (!_isOpen) open();
      final consented = await _requestConsent();
      if (!consented) return;
    }

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
            in _service.askStream(
              trimmed,
              historySnapshot,
              mode: bellaMode == BellaMode.symptomCheck
                  ? 'symptomCheck'
                  : null,
            )) {
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
            case BellaUsageEvent(:final used, :final limit):
              dailyUsed = used;
              dailyLimit = limit;
              notifyListeners();
            case BellaProUpsellEvent():
              if (!isPro) {
                assistantMsg.showProUpsell = true;
                notifyListeners();
              }
            case BellaWoundAnalysisEvent(:final result):
              assistantMsg.woundAnalysis = result;
              notifyListeners();
            case BellaTriageAssessmentEvent(:final assessment):
              lastTriageAssessment = assessment;
              // End triage mode automatically after assessment.
              bellaMode = BellaMode.normal;
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

  /// Ensures a Pro chat document exists, creating one lazily if needed.
  Future<String> _ensureProChat() async {
    if (_activeChatId != null) return _activeChatId!;
    _activeChatId = await _chatRepo.createChat();
    return _activeChatId!;
  }

  void _persistMessage(
    String role,
    String text,
    DateTime ts, {
    WoundAnalysisResult? woundAnalysis,
  }) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    if (isPro) {
      // Pro path: persist into structured chat conversation.
      unawaited(_ensureProChat().then((chatId) {
        return _chatRepo.addMessage(
          chatId,
          role: role,
          text: text,
          timestamp: ts,
          woundAnalysis: woundAnalysis,
        );
      }).catchError((Object e) {
        debugPrint('[Bella] Failed to persist Pro message: $e');
      }));
    } else {
      // Free path: legacy flat collection.
      final col = FirebaseFirestore.instance
          .collection(FirestorePaths.bellaChatCollection(uid));
      final data = <String, dynamic>{
        'role': role,
        'text': text,
        'createdAt': ts.toUtc().toIso8601String(),
      };
      if (woundAnalysis != null) {
        data['woundAnalysis'] = woundAnalysis.toJson();
      }
      unawaited(col.add(data).then<void>((_) {}).catchError((Object e) {
        debugPrint('[Bella] Failed to persist message: $e');
      }));
    }
  }

  /// Send a message with wound images for AI analysis.
  ///
  /// Uploads images to Firebase Storage, then streams the analysis.
  /// [localImagePaths] should contain the current wound photo first,
  /// followed by up to 3 previous wound photos for comparison.
  Future<void> sendWithImages(
    String text,
    List<String> localImagePaths,
  ) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty && localImagePaths.isEmpty) return;

    // Ensure DSGVO consent before uploading data.
    if (needsConsent) {
      if (!_isOpen) open();
      final consented = await _requestConsent();
      if (!consented) return;
    }

    // Show user message with attached images.
    messages.add(ChatMessage(
      role: ChatRole.user,
      text: trimmed.isNotEmpty ? trimmed : 'Wunde analysieren 🩹',
      timestamp: DateTime.now(),
      attachedImagePaths: localImagePaths,
    ));

    final historySnapshot = List<ChatMessage>.of(messages);

    final assistantMsg = ChatMessage(
      role: ChatRole.assistant,
      text: '',
      timestamp: DateTime.now(),
    );
    messages.add(assistantMsg);
    _isTyping = true;
    isUploadingImages = true;
    notifyListeners();

    List<String> uploadedUrls = [];
    try {
      // Upload wound photos to temporary storage.
      uploadedUrls = await WoundAnalysisUploadService.instance
          .uploadPhotos(localImagePaths);

      isUploadingImages = false;
      notifyListeners();

      if (uploadedUrls.isEmpty) {
        assistantMsg.text =
            'Leider konnte kein Foto hochgeladen werden. '
            'Bitte versuche es erneut. 🐰';
        _isTyping = false;
        notifyListeners();
        return;
      }

      // Stream the wound analysis.
      dynamicSuggestions = [];
      await for (final event in _service.askStream(
        trimmed.isNotEmpty ? trimmed : 'Analysiere meine Wundfotos.',
        historySnapshot,
        imageUrls: uploadedUrls,
      )) {
        switch (event) {
          case BellaTextChunk(:final accumulated):
            assistantMsg.text = accumulated;
            notifyListeners();
          case BellaWoundAnalysisEvent(:final result):
            assistantMsg.woundAnalysis = result;
            notifyListeners();
          case BellaActionEvent(:final action):
            if (isPro) {
              assistantMsg.pendingAction = action;
              assistantMsg.actionStatus = BellaActionStatus.pending;
              notifyListeners();
            }
          case BellaSuggestionsEvent(:final suggestions):
            dynamicSuggestions = suggestions;
            notifyListeners();
          case BellaUsageEvent(:final used, :final limit):
            dailyUsed = used;
            dailyLimit = limit;
            notifyListeners();
          case BellaProUpsellEvent():
            break;
          case BellaTriageAssessmentEvent():
            break;
        }
      }
      _isTyping = false;
    } catch (e) {
      debugPrint('[Bella] Wound analysis failed: $e');
      isUploadingImages = false;
      _isTyping = false;
      if (assistantMsg.text.isEmpty) {
        assistantMsg.text =
            'Die Wundanalyse konnte nicht durchgeführt werden. '
            'Bitte versuche es erneut. 🐰';
      }
    }
    notifyListeners();

    // Persist messages (including wound analysis JSON for history restoration).
    _persistMessage(
      'user',
      trimmed.isNotEmpty ? trimmed : 'Wunde analysieren \u{1F9B9}',
      DateTime.now(),
    );
    if (assistantMsg.text.isNotEmpty || assistantMsg.woundAnalysis != null) {
      _persistMessage(
        'assistant',
        assistantMsg.text,
        DateTime.now(),
        woundAnalysis: assistantMsg.woundAnalysis,
      );
    }

    // Clean up temporary uploads (fire-and-forget).
    if (uploadedUrls.isNotEmpty) {
      unawaited(WoundAnalysisUploadService.instance
          .deletePhotos(uploadedUrls)
          .catchError((Object e) {
        debugPrint('[Bella] Cleanup failed: $e');
      }));
    }
  }
}
