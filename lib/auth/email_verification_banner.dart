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

    final tt = Theme.of(context).textTheme;

    return Column(
      children: [
        // ── Inline verification strip ──────────────────────────────────
        // Lives in the layout flow — pushes content down, no overlay.
        SafeArea(
          bottom: false,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.08),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.warning.withValues(alpha: 0.22),
                  width: 0.5,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.mark_email_unread_outlined,
                  size: 15,
                  color: AppColors.warning,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'E-Mail-Adresse bestätigen',
                    style: tt.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Resend link
                GestureDetector(
                  onTap: (_sending || _cooldownLeft > 0) ? null : _resend,
                  child: Text(
                    _sending
                        ? 'Sende…'
                        : _cooldownLeft > 0
                            ? '${_cooldownLeft}s'
                            : 'Erneut senden',
                    style: tt.labelSmall?.copyWith(
                      color: (_sending || _cooldownLeft > 0)
                          ? AppColors.textSecondary.withValues(alpha: 0.45)
                          : AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                // "Done" link
                GestureDetector(
                  onTap: _checkVerified,
                  child: Text(
                    'Fertig',
                    style: tt.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── App content ────────────────────────────────────────────────
        // Strip above consumed the safe-area top, tell child not to re-add it.
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: widget.child,
          ),
        ),
      ],
    );
  }
}
