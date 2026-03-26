import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../ui/ui.dart';
import '../../../l10n/app_localizations.dart';

/// A celebratory overlay shown when a milestone is reached.
///
/// Usage:
/// ```dart
/// MilestoneOverlay.show(context, title: 'Level Up!', subtitle: 'Level 5 erreicht');
/// ```
class MilestoneOverlay extends StatefulWidget {
  const MilestoneOverlay({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.emoji_events_rounded,
    this.iconColor = AppColors.warning,
    this.xpAwarded,
    this.onShare,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final int? xpAwarded;
  final void Function(ui.Image screenshot)? onShare;

  /// Show the overlay as a modal popup. Auto-dismisses after 3 seconds.
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String subtitle,
    IconData icon = Icons.emoji_events_rounded,
    Color iconColor = AppColors.warning,
    int? xpAwarded,
    void Function(ui.Image screenshot)? onShare,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'MilestoneOverlay',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (context, anim, _, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: anim,
              curve: Curves.elasticOut,
            ),
            child: child,
          ),
        );
      },
      pageBuilder: (context, _, _) {
        return MilestoneOverlay(
          title: title,
          subtitle: subtitle,
          icon: icon,
          iconColor: iconColor,
          xpAwarded: xpAwarded,
          onShare: onShare,
        );
      },
    );
  }

  @override
  State<MilestoneOverlay> createState() => _MilestoneOverlayState();
}

class _MilestoneOverlayState extends State<MilestoneOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _confettiController;
  late final List<_ConfettiParticle> _particles;
  final GlobalKey _screenshotKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..forward();

    final rng = math.Random();
    _particles = List.generate(
      30,
      (_) => _ConfettiParticle(
        x: rng.nextDouble(),
        speed: 0.3 + rng.nextDouble() * 0.7,
        size: 4.0 + rng.nextDouble() * 6.0,
        color: [
          AppColors.primary,
          AppColors.accent,
          AppColors.warning,
          AppColors.success,
          AppColors.error,
          const Color(0xFFFFD700),
        ][rng.nextInt(6)],
        wobble: rng.nextDouble() * 2 * math.pi,
      ),
    );

    // Auto-dismiss after 3 seconds (extended to 5 if share is available)
    Future.delayed(Duration(seconds: widget.onShare != null ? 5 : 3), () {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  Future<void> _captureAndShare() async {
    try {
      final boundary = _screenshotKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3.0);
      widget.onShare?.call(image);
    } catch (e) {
      debugPrint('[MilestoneOverlay] screenshot failed: $e');
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Confetti
          AnimatedBuilder(
            animation: _confettiController,
            builder: (context, _) {
              return CustomPaint(
                size: MediaQuery.of(context).size,
                painter: _ConfettiPainter(
                  particles: _particles,
                  progress: _confettiController.value,
                ),
              );
            },
          ),

          // Card
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: RepaintBoundary(
                key: _screenshotKey,
                child: GlassContainer(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl,
                    vertical: AppSpacing.xxl + AppSpacing.lg,
                  ),
                  borderRadius: AppRadius.borderRadiusXl,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon with glow
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: widget.iconColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: widget.iconColor.withValues(alpha: 0.25),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          widget.icon,
                          size: 42,
                          color: widget.iconColor,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Title
                      Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Subtitle
                      Text(
                        widget.subtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),

                      // XP badge
                      if (widget.xpAwarded != null) ...[
                        const SizedBox(height: AppSpacing.xl),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.10),
                            borderRadius: AppRadius.borderRadiusPill,
                          ),
                          child: Text(
                            '+${widget.xpAwarded} XP',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      ],

                      // Share button
                      if (widget.onShare != null) ...[
                        const SizedBox(height: AppSpacing.lg),
                        GestureDetector(
                          onTap: _captureAndShare,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: AppSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.10),
                              borderRadius: AppRadius.borderRadiusPill,
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                width: 0.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.share_rounded, size: 16, color: AppColors.primary),
                                SizedBox(width: AppSpacing.xs),
                                Text(
                                  l.share,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'Tippe zum Schließen',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Tap to dismiss
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              behavior: HitTestBehavior.translucent,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfettiParticle {
  _ConfettiParticle({
    required this.x,
    required this.speed,
    required this.size,
    required this.color,
    required this.wobble,
  });

  final double x; // 0..1 horizontal position
  final double speed;
  final double size;
  final Color color;
  final double wobble;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.particles, required this.progress});

  final List<_ConfettiParticle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final y = -20.0 + progress * (size.height + 40) * p.speed;
      final x = p.x * size.width +
          math.sin(progress * math.pi * 4 + p.wobble) * 30;
      final opacity = (1.0 - progress).clamp(0.0, 1.0);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(x, y), width: p.size, height: p.size * 1.5),
          Radius.circular(p.size * 0.3),
        ),
        Paint()..color = p.color.withValues(alpha: opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => true;
}
