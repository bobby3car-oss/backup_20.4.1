import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../auth/auth_service.dart';
import '../features/pro/presentation/pro_upsell_sheet.dart';
import '../ui/ui.dart';
import 'alert_screen.dart';
import 'caregiver_screen.dart';
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
                emoji: '🚨',
                title: 'Red-Flag System',
                subtitle: 'Warnungen & Notfallaktionen',
                accentColor: const Color(0xFFFF3B30),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const AlertScreen()),
                ),
              ),
              _MenuItem(
                emoji: '💪',
                title: 'Fortschritt',
                subtitle: 'Streaks, Abzeichen & Recovery',
                accentColor: const Color(0xFF34C759),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ProgressScreen(),
                  ),
                ),
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
                onTap: () => Navigator.of(context).pushNamed('/speech'),
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
                onTap: () => ProUpsellSheet.show(
                  context: context,
                  emoji: '👨\u200D👩\u200D👧',
                  title: 'Angehörige einladen',
                  body:
                      'Mit Pro kannst du Familienmitglieder\nin deine OP Timeline einladen.',
                  cta: 'Pro freischalten',
                  onProAction: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const CaregiverScreen(),
                    ),
                  ),
                ),
              ),
              _MenuItem(
                emoji: '🔗',
                title: 'Linking / Einladungen',
                subtitle: 'Invite erstellen oder akzeptieren',
                accentColor: const Color(0xFF007AFF),
                onTap: () => Navigator.of(context).pushNamed('/linking'),
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
                onTap: () {},
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

          // Debug (nur im Debug-Modus)
          if (kDebugMode) ...[
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
                  onTap: () => Navigator.of(context).pushNamed('/role-debug'),
                ),
              ],
            ),
          ],

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
  });

  final String emoji;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;

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
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
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
