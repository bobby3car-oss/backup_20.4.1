import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../auth/user_profile_service.dart';
import '../../../domain/task_orchestrator_sync.dart';
import 'assistant_engine.dart';
import 'bella_action.dart';
import 'chat_message.dart';
import 'patient_context.dart';
import 'wound_analysis_result.dart';

/// Events emitted by [AssistantService.askStream].
sealed class BellaStreamEvent {
  const BellaStreamEvent();
}

/// A text chunk with the accumulated response so far.
class BellaTextChunk extends BellaStreamEvent {
  const BellaTextChunk(this.accumulated);
  final String accumulated;
}

/// An action proposed by Bella (for Pro users).
class BellaActionEvent extends BellaStreamEvent {
  const BellaActionEvent(this.action);
  final BellaAction action;
}

/// Dynamic suggestion chips from the server.
class BellaSuggestionsEvent extends BellaStreamEvent {
  const BellaSuggestionsEvent(this.suggestions);
  final List<String> suggestions;
}

/// The AI indicated this response relates to a Pro feature.
class BellaProUpsellEvent extends BellaStreamEvent {
  const BellaProUpsellEvent();
}

/// Usage info: how many messages used today vs. limit.
class BellaUsageEvent extends BellaStreamEvent {
  const BellaUsageEvent({required this.used, required this.limit});
  final int used;
  final int limit;
}

/// Wound analysis result from the AI.
class BellaWoundAnalysisEvent extends BellaStreamEvent {
  const BellaWoundAnalysisEvent(this.result);
  final WoundAnalysisResult result;
}

/// Triage assessment result from the symptom-check mode.
class BellaTriageAssessmentEvent extends BellaStreamEvent {
  const BellaTriageAssessmentEvent(this.assessment);
  final Map<String, dynamic> assessment;
}

/// Service that calls the NVIDIA-powered Cloud Function for AI responses,
/// with offline fallback to the local keyword engine.
class AssistantService {
  AssistantService();

  final _engine = AssistantEngine();

  /// Streaming endpoint URL (set after first deploy).
  String? _streamUrl;

  Future<String> _getStreamUrl() async {
    if (_streamUrl != null) return _streamUrl!;
    _streamUrl = 'https://askassistantstream-unsezhozna-uc.a.run.app';
    return _streamUrl!;
  }

  /// Offline keyword-based answer.
  String askOffline(String message, {String role = 'patient'}) =>
      _engine.query(message, role: role);

  /// Stream AI answer chunks & actions. Yields [BellaStreamEvent]s.
  ///
  /// When [imageUrls] is provided, the request includes image URLs for
  /// multimodal wound analysis on the backend.
  Stream<BellaStreamEvent> askStream(
    String message,
    List<ChatMessage> history, {
    List<String>? imageUrls,
    String? mode,
  }) async* {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      yield const BellaTextChunk(
        'Bitte melde dich an, um den Assistenten zu nutzen.',
      );
      return;
    }

    final token = await user.getIdToken();
    final url = await _getStreamUrl();

    final historyData = history
        .map(
          (m) => {
            'role': m.role == ChatRole.user ? 'user' : 'assistant',
            'text': m.text,
          },
        )
        .toList();

    // Gather patient context from local data for personalized answers.
    Map<String, dynamic>? contextJson;
    try {
      final ctx = await PatientContext.gather(
        TaskOrchestratorSync.instance.orchestrator,
      );
      contextJson = ctx.toJson();
    } catch (_) {
      // Context gathering is best-effort.
    }

    // Include user role so the Cloud Function can tailor the system prompt.
    String userRole = 'patient';
    try {
      final role = await UserProfileService().getMyRole();
      userRole = role.name;
    } catch (_) {
      // Best-effort – default to patient.
    }

    final bodyMap = <String, dynamic>{
      'message': message,
      'history': historyData,
      'userRole': userRole,
      'locale': PlatformDispatcher.instance.locale.languageCode,
    };
    if (contextJson != null && contextJson.isNotEmpty) {
      bodyMap['context'] = contextJson;
    }
    if (imageUrls != null && imageUrls.isNotEmpty) {
      bodyMap['imageUrl'] = imageUrls.first;
      if (imageUrls.length > 1) {
        bodyMap['imageUrls'] = imageUrls;
      }
      bodyMap['analysisMode'] = 'wound';
    }
    if (mode != null) {
      bodyMap['mode'] = mode;
    }
    final body = jsonEncode(bodyMap);

    // dart:io HttpClient is not available on web.
    if (kIsWeb) {
      yield BellaTextChunk(askOffline(message));
      return;
    }

    final client = HttpClient();
    try {
      final request = await client.postUrl(Uri.parse(url));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.contentType = ContentType.json;
      request.add(utf8.encode(body));

      final response = await request.close();

      if (response.statusCode != 200) {
        await response.drain<void>();
        debugPrint('[Bella] Stream HTTP ${response.statusCode}');
        if (response.statusCode == 429) {
          yield const BellaTextChunk(
            'Zu viele Anfragen. Bitte warte einen Moment.',
          );
        } else if (response.statusCode == 401) {
          yield const BellaTextChunk(
            'Bitte melde dich an, um den Assistenten zu nutzen.',
          );
        } else {
          yield const BellaTextChunk(
            'Es gab ein Problem mit der KI. Bitte versuche es erneut. 🐰',
          );
        }
        return;
      }

      String accumulated = '';
      String buffer = '';

      await for (final chunk in response.transform(utf8.decoder)) {
        buffer += chunk;
        final lines = buffer.split('\n');
        buffer = lines.removeLast();

        for (final line in lines) {
          final trimmed = line.trim();
          if (!trimmed.startsWith('data: ')) continue;
          final payload = trimmed.substring(6);
          if (payload == '[DONE]') return;
          try {
            final parsed = jsonDecode(payload) as Map<String, dynamic>;
            if (parsed.containsKey('error')) {
              yield BellaTextChunk(
                parsed['error'] as String? ??
                    'KI-Fehler. Bitte versuche es erneut.',
              );
              return;
            }
            // Wound analysis result from backend.
            if (parsed.containsKey('woundAnalysis')) {
              final map = parsed['woundAnalysis'] as Map<String, dynamic>;
              yield BellaWoundAnalysisEvent(
                WoundAnalysisResult.fromJson(map),
              );
              continue;
            }
            // Triage assessment result from symptom-check mode.
            if (parsed.containsKey('triageAssessment')) {
              final map = parsed['triageAssessment'] as Map<String, dynamic>;
              yield BellaTriageAssessmentEvent(map);
              continue;
            }
            // Action event from backend.
            if (parsed.containsKey('action')) {
              final actionMap = parsed['action'] as Map<String, dynamic>;
              yield BellaActionEvent(BellaAction.fromJson(actionMap));
              continue;
            }
            // Pro upsell event from backend.
            if (parsed.containsKey('proUpsell')) {
              yield const BellaProUpsellEvent();
              continue;
            }
            // Dynamic suggestions from backend.
            if (parsed.containsKey('suggestions')) {
              final list = (parsed['suggestions'] as List)
                  .whereType<String>()
                  .toList();
              if (list.isNotEmpty) {
                yield BellaSuggestionsEvent(list);
              }
              continue;
            }
            // Usage info from backend.
            if (parsed.containsKey('usage')) {
              final u = parsed['usage'] as Map<String, dynamic>;
              final used = u['used'] as int? ?? 0;
              final limit = u['limit'] as int? ?? 15;
              yield BellaUsageEvent(used: used, limit: limit);
              continue;
            }
            final delta = parsed['t'] as String?;
            if (delta != null) {
              accumulated += delta;
              yield BellaTextChunk(accumulated);
            }
          } catch (_) {}
        }
      }

      if (accumulated.isEmpty) {
        yield const BellaTextChunk(
          'Keine Antwort erhalten. Bitte versuche es erneut. 🐰',
        );
      }
    } catch (e) {
      debugPrint('[Bella] Stream request failed: ${e.runtimeType}');
      yield const BellaTextChunk(
        'Verbindungsproblem — bitte prüfe deine Internetverbindung '
        'und versuche es erneut. 🐰',
      );
    } finally {
      client.close();
    }
  }
}
