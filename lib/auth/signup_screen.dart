import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

import 'auth_service.dart';
import 'user_profile_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({
    super.key,
    AuthService? authService,
    UserProfileService? profileService,
  }) : _authService = authService,
       _profileService = profileService;

  final AuthService? _authService;
  final UserProfileService? _profileService;

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _loading = false;

  AuthService get _auth => widget._authService ?? AuthService();
  UserProfileService get _profiles =>
      widget._profileService ?? UserProfileService();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    if (_passwordController.text != _confirmPasswordController.text) {
      final l = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.validationPasswordsMismatchLegacy)),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final credential = await _auth.signUp(
        email: _emailController.text,
        password: _passwordController.text,
        displayName: _nameController.text,
      );
      final user = credential.user;
      if (user != null) {
        await _profiles.ensureUserDocExists(
          user.uid,
          email: user.email,
          displayName: user.displayName,
        );
      }
      if (!mounted) return;
      Navigator.of(context).popUntil((r) => r.isFirst);
    } catch (error) {
      if (!mounted) return;
      final l = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.errorRegistrationFailed('$error'))),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l.signupTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: l.fieldName),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(labelText: l.fieldEmail),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(labelText: l.fieldPassword),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _confirmPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: l.fieldConfirmPassword,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _loading ? null : _submit,
            child: Text(_loading ? l.creatingAccount : l.createAccount),
          ),
        ],
      ),
    );
  }
}
