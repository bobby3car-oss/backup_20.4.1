import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import 'login_screen.dart';
import 'register_doctor_screen.dart';
import 'register_screen.dart';

/// The final slide of the onboarding carousel.
///
/// Features social proof strip, pulsing glow CTA, trust signals,
/// and progressive CTA hierarchy to maximize conversion.
class AuthSlide extends StatefulWidget {
  const AuthSlide({super.key, this.onSkipAsGuest});

  /// Called when the user taps "Ohne Konto testen".
  final VoidCallback? onSkipAsGuest;

  @override
  State<AuthSlide> createState() => _AuthSlideState();
}

class _AuthSlideState extends State<AuthSlide>
    with TickerProviderStateMixin {
  // Pulsing glow on the primary CTA
  late final AnimationController _glowCtrl;
  late final Animation<double> _glowAnim;

  // Staggered entrance
  late final AnimationController _entranceCtrl;

  @override
  void initState() {
    super.initState();

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _entranceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final l = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                left: AppSpacing.xxl,
                right: AppSpacing.xxl,
                top: mq.padding.top + 60,
                bottom: mq.padding.bottom + AppSpacing.xxxl,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: (constraints.maxHeight - mq.padding.vertical)
                      .clamp(0.0, double.infinity),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: AppSpacing.xl),

                    // ── App Logo ───────────────────────────────
                    _StaggerEntry(
                      controller: _entranceCtrl,
                      delay: 0.0,
                      child: Image.asset(
                        'assets/images/app_logo.png',
                        width: 80,
                        height: 80,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),

                    // ── Headline ──────────────────────────────────
                    _StaggerEntry(
                      controller: _entranceCtrl,
                      delay: 0.10,
                      child: Text(
                        l.authSlideTitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          height: 1.10,
                          letterSpacing: -0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // ── Subtitle ──────────────────────────────────
                    _StaggerEntry(
                      controller: _entranceCtrl,
                      delay: 0.15,
                      child: Text(
                        l.authSlideSubtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                          height: 1.45,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // ── Social Proof Strip ────────────────────────
                    _StaggerEntry(
                      controller: _entranceCtrl,
                      delay: 0.22,
                      child: _SocialProofStrip(l: l),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),

                    // ── Primary CTA: Glow button ──────────────────
                    _StaggerEntry(
                      controller: _entranceCtrl,
                      delay: 0.30,
                      child: _GlowCTA(
                        glowAnimation: _glowAnim,
                        onPressed: () =>
                            _push(context, const RegisterScreen()),
                        label: l.authSlideRegister,
                      ),
                    ),

                    // ── Trust signals ────────────────────────────
                    _StaggerEntry(
                      controller: _entranceCtrl,
                      delay: 0.35,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: AppSpacing.sm,
                          bottom: AppSpacing.xl,
                        ),
                        child: Text(
                          l.authSlideTrustSignals,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary.withValues(alpha: 0.7),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),

                    // ── Secondary: Login ──────────────────────────
                    _StaggerEntry(
                      controller: _entranceCtrl,
                      delay: 0.40,
                      child: _SecondaryButton(
                        onPressed: () =>
                            _push(context, const LoginScreen()),
                        label: l.authSlideLogin,
                        icon: Icons.login_rounded,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // ── Ghost: Doctor Register ────────────────────
                    _StaggerEntry(
                      controller: _entranceCtrl,
                      delay: 0.48,
                      child: _GhostButton(
                        onPressed: () =>
                            _push(context, const RegisterDoctorScreen()),
                        label: l.authSlideDoctorRegister,
                      ),
                    ),

                    // ── Ghost (dimmer): Guest Mode ────────────────
                    if (widget.onSkipAsGuest != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _StaggerEntry(
                        controller: _entranceCtrl,
                        delay: 0.55,
                        child: _GhostButton(
                          onPressed: widget.onSkipAsGuest!,
                          label: l.authSlideGuestMode,
                          dimmed: true,
                        ),
                      ),
                    ],

                    const SizedBox(height: AppSpacing.xxl),
                    // ── Medical disclaimer ────────────────────────
                    _StaggerEntry(
                      controller: _entranceCtrl,
                      delay: 0.60,
                      child: Text(
                        l.medicalDisclaimer,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary.withValues(alpha: 0.7),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// Staggered entrance animation driven by a single parent controller.
class _StaggerEntry extends StatelessWidget {
  const _StaggerEntry({
    required this.controller,
    required this.delay,
    required this.child,
  });

  final AnimationController controller;
  final double delay;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final end = (delay + 0.25).clamp(0.0, 1.0);
    final opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(delay, end, curve: MotionCurve.enter),
      ),
    );
    final slide = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(delay, end, curve: MotionCurve.enter),
      ),
    );

    return AnimatedBuilder(
      animation: controller,
      builder: (_, _) => Opacity(
        opacity: opacity.value,
        child: Transform.translate(
          offset: Offset(0, slide.value),
          child: child,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// Social proof strip — star rating + user count.
class _SocialProofStrip extends StatelessWidget {
  const _SocialProofStrip({required this.l});

  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: AppRadius.borderRadiusPill,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.12),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 5 stars
          ...List.generate(
            5,
            (_) => const Icon(
              Icons.star_rounded,
              size: 16,
              color: Color(0xFFFFB800),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              l.authSlideSocialProof,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary.withValues(alpha: 0.8),
                letterSpacing: -0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// Primary CTA with pulsing glow shadow — draws the eye.
class _GlowCTA extends StatelessWidget {
  const _GlowCTA({
    required this.glowAnimation,
    required this.onPressed,
    required this.label,
  });

  final Animation<double> glowAnimation;
  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: () {
        Haptic.light();
        onPressed();
      },
      child: AnimatedBuilder(
        animation: glowAnimation,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xxl,
              vertical: AppSpacing.lg + 2,
            ),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: AppRadius.borderRadiusPill,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(
                    alpha: glowAnimation.value,
                  ),
                  blurRadius: 40,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: AppColors.primaryLight.withValues(
                    alpha: glowAnimation.value * 0.3,
                  ),
                  blurRadius: 80,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: child,
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.rocket_launch_rounded,
              size: 20,
              color: Colors.white,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.onPressed,
    required this.label,
    required this.icon,
  });

  final VoidCallback onPressed;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.04),
          borderRadius: AppRadius.borderRadiusPill,
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.08),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: AppColors.textPrimary.withValues(alpha: 0.8)),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.1,
                color: AppColors.textPrimary.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _GhostButton extends StatelessWidget {
  const _GhostButton({
    required this.onPressed,
    required this.label,
    this.dimmed = false,
  });

  final VoidCallback onPressed;
  final String label;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.md,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: dimmed
                ? AppColors.textSecondary.withValues(alpha: 0.45)
                : AppColors.textSecondary.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}
