import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/auth_gate.dart';
import '../../auth/post_auth_transition.dart';
import '../../auth/auth_service.dart';
import '../../l10n/app_localizations.dart';

import '../../features/settings/presentation/legal/privacy_screen.dart';
import '../../features/settings/presentation/legal/terms_screen.dart';
import '../../locale/locale_provider.dart';
import '../../ui/ui.dart';
import 'onboarding_carousel.dart';
import 'register_doctor_screen.dart';

/// Light-themed registration screen matching the onboarding aesthetic.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _birthCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agbAccepted = false;
  bool _parentalConsentAccepted = false;
  bool _isMinor = false;
  bool _loading = false;
  final _auth = AuthService();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _birthCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final l = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: l.fieldBirthDatePicker,
      cancelText: l.datePickerCancel,
      confirmText: l.datePickerConfirm,
    );
    if (picked != null) {
      _birthCtrl.text =
          '${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}';
      final now = DateTime.now();
      int age = now.year - picked.year;
      if (now.month < picked.month ||
          (now.month == picked.month && now.day < picked.day)) {
        age--;
      }
      setState(() {
        _isMinor = age < 16;
        if (!_isMinor) _parentalConsentAccepted = false;
      });
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_agbAccepted) return;

    // For minors (under 16): parental consent is required (DSGVO Art. 8).
    if (_isMinor && !_parentalConsentAccepted) return;

    setState(() => _loading = true);
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      await cred.user?.updateDisplayName(_nameCtrl.text.trim());

      // Send email verification link (don't block navigation if it fails).
      try {
        await cred.user?.sendEmailVerification();
        if (kDebugMode) debugPrint('[Register] Verification email sent');
      } catch (e) {
        if (kDebugMode) debugPrint('[Register] sendEmailVerification failed: $e');
      }

      // Mark onboarding as seen so we don't show slides again.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(kOnboardingSeenKey, true);

      await finishPostAuthTransition(context);
    } catch (e) {
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
    final l = AppLocalizations.of(context)!;
    final localeProvider = LocaleProvider.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textSecondary),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF2F2F7), Color(0xFFE8EBF4), Color(0xFFF2F2F7)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.xxxl),

                  // -- Header
                  FadeSlideIn(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.createAccountTitle,
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            height: 1.12,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          l.createAccountSubtitle,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          l.medicalDisclaimer,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.45,
                            color: AppColors.textSecondary.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),

                  // -- Language picker
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 30),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppRadius.borderRadiusMd,
                        border: Border.all(
                          color: Colors.black.withValues(alpha: 0.08),
                          width: 0.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: DropdownButtonFormField<Locale>(
                        initialValue: localeProvider.locale,
                        decoration: InputDecoration(
                          labelText: l.languageLabel,
                          labelStyle: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(Icons.language_rounded,
                              size: 20, color: AppColors.textSecondary),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.lg,
                          ),
                        ),
                        dropdownColor: Colors.white,
                        style: const TextStyle(
                            color: AppColors.textPrimary, fontSize: 15),
                        iconEnabledColor: AppColors.textSecondary,
                        items: LocaleProvider.supportedLocales.map((loc) {
                          final info =
                              LocaleProvider.localeLabels[loc.languageCode]!;
                          return DropdownMenuItem(
                            value: loc,
                            child: Text('${info.flag}  ${info.name}'),
                          );
                        }).toList(),
                        onChanged: (loc) {
                          if (loc != null) localeProvider.setLocale(loc);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // -- Name
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 60),
                    child: _LightTextField(
                      controller: _nameCtrl,
                      label: l.fieldFullName,
                      icon: Icons.person_outline_rounded,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? l.validationNameRequired : null,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // -- Email
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 120),
                    child: _LightTextField(
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

                  // -- Birth date
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 180),
                    child: GestureDetector(
                      onTap: _pickDate,
                      child: AbsorbPointer(
                        child: _LightTextField(
                          controller: _birthCtrl,
                          label: l.fieldBirthDate,
                          hint: l.fieldBirthDateHint,
                          icon: Icons.cake_outlined,
                          validator: (v) =>
                              (v == null || v.isEmpty) ? l.validationBirthDateRequired : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // -- Password
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 240),
                    child: _LightTextField(
                      controller: _passwordCtrl,
                      label: l.fieldPassword,
                      icon: Icons.lock_outline_rounded,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.newPassword],
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (v) =>
                          (v == null || v.length < 6) ? l.validationPasswordMin6 : null,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // -- Confirm password
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 300),
                    child: _LightTextField(
                      controller: _confirmCtrl,
                      label: l.fieldRepeatPassword,
                      icon: Icons.lock_outline_rounded,
                      obscureText: _obscureConfirm,
                      textInputAction: TextInputAction.done,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return l.validationRepeatPassword;
                        if (v != _passwordCtrl.text) {
                          return l.validationPasswordsMismatch;
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // -- AGB checkbox
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 360),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
                        borderRadius: AppRadius.borderRadiusMd,
                        border: Border.all(
                          color: Colors.black.withValues(alpha: 0.08),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _agbAccepted,
                              onChanged: (v) =>
                                  setState(() => _agbAccepted = v ?? false),
                              activeColor: AppColors.primary,
                              checkColor: Colors.white,
                              side: BorderSide(
                                color: Colors.black.withValues(alpha: 0.2),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadius.xs),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                text: l.agbAcceptPrefix,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () =>
                                      setState(() => _agbAccepted = !_agbAccepted),
                                children: [
                                  TextSpan(
                                    text: l.agbTermsLink,
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                      decorationColor: AppColors.primary,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute<void>(
                                            builder: (_) => const TermsScreen(),
                                          ),
                                        );
                                      },
                                  ),
                                  TextSpan(
                                    text: l.agbAndConnector,
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () =>
                                          setState(() => _agbAccepted = !_agbAccepted),
                                  ),
                                  TextSpan(
                                    text: l.agbPrivacyLink,
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                      decorationColor: AppColors.primary,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute<void>(
                                            builder: (_) => const PrivacyScreen(),
                                          ),
                                        );
                                      },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // -- Parental consent (only shown for users under 16)
                  if (_isMinor)
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 390),
                      child: Container(
                        margin:
                            const EdgeInsets.only(bottom: AppSpacing.xxl),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9500).withValues(alpha: 0.1),
                          borderRadius: AppRadius.borderRadiusMd,
                          border: Border.all(
                            color: const Color(0xFFFF9500).withValues(alpha: 0.3),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _parentalConsentAccepted,
                                onChanged: (v) => setState(
                                  () => _parentalConsentAccepted = v ?? false,
                                ),
                                activeColor: const Color(0xFFFF9500),
                                checkColor: Colors.white,
                                side: BorderSide(
                                  color:
                                      const Color(0xFFFF9500).withValues(alpha: 0.5),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.xs),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(
                                  () => _parentalConsentAccepted =
                                      !_parentalConsentAccepted,
                                ),
                                child: const Text(
                                  'Ich bestätige, dass meine Eltern oder '
                                  'Erziehungsberechtigten der Nutzung dieser '
                                  'App und der Verarbeitung meiner Daten '
                                  'ausdrücklich zugestimmt haben '
                                  '(DSGVO Art. 8).',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFFFF9500),
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // -- Create account
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 420),
                    child: PressableScale(
                      onTap: (_agbAccepted &&
                              !_loading &&
                              (!_isMinor || _parentalConsentAccepted))
                          ? _submit
                          : null,
                      enabled: _agbAccepted &&
                          !_loading &&
                          (!_isMinor || _parentalConsentAccepted),
                      child: Opacity(
                        opacity: (_agbAccepted &&
                                (!_isMinor || _parentalConsentAccepted))
                            ? 1.0
                            : 0.45,
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
                                    const Icon(Icons.person_add_rounded,
                                        size: 18, color: Colors.white),
                                    const SizedBox(width: AppSpacing.sm),
                                    Text(
                                      l.createAccount,
                                      style: const TextStyle(
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
                  ),
                  const SizedBox(height: AppSpacing.huge),

                  // -- Social sign-up (Google / Apple)
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 480),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: AppColors.textSecondary.withValues(alpha: 0.2),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md),
                              child: Text(
                                l.or,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: AppColors.textSecondary.withValues(alpha: 0.2),
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
                  const SizedBox(height: AppSpacing.xxl),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 560),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const RegisterDoctorScreen(),
                          ),
                        );
                      },
                      child: Text(
                        l.authSlideDoctorRegister,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primary.withValues(alpha: 0.85),
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primary.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 620),
                    child: GestureDetector(
                      onTap: _loading ? null : _continueAsGuest,
                      child: Text(
                        l.registerContinueAsGuest,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.textSecondary.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.huge),
                ],
              ),
            ),
          ),
          ),
          ),
        ),
      ),
    );
  }

  /// On web, popup-based auth can throw even though sign-in succeeded.
  Future<bool> _didWebAuthSucceed() async {
    if (!kIsWeb) return false;
    if (FirebaseAuth.instance.currentUser != null) return true;
    try {
      final user = await FirebaseAuth.instance
          .authStateChanges()
          .firstWhere((u) => u != null)
          .timeout(const Duration(seconds: 2));
      return user != null;
    } catch (_) {
      return FirebaseAuth.instance.currentUser != null;
    }
  }

  Future<void> _continueAsGuest() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kOnboardingSeenKey, true);
    await prefs.setBool(AuthGate.kGuestModeKey, true);
    AuthGate.guestModeNotifier.value = true;
    if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
  }

  Future<void> _signInWithApple() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      await _auth.signInWithApple();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(kOnboardingSeenKey, true);
      await finishPostAuthTransition(context);
    } catch (e) {
      if (await _didWebAuthSucceed()) {
        await finishPostAuthTransition(context);
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
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(kOnboardingSeenKey, true);
      await finishPostAuthTransition(context);
    } catch (e) {
      if (await _didWebAuthSucceed()) {
        await finishPostAuthTransition(context);
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
}

// --------------------------------------------------------------------------

class _LightTextField extends StatelessWidget {
  const _LightTextField({
    this.controller,
    this.label,
    this.hint,
    this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.autofillHints,
    this.suffixIcon,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final IconData? icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final Iterable<String>? autofillHints;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.08),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        validator: validator,
        autofillHints: autofillHints,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
          hintStyle: TextStyle(
            color: AppColors.textSecondary.withValues(alpha: 0.5),
            fontSize: 14,
          ),
          prefixIcon: icon != null
              ? Icon(icon, size: 20, color: AppColors.textSecondary)
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
        icon: Icon(icon, size: 22, color: AppColors.textPrimary),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          side: BorderSide(
            color: Colors.black.withValues(alpha: 0.12),
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
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.black54,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderRadiusPill,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.apple, size: 24, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
