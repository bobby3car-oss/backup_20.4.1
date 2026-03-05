import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../screens/caregiver_screen.dart';

// ── Dark palette (matches paywall) ──────────────────────────────────

abstract final class _C {
  static const bg = Color(0xFF0A0A0F);
  static const textPrimary = Color(0xFFF5F5F7);
  static const textSecondary = Color(0x99EBEBF5);
  static const accent = Color(0xFF0A84FF);
  static const success = Color(0xFF30D158);
}

/// Celebratory screen shown after a successful Pro purchase.
class ProSuccessScreen extends StatefulWidget {
  const ProSuccessScreen({super.key});

  @override
  State<ProSuccessScreen> createState() => _ProSuccessScreenState();
}

class _ProSuccessScreenState extends State<ProSuccessScreen>
    with TickerProviderStateMixin {
  late final AnimationController _iconCtrl;
  late final Animation<double> _iconScale;
  late final AnimationController _contentCtrl;

  @override
  void initState() {
    super.initState();
    HapticFeedback.heavyImpact();

    // Icon pop-in
    _iconCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _iconScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.15), weight: 55),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 0.92), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.92, end: 1.0), weight: 25),
    ]).animate(CurvedAnimation(parent: _iconCtrl, curve: Curves.easeOut));

    // Content fade-slide
    _contentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _playEntrance();
  }

  Future<void> _playEntrance() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    _iconCtrl.forward();
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    _contentCtrl.forward();
  }

  @override
  void dispose() {
    _iconCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  void _openCaregiver() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const CaregiverScreen()),
    );
  }

  void _goToTimeline() {
    // Pop back to root (timeline)
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final contentCurved =
        CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOutCubic);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _C.bg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Spacer(flex: 3),

                // ── Animated checkmark ─────────────────────
                ScaleTransition(
                  scale: _iconScale,
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _C.success.withValues(alpha: 0.12),
                    ),
                    child: const Center(
                      child: Text('\u2705', style: TextStyle(fontSize: 52)),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // ── Title + body ───────────────────────────
                AnimatedBuilder(
                  animation: contentCurved,
                  builder: (_, child) => Opacity(
                    opacity: contentCurved.value,
                    child: Transform.translate(
                      offset: Offset(0, 16 * (1 - contentCurved.value)),
                      child: child,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Pro aktiviert',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: _C.textPrimary,
                              letterSpacing: -0.5,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Du kannst jetzt Angehörige einladen\n'
                        'und alle Pro Funktionen nutzen.',
                        style:
                            Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: _C.textSecondary,
                                  height: 1.45,
                                ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                // ── Buttons ────────────────────────────────
                AnimatedBuilder(
                  animation: contentCurved,
                  builder: (_, child) => Opacity(
                    opacity: contentCurved.value,
                    child: child,
                  ),
                  child: Column(
                    children: [
                      // Primary CTA
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _openCaregiver,
                          icon: const Text(
                            '\u{1F468}\u200D\u{1F469}\u200D\u{1F467}',
                            style: TextStyle(fontSize: 18),
                          ),
                          label: const Text('Angehörige einladen'),
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
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Secondary
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: TextButton(
                          onPressed: _goToTimeline,
                          style: TextButton.styleFrom(
                            foregroundColor: _C.textSecondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(
                                color: _C.textSecondary.withValues(alpha: 0.2),
                              ),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: const Text('Zur Timeline'),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
