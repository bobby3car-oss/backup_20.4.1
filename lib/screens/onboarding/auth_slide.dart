import 'dart:ui';

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import 'login_screen.dart';
import 'register_doctor_screen.dart';
import 'register_screen.dart';

/// The final slide of the onboarding carousel – replaces the old LandingPage.
/// Shows the app logo with a pulsing halo, a welcome headline, and
/// three action buttons (Register, Login, Family).
class AuthSlide extends StatefulWidget {
  const AuthSlide({super.key, this.onSkipAsGuest});

  /// Called when the user taps "App ohne Konto testen".
  final VoidCallback? onSkipAsGuest;

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
            top: mq.padding.top + 80,
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
                const SizedBox(height: AppSpacing.xxl),
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
                              alpha: _pulseAnim.value * 0.5,
                            ),
                            blurRadius: 48,
                            spreadRadius: 2,
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
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Image.asset(
                          'assets/images/app_logo.png',
                          width: 60,
                          height: 60,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.huge),
                Text(
                  l.authSlideTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.12,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l.authSlideSubtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 100),
                  child: _DarkGlassButton(
                    onPressed: () => _push(context, const RegisterScreen()),
                    label: l.authSlideRegister,
                    icon: Icons.person_add_rounded,
                    isPrimary: true,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 200),
                  child: _DarkGlassButton(
                    onPressed: () => _push(context, const LoginScreen()),
                    label: l.authSlideLogin,
                    icon: Icons.login_rounded,
                    isPrimary: false,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 300),
                  child: _GhostButton(
                    onPressed: () =>
                        _push(context, const RegisterDoctorScreen()),
                    label: l.authSlideDoctorRegister,
                  ),
                ),
                if (widget.onSkipAsGuest != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 500),
                    child: _GhostButton(
                      onPressed: widget.onSkipAsGuest!,
                      label: l.authSlideGuestMode,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xxl),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 600),
                  child: Text(
                    l.medicalDisclaimer,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
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
          color: isPrimary ? null : Colors.black.withValues(alpha: 0.04),
          borderRadius: AppRadius.borderRadiusPill,
          border: isPrimary
              ? null
              : Border.all(
                  color: Colors.black.withValues(alpha: 0.08),
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
              color: isPrimary ? Colors.white : AppColors.textPrimary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.1,
                color: isPrimary ? Colors.white : AppColors.textPrimary,
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
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
