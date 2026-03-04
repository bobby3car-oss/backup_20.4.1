import 'package:flutter/material.dart';

import '../../ui/ui.dart';

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
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Geburtsdatum wählen',
      cancelText: 'Abbrechen',
      confirmText: 'Übernehmen',
    );
    if (picked != null) {
      _birthCtrl.text =
          '${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(title: const Text('Registrieren')),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.lg),

              Text(
                'Konto erstellen',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Fülle die Felder aus, um loszulegen.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: AppSpacing.xxxl),

              // ── Name ──────────────────────────────────────────
              GlassTextField(
                controller: _nameCtrl,
                label: 'Vollständiger Name',
                prefixIcon: Icons.person_outline_rounded,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Name eingeben' : null,
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Email ─────────────────────────────────────────
              GlassTextField(
                controller: _emailCtrl,
                label: 'E-Mail',
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                validator: (v) =>
                    (v == null || !v.contains('@')) ? 'Gültige E‑Mail eingeben' : null,
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Birth date ────────────────────────────────────
              GestureDetector(
                onTap: _pickDate,
                child: AbsorbPointer(
                  child: GlassTextField(
                    controller: _birthCtrl,
                    label: 'Geburtsdatum',
                    hint: 'TT.MM.JJJJ',
                    prefixIcon: Icons.cake_outlined,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Geburtsdatum wählen' : null,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Password ──────────────────────────────────────
              GlassTextField(
                controller: _passwordCtrl,
                label: 'Passwort',
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                    color: AppColors.grey500,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                validator: (v) =>
                    (v == null || v.length < 6) ? 'Mindestens 6 Zeichen' : null,
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Confirm password ──────────────────────────────
              GlassTextField(
                controller: _confirmCtrl,
                label: 'Passwort wiederholen',
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: _obscureConfirm,
                textInputAction: TextInputAction.done,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                    color: AppColors.grey500,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Passwort wiederholen';
                  if (v != _passwordCtrl.text) {
                    return 'Passwörter stimmen nicht überein';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.xxl),

              // ── AGB checkbox ──────────────────────────────────
              GlassContainer(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
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
                            text: 'Ich akzeptiere die ',
                            style: Theme.of(context).textTheme.bodySmall,
                            children: const [
                              TextSpan(
                                text: 'AGB und Datenschutzerklärung',
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
              const SizedBox(height: AppSpacing.xxl),

              // ── Create account ────────────────────────────────
              GlassButton(
                onPressed: _agbAccepted
                    ? () {
                        if (_formKey.currentState?.validate() ?? false) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Registrierung – kommt bald'),
                            ),
                          );
                        }
                      }
                    : null,
                label: 'Konto erstellen',
                icon: Icons.person_add_rounded,
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
