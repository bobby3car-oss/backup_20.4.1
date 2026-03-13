import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';

/// Medical specialties for doctor registration.
const _specialties = <String>[
  'Allgemeinchirurgie',
  'Orthopädie & Unfallchirurgie',
  'Viszeralchirurgie',
  'Herzchirurgie',
  'Neurochirurgie',
  'Gefäßchirurgie',
  'Plastische Chirurgie',
  'Urologie',
  'Gynäkologie',
  'HNO',
  'Augenheilkunde',
  'Innere Medizin',
  'Anästhesiologie',
  'Sonstige',
];

class RegisterDoctorScreen extends StatefulWidget {
  const RegisterDoctorScreen({super.key});

  @override
  State<RegisterDoctorScreen> createState() => _RegisterDoctorScreenState();
}

class _RegisterDoctorScreenState extends State<RegisterDoctorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _approbationCtrl = TextEditingController();
  final _practiceNameCtrl = TextEditingController();
  final _kvNumberCtrl = TextEditingController();

  String? _selectedSpecialty;
  bool _obscure = true;
  bool _submitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _approbationCtrl.dispose();
    _practiceNameCtrl.dispose();
    _kvNumberCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedSpecialty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.doctorRegSpecialtyRequired)),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final email = _emailCtrl.text.trim();
      final password = _passwordCtrl.text;

      final callable =
          FirebaseFunctions.instance.httpsCallable('registerDoctor');
      await callable.call(<String, dynamic>{
        'name': _nameCtrl.text.trim(),
        'email': email,
        'password': password,
        'specialty': _selectedSpecialty,
        'approbationNumber': _approbationCtrl.text.trim(),
        'practiceName': _practiceNameCtrl.text.trim(),
        'kvNumber': _kvNumberCtrl.text.trim(),
      });

      // Auto sign-in so the doctor lands on the verification-pending screen.
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Send email verification link (don't block navigation if it fails).
      try {
        await FirebaseAuth.instance.currentUser?.sendEmailVerification();
        if (kDebugMode) debugPrint('[RegisterDoctor] Verification email sent');
      } catch (e) {
        if (kDebugMode) debugPrint('[RegisterDoctor] sendEmailVerification failed: $e');
      }

      if (!mounted) return;
      // Pop back to root — AuthGate will pick up the session.
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFacingError(e))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFacingError(e))),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: Text(l.doctorRegTitle),
              backgroundColor: Colors.transparent,
            ),
            SliverPadding(
              padding: AppSpacing.screenPadding,
              sliver: SliverToBoxAdapter(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Role badge ──────────────────────────────
                      FadeSlideIn(
                        child: GlassContainer(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.md,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.success
                                      .withValues(alpha: 0.12),
                                  borderRadius: AppRadius.borderRadiusMd,
                                ),
                                child: const Icon(
                                  Icons.medical_services_outlined,
                                  color: AppColors.success,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(l.doctorRegRoleBadge,
                                        style:
                                            theme.textTheme.titleMedium),
                                    const SizedBox(height: 2),
                                    Text(
                                      l.doctorRegRoleBadgeSubtitle,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                              color: AppColors
                                                  .textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      // ── Personal data section ──────────────────
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 80),
                        child: _SectionLabel(
                          icon: Icons.person_outline_rounded,
                          label: l.doctorRegPersonalData,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      FadeSlideIn(
                        delay: const Duration(milliseconds: 120),
                        child: GlassTextField(
                          controller: _nameCtrl,
                          label: l.fieldFullName,
                          hint: l.doctorRegNameHint,
                          prefixIcon: Icons.badge_outlined,
                          textInputAction: TextInputAction.next,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? l.validationNameRequired
                              : null,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      FadeSlideIn(
                        delay: const Duration(milliseconds: 160),
                        child: GlassTextField(
                          controller: _emailCtrl,
                          label: l.doctorRegServiceEmail,
                          hint: l.doctorRegEmailHint,
                          prefixIcon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return l.doctorRegEmailRequired;
                            }
                            if (!v.contains('@') || !v.contains('.')) {
                              return l.doctorRegEmailInvalid;
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      FadeSlideIn(
                        delay: const Duration(milliseconds: 200),
                        child: GlassTextField(
                          controller: _passwordCtrl,
                          label: l.fieldPassword,
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: _obscure,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [
                            AutofillHints.newPassword,
                          ],
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                              color: AppColors.grey500,
                            ),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                          validator: (v) {
                            if (v == null || v.length < 8) {
                              return l.doctorRegPasswordMin8;
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      // ── Professional data section ──────────────
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 240),
                        child: _SectionLabel(
                          icon: Icons.medical_information_outlined,
                          label: l.doctorRegProfessionalData,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      FadeSlideIn(
                        delay: const Duration(milliseconds: 280),
                        child: GlassContainer(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.xs,
                          ),
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedSpecialty,
                            decoration: InputDecoration(
                              labelText: l.doctorRegSpecialty,
                              border: InputBorder.none,
                              prefixIcon: Icon(
                                Icons.local_hospital_outlined,
                                size: 20,
                              ),
                            ),
                            items: _specialties
                                .map((s) => DropdownMenuItem(
                                    value: s, child: Text(s)))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedSpecialty = v),
                            validator: (v) => v == null
                                ? l.doctorRegSelectSpecialty
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      FadeSlideIn(
                        delay: const Duration(milliseconds: 320),
                        child: GlassTextField(
                          controller: _approbationCtrl,
                          label: l.doctorRegApprobation,
                          hint: l.doctorRegApprobationHint,
                          prefixIcon: Icons.verified_outlined,
                          textInputAction: TextInputAction.next,
                          validator: (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? l.doctorRegApprobationRequired
                                  : null,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      FadeSlideIn(
                        delay: const Duration(milliseconds: 360),
                        child: GlassTextField(
                          controller: _practiceNameCtrl,
                          label: l.doctorRegPractice,
                          hint: l.doctorRegPracticeHint,
                          prefixIcon: Icons.business_outlined,
                          textInputAction: TextInputAction.next,
                          validator: (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? l.doctorRegPracticeRequired
                                  : null,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      FadeSlideIn(
                        delay: const Duration(milliseconds: 400),
                        child: GlassTextField(
                          controller: _kvNumberCtrl,
                          label: l.doctorRegKvNumber,
                          hint: l.doctorRegKvHint,
                          prefixIcon: Icons.numbers_outlined,
                          textInputAction: TextInputAction.done,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxxl),

                      // ── Submit ──────────────────────────────────
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 440),
                        child: GlassButton(
                          onPressed: _submitting ? null : _submit,
                          label: _submitting
                              ? l.doctorRegSubmitting
                              : l.doctorRegSubmit,
                          icon: Icons.send_rounded,
                          expand: true,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      FadeSlideIn(
                        delay: const Duration(milliseconds: 480),
                        child: Text(
                          l.doctorRegDisclaimer,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.huge),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
        ),
      ],
    );
  }
}
