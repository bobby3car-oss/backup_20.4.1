import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../main.dart';

// ── Dark palette (matches paywall) ──────────────────────────────────

abstract final class _C {
  static const bg = Color(0xFF0A0A0F);
  static const border = Color(0x20FFFFFF);
  static const textPrimary = Color(0xFFF5F5F7);
  static const textSecondary = Color(0x99EBEBF5);
  static const accent = Color(0xFF0A84FF);
}

/// A non-aggressive bottom-sheet upsell nudge for Pro-gated features.
///
/// Call [ProUpsellSheet.show] – it checks Pro status and either triggers
/// the [onProAction] callback or presents the bottom sheet.
///
/// ```dart
/// ProUpsellSheet.show(
///   context: context,
///   emoji: '👨‍👩‍👧',
///   title: 'Angehörige einladen',
///   body: 'Mit Pro kannst du Familienmitglieder\nin deine OP Timeline einladen.',
///   cta: 'Pro freischalten',
///   onProAction: () { /* open feature */ },
/// );
/// ```
class ProUpsellSheet {
  ProUpsellSheet._();

  /// Shows the feature or the upsell sheet depending on Pro status.
  static void show({
    required BuildContext context,
    required String emoji,
    required String title,
    required String body,
    String cta = 'Pro freischalten',
    required VoidCallback onProAction,
  }) {
    final pro = ProServices.of(context);
    if (pro.entitlementService.isPro) {
      onProAction();
      return;
    }

    HapticFeedback.lightImpact();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _UpsellContent(
        emoji: emoji,
        title: title,
        body: body,
        cta: cta,
      ),
    );
  }
}

// ── Sheet content ────────────────────────────────────────────────────

class _UpsellContent extends StatefulWidget {
  const _UpsellContent({
    required this.emoji,
    required this.title,
    required this.body,
    required this.cta,
  });

  final String emoji;
  final String title;
  final String body;
  final String cta;

  @override
  State<_UpsellContent> createState() => _UpsellContentState();
}

class _UpsellContentState extends State<_UpsellContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _openPaywall() {
    Navigator.of(context).pop(); // close sheet
    Navigator.of(context).pushNamed(
      '/paywall',
      arguments: const {'source': 'upsell_sheet'},
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewPadding.bottom;

    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _fade,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
            child: Container(
              padding: EdgeInsets.fromLTRB(28, 20, 28, 16 + bottomPad),
              decoration: const BoxDecoration(
                color: _C.bg,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(28)),
                border: Border(
                  top: BorderSide(color: _C.border, width: 0.5),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Handle ────────────────────────────────
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _C.textSecondary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Emoji ─────────────────────────────────
                  Text(
                    widget.emoji,
                    style: const TextStyle(fontSize: 48),
                  ),
                  const SizedBox(height: 16),

                  // ── Title ─────────────────────────────────
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: _C.textPrimary,
                          letterSpacing: -0.3,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),

                  // ── Body ──────────────────────────────────
                  Text(
                    widget.body,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _C.textSecondary,
                          height: 1.45,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),

                  // ── CTA ───────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _openPaywall,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _C.accent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                      child: Text(widget.cta),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Dismiss ───────────────────────────────
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: _C.textSecondary,
                    ),
                    child: const Text(
                      'Nicht jetzt',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
