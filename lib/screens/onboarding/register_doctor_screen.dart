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

/// Organisation types for org registration.
const _orgTypes = <String>[
  'Klinik / Krankenhaus',
  'MVZ',
  'Praxis-Netzwerk',
  'Sonstige',
];

enum _RegMode { doctor, organisation }

class RegisterDoctorScreen extends StatefulWidget {
  const RegisterDoctorScreen({super.key});

  @override
  State<RegisterDoctorScreen> createState() => _RegisterDoctorScreenState();
}

class _RegisterDoctorScreenState extends State<RegisterDoctorScreen> {
  _RegMode _mode = _RegMode.doctor;

  // ── Shared controllers ──
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _submitting = false;

  // ── Doctor-specific ──
  final _approbationCtrl = TextEditingController();
  final _practiceNameCtrl = TextEditingController();
  final _kvNumberCtrl = TextEditingController();
  String? _selectedSpecialty;

  // ── Org-specific ──
  final _addressCtrl = TextEditingController();
  final _contactPersonCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String? _selectedOrgType;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _approbationCtrl.dispose();
    _practiceNameCtrl.dispose();
    _kvNumberCtrl.dispose();
    _addressCtrl.dispose();
    _contactPersonCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_mode == _RegMode.doctor) {
      await _submitDoctor();
    } else {
      await _submitOrg();
    }
  }
  Future<void> _submitDoctor() async {
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

      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      try {
        await FirebaseAuth.instance.currentUser?.sendEmailVerification();
        if (kDebugMode) debugPrint('[RegisterDoctor] Verification email sent');
      } catch (e) {
        if (kDebugMode) debugPrint('[RegisterDoctor] sendEmailVerification failed: $e');
      }

      if (!mounted) return;
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

  Future<void> _submitOrg() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedOrgType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.orgRegSelectOrgType)),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final email = _emailCtrl.text.trim();
      final password = _passwordCtrl.text;

      final callable =
          FirebaseFunctions.instance.httpsCallable('registerOrganisation');
      await callable.call(<String, dynamic>{
        'name': _nameCtrl.text.trim(),
        'email': email,
        'password': password,
        'orgType': _selectedOrgType,
        'address': _addressCtrl.text.trim(),
        'contactPerson': _contactPersonCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
      });

      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      try {
        await FirebaseAuth.instance.currentUser?.sendEmailVerification();
        if (kDebugMode) debugPrint('[RegisterOrg] Verification email sent');
      } catch (e) {
        if (kDebugMode) debugPrint('[RegisterOrg] sendEmailVerification failed: $e');
      }

      if (!mounted) return;
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
    final isDoctor = _mode == _RegMode.doctor;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: Text(isDoctor ? l.doctorRegTitle : l.orgRegTitle),
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
                      // ── Mode toggle ─────────────────────────────
                      FadeSlideIn(
                        child: GlassContainer(
                          padding: const EdgeInsets.all(4),
                          child: Row(
                            children: [
                              Expanded(
                                child: _ModeToggleButton(
                                  label: 'Arzt',
                                  icon: Icons.medical_services_outlined,
                                  selected: isDoctor,
                                  onTap: () => setState(() {
                                    _mode = _RegMode.doctor;
                                    _formKey.currentState?.reset();
                                  }),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: _ModeToggleButton(
                                  label: 'Organisation',
                                  icon: Icons.business_outlined,
                                  selected: !isDoctor,
                                  onTap: () => setState(() {
                                    _mode = _RegMode.organisation;
                                    _formKey.currentState?.reset();
                                  }),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

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
                                child: Icon(
                                  isDoctor
                                      ? Icons.medical_services_outlined
                                      : Icons.business_outlined,
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
                                    Text(
                                      isDoctor
                                          ? l.doctorRegRoleBadge
                                          : l.orgRegRoleBadge,
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      isDoctor
                                          ? l.doctorRegRoleBadgeSubtitle
                                          : l.orgRegRoleBadgeSubtitle,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                              color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      // ── Shared: Name, E-Mail, Password ─────────
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 80),
                        child: _SectionLabel(
                          icon: Icons.person_outline_rounded,
                          label: isDoctor
                              ? l.doctorRegPersonalData
                              : l.orgRegGeneralData,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      FadeSlideIn(
                        delay: const Duration(milliseconds: 120),
                        child: GlassTextField(
                          controller: _nameCtrl,
                          label: isDoctor ? l.fieldFullName : l.orgRegOrgName,
                          hint: isDoctor
                              ? l.doctorRegNameHint
                              : l.orgRegOrgNameHint,
                          prefixIcon: isDoctor
                              ? Icons.badge_outlined
                              : Icons.business_outlined,
                          textInputAction: TextInputAction.next,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? (isDoctor ? l.validationNameRequired : l.orgRegNameRequired)
                              : null,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      FadeSlideIn(
                        delay: const Duration(milliseconds: 160),
                        child: GlassTextField(
                          controller: _emailCtrl,
                          label: isDoctor ? l.doctorRegServiceEmail : l.orgRegEmail,
                          hint: isDoctor
                              ? l.doctorRegEmailHint
                              : l.orgRegEmailHint,
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
                          autofillHints: const [AutofillHints.newPassword],
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

                      // ── Mode-specific fields ───────────────────
                      if (isDoctor) ..._buildDoctorFields(l, theme)
                      else ..._buildOrgFields(l, theme),

                      const SizedBox(height: AppSpacing.xxxl),

                      // ── Submit ──────────────────────────────────
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 440),
                        child: GlassButton(
                          onPressed: _submitting ? null : _submit,
                          label: _submitting
                              ? (isDoctor ? l.doctorRegSubmitting : l.orgRegSubmitting)
                              : (isDoctor ? l.doctorRegSubmit : l.orgRegSubmit),
                          icon: Icons.send_rounded,
                          expand: true,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      FadeSlideIn(
                        delay: const Duration(milliseconds: 480),
                        child: Text(
                          isDoctor
                              ? l.doctorRegDisclaimer
                              : l.orgRegDisclaimer,
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

  List<Widget> _buildDoctorFields(AppLocalizations l, ThemeData theme) {
    return [
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
              prefixIcon: const Icon(Icons.local_hospital_outlined, size: 20),
            ),
            items: _specialties
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) => setState(() => _selectedSpecialty = v),
            validator: (v) => v == null ? l.doctorRegSelectSpecialty : null,
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
          validator: (v) => (v == null || v.trim().isEmpty)
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
          validator: (v) => (v == null || v.trim().isEmpty)
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
    ];
  }

  List<Widget> _buildOrgFields(AppLocalizations l, ThemeData theme) {
    return [
      FadeSlideIn(
        delay: const Duration(milliseconds: 240),
        child: _SectionLabel(
          icon: Icons.domain_outlined,
          label: l.orgRegOrgData,
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
            initialValue: _selectedOrgType,
            decoration: InputDecoration(
              labelText: l.orgRegOrgType,
              border: InputBorder.none,
              prefixIcon: const Icon(Icons.category_outlined, size: 20),
            ),
            items: _orgTypes
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) => setState(() => _selectedOrgType = v),
            validator: (v) => v == null ? l.orgRegSelectOrgType : null,
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.md),
      FadeSlideIn(
        delay: const Duration(milliseconds: 320),
        child: GlassTextField(
          controller: _addressCtrl,
          label: l.orgRegAddress,
          hint: l.orgRegAddressHint,
          prefixIcon: Icons.location_on_outlined,
          textInputAction: TextInputAction.next,
          validator: (v) => (v == null || v.trim().isEmpty)
              ? l.orgRegAddressRequired
              : null,
        ),
      ),
      const SizedBox(height: AppSpacing.md),
      FadeSlideIn(
        delay: const Duration(milliseconds: 360),
        child: GlassTextField(
          controller: _contactPersonCtrl,
          label: l.orgRegContactPerson,
          hint: l.orgRegContactPersonHint,
          prefixIcon: Icons.person_outline_rounded,
          textInputAction: TextInputAction.next,
          validator: (v) => (v == null || v.trim().isEmpty)
              ? l.orgRegContactPersonRequired
              : null,
        ),
      ),
      const SizedBox(height: AppSpacing.md),
      FadeSlideIn(
        delay: const Duration(milliseconds: 400),
        child: GlassTextField(
          controller: _phoneCtrl,
          label: l.orgRegPhone,
          hint: l.orgRegPhoneHint,
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
        ),
      ),
    ];
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ModeToggleButton extends StatelessWidget {
  const _ModeToggleButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: AppRadius.borderRadiusMd,
          border: Border.all(
            color: selected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
