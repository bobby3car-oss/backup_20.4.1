import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../sync/connectivity_service.dart';
import '../../../ui/ui.dart';
import 'bella_overlay_controller.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/suggestion_chips.dart';

/// Floating chat overlay for Bella AI.
///
/// Slides up from the bottom-right when opened; covers ~85 % of the
/// screen height with a glass-morphism card.
class BellaChatOverlay extends StatefulWidget {
  const BellaChatOverlay({super.key, required this.controller});

  final BellaOverlayController controller;

  @override
  State<BellaChatOverlay> createState() => _BellaChatOverlayState();
}

class _BellaChatOverlayState extends State<BellaChatOverlay> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
    _scrollToBottom();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onStateChanged);
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _send(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    HapticFeedback.lightImpact();
    _textController.clear();
    widget.controller.send(trimmed);
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

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final messages = widget.controller.messages;
    final isTyping = widget.controller.isTyping;
    final bottomInset = mq.viewInsets.bottom; // keyboard height

    return Positioned.fill(
      child: Stack(
        children: [
          // Scrim
          GestureDetector(
            onTap: widget.controller.close,
            child: Container(color: Colors.black54),
          ),

          // Chat card
          Positioned(
            left: AppSpacing.md,
            right: AppSpacing.md,
            top: mq.padding.top + AppSpacing.xl,
            bottom: bottomInset > 0
                ? bottomInset + AppSpacing.xs
                : mq.padding.bottom + AppSpacing.xl,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 32,
                    offset: const Offset(0, 8),
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Column(
                  children: [
                    _Header(onClose: widget.controller.close),
                    Expanded(
                      child: messages.isEmpty
                          ? _EmptyState(onSuggestion: _send)
                          : _MessageList(
                              messages: messages,
                              isTyping: isTyping,
                              scrollController: _scrollController,
                            ),
                    ),
                    if (messages.isNotEmpty && messages.length <= 4)
                      Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: SuggestionChips(onSelected: _send),
                      ),
                    _InputBar(
                      controller: _textController,
                      focusNode: _focusNode,
                      onSend: () => _send(_textController.text),
                      onSubmitted: (t) {
                        _send(t);
                        _focusNode.requestFocus();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF0F5), Color(0xFFFCE4EC)],
        ),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFFF6B9D).withValues(alpha: 0.15),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Bella avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6B9D).withValues(alpha: 0.20),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/bella_avatar.png',
                width: 36,
                height: 36,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

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
                      ? 'Dein OP-Wissenshelfer 🐰'
                      : 'Offline • Eingeschränkter Modus',
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

          // Close button
          PressableScale(
            onTap: () {
              Haptic.light();
              onClose();
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 18,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Message list ─────────────────────────────────────────────────────

class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.messages,
    required this.isTyping,
    required this.scrollController,
  });

  final List messages;
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

// ─── Empty state ──────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onSuggestion});
  final ValueChanged<String> onSuggestion;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: adaptiveScrollPhysics,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: AppSpacing.xxxl),

          Text(
            'Hallo! Ich bin Bella AI 🐰',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),

          Text(
            'Ich helfe dir bei Fragen rund um deine '
            'Operation, Nachsorge und die App.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Feature pills
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            alignment: WrapAlignment.center,
            children: const [
              _FeaturePill(emoji: '🏥', label: 'OP-Wissen'),
              _FeaturePill(emoji: '📱', label: 'App-Hilfe'),
              _FeaturePill(emoji: '🩹', label: 'Nachsorge'),
              _FeaturePill(emoji: '🚨', label: 'Warnzeichen'),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),

          SuggestionChips(onSelected: onSuggestion),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

// ─── Feature pill ─────────────────────────────────────────────────────

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({required this.emoji, required this.label});
  final String emoji;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: AppRadius.borderRadiusPill,
        border: Border.all(
          color: Colors.grey.shade200,
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Input bar ────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.focusNode,
    required this.onSend,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade200,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: AppRadius.borderRadiusPill,
                    border: Border.all(
                      color: Colors.grey.shade200,
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
                      hintText: 'Frage an Bella …',
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
              PressableScale(
                onTap: onSend,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFF6B9D), Color(0xFFC44EBB)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            const Color(0xFFFF6B9D).withValues(alpha: 0.30),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_upward_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Keine medizinische Beratung – bei Beschwerden Arzt kontaktieren.',
            style: TextStyle(
              fontSize: 9,
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
