import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../auth/auth_service.dart';
import '../auth/user_profile_service.dart';
import '../features/pro/domain/trigger_context.dart';
import '../features/pro/presentation/smart_paywall.dart';
import '../main.dart';
import '../ui/ui.dart';
import '../features/doctor_invite/presentation/connect_doctor_screen.dart';
import 'caregiver_screen.dart';
import 'help_screen.dart';
import 'notification_settings_screen.dart';
import 'profile_settings_screen.dart';
import 'progress_screen.dart';
import 'symptom_checker_screen.dart';
import '../features/vitals/presentation/vitals_screen.dart';

class MehrScreen extends StatelessWidget {
  const MehrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        physics: adaptiveScrollPhysics,
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: topPadding + AppSpacing.xl,
          bottom: 120,
        ),
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.xs,
              bottom: AppSpacing.sm,
            ),
            child: Text(
              'Entdecken',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.xs,
              bottom: AppSpacing.xxl,
            ),
            child: Text(
              'Alle Funktionen auf einen Blick ✨',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),

          // ── Pro Banner (prominent, but not annoying) ─────────
          _ProBannerCard(),
          const SizedBox(height: AppSpacing.xxl),

          // Gesundheit & Tracking
          _MenuSection(
            emoji: '❤️',
            title: 'Gesundheit & Tracking',
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
            ),
            initiallyExpanded: true,
            children: [
              _MenuItem(
                emoji: '🩺',
                title: 'Vitalwerte',
                subtitle: 'Blutdruck, Puls & Temperatur',
                accentColor: const Color(0xFFFF6B6B),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const VitalsScreen()),
                ),
              ),
              _MenuItem(
                emoji: '📊',
                title: 'Schmerztagebuch',
                subtitle: 'Schmerzlevel dokumentieren',
                accentColor: const Color(0xFFFF9500),
                onTap: () => Navigator.of(context).pushNamed('/pain'),
              ),
              _MenuItem(
                emoji: '🧩',
                title: 'Symptom-Check',
                subtitle: 'Beschwerden bewerten & Empfehlung',
                accentColor: const Color(0xFF007AFF),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const SymptomCheckerScreen(),
                  ),
                ),
              ),
              _MenuItem(
                emoji: '🏋️',
                title: 'Rehabilitation',
                subtitle: 'Übungen, Timer & Fortschritt',
                accentColor: const Color(0xFF34C759),
                onTap: () => Navigator.of(context).pushNamed('/rehab'),
              ),
              _MenuItem(
                emoji: '�',
                title: 'Analytics',
                subtitle: 'Schmerz, Vitals & Wunden im Verlauf',
                accentColor: const Color(0xFF5856D6),
                isProFeature: true,
                onTap: () async {
                  final pro = ProServices.maybeOf(context);
                  if (pro != null && pro.entitlementService.isPro) {
                    Navigator.of(context).pushNamed('/analytics');
                    return;
                  }
                  if (context.mounted) {
                    SmartPaywall.trigger(
                      context: context,
                      triggerContext: TriggerContext.analyticsFeature,
                    );
                  }
                },
              ),
              _MenuItem(
                emoji: '�🚨',
                title: 'Red-Flag System',
                subtitle: 'Warnungen & Notfallaktionen',
                accentColor: const Color(0xFFFF3B30),
                isProFeature: false,
                onTap: () {
                  Navigator.of(context).pushNamed('/alerts');
                },
              ),
              _MenuItem(
                emoji: '💪',
                title: 'Fortschritt',
                subtitle: 'Streaks, Abzeichen & Recovery',
                accentColor: const Color(0xFF34C759),
                isProFeature: true,
                onTap: () async {
                  final pro = ProServices.maybeOf(context);
                  if (pro != null && pro.entitlementService.isPro) {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const ProgressScreen(),
                      ),
                    );
                    return;
                  }
                  if (context.mounted) {
                    SmartPaywall.trigger(
                      context: context,
                      triggerContext: TriggerContext.progressFeature,
                    );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Dokumentation
          _MenuSection(
            emoji: '📝',
            title: 'Dokumentation',
            gradient: const LinearGradient(
              colors: [Color(0xFF5856D6), Color(0xFF8E8BF5)],
            ),
            children: [
              _MenuItem(
                emoji: '🎤',
                title: 'Sprache & Memos',
                subtitle: 'Speech-to-Text & Sprachnotizen',
                accentColor: const Color(0xFF5856D6),
                isProFeature: true,
                onTap: () async {
                  final pro = ProServices.maybeOf(context);
                  if (pro != null && pro.entitlementService.isPro) {
                    Navigator.of(context).pushNamed('/speech');
                    return;
                  }
                  if (context.mounted) {
                    SmartPaywall.trigger(
                      context: context,
                      triggerContext: TriggerContext.voiceFeature,
                    );
                  }
                },
              ),
              _MenuItem(
                emoji: '📸',
                title: 'Fotos',
                subtitle: 'Doku-Hub: Kamera oder Galerie',
                accentColor: const Color(0xFF007AFF),
                onTap: () => Navigator.of(context).pushNamed('/photos'),
              ),
              _MenuItem(
                emoji: '🧑‍⚕️',
                title: 'Arztbericht',
                subtitle: 'Alle Infos auf einen Blick',
                accentColor: const Color(0xFF00C7BE),
                onTap: () => Navigator.of(context).pushNamed('/doctor-report'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // OP-Vorbereitung
          _MenuSection(
            emoji: '🏥',
            title: 'OP-Vorbereitung',
            gradient: const LinearGradient(
              colors: [Color(0xFF007AFF), Color(0xFF5AC8FA)],
            ),
            children: [
              _MenuItem(
                emoji: '📖',
                title: 'OP-Infos',
                subtitle: 'Alles Wichtige zur Operation',
                accentColor: const Color(0xFF007AFF),
                onTap: () => Navigator.of(context).pushNamed('/op-info'),
              ),
              _MenuItem(
                emoji: '🧳',
                title: 'Packliste',
                subtitle: 'Checkliste: Klinik & OP-Tag',
                accentColor: const Color(0xFFFF9500),
                onTap: () => Navigator.of(context).pushNamed('/packing'),
              ),
              _MenuItem(
                emoji: '📅',
                title: 'Termine',
                subtitle: 'Tagesliste & schnelle Erfassung',
                accentColor: const Color(0xFF5856D6),
                onTap: () => Navigator.of(context).pushNamed('/appointments'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Kontakt & Soziales
          _MenuSection(
            emoji: '🤝',
            title: 'Kontakt & Soziales',
            gradient: const LinearGradient(
              colors: [Color(0xFF34C759), Color(0xFF6EE29A)],
            ),
            children: [
              _MenuItem(
                emoji: '👪',
                title: 'Angehoerige',
                subtitle: 'Begleiter verwalten & einladen',
                accentColor: const Color(0xFF34C759),
                isProFeature: true,
                onTap: () {
                  // Smart Paywall decides whether to show paywall or proceed.
                  final pro = ProServices.maybeOf(context);
                  if (pro != null && pro.entitlementService.isPro) {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const CaregiverScreen(),
                      ),
                    );
                    return;
                  }
                  SmartPaywall.trigger(
                    context: context,
                    triggerContext: TriggerContext.relativesFeature,
                  );
                },
              ),
              _MenuItem(
                emoji: '🩺',
                title: 'Mit Arzt verbinden',
                subtitle: 'Arzt-Code eingeben oder scannen',
                accentColor: const Color(0xFF007AFF),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ConnectDoctorScreen(),
                  ),
                ),
              ),
              _MenuItem(
                emoji: '🔔',
                title: 'Benachrichtigungen',
                subtitle: 'Push-Einstellungen anpassen',
                accentColor: const Color(0xFFFF9500),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const NotificationSettingsScreen(),
                  ),
                ),
              ),
              _MenuItem(
                emoji: '💬',
                title: 'Hilfe & Support',
                subtitle: 'FAQ, Tipps & Kontakt',
                accentColor: const Color(0xFF5856D6),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const HelpScreen(),
                  ),
                ),
              ),
              _MenuItem(
                emoji: '🤖',
                title: 'OP-Assistent',
                subtitle: 'KI-Hilfe zu OPs, Nachsorge & App',
                accentColor: const Color(0xFF5856D6),
                isProFeature: true,
                onTap: () {
                  final pro = ProServices.maybeOf(context);
                  if (pro != null && pro.entitlementService.isPro) {
                    Navigator.of(context).pushNamed('/assistant');
                    return;
                  }
                  SmartPaywall.trigger(
                    context: context,
                    triggerContext: TriggerContext.assistantFeature,
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Konto & Einstellungen
          _MenuSection(
            emoji: '⚙️',
            title: 'Konto & Einstellungen',
            gradient: const LinearGradient(
              colors: [Color(0xFF636366), Color(0xFF8E8E93)],
            ),
            children: [
              _MenuItem(
                emoji: '👤',
                title: 'Profil',
                subtitle: 'Persoenliche Daten verwalten',
                accentColor: const Color(0xFF007AFF),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ProfileSettingsScreen(),
                  ),
                ),
              ),
              _MenuItem(
                emoji: '🔧',
                title: 'Einstellungen',
                subtitle: 'Account, Daten & Rechtliches',
                accentColor: const Color(0xFF636366),
                onTap: () => Navigator.of(context).pushNamed('/settings'),
              ),
              _MenuItem(
                emoji: '👋',
                title: 'Abmelden',
                subtitle: 'Bis bald!',
                accentColor: const Color(0xFFFF3B30),
                onTap: () async => AuthService().signOut(),
              ),
            ],
          ),

          // Debug (nur im Debug-Modus fuer Admins)
          if (kDebugMode) ..._buildDebugSection(context),

          // Footer
          const SizedBox(height: AppSpacing.xxl),
          Center(
            child: Text(
              'Mit ❤️ gebaut fuer deine Genesung',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary.withValues(alpha: 0.6),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }

  static List<Widget> _buildDebugSection(BuildContext context) {
    return [
      FutureBuilder<AppUserRole>(
        future: UserProfileService().getMyRole(),
        builder: (context, snapshot) {
          if (!snapshot.hasData ||
              snapshot.data != AppUserRole.admin) {
            return const SizedBox.shrink();
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSpacing.lg),
              _MenuSection(
                emoji: '🐛',
                title: 'Debug-Tools',
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF9500), Color(0xFFFFBB4D)],
                ),
                children: [
                  _MenuItem(
                    emoji: '🧪',
                    title: 'Firebase Smoke Test',
                    subtitle: 'Firestore & Rules pruefen',
                    accentColor: const Color(0xFFFF9500),
                    onTap: () =>
                        Navigator.of(context).pushNamed('/debug/firebase'),
                  ),
                  _MenuItem(
                    emoji: '🔍',
                    title: 'Role Debug',
                    subtitle: 'UID, Rolle & Link-Count',
                    accentColor: const Color(0xFFFF9500),
                    onTap: () =>
                        Navigator.of(context).pushNamed('/role-debug'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    ];
  }
}

// ============================================================================
// _MenuSection - Collapsible category with gradient header & emoji
// ============================================================================

class _MenuSection extends StatefulWidget {
  const _MenuSection({
    required this.emoji,
    required this.title,
    required this.gradient,
    required this.children,
    this.initiallyExpanded = false,
  });

  final String emoji;
  final String title;
  final LinearGradient gradient;
  final List<_MenuItem> children;
  final bool initiallyExpanded;

  @override
  State<_MenuSection> createState() => _MenuSectionState();
}

class _MenuSectionState extends State<_MenuSection>
    with SingleTickerProviderStateMixin {
  late bool _expanded;
  late AnimationController _controller;
  late Animation<double> _heightFactor;
  late Animation<double> _rotation;
  late Animation<double> _headerGlow;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
      value: _expanded ? 1.0 : 0.0,
    );
    _heightFactor = _controller.drive(CurveTween(curve: Curves.easeOutCubic));
    _rotation = _controller.drive(
      Tween<double>(
        begin: 0.0,
        end: 0.5,
      ).chain(CurveTween(curve: Curves.easeInOut)),
    );
    _headerGlow = _controller.drive(
      Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).chain(CurveTween(curve: Curves.easeOut)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    Haptic.light();
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final gradColors = widget.gradient.colors;
    final mainColor = gradColors.first;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: AppRadius.borderRadiusXl,
            border: Border.all(
              color: mainColor.withValues(
                alpha: 0.08 + (_headerGlow.value * 0.12),
              ),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: mainColor.withValues(
                  alpha: 0.04 + (_headerGlow.value * 0.06),
                ),
                blurRadius: 16 + (_headerGlow.value * 8),
                offset: const Offset(0, 4),
                spreadRadius: -2,
              ),
            ],
          ),
          child: child,
        );
      },
      child: GlassContainer(
        borderRadius: AppRadius.borderRadiusXl,
        variant: GlassVariant.medium,
        elevation: GlassElevation.flat,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            GestureDetector(
              onTap: _toggle,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.lg + 2,
                ),
                child: Row(
                  children: [
                    // Gradient emoji bubble
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: widget.gradient,
                        borderRadius: AppRadius.borderRadiusMd,
                        boxShadow: [
                          BoxShadow(
                            color: mainColor.withValues(alpha: 0.30),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                            spreadRadius: -2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          widget.emoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md + 2),

                    // Title & count
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${widget.children.length} Funktionen',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: mainColor.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Chevron
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: mainColor.withValues(alpha: 0.08),
                        borderRadius: AppRadius.borderRadiusSm,
                      ),
                      child: RotationTransition(
                        turns: _rotation,
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 20,
                          color: mainColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Expandable body
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return ClipRect(
                  child: Align(
                    alignment: Alignment.topCenter,
                    heightFactor: _heightFactor.value,
                    child: child,
                  ),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Gradient divider
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    child: Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            mainColor.withValues(alpha: 0.0),
                            mainColor.withValues(alpha: 0.20),
                            mainColor.withValues(alpha: 0.0),
                          ],
                        ),
                        borderRadius: AppRadius.borderRadiusPill,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Items
                  ...widget.children,

                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// _MenuItem - Single item with emoji, accent color & chevron
// ============================================================================

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
    this.isProFeature = false,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;
  final bool isProFeature;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: () {
        Haptic.selection();
        onTap();
      },
      scaleFactor: 0.975,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 3,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md + 2,
          ),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.04),
            borderRadius: AppRadius.borderRadiusMd,
            border: Border.all(
              color: accentColor.withValues(alpha: 0.06),
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              // Emoji bubble
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.10),
                  borderRadius: AppRadius.borderRadiusSm,
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        if (isProFeature && !(ProServices.maybeOf(context)?.entitlementService.isPro ?? false)) ...[
                          const SizedBox(width: 6),
                          const _ProChip(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),

              // Accent arrow
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.08),
                  borderRadius: AppRadius.borderRadiusXs,
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: accentColor.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// _ProChip – Small "PRO" label used next to menu titles for gated features
// ============================================================================

class _ProChip extends StatelessWidget {
  const _ProChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF0A84FF).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'PRO',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: Color(0xFF0A84FF),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ============================================================================
// _ProBannerCard – Prominent Pro upsell on the Mehr / Discover screen
// ============================================================================

class _ProBannerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final pro = ProServices.maybeOf(context);
    if (pro == null) return const SizedBox.shrink();

    return ValueListenableBuilder(
      valueListenable: pro.entitlementService.entitlement,
      builder: (context, entitlement, _) {
        // Pro users: compact status row instead of upsell.
        if (entitlement.isPro) {
          return _ProActiveCard();
        }
        return _ProUpsellBanner();
      },
    );
  }
}

/// Shown when user is Pro – a subtle confirmation card.
class _ProActiveCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return GlassContainer(
      child: InkWell(
        borderRadius: AppRadius.borderRadiusLg,
        onTap: () => Navigator.of(context).pushNamed('/pro-status'),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: AppRadius.borderRadiusMd,
              ),
              child: const Center(
                child: Text('⭐', style: TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pro aktiv',
                    style: tt.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Abo & Details verwalten',
                    style: tt.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.grey400,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown when user is Free – a visually prominent upsell banner.
class _ProUpsellBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.borderRadiusXl,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.borderRadiusXl,
        child: InkWell(
          borderRadius: AppRadius.borderRadiusXl,
          onTap: () => Navigator.of(context).pushNamed(
            '/paywall',
            arguments: const {'source': 'mehr_banner'},
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: emoji + title + badge
                Row(
                  children: [
                    const Text('🚀', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        'Pro freischalten',
                        style: tt.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'PRO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Feature bullets
                _BulletPoint(text: 'Angehörige einladen & gemeinsam begleiten'),
                const SizedBox(height: 6),
                _BulletPoint(text: 'Timeline besser organisieren'),
                const SizedBox(height: 6),
                _BulletPoint(text: 'Alle Funktionen ohne Einschränkung'),
                const SizedBox(height: AppSpacing.xl),

                // CTA
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Jetzt freischalten',
                        style: tt.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  const _BulletPoint({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.7),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
