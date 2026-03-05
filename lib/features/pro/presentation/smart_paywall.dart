import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../main.dart';
import '../domain/trigger_context.dart';

// ── Dark palette (consistent with paywall / upsell sheet) ────────────

abstract final class _C {
  static const bg = Color(0xFF0A0A0F);
  static const border = Color(0x20FFFFFF);
  static const textPrimary = Color(0xFFF5F5F7);
  static const textSecondary = Color(0x99EBEBF5);
  static const accent = Color(0xFF0A84FF);
}

/// Presents the right paywall surface for the given [triggerContext].
///
/// * Checks [PaywallTriggerService.shouldShowPaywall] first.
/// * Uses fullscreen [PaywallScreen] for `fullscreen` surfaces.
/// * Uses a bottom sheet for `bottomSheet` surfaces.
///
/// Returns `true` if a paywall was shown, `false` if suppressed or Pro.
class SmartPaywall {
  SmartPaywall._();

  static Future<bool> trigger({
    required BuildContext context,
    required TriggerContext triggerContext,
  }) async {
    final pro = ProServices.of(context);
    final trigger = pro.paywallTriggerService;

    // Pro users never see a paywall.
    if (pro.entitlementService.isPro) return false;

    // Let the trigger service decide.
    if (!trigger.shouldShowPaywall(triggerContext)) return false;

    final surface = triggerContext.surfaceType;
    await trigger.registerPaywallShown(triggerContext);

    switch (surface) {
      case PaywallSurfaceType.fullscreen:
        if (!context.mounted) return false;
        await Navigator.of(context).pushNamed(
          '/paywall',
          arguments: {'source': triggerContext.sourceKey},
        );
        return true;

      case PaywallSurfaceType.bottomSheet:
        if (!context.mounted) return false;
        HapticFeedback.lightImpact();
        await showModalBottomSheet<void>(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (_) => _SmartUpsellSheet(triggerContext: triggerContext),
        );
        return true;

      case PaywallSurfaceType.inlineCard:
        // Inline cards are embedded in widgets; nothing to trigger here.
        return false;
    }
  }
}

// ── Bottom-sheet upsell surface ──────────────────────────────────────

class _SmartUpsellSheet extends StatefulWidget {
  const _SmartUpsellSheet({required this.triggerContext});

  final TriggerContext triggerContext;

  @override
  State<_SmartUpsellSheet> createState() => _SmartUpsellSheetState();
}

class _SmartUpsellSheetState extends State<_SmartUpsellSheet>
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

  String get _title => switch (widget.triggerContext) {
        TriggerContext.timelineBanner =>
          'Deine Timeline kann mehr',
        TriggerContext.dashboardCard =>
          'Pro freischalten',
        _ => 'Pro freischalten',
      };

  String get _body => switch (widget.triggerContext) {
        TriggerContext.timelineBanner =>
          'Schalte Pro frei um Angehörige einzuladen '
              'und deine OP Timeline besser zu organisieren.',
        TriggerContext.dashboardCard =>
          'Angehörige einladen und deine '
              'OP Timeline besser organisieren.',
        _ =>
          'Angehörige einladen und deine '
              'OP Timeline besser organisieren.',
      };

  String get _emoji => switch (widget.triggerContext) {
        TriggerContext.timelineBanner => '📋',
        _ => '🚀',
      };

  void _openPaywall() {
    Navigator.of(context).pop();
    Navigator.of(context).pushNamed(
      '/paywall',
      arguments: {'source': widget.triggerContext.sourceKey},
    );
  }

  void _maybeLater() {
    final pro = ProServices.maybeOf(context);
    pro?.paywallTriggerService.registerPaywallDismissed(
      triggerContext: widget.triggerContext,
      maybeLater: true,
    );
    Navigator.of(context).pop();
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
                  Text(_emoji, style: const TextStyle(fontSize: 48)),
                  const SizedBox(height: 16),

                  // ── Title ─────────────────────────────────
                  Text(
                    _title,
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
                    _body,
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
                      child: const Text('Freischalten'),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Maybe later ───────────────────────────
                  TextButton(
                    onPressed: _maybeLater,
                    style: TextButton.styleFrom(
                      foregroundColor: _C.textSecondary,
                    ),
                    child: const Text(
                      'Vielleicht später',
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
