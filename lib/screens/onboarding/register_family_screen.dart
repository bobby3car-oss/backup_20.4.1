import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../ui/ui.dart';
import '../qr_scanner_screen.dart';

class RegisterFamilyScreen extends StatefulWidget {
  const RegisterFamilyScreen({super.key, this.initialCode});

  final String? initialCode;

  @override
  State<RegisterFamilyScreen> createState() =>
      _RegisterFamilyScreenState();
}

class _RegisterFamilyScreenState extends State<RegisterFamilyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _obscure = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialCode != null) {
      _codeCtrl.text = widget.initialCode!;
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _scanQrCode() async {
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const QrScannerScreen()),
    );
    if (code != null && mounted) {
      setState(() => _codeCtrl.text = code);
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _busy = true);

    try {
      // 1. Create Firebase Auth account
      final cred =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );

      // Update display name
      await cred.user?.updateDisplayName(_nameCtrl.text.trim());

      // 2. Accept the invite via Cloud Function
      final code = _codeCtrl.text.trim().toUpperCase();
      await FirebaseFunctions.instance
          .httpsCallable('acceptInvite')
          .call<Map<String, dynamic>>({'code': code});

      if (mounted) {
        // Navigate to root — AuthGate will pick up family role
        Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_authErrorMessage(e.code))),
        );
      }
    } on FirebaseFunctionsException catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Einladungsfehler: ${e.message ?? e.code}'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e')),
        );
      }
    }
  }

  String _authErrorMessage(String code) => switch (code) {
    'email-already-in-use' => 'Diese E-Mail wird bereits verwendet.',
    'weak-password' => 'Passwort ist zu schwach.',
    'invalid-email' => 'Ungültige E-Mail-Adresse.',
    _ => 'Registrierungsfehler ($code)',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(title: const Text('Angehöriger')),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.lg),

              Text(
                'Als Angehöriger beitreten',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Gib den Einladungscode ein, den du vom '
                'Patienten erhalten hast.',
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
                        color: AppColors.accent.withValues(alpha: 0.12),
                        borderRadius: AppRadius.borderRadiusMd,
                      ),
                      child: const Icon(
                        Icons.people_rounded,
                        color: AppColors.accent,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rolle: Angehöriger',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            'Begleitender Zugang mit Lesezugriff',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // ── Invitation code with QR scan ──────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: GlassTextField(
                      controller: _codeCtrl,
                      label: 'Einladungscode',
                      hint: 'z.B. A1B2C3D4E5F6',
                      prefixIcon: Icons.vpn_key_outlined,
                      textInputAction: TextInputAction.next,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty)
                              ? 'Code eingeben'
                              : null,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: GlassButton(
                      onPressed: _scanQrCode,
                      label: '',
                      icon: Icons.qr_code_scanner_rounded,
                      variant: GlassButtonVariant.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

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

              // ── Submit ────────────────────────────────────────
              GlassButton(
                onPressed: _busy ? null : _submit,
                label: _busy ? 'Wird verarbeitet…' : 'Beitreten',
                icon: _busy ? Icons.hourglass_top_rounded : Icons.group_add_rounded,
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
