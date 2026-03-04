import 'package:flutter/material.dart';

import '../../ui/ui.dart';

class RegisterDoctorScreen extends StatefulWidget {
  const RegisterDoctorScreen({super.key});

  @override
  State<RegisterDoctorScreen> createState() => _RegisterDoctorScreenState();
}

class _RegisterDoctorScreenState extends State<RegisterDoctorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _doctorKeyCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _obscure = true;

  @override
  void dispose() {
    _doctorKeyCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(title: const Text('Arzt‑Zugang')),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.lg),

              Text(
                'Arzt‑Registrierung',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Zugang für medizinisches Fachpersonal.\n'
                'Ein gültiger Arzt‑Schlüssel wird benötigt.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: AppSpacing.xxxl),

              // ── Role badge ────────────────────────────────────
              GlassContainer(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: AppRadius.borderRadiusMd,
                      ),
                      child: const Icon(
                        Icons.medical_services_outlined,
                        color: AppColors.success,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rolle: Arzt / Ärztin',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            'Vollzugriff auf Patientendaten',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // ── Doctor key ────────────────────────────────────
              GlassTextField(
                controller: _doctorKeyCtrl,
                label: 'Arzt‑Schlüssel',
                hint: 'Von der Klinik erhalten',
                prefixIcon: Icons.key_rounded,
                textInputAction: TextInputAction.next,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Schlüssel eingeben' : null,
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Email ─────────────────────────────────────────
              GlassTextField(
                controller: _emailCtrl,
                label: 'Dienst‑E‑Mail',
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                validator: (v) =>
                    (v == null || !v.contains('@')) ? 'Gültige E‑Mail eingeben' : null,
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Password ──────────────────────────────────────
              GlassTextField(
                controller: _passwordCtrl,
                label: 'Passwort',
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: _obscure,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                    color: AppColors.grey500,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
                validator: (v) =>
                    (v == null || v.length < 6) ? 'Mindestens 6 Zeichen' : null,
              ),
              const SizedBox(height: AppSpacing.xxl),

              // ── 2FA placeholder ───────────────────────────────
              const _TwoFactorPlaceholder(),
              const SizedBox(height: AppSpacing.xxl),

              // ── Submit ────────────────────────────────────────
              GlassButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Arzt‑Registrierung – kommt bald'),
                      ),
                    );
                  }
                },
                label: 'Zugang beantragen',
                icon: Icons.verified_user_outlined,
                expand: true,
              ),
              const SizedBox(height: AppSpacing.huge),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _TwoFactorPlaceholder extends StatelessWidget {
  const _TwoFactorPlaceholder();

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.10),
              borderRadius: AppRadius.borderRadiusLg,
            ),
            child: const Icon(
              Icons.security_rounded,
              color: AppColors.warning,
              size: 26,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Zwei‑Faktor‑Authentifizierung',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Nach erfolgreicher Verifizierung des Arzt‑Schlüssels '
            'wird ein zweiter Faktor zur Absicherung eingerichtet.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  height: 1.45,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _TwoFAMethod(
                icon: Icons.sms_outlined,
                label: 'SMS',
              ),
              const SizedBox(width: AppSpacing.xl),
              _TwoFAMethod(
                icon: Icons.email_outlined,
                label: 'E-Mail',
              ),
              const SizedBox(width: AppSpacing.xl),
              _TwoFAMethod(
                icon: Icons.app_settings_alt_rounded,
                label: 'App',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TwoFAMethod extends StatelessWidget {
  const _TwoFAMethod({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.grey100,
            borderRadius: AppRadius.borderRadiusMd,
            border: Border.all(color: AppColors.grey200, width: 0.5),
          ),
          child: Icon(icon, size: 22, color: AppColors.grey600),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
