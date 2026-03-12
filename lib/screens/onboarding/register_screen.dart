import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/app_localizations.dart';

import '../../locale/locale_provider.dart';
import '../../ui/ui.dart';
import 'onboarding_carousel.dart';

/// Dark-themed registration screen matching the onboarding aesthetic.
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
  bool _loading = false;

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
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_agbAccepted) return;
    setState(() => _loading = true);
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      await cred.user?.updateDisplayName(_nameCtrl.text.trim());

      // Send email verification link.
      await cred.user?.sendEmailVerification();

      // Mark onboarding as seen so we don't show slides again.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(kOnboardingSeenKey, true);

      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
    } on FirebaseAuthException catch (e) {
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
                            color: Colors.white,
                            height: 1.12,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          l.createAccountSubtitle,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.6),
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
                        color: Colors.white.withValues(alpha: 0.07),
                        borderRadius: AppRadius.borderRadiusMd,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 0.5,
                        ),
                      ),
                      child: DropdownButtonFormField<Locale>(
                        initialValue: localeProvider.locale,
                        decoration: InputDecoration(
                          labelText: l.languageLabel,
                          labelStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(Icons.language_rounded,
                              size: 20, color: Colors.white38),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.lg,
                          ),
                        ),
                        dropdownColor: const Color(0xFF1A1A2E),
                        style: const TextStyle(
                            color: Colors.white, fontSize: 15),
                        iconEnabledColor: Colors.white38,
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
                    child: _DarkTextField(
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

                  // -- Birth date
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 180),
                    child: GestureDetector(
                      onTap: _pickDate,
                      child: AbsorbPointer(
                        child: _DarkTextField(
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
                    child: _DarkTextField(
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
                          color: Colors.white38,
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
                    child: _DarkTextField(
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
                          color: Colors.white38,
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
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: AppRadius.borderRadiusMd,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
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
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadius.xs),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _agbAccepted = !_agbAccepted),
                              child: Text.rich(
                                TextSpan(
                                  text: l.agbAcceptPrefix,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withValues(alpha: 0.6),
                                  ),
                                  children: [
                                    TextSpan(
                                      text: l.agbAcceptLink,
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // -- Create account
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 420),
                    child: PressableScale(
                      onTap: (_agbAccepted && !_loading) ? _submit : null,
                      enabled: _agbAccepted && !_loading,
                      child: Opacity(
                        opacity: _agbAccepted ? 1.0 : 0.45,
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
                ],
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
        style: const TextStyle(color: Colors.white, fontSize: 16),
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 14,
          ),
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.3),
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
