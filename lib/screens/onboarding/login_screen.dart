import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../auth/auth_service.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import 'register_screen.dart';
import '../../features/settings/presentation/legal/privacy_screen.dart';
import '../../features/settings/presentation/legal/terms_screen.dart';

/// Dark-themed login screen that matches the onboarding aesthetic.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  final _auth = AuthService();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  /// On web, popup-based auth (and occasionally email/password) can throw
  /// even though sign-in succeeded at the JS SDK level. The auth token is
  /// persisted in IndexedDB but [FirebaseAuth.instance.currentUser] may
  /// still be null because the state change hasn't propagated yet.
  /// This helper waits briefly for that propagation before giving up.
  Future<bool> _didWebAuthSucceed() async {
    if (!kIsWeb) return false;
    if (FirebaseAuth.instance.currentUser != null) return true;
    // Give the auth state up to 2 s to propagate.
    try {
      final user = await FirebaseAuth.instance
          .authStateChanges()
          .firstWhere((u) => u != null)
          .timeout(const Duration(seconds: 2));
      return user != null;
    } catch (_) {
      // Timeout – check one last time.
      return FirebaseAuth.instance.currentUser != null;
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
    } catch (e) {
      // On web, auth may have succeeded despite the exception.
      if (await _didWebAuthSucceed()) {
        if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
        return;
      }
      if (!mounted) return;
      final msg = userFacingError(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      await _auth.signInWithGoogle();
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
    } catch (e) {
      // On web the popup flow may throw even though auth succeeded.
      if (await _didWebAuthSucceed()) {
        if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
        return;
      }
      if (!mounted) return;
      final msg = userFacingError(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInWithApple() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      await _auth.signInWithApple();
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
    } catch (e) {
      // On web the popup flow may throw even though auth succeeded.
      if (await _didWebAuthSucceed()) {
        if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
        return;
      }
      if (!mounted) return;
      final msg = userFacingError(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white70),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0A0F), Color(0xFF0D1B2A), Color(0xFF0A0A0F)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: Builder(builder: (context) {
              final l = AppLocalizations.of(context)!;
              return Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.huge),

                  // -- Header
                  FadeSlideIn(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.loginWelcomeBack,
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.12,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          l.loginSubtitle,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          l.medicalDisclaimer,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.45,
                            color: Colors.white.withValues(alpha: 0.45),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.huge),

                  // -- Email
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 80),
                    child: _DarkTextField(
                      controller: _emailCtrl,
                      label: l.fieldEmail,
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      validator: (v) => (v == null || !v.contains('@'))
                          ? l.validationEmailInvalid
                          : null,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // -- Password
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 160),
                    child: _DarkTextField(
                      controller: _passwordCtrl,
                      label: l.fieldPassword,
                      icon: Icons.lock_outline_rounded,
                      obscureText: _obscure,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onFieldSubmitted: (_) => _submit(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20,
                          color: Colors.white38,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                      validator: (v) => (v == null || v.length < 6)
                          ? l.validationPasswordMin6
                          : null,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // -- Forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        final email = _emailCtrl.text.trim();
                        if (email.contains('@')) {
                          FirebaseAuth.instance
                              .sendPasswordResetEmail(email: email);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                l.loginPasswordResetSent,
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text(l.loginEnterEmailFirst),
                            ),
                          );
                        }
                      },
                      child: Text(
                        l.loginForgotPassword,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // -- Login button
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 240),
                    child: PressableScale(
                      onTap: _loading ? null : _submit,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xxl,
                          vertical: AppSpacing.lg,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: AppRadius.borderRadiusPill,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: _loading
                            ? const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.login_rounded,
                                      size: 18, color: Colors.white),
                                  SizedBox(width: AppSpacing.sm),
                                  Text(
                                    l.authSlideLogin,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      letterSpacing: -0.1,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.huge),

                  // -- Social sign-in (Google / Apple)
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 320),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.white.withValues(alpha: 0.15),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md),
                              child: Text(
                                l.or,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.4),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.white.withValues(alpha: 0.15),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _AppleSignInButton(
                          onPressed: _loading ? null : _signInWithApple,
                          label: l.loginWithApple,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _SocialButton(
                          onPressed: _loading ? null : _signInWithGoogle,
                          icon: Icons.g_mobiledata,
                          label: l.loginWithGoogle,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.huge),

                  // -- Register link
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 320),
                    child: Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute<void>(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: Text(
                          l.noAccountYet,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // -- Legal links (Privacy / Terms)
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 420),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const PrivacyScreen(),
                            ),
                          ),
                          child: Text(
                            l.settingsPrivacy,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                        Text(
                          ' · ',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const TermsScreen(),
                            ),
                          ),
                          child: Text(
                            l.settingsTerms,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                ],
              ),
            );
            }),
          ),
            ),
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------------------------------

class _DarkTextField extends StatelessWidget {
  const _DarkTextField({
    this.controller,
    this.label,
    this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.autofillHints,
    this.suffixIcon,
    this.onFieldSubmitted,
  });

  final TextEditingController? controller;
  final String? label;
  final IconData? icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final Iterable<String>? autofillHints;
  final Widget? suffixIcon;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        validator: validator,
        autofillHints: autofillHints,
        onFieldSubmitted: onFieldSubmitted,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 14,
          ),
          prefixIcon: icon != null
              ? Icon(icon, size: 20, color: Colors.white38)
              : null,
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          errorStyle: const TextStyle(color: AppColors.error),
        ),
      ),
    );
  }
}

// --------------------------------------------------------------------------

// --------------------------------------------------------------------------

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 22, color: Colors.white70),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.15),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderRadiusPill,
          ),
        ),
      ),
    );
  }
}

/// Apple HIG-compliant Sign in with Apple button.
class _AppleSignInButton extends StatelessWidget {
  const _AppleSignInButton({
    required this.onPressed,
    required this.label,
  });

  final VoidCallback? onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          disabledBackgroundColor: Colors.white70,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderRadiusPill,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.apple, size: 24, color: Colors.black),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
