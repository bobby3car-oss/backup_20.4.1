import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../ui/ui.dart';
import '../../domain/chat_message.dart';

/// A single chat bubble with premium animations and glassmorphism.
/// User messages are right-aligned with a gradient,
/// assistant messages are left-aligned with a glass surface.
class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message, required this.animate});

  final ChatMessage message;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;

    Widget bubble = Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.80,
        ),
        margin: EdgeInsets.only(
          left: isUser ? 52 : 0,
          right: isUser ? 0 : 52,
          bottom: AppSpacing.md,
        ),
        child: isUser
            ? _UserBubble(text: message.text)
            : _AssistantBubble(text: message.text),
      ),
    );

    if (animate) {
      bubble = FadeSlideIn(
        slideOffset: isUser ? 12 : 10,
        duration: const Duration(milliseconds: 400),
        child: bubble,
      );
    }

    return bubble;
  }
}

// ── User bubble ─────────────────────────────────────────────────────

class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.text});
  final String text;

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
          colors: [Color(0xFF007AFF), Color(0xFF5AC8FA)],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(6),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.30),
            blurRadius: 16,
            offset: const Offset(0, 6),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w400,
          height: 1.45,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}

// ── Assistant bubble ────────────────────────────────────────────────

class _AssistantBubble extends StatelessWidget {
  const _AssistantBubble({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(22),
        topRight: Radius.circular(22),
        bottomLeft: Radius.circular(6),
        bottomRight: Radius.circular(22),
      ),
      variant: GlassVariant.thick,
      elevation: GlassElevation.medium,
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w400,
          height: 1.45,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}

// ── Typing indicator ────────────────────────────────────────────────

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(left: 36, bottom: AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dots
            GlassContainer(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md + 2,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
                bottomLeft: Radius.circular(6),
                bottomRight: Radius.circular(22),
              ),
              variant: GlassVariant.thick,
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (_, _) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(3, (i) {
                      final delay = i * 0.25;
                      final t = ((_ctrl.value - delay) % 1.0).clamp(0.0, 1.0);
                      final bounce = math.sin(t * math.pi);
                      return Container(
                        width: 7,
                        height: 7,
                        margin: EdgeInsets.only(
                          right: i < 2 ? 5 : 0,
                          bottom: bounce * 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.grey400.withValues(
                            alpha: 0.5 + bounce * 0.5,
                          ),
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
