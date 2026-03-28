import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../sync/connectivity_service.dart';
import '../../../ui/ui.dart';
import '../domain/assistant_service.dart';
import '../domain/chat_message.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/suggestion_chips.dart';
import '../../../ui/theme/app_icons.dart';
import '../../../l10n/app_localizations.dart';

/// Gemini-powered AI assistant chat screen — Bella AI.
/// Falls back to offline keyword engine when there is no connection.
class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final _service = AssistantService();
  final _messages = <ChatMessage>[];
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _send(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    HapticFeedback.lightImpact();

    setState(() {
      _messages.add(ChatMessage(
        role: ChatRole.user,
        text: trimmed,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });

    _controller.clear();
    _scrollToBottom();

    _askAssistant(trimmed);
  }

  Future<void> _askAssistant(String text) async {
    final l = AppLocalizations.of(context)!;
    try {
      if (ConnectivityService.instance.isOnline.value) {
        String lastText = '';
        await for (final event
            in _service.askStream(text, _messages)) {
          if (!mounted) return;
          if (event is BellaTextChunk) {
            lastText = event.accumulated;
          }
        }
        if (!mounted) return;
        setState(() {
          _isTyping = false;
          _messages.add(ChatMessage(
            role: ChatRole.assistant,
            text: lastText.isNotEmpty
                ? lastText
                : l.bellaNoAnswerReceived,
            timestamp: DateTime.now(),
          ));
        });
      } else {
        if (!mounted) return;
        setState(() {
          _isTyping = false;
          _messages.add(ChatMessage(
            role: ChatRole.assistant,
            text: _service.askOffline(text),
            timestamp: DateTime.now(),
          ));
        });
      }
      _scrollToBottom();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(
          role: ChatRole.assistant,
          text: l.esIstEinFehlerAufgetretenBitteVersucheEsErneut,
          timestamp: DateTime.now(),
        ));
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: MotionDuration.medium,
          curve: MotionCurve.standard,
        );
      }
    });
  }

  void _onSubmitted(String text) {
    _send(text);
    // Refocus for quick follow-up questions.
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────
            _AssistantHeader(topPadding: topPadding),

            // ── Chat content ────────────────────────────────────
            Expanded(
              child: _messages.isEmpty
                  ? _EmptyState(onSuggestion: _send)
                  : _ChatList(
                      messages: _messages,
                      isTyping: _isTyping,
                      scrollController: _scrollController,
                    ),
            ),

            // ── Suggestion chips (visible with few messages) ────
            if (_messages.isNotEmpty && _messages.length <= 4)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: SuggestionChips(onSelected: _send),
              ),

            // ── Input bar ───────────────────────────────────────
            _InputBar(
              controller: _controller,
              focusNode: _focusNode,
              bottomPadding: bottomPadding,
              onSend: () => _send(_controller.text),
              onSubmitted: _onSubmitted,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// _AssistantHeader — Frosted glass header with animated gradient
// ═══════════════════════════════════════════════════════════════════════

class _AssistantHeader extends StatelessWidget {
  const _AssistantHeader({required this.topPadding});
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return GlassContainer(
      variant: GlassVariant.thick,
      elevation: GlassElevation.medium,
      borderRadius: BorderRadius.zero,
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: topPadding + AppSpacing.sm,
        bottom: AppSpacing.md,
      ),
      child: Row(
        children: [
          // Back button
          PressableScale(
            onTap: () {
              Haptic.light();
              Navigator.of(context).pop();
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // AI Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF5856D6), Color(0xFF007AFF)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.30),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: GlassIcon(icon: CupertinoIcons.hare, color: AppColors.primary, size: 14),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Bella AI',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                Text(
                  ConnectivityService.instance.isOnline.value
                      ? l.bellaSubtitlePatient
                      : l.offlineEingeschraenkterModus,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary.withValues(alpha: 0.8),
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),

          // Pro badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF5856D6), Color(0xFF007AFF)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '🐰 AI',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// _ChatList — Animated scrolling message list
// ═══════════════════════════════════════════════════════════════════════

class _ChatList extends StatelessWidget {
  const _ChatList({
    required this.messages,
    required this.isTyping,
    required this.scrollController,
  });

  final List<ChatMessage> messages;
  final bool isTyping;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      physics: adaptiveScrollPhysics,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      itemCount: messages.length + (isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length && isTyping) {
          return const TypingIndicator();
        }
        final isLast = index >= messages.length - 2;
        return ChatBubble(
          message: messages[index],
          animate: isLast,
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// _EmptyState — Welcome screen with gradient accents
// ═══════════════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onSuggestion});
  final ValueChanged<String> onSuggestion;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      physics: adaptiveScrollPhysics,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: AppSpacing.huge),

          // Large avatar
          FadeSlideIn(
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF5856D6), Color(0xFF007AFF), Color(0xFF5AC8FA)],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                    spreadRadius: -4,
                  ),
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 48,
                    offset: const Offset(0, 16),
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: const Center(
                child: GlassIcon(icon: CupertinoIcons.hare, color: AppColors.primary, size: 29),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Welcome text
          FadeSlideIn(
            delay: const Duration(milliseconds: 100),
            child: Text(
              l.bellaGreeting,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          FadeSlideIn(
            delay: const Duration(milliseconds: 200),
            child: Text(
              l.bellaDescriptionPatient,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),

          // Feature cards
          FadeSlideIn(
            delay: const Duration(milliseconds: 300),
            child: Row(
              children: [
                Expanded(
                  child: _FeatureCard(
                    icon: AppIcons.hospital,
                    iconColor: AppIcons.hospitalColor,
                    title: l.bellaFeatureMedicalKnowledge,
                    subtitle: l.ablaufNarkoseEingriffe,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _FeatureCard(
                    icon: CupertinoIcons.device_phone_portrait, iconColor: AppColors.primary,
                    title: l.bellaFeatureAppHelp,
                    subtitle: l.funktionenErklaert,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          FadeSlideIn(
            delay: const Duration(milliseconds: 400),
            child: Row(
              children: [
                Expanded(
                  child: _FeatureCard(
                    icon: AppIcons.wound,
                    iconColor: AppIcons.woundColor,
                    title: l.onboardingSlide3Title,
                    subtitle: l.wundeSchmerzBewegung,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _FeatureCard(
                    icon: AppIcons.redFlags,
                    iconColor: AppIcons.redFlagsColor,
                    title: l.bellaFeatureWarnings,
                    subtitle: l.wannZumArzt,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),

          // Chips
          FadeSlideIn(
            delay: const Duration(milliseconds: 500),
            child: Column(
              children: [
                Text(
                  l.bellaAskDirectly,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SuggestionChips(onSelected: onSuggestion),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.huge),
        ],
      ),
    );
  }
}

// ── Feature card for empty state ──────────────────────────────────────

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;


  final Color iconColor;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      variant: GlassVariant.medium,
      elevation: GlassElevation.low,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: GlassIcon(icon: icon, color: iconColor, size: 18),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// _InputBar — Glass input bar with send button
// ═══════════════════════════════════════════════════════════════════════

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.focusNode,
    required this.bottomPadding,
    required this.onSend,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final double bottomPadding;
  final VoidCallback onSend;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return GlassContainer(
      variant: GlassVariant.thick,
      elevation: GlassElevation.high,
      borderRadius: BorderRadius.zero,
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.sm,
        bottom: bottomPadding + AppSpacing.sm,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.35),
                    borderRadius: AppRadius.borderRadiusPill,
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                  ),
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    onSubmitted: onSubmitted,
                    textInputAction: TextInputAction.send,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.1,
                    ),
                    decoration: InputDecoration(
                      hintText: l.frageStellen,
                      hintStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: AppColors.grey400,
                      ),
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _SendButton(onPressed: onSend),
            ],
          ),
          const SizedBox(height: AppSpacing.xs + 2),
          Text(
            l.bellaDisclaimer,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.grey500.withValues(alpha: 0.7),
              letterSpacing: -0.1,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Send button with gradient ─────────────────────────────────────────

class _SendButton extends StatelessWidget {
  const _SendButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onPressed,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF5856D6), Color(0xFF007AFF)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: -2,
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_upward_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}

