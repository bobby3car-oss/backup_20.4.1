import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../ui/ui.dart';
import '../../features/pro/presentation/paywall_screen.dart';
import '../../main.dart';

/// Key used in [SharedPreferences] to track if the user already saw
/// the one-time Pro upgrade promo after registration.
const kProPromoSeenKey = 'pro_promo_seen';

/// One-time Pro upgrade promotion shown after the user's first
/// successful login / registration.
///
/// Uses a dark theme with gold accent to convey premium quality.
/// Tapping "Pro testen" navigates to [PaywallScreen]; "Jetzt nicht"
/// dismisses the screen. Both paths set [kProPromoSeenKey] = true.
class ProPromoScreen extends StatefulWidget {
  const ProPromoScreen({
    super.key,
    required this.onDismiss,
  });

  /// Called when the user closes the promo (via CTA or skip).
  final VoidCallback onDismiss;

  @override
  State<ProPromoScreen> createState() => _ProPromoScreenState();
}

class _ProPromoScreenState extends State<ProPromoScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowCtrl;
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.3, end: 0.65).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kProPromoSeenKey, true);
    widget.onDismiss();
  }

  Future<void> _openPaywall() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kProPromoSeenKey, true);

    if (!mounted) return;

    // Try to get services from ProServices InheritedWidget
    final proServices = ProServices.maybeOf(context);
    if (proServices != null) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => PaywallScreen(
            billingService: proServices.billingService,
            entitlementService: proServices.entitlementService,
            proAnalytics: proServices.proAnalytics,
            paywallConfig: proServices.paywallConfig,
            source: 'onboarding_promo',
          ),
        ),
      );
    }

    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    const gold = Color(0xFFFF9500);
    const goldLight = Color(0xFFFFCC02);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A0A0F),
              Color(0xFF1A1000),
              Color(0xFF0A0A0F),
            ],
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: Column(
              children: [
                SizedBox(height: mq.padding.top > 0 ? AppSpacing.xxl : AppSpacing.huge),

                // ── Crown icon with glow ────────────────────────────
                AnimatedBuilder(
                  animation: _glowAnim,
                  builder: (context, child) {
                    return Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: gold.withValues(alpha: _glowAnim.value),
                            blurRadius: 56,
                            spreadRadius: 4,
                          ),
                          BoxShadow(
                            color: goldLight.withValues(alpha: _glowAnim.value * 0.3),
                            blurRadius: 100,
                            spreadRadius: 16,
                          ),
                        ],
                      ),
                      child: child,
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: gold.withValues(alpha: 0.12),
                      border: Border.all(
                        color: gold.withValues(alpha: 0.35),
                        width: 1.5,
                      ),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: const Icon(
                        Icons.workspace_premium_rounded,
                        size: 52,
                        color: gold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),

                // ── Headline ────────────────────────────────────────
                const Text(
                  'Hol das Beste aus deiner\nGenesung heraus',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.15,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Mit Pro bekommst du erweiterte Funktionen\nfür eine bestmögliche Begleitung.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withValues(alpha: 0.65),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),

                // ── Feature comparison ──────────────────────────────
                _ComparisonCard(),
                const SizedBox(height: AppSpacing.xxxl),

                // ── CTA: Pro testen ─────────────────────────────────
                FadeSlideIn(
                  delay: const Duration(milliseconds: 200),
                  child: PressableScale(
                    onTap: _openPaywall,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xxl,
                        vertical: AppSpacing.lg,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [gold, goldLight],
                        ),
                        borderRadius: AppRadius.borderRadiusPill,
                        boxShadow: [
                          BoxShadow(
                            color: gold.withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.workspace_premium_rounded,
                            size: 20,
                            color: Color(0xFF1A1000),
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Text(
                            'Pro entdecken',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1000),
                              letterSpacing: -0.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Skip ────────────────────────────────────────────
                FadeSlideIn(
                  delay: const Duration(milliseconds: 350),
                  child: PressableScale(
                    onTap: _dismiss,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      child: Text(
                        'Jetzt nicht',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xxxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ComparisonCard extends StatelessWidget {
  static const _features = [
    _CompareRow('Timeline & Checklisten', free: true, pro: true),
    _CompareRow('Vitalwerte & Schmerz', free: true, pro: true),
    _CompareRow('Foto-Dokumentation', free: true, pro: true),
    _CompareRow('Red-Flag Warnungen', free: false, pro: true),
    _CompareRow('Sprach-Memos', free: false, pro: true),
    _CompareRow('Angehörige einladen', free: false, pro: true),
    _CompareRow('Fortschritts-Badges', free: false, pro: true),
    _CompareRow('Erweitertes Tracking', free: false, pro: true),
    _CompareRow('Werbefrei', free: false, pro: true),
  ];

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFFF9500);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: AppRadius.borderRadiusXl,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.xl),
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                  flex: 3,
                  child: Text(
                    'Funktion',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Free',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                const Expanded(
                  child: Text(
                    'Pro',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: gold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Rows
          ...List.generate(_features.length, (i) {
            final f = _features[i];
            return FadeSlideIn(
              delay: Duration(milliseconds: 80 + i * 60),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withValues(alpha: 0.06),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        f.label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Icon(
                        f.free
                            ? Icons.check_circle_rounded
                            : Icons.remove_circle_outline_rounded,
                        size: 20,
                        color: f.free
                            ? AppColors.success.withValues(alpha: 0.7)
                            : Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    Expanded(
                      child: Icon(
                        f.pro
                            ? Icons.check_circle_rounded
                            : Icons.remove_circle_outline_rounded,
                        size: 20,
                        color: f.pro ? gold : Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _CompareRow {
  const _CompareRow(this.label, {required this.free, required this.pro});
  final String label;
  final bool free;
  final bool pro;
}
