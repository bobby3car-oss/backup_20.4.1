import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../ui/ui.dart';

/// Non-blocking banner that reminds the user to verify their email address.
///
/// Shows a persistent strip at the top of the screen with a "Resend" button
/// (60 s cooldown) and a "Done" button that reloads the auth state.
/// Automatically disappears once [User.emailVerified] is true.
class EmailVerificationBanner extends StatefulWidget {
  const EmailVerificationBanner({super.key, required this.child});

  final Widget child;

  @override
  State<EmailVerificationBanner> createState() =>
      _EmailVerificationBannerState();
}

class _EmailVerificationBannerState extends State<EmailVerificationBanner> {
  static const _cooldown = Duration(seconds: 60);
  static const _pollInterval = Duration(seconds: 15);

  bool _verified = false;
  bool _sending = false;
  Timer? _cooldownTimer;
  Timer? _pollTimer;
  int _cooldownLeft = 0;

  @override
  void initState() {
    super.initState();
    _checkVerified();
    // Poll periodically so the banner auto-hides after the user taps the link.
    _pollTimer = Timer.periodic(_pollInterval, (_) => _checkVerified());
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkVerified() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await user.reload();
    final nowVerified =
        FirebaseAuth.instance.currentUser?.emailVerified ?? false;
    if (mounted && nowVerified != _verified) {
      setState(() => _verified = nowVerified);
    }
  }

  Future<void> _resend() async {
    if (_sending || _cooldownLeft > 0) return;
    setState(() => _sending = true);
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      _startCooldown();
    } catch (_) {
      // Silently ignore — rate-limited by Firebase anyway.
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _startCooldown() {
    _cooldownLeft = _cooldown.inSeconds;
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _cooldownLeft--;
        if (_cooldownLeft <= 0) _cooldownTimer?.cancel();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Nothing to show for guests or already verified users.
    if (user == null || _verified || user.emailVerified) {
      return widget.child;
    }

    return Stack(
      children: [
        widget.child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Material(
            color: AppColors.primary.withValues(alpha: 0.65),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.mark_email_unread_outlined,
                      color: AppColors.white,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Bitte bestätige deine E-Mail-Adresse.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    if (_cooldownLeft > 0)
                      Padding(
                        padding:
                            const EdgeInsets.only(right: AppSpacing.xs),
                        child: Text(
                          '${_cooldownLeft}s',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.white,
                                  ),
                        ),
                      ),
                    TextButton(
                      onPressed:
                          (_sending || _cooldownLeft > 0) ? null : _resend,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.white,
                        disabledForegroundColor: AppColors.white.withValues(alpha: 0.5),
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        _sending ? 'Sende…' : 'Erneut senden',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    TextButton(
                      onPressed: _checkVerified,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Bereits bestätigt',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
