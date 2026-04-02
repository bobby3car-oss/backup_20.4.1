import 'package:flutter/material.dart';

import '../../features/settings/presentation/legal/privacy_screen.dart';
import '../../features/settings/presentation/legal/terms_screen.dart';
import '../../ui/ui.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import '../../l10n/app_localizations.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final mq = MediaQuery.of(context);
    final topPadding = mq.padding.top;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F0FE), Color(0xFFF2F2F7), AppColors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: AppSpacing.xxl,
              right: AppSpacing.xxl,
              top: topPadding > 0 ? AppSpacing.xxxl : AppSpacing.huge,
            ),
            child: Column(
              children: [
                // ── Logo ──────────────────────────────────────────
                _Logo(),
                const SizedBox(height: AppSpacing.xxl),

                // ── Claim ─────────────────────────────────────────
                Text(
                  'Dein digitaler\nOP-Begleiter',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontSize: 32,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Alle Informationen rund um deinen\nEingriff – sicher und übersichtlich.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: AppSpacing.huge),

                // ── Buttons ───────────────────────────────────────
                GlassButton(
                  onPressed: () => _push(context, const LoginScreen()),
                  label: l.login,
                  icon: Icons.login_rounded,
                  expand: true,
                ),
                const SizedBox(height: AppSpacing.md),
                GlassButton(
                  onPressed: () => _push(context, const RegisterScreen()),
                  label: l.register,
                  icon: Icons.person_add_outlined,
                  variant: GlassButtonVariant.secondary,
                  expand: true,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const PrivacyScreen(),
                        ),
                      ),
                      child: Text(
                        l.privacyPolicy,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    Text(
                      ' · ',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary.withValues(alpha: 0.4),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const TermsScreen(),
                        ),
                      ),
                      child: Text(
                        l.termsOfUse,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.huge),

                // ── 3-Step explanation ────────────────────────────
                _StepExplanation(),
                const SizedBox(height: AppSpacing.huge),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.xl),
      borderRadius: AppRadius.borderRadiusXxl,
      child: Image.asset(
        'assets/images/app_logo.png',
        width: 56,
        height: 56,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _StepExplanation extends StatelessWidget {
  _StepExplanation();

  static final _steps = [
    _StepData(
      icon: Icons.app_registration_rounded,
      title: 'Registrieren',
      description: 'Erstelle dein Konto in wenigen Sekunden.',
    ),
    _StepData(
      icon: Icons.assignment_outlined,
      title: 'Daten eingeben',
      description: 'Füge deine OP-Informationen hinzu.',
    ),
    _StepData(
      icon: Icons.check_circle_outline_rounded,
      title: 'Begleitet werden',
      description: 'Erhalte alle Infos Schritt für Schritt.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.xl),
      borderRadius: AppRadius.borderRadiusXl,
      child: Column(
        children: [
          Text(
            'So funktioniert es',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.xl),
          for (var i = 0; i < _steps.length; i++) ...[
            _StepRow(step: _steps[i], index: i + 1),
            if (i < _steps.length - 1) ...[
              Padding(
                padding: const EdgeInsets.only(left: 19),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 2,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.grey200,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _StepData {
  const _StepData({
    required this.icon,
    required this.title,
    required this.description,
  });
  final IconData icon;
  final String title;
  final String description;
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.step, required this.index});

  final _StepData step;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: AppRadius.borderRadiusMd,
          ),
          child: Center(
            child: Text(
              '$index',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(step.title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                step.description,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
