import 'package:flutter/material.dart';

import '../../../main.dart';
import '../../../ui/motion/motion.dart';
import '../../../ui/theme/radius.dart';
import '../../../ui/theme/spacing.dart';
import '../domain/trigger_context.dart';
import 'smart_paywall.dart';
import 'package:operationsbegleiter_v3/ui/components/glass_icon.dart';
import 'package:operationsbegleiter_v3/ui/theme/app_icons.dart';

/// A small, always-visible floating badge that hovers at the bottom-right
/// of the screen. Only shown for free users. Tapping opens the paywall.
///
/// Design: gradient pill (amber→orange) with ⚡ icon + "PRO" text,
/// subtle glow shadow, and a slow shimmer animation.
class FloatingProBadge extends StatefulWidget {
  const FloatingProBadge({super.key});

  @override
  State<FloatingProBadge> createState() => _FloatingProBadgeState();
}

class _FloatingProBadgeState extends State<FloatingProBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pro = ProServices.maybeOf(context);
    if (pro == null || pro.entitlementService.isPro) {
      return const SizedBox.shrink();
    }

    return PressableScale(
      onTap: () => SmartPaywall.trigger(
        context: context,
        triggerContext: TriggerContext.timelineBanner,
      ),
      scaleFactor: 0.92,
      child: AnimatedBuilder(
        animation: _shimmer,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF59E0B), Color(0xFFEF6C00)],
              ),
              borderRadius: AppRadius.borderRadiusPill,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.45),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                  spreadRadius: -2,
                ),
                BoxShadow(
                  color: const Color(0xFFEF6C00).withValues(alpha: 0.20),
                  blurRadius: 32,
                  offset: const Offset(0, 8),
                  spreadRadius: -4,
                ),
              ],
            ),
            child: ShaderMask(
              shaderCallback: (bounds) {
                final dx = _shimmer.value * 2.0 - 0.5;
                return LinearGradient(
                  begin: Alignment(dx - 0.3, 0),
                  end: Alignment(dx + 0.3, 0),
                  colors: const [
                    Colors.white,
                    Color(0x66FFFFFF),
                    Colors.white,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ).createShader(bounds);
              },
              blendMode: BlendMode.srcIn,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GlassIcon(icon: AppIcons.energy, color: AppIcons.energyColor, size: 14),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    'PRO',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
