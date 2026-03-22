import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:share_plus/share_plus.dart';

import '../../../domain/task_orchestrator_sync.dart';
import '../../../main.dart';
import '../../../ui/ui.dart';
import '../../../ui/theme/app_icons.dart';
import '../../pro/domain/trigger_context.dart';
import '../../pro/presentation/smart_paywall.dart';
import '../domain/patient_context.dart';

/// Free-text AI briefing that helps the patient prepare for the next
/// doctor appointment. Uses [PatientContext.gather] as data source and
/// sends it to the Cloud Function with `"mode": "arztBriefing"`.
class BellaBriefingScreen extends StatefulWidget {
  const BellaBriefingScreen({super.key});

  @override
  State<BellaBriefingScreen> createState() => _BellaBriefingScreenState();
}

class _BellaBriefingScreenState extends State<BellaBriefingScreen> {
  String _briefingText = '';
  bool _loading = false;
  String? _error;

  // ── TTS ──────────────────────────────────────────────
  FlutterTts? _tts;
  bool _isSpeaking = false;

  bool get _isPro =>
      ProServices.maybeOf(context)?.entitlementService.isPro ?? false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isPro) {
        SmartPaywall.trigger(
          context: context,
          triggerContext: TriggerContext.bellaBriefing,
        );
        return;
      }
      _generateBriefing();
    });
  }

  Future<void> _generateBriefing() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _error = 'Bitte melde dich an.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _briefingText = '';
    });

    Map<String, dynamic>? contextJson;
    try {
      final ctx = await PatientContext.gather(
        TaskOrchestratorSync.instance.orchestrator,
      );
      contextJson = ctx.toJson();
    } catch (_) {
      // Context gathering is best-effort.
    }

    final token = await user.getIdToken();
    const url = 'https://askassistantstream-unsezhozna-uc.a.run.app';

    final bodyMap = <String, dynamic>{
      'message': 'Erstelle ein Arzt-Briefing für meinen nächsten Termin.',
      'history': <Map<String, String>>[],
      'mode': 'arztBriefing',
    };
    if (contextJson != null && contextJson.isNotEmpty) {
      bodyMap['context'] = contextJson;
    }

    if (kIsWeb) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Arzt-Briefing ist auf Web nicht verfügbar.';
      });
      return;
    }

    final client = HttpClient();
    try {
      final request = await client.postUrl(Uri.parse(url));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.contentType = ContentType.json;
      request.add(utf8.encode(jsonEncode(bodyMap)));

      final response = await request.close();

      if (response.statusCode != 200) {
        await response.drain<void>();
        if (!mounted) return;
        setState(() {
          _loading = false;
          _error = 'Fehler beim Erstellen des Briefings '
              '(HTTP ${response.statusCode}).';
        });
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
          if (payload == '[DONE]') break;
          try {
            final parsed = jsonDecode(payload) as Map<String, dynamic>;
            if (parsed.containsKey('error')) {
              if (!mounted) return;
              setState(() {
                _loading = false;
                _error = parsed['error'] as String? ??
                    'KI-Fehler. Bitte versuche es erneut.';
              });
              return;
            }
            final delta = parsed['t'] as String?;
            if (delta != null) {
              accumulated += delta;
              if (mounted) setState(() => _briefingText = accumulated);
            }
          } catch (_) {
            // Ignore malformed SSE lines.
          }
        }
      }

      if (mounted) setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Verbindungsfehler. Bitte prüfe deine Internetverbindung.';
      });
      debugPrint('[BellaBriefing] Error: $e');
    } finally {
      client.close();
    }
  }

  void _shareBriefing() {
    if (_briefingText.isEmpty) return;
    HapticFeedback.lightImpact();
    SharePlus.instance.share(
      ShareParams(
        text: _briefingText,
        subject: 'Bella Arzt-Briefing',
      ),
    );
  }

  void _copyBriefing() {
    if (_briefingText.isEmpty) return;
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: _briefingText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Briefing in die Zwischenablage kopiert'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // ── TTS methods ──────────────────────────────────────

  Future<FlutterTts> _ensureTts() async {
    if (_tts != null) return _tts!;
    final tts = FlutterTts();
    await tts.setLanguage('de-DE');
    await tts.setSpeechRate(0.45);
    await tts.setPitch(1.0);
    tts.setCompletionHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
    tts.setCancelHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
    _tts = tts;
    return tts;
  }

  Future<void> _toggleTts() async {
    if (_briefingText.isEmpty) return;
    HapticFeedback.lightImpact();
    final tts = await _ensureTts();
    if (!mounted) return;
    if (_isSpeaking) {
      await tts.stop();
      if (!mounted) return;
      setState(() => _isSpeaking = false);
    } else {
      setState(() => _isSpeaking = true);
      await tts.speak(_briefingText);
    }
  }

  @override
  void dispose() {
    _tts?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          PressableScale(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                CupertinoIcons.back,
                size: 20,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bella Arzt-Briefing',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Vorbereitung für deinen nächsten Termin',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary.withValues(alpha: 0.8),
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),
          if (_briefingText.isNotEmpty) ...[
            PressableScale(
              onTap: _toggleTts,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _isSpeaking
                      ? const Color(0xFFFF6B9D).withValues(alpha: 0.15)
                      : Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _isSpeaking
                      ? CupertinoIcons.stop_fill
                      : CupertinoIcons.speaker_2_fill,
                  size: 18,
                  color: _isSpeaking
                      ? const Color(0xFFFF6B9D)
                      : AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            PressableScale(
              onTap: _copyBriefing,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  CupertinoIcons.doc_on_clipboard,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            PressableScale(
              onTap: _shareBriefing,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  CupertinoIcons.share,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (!_isPro) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                AppIcons.doctor,
                size: 48,
                color: AppIcons.doctorColor.withValues(alpha: 0.6),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Arzt-Briefing ist ein Pro-Feature',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Mit Pro erstellt Bella eine persönliche Zusammenfassung '
                'für deinen nächsten Arzttermin.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton(
                onPressed: () => SmartPaywall.trigger(
                  context: context,
                  triggerContext: TriggerContext.bellaBriefing,
                ),
                child: const Text('Pro freischalten'),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                CupertinoIcons.exclamationmark_triangle,
                size: 48,
                color: AppColors.warning,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                _error!,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton(
                onPressed: _generateBriefing,
                child: const Text('Erneut versuchen'),
              ),
            ],
          ),
        ),
      );
    }

    if (_loading && _briefingText.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CupertinoActivityIndicator(radius: 16),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Bella erstellt dein Arzt-Briefing …',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      physics: adaptiveScrollPhysics,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassContainer(
            padding: const EdgeInsets.all(AppSpacing.xl),
            borderRadius: AppRadius.borderRadiusXl,
            variant: GlassVariant.thick,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E5F5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text('🐰', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        'Dein persönliches Arzt-Briefing',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.3,
                                ),
                      ),
                    ),
                    if (_loading)
                      const CupertinoActivityIndicator(radius: 8),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                SelectableText(
                  _briefingText,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.7,
                        letterSpacing: -0.1,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (!_loading)
            Center(
              child: TextButton.icon(
                onPressed: _generateBriefing,
                icon: const Icon(CupertinoIcons.refresh, size: 16),
                label: const Text('Neu generieren'),
              ),
            ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}
