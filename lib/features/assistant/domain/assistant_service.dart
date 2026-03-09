import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'assistant_engine.dart';
import 'chat_message.dart';

/// Service that calls the NVIDIA-powered Cloud Function for AI responses,
/// with offline fallback to the local keyword engine.
class AssistantService {
  AssistantService();

  final _engine = AssistantEngine();

  /// Streaming endpoint URL (set after first deploy).
  String? _streamUrl;

  Future<String> _getStreamUrl() async {
    if (_streamUrl != null) return _streamUrl!;
    // Discover the URL from the non-streaming callable, which shares the
    // same project. The v2 onRequest URL follows the Cloud Run pattern.
    // We hardcode it here — it's printed by `firebase deploy`.
    _streamUrl = 'https://askassistantstream-unsezhozna-uc.a.run.app';
    return _streamUrl!;
  }

  /// Offline keyword-based answer.
  String askOffline(String message) => _engine.query(message);

  /// Stream AI answer chunks. Yields the accumulated text so far.
  Stream<String> askStream(
    String message,
    List<ChatMessage> history,
  ) async* {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      yield 'Bitte melde dich an, um den Assistenten zu nutzen.';
      return;
    }

    final token = await user.getIdToken();
    final url = await _getStreamUrl();

    final historyData = history
        .map((m) => {
              'role': m.role == ChatRole.user ? 'user' : 'assistant',
              'text': m.text,
            })
        .toList();

    final body = jsonEncode({
      'message': message,
      'history': historyData,
    });

    final client = HttpClient();
    try {
      final request = await client.postUrl(Uri.parse(url));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.contentType = ContentType.json;
      request.add(utf8.encode(body));

      final response = await request.close();

      if (response.statusCode != 200) {
        final errBody = await response.transform(utf8.decoder).join();
        debugPrint('[Bella] Stream HTTP ${response.statusCode}: $errBody');
        if (response.statusCode == 429) {
          yield 'Zu viele Anfragen. Bitte warte einen Moment.';
        } else if (response.statusCode == 401) {
          yield 'Bitte melde dich an, um den Assistenten zu nutzen.';
        } else {
          yield 'Es gab ein Problem mit der KI. Bitte versuche es erneut. 🐰';
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
              yield parsed['error'] as String? ??
                  'KI-Fehler. Bitte versuche es erneut.';
              return;
            }
            final delta = parsed['t'] as String?;
            if (delta != null) {
              accumulated += delta;
              yield accumulated;
            }
          } catch (_) {}
        }
      }

      if (accumulated.isEmpty) {
        yield 'Keine Antwort erhalten. Bitte versuche es erneut. 🐰';
      }
    } catch (e) {
      debugPrint('[Bella] Stream-Fehler: $e');
      yield 'Verbindungsproblem — bitte prüfe deine Internetverbindung '
          'und versuche es erneut. 🐰';
    } finally {
      client.close();
    }
  }
}
