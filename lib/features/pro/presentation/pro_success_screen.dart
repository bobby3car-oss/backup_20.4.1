import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:operationsbegleiter_v3/ui/components/glass_icon.dart';
import 'package:operationsbegleiter_v3/ui/theme/app_icons.dart';
import '../../../l10n/app_localizations.dart';

// ── Light palette (matches paywall) ────────────────────────────────

abstract final class _C {
  static const bg = Color(0xFFF0F2F9);
  static const textPrimary = Color(0xFF1C1C1E);
  static const textSecondary = Color(0xFF8E8E93);
  static const accent = Color(0xFF007AFF);
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

  void _goToTimeline() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final contentCurved =
        CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOutCubic);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _C.bg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Spacer(flex: 3),

                // ── Animated celebration ─────────────────────
                ScaleTransition(
                  scale: _iconScale,
                  child: GlassIcon(icon: AppIcons.achievement, color: AppIcons.achievementColor, size: 50),
                ),

                const SizedBox(height: 32),

                // ── Title + body ───────────────────────────
                ListenableBuilder(
                  listenable: contentCurved,
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
                        'Du bist dabei.',
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
                        'Alle Pro Funktionen sind jetzt\n'
                        'für dich freigeschaltet.',
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

                // ── Button ─────────────────────────────────
                ListenableBuilder(
                  listenable: contentCurved,
                  builder: (_, child) => Opacity(
                    opacity: contentCurved.value,
                    child: child,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _goToTimeline,
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
                      child: Text(l.losGehts),
                    ),
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
