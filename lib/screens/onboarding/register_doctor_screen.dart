import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

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

class _RegisterDoctorScreenState extends State<RegisterDoctorScreen>
    with SingleTickerProviderStateMixin {
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
  bool _submitted = false;

  late final AnimationController _checkAnim;

  @override
  void initState() {
    super.initState();
    _checkAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _approbationCtrl.dispose();
    _practiceNameCtrl.dispose();
    _kvNumberCtrl.dispose();
    _checkAnim.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedSpecialty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte Fachrichtung wählen')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final callable =
          FirebaseFunctions.instance.httpsCallable('registerDoctor');
      await callable.call(<String, dynamic>{
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'password': _passwordCtrl.text,
        'specialty': _selectedSpecialty,
        'approbationNumber': _approbationCtrl.text.trim(),
        'practiceName': _practiceNameCtrl.text.trim(),
        'kvNumber': _kvNumberCtrl.text.trim(),
      });

      if (!mounted) return;
      setState(() => _submitted = true);
      _checkAnim.forward();
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Registrierung fehlgeschlagen')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ein Fehler ist aufgetreten')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_submitted) return _SuccessView(animation: _checkAnim);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: const Text('Arzt‑Registrierung'),
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
                                    Text('Zugang für Ärzt*innen',
                                        style:
                                            theme.textTheme.titleMedium),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Nach der Registrierung prüft '
                                      'unser Team Ihre Angaben.',
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
                          label: 'Persönliche Daten',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      FadeSlideIn(
                        delay: const Duration(milliseconds: 120),
                        child: GlassTextField(
                          controller: _nameCtrl,
                          label: 'Vollständiger Name',
                          hint: 'Dr. med. Max Mustermann',
                          prefixIcon: Icons.badge_outlined,
                          textInputAction: TextInputAction.next,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Name eingeben'
                              : null,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      FadeSlideIn(
                        delay: const Duration(milliseconds: 160),
                        child: GlassTextField(
                          controller: _emailCtrl,
                          label: 'Dienst‑E‑Mail',
                          hint: 'arzt@klinik.de',
                          prefixIcon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'E‑Mail eingeben';
                            }
                            if (!v.contains('@') || !v.contains('.')) {
                              return 'Gültige E‑Mail eingeben';
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
                          label: 'Passwort',
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
                              return 'Mindestens 8 Zeichen';
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
                          label: 'Berufliche Angaben',
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
                            decoration: const InputDecoration(
                              labelText: 'Fachrichtung',
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
                                ? 'Fachrichtung wählen'
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      FadeSlideIn(
                        delay: const Duration(milliseconds: 320),
                        child: GlassTextField(
                          controller: _approbationCtrl,
                          label: 'Approbationsnummer',
                          hint: 'Ihre ärztliche Approbationsnummer',
                          prefixIcon: Icons.verified_outlined,
                          textInputAction: TextInputAction.next,
                          validator: (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Approbationsnummer eingeben'
                                  : null,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      FadeSlideIn(
                        delay: const Duration(milliseconds: 360),
                        child: GlassTextField(
                          controller: _practiceNameCtrl,
                          label: 'Praxis / Klinik',
                          hint: 'Name der Praxis oder Klinik',
                          prefixIcon: Icons.business_outlined,
                          textInputAction: TextInputAction.next,
                          validator: (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Praxis/Klinik eingeben'
                                  : null,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      FadeSlideIn(
                        delay: const Duration(milliseconds: 400),
                        child: GlassTextField(
                          controller: _kvNumberCtrl,
                          label: 'KV‑Nummer (optional)',
                          hint: 'Falls vorhanden',
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
                              ? 'Wird gesendet …'
                              : 'Zugang beantragen',
                          icon: Icons.send_rounded,
                          expand: true,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      FadeSlideIn(
                        delay: const Duration(milliseconds: 480),
                        child: Text(
                          'Ihre Angaben werden vertraulich behandelt und '
                          'ausschließlich zur Verifizierung verwendet.',
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

// ── Success screen after submission ──────────────────────────────────

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.animation});
  final AnimationController animation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: AppSpacing.screenPadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: CurvedAnimation(
                      parent: animation,
                      curve: Curves.elasticOut,
                    ),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                        size: 48,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    'Antrag eingereicht',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Vielen Dank für Ihre Registrierung!\n\n'
                    'Unser Team prüft Ihre Angaben und '
                    'schaltet Ihren Zugang frei. '
                    'Sie erhalten eine Benachrichtigung, sobald '
                    'Ihr Konto verifiziert wurde.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  GlassButton(
                    onPressed: () => Navigator.of(context).pop(),
                    label: 'Zurück zum Login',
                    icon: Icons.arrow_back_rounded,
                    expand: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
