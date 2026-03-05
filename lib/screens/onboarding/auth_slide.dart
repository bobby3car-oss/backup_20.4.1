import 'dart:ui';

import 'package:flutter/material.dart';

import '../../ui/ui.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'register_caregiver_screen.dart';

/// The final slide of the onboarding carousel – replaces the old LandingPage.
/// Shows the app logo with a pulsing halo, a welcome headline, and
/// three action buttons (Register, Login, Caregiver).
class AuthSlide extends StatefulWidget {
  const AuthSlide({super.key});

  @override
  State<AuthSlide> createState() => _AuthSlideState();
}

class _AuthSlideState extends State<AuthSlide>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.25, end: 0.55).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.xxl,
        right: AppSpacing.xxl,
        top: mq.padding.top + 80,
        bottom: mq.padding.bottom + AppSpacing.xxxl,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),

          // ── Pulsing logo ─────────────────────────────────────────
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (context, child) {
              return Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(
                        alpha: _pulseAnim.value,
                      ),
                      blurRadius: 64,
                      spreadRadius: 4,
                    ),
                    BoxShadow(
                      color: AppColors.primaryLight.withValues(
                        alpha: _pulseAnim.value * 0.5,
                      ),
                      blurRadius: 120,
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
                color: AppColors.primary.withValues(alpha: 0.12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  width: 1.5,
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: const Icon(
                  Icons.monitor_heart_outlined,
                  size: 60,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.huge),

          // ── Headline ─────────────────────────────────────────────
          const Text(
            'Bereit loszulegen?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.12,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Erstelle dein Konto oder melde dich an,\num deine OP-Begleitung zu starten.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.7),
              height: 1.45,
            ),
          ),

          const Spacer(flex: 3),

          // ── Buttons ──────────────────────────────────────────────
          FadeSlideIn(
            delay: const Duration(milliseconds: 100),
            child: _DarkGlassButton(
              onPressed: () => _push(context, const RegisterScreen()),
              label: 'Jetzt registrieren',
              icon: Icons.person_add_rounded,
              isPrimary: true,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          FadeSlideIn(
            delay: const Duration(milliseconds: 200),
            child: _DarkGlassButton(
              onPressed: () => _push(context, const LoginScreen()),
              label: 'Anmelden',
              icon: Icons.login_rounded,
              isPrimary: false,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          FadeSlideIn(
            delay: const Duration(milliseconds: 300),
            child: _GhostButton(
              onPressed: () =>
                  _push(context, const RegisterCaregiverScreen()),
              label: 'Als Angehöriger beitreten',
            ),
          ),

          const Spacer(),
        ],
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _DarkGlassButton extends StatelessWidget {
  const _DarkGlassButton({
    required this.onPressed,
    required this.label,
    required this.icon,
    required this.isPrimary,
  });

  final VoidCallback onPressed;
  final String label;
  final IconData icon;
  final bool isPrimary;

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
          gradient: isPrimary ? AppColors.primaryGradient : null,
          color: isPrimary ? null : Colors.white.withValues(alpha: 0.08),
          borderRadius: AppRadius.borderRadiusPill,
          border: isPrimary
              ? null
              : Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 0.5,
                ),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isPrimary ? Colors.white : Colors.white.withValues(alpha: 0.9),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.1,
                color: isPrimary ? Colors.white : Colors.white.withValues(alpha: 0.9),
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
  });

  final VoidCallback onPressed;
  final String label;

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
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}
