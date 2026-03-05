import 'package:flutter/material.dart';

import '../../ui/ui.dart';

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

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(title: const Text('Anmelden')),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.lg),

              // ── Header ────────────────────────────────────────
              Text(
                'Willkommen zurück',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Melde dich mit deinem Konto an.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),

              // ── Email ─────────────────────────────────────────
              GlassTextField(
                controller: _emailCtrl,
                label: 'E-Mail',
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                validator: (v) => (v == null || !v.contains('@'))
                    ? 'Gültige E‑Mail eingeben'
                    : null,
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Password ──────────────────────────────────────
              GlassTextField(
                controller: _passwordCtrl,
                label: 'Passwort',
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: _obscure,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
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
              const SizedBox(height: AppSpacing.sm),

              // ── Forgot password ───────────────────────────────
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Passwort zurücksetzen – kommt bald'),
                      ),
                    );
                  },
                  child: const Text(
                    'Passwort vergessen?',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // ── Login button ──────────────────────────────────
              GlassButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Login – kommt bald')),
                    );
                  }
                },
                label: 'Anmelden',
                icon: Icons.login_rounded,
                expand: true,
              ),
              const SizedBox(height: AppSpacing.xxxl),

              // ── Biometric placeholder ─────────────────────────
              const _BiometricSection(),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _BiometricSection extends StatelessWidget {
  const _BiometricSection();

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      child: Column(
        children: [
          Text(
            'Schnellanmeldung',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _BiometricOption(
                icon: Icons.face_rounded,
                label: 'Face ID',
                onTap: () {},
              ),
              const SizedBox(width: AppSpacing.xxxl),
              _BiometricOption(
                icon: Icons.fingerprint_rounded,
                label: 'Touch ID',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Verfügbar nach erstmaliger Anmeldung',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _BiometricOption extends StatelessWidget {
  const _BiometricOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: AppRadius.borderRadiusLg,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Icon(icon, size: 28, color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
