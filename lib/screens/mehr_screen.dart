import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../auth/auth_service.dart';
import '../auth/user_profile_service.dart';
import '../main.dart';
import '../ui/ui.dart';
import '../features/doctor_invite/presentation/connect_doctor_screen.dart';
import 'caregiver_screen.dart' show CaregiverScreen;
import 'linked_doctors_screen.dart';
import 'help_screen.dart';
import 'notification_settings_screen.dart';
import 'profile_settings_screen.dart';
import 'progress_screen.dart';
import 'symptom_checker_screen.dart';
import '../features/vitals/presentation/vitals_screen.dart';
import '../features/wound/presentation/wound_hub_screen.dart';

// ════════════════════════════════════════════════════════════════════════════
// Data model for a single grid tile
// ════════════════════════════════════════════════════════════════════════════

class _TileData {
  const _TileData({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
    this.isProFeature = false,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final LinearGradient gradient;
  final VoidCallback Function(BuildContext) onTap;
  final bool isProFeature;
}

class _SectionData {
  const _SectionData({
    required this.emoji,
    required this.title,
    required this.gradient,
    required this.tiles,
  });

  final String emoji;
  final String title;
  final LinearGradient gradient;
  final List<_TileData> tiles;
}

// ════════════════════════════════════════════════════════════════════════════
// MehrScreen – Premium grid layout
// ════════════════════════════════════════════════════════════════════════════

class MehrScreen extends StatefulWidget {
  const MehrScreen({super.key});

  @override
  State<MehrScreen> createState() => _MehrScreenState();
}

class _MehrScreenState extends State<MehrScreen> {
  // ── Section definitions ─────────────────────────────────────────────────

  List<_SectionData> _buildSections() {
    return [
      _SectionData(
        emoji: '❤️',
        title: 'Gesundheit & Tracking',
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
        ),
        tiles: [
          _TileData(
            emoji: '🩺',
            title: 'Vitalwerte',
            subtitle: 'Blutdruck, Puls & Temperatur',
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
            ),
            onTap: (ctx) => () => Navigator.of(ctx).push(
                  MaterialPageRoute<void>(
                      builder: (_) => const VitalsScreen()),
                ),
          ),
          _TileData(
            emoji: '🩹',
            title: 'Wunddoku',
            subtitle: 'Fotos & Heilungsverlauf',
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFAF52DE), Color(0xFFDA70D6)],
            ),
            onTap: (ctx) => () => Navigator.of(ctx).push(
                  MaterialPageRoute<void>(
                      builder: (_) => const WoundHubScreen()),
                ),
          ),
          _TileData(
            emoji: '📊',
            title: 'Schmerz',
            subtitle: 'Schmerzlevel tracken',
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFF9500), Color(0xFFFFBE76)],
            ),
            onTap: (ctx) => () => Navigator.of(ctx).pushNamed('/pain'),
          ),
          _TileData(
            emoji: '🧩',
            title: 'Symptom-Check',
            subtitle: 'Beschwerden bewerten',
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF007AFF), Color(0xFF5AC8FA)],
            ),
            onTap: (ctx) => () => Navigator.of(ctx).push(
                  MaterialPageRoute<void>(
                      builder: (_) => const SymptomCheckerScreen()),
                ),
          ),
          _TileData(
            emoji: '🏋️',
            title: 'Rehabilitation',
            subtitle: 'Übungen & Timer',
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF34C759), Color(0xFF6EE29A)],
            ),
            isProFeature: true,
            onTap: (ctx) => () => Navigator.of(ctx).pushNamed('/rehab'),
          ),
          _TileData(
            emoji: '📈',
            title: 'Analytics',
            subtitle: 'Daten im Verlauf',
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF5856D6), Color(0xFF8E8BF5)],
            ),
            isProFeature: true,
            onTap: (ctx) =>
                () => Navigator.of(ctx).pushNamed('/analytics'),
          ),
          _TileData(
            emoji: '🚨',
            title: 'Red Flags',
            subtitle: 'Warnungen & Notfall',
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFF3B30), Color(0xFFFF6961)],
            ),
            onTap: (ctx) => () => Navigator.of(ctx).pushNamed('/alerts'),
          ),
          _TileData(
            emoji: '🍽️',
            title: 'Ernährung',
            subtitle: 'Mahlzeiten & Verträglichkeit',
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF34C759), Color(0xFF81C784)],
            ),
            onTap: (ctx) =>
                () => Navigator.of(ctx).pushNamed('/nutrition'),
          ),
          _TileData(
            emoji: '💪',
            title: 'Fortschritt',
            subtitle: 'Streaks & Abzeichen',
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF34C759), Color(0xFF30D158)],
            ),
            isProFeature: true,
            onTap: (ctx) => () => Navigator.of(ctx).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ProgressScreen(),
                  ),
                ),
          ),
        ],
      ),
      _SectionData(
        emoji: '📝',
        title: 'Dokumentation',
        gradient: const LinearGradient(
          colors: [Color(0xFF5856D6), Color(0xFF8E8BF5)],
        ),
        tiles: [
          _TileData(
            emoji: '🎤',
            title: 'Sprache',
            subtitle: 'Speech-to-Text',
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF5856D6), Color(0xFF8E8BF5)],
            ),
            isProFeature: true,
            onTap: (ctx) =>
                () => Navigator.of(ctx).pushNamed('/speech'),
          ),
          _TileData(
            emoji: '📸',
            title: 'Fotos',
            subtitle: 'Kamera & Galerie',
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF007AFF), Color(0xFF5AC8FA)],
            ),
            onTap: (ctx) => () => Navigator.of(ctx).pushNamed('/photos'),
          ),
          _TileData(
            emoji: '❓',
            title: 'Arztfragen',
            subtitle: 'Fragen sammeln',
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0A84FF), Color(0xFF64B5F6)],
            ),
            onTap: (ctx) =>
                () => Navigator.of(ctx).pushNamed('/doctor-questions'),
          ),
          _TileData(
            emoji: '🧑‍⚕️',
            title: 'Arztbericht',
            subtitle: 'Infos auf einen Blick',
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF00C7BE), Color(0xFF64DFDF)],
            ),
            isProFeature: true,
            onTap: (ctx) =>
                () => Navigator.of(ctx).pushNamed('/doctor-report'),
          ),
        ],
      ),
      _SectionData(
        emoji: '🏥',
        title: 'OP-Vorbereitung',
        gradient: const LinearGradient(
          colors: [Color(0xFF007AFF), Color(0xFF5AC8FA)],
        ),
        tiles: [
          _TileData(
            emoji: '📖',
            title: 'OP-Infos',
            subtitle: 'Alles zur Operation',
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF007AFF), Color(0xFF5AC8FA)],
            ),
            onTap: (ctx) => () => Navigator.of(ctx).pushNamed('/op-info'),
          ),
          _TileData(
            emoji: '🧳',
            title: 'Packliste',
            subtitle: 'Klinik-Checkliste',
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFF9500), Color(0xFFFFBE76)],
            ),
            onTap: (ctx) => () => Navigator.of(ctx).pushNamed('/packing'),
          ),
          _TileData(
            emoji: '📅',
            title: 'Termine',
            subtitle: 'Schnelle Erfassung',
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF5856D6), Color(0xFF8E8BF5)],
            ),
            onTap: (ctx) =>
                () => Navigator.of(ctx).pushNamed('/appointments'),
          ),
        ],
      ),
      _SectionData(
        emoji: '🤝',
        title: 'Kontakt & Soziales',
        gradient: const LinearGradient(
          colors: [Color(0xFF34C759), Color(0xFF6EE29A)],
        ),
        tiles: [
          _TileData(
            emoji: '👪',
            title: 'Angehörige',
            subtitle: 'Begleiter einladen',
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF34C759), Color(0xFF6EE29A)],
            ),
            isProFeature: true,
            onTap: (ctx) => () => Navigator.of(ctx).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const CaregiverScreen(),
                  ),
                ),
          ),
          _TileData(
            emoji: '🩺',
            title: 'Arzt verbinden',
            subtitle: 'Code eingeben',
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF007AFF), Color(0xFF5AC8FA)],
            ),
            onTap: (ctx) => () => Navigator.of(ctx).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ConnectDoctorScreen(),
                  ),
                ),
          ),
          _TileData(
            emoji: '👨‍⚕️',
            title: 'Meine Ärzte',
            subtitle: 'Rechte verwalten',
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF5856D6), Color(0xFF9B8FFF)],
            ),
            onTap: (ctx) => () => Navigator.of(ctx).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const LinkedDoctorsScreen(),
                  ),
                ),
          ),
          _TileData(
            emoji: '🔔',
            title: 'Benachrich-\ntigungen',
            subtitle: 'Push anpassen',
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFF9500), Color(0xFFFFBE76)],
            ),
            onTap: (ctx) => () => Navigator.of(ctx).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const NotificationSettingsScreen(),
                  ),
                ),
          ),
          _TileData(
            emoji: '💬',
            title: 'Hilfe',
            subtitle: 'FAQ & Support',
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF5856D6), Color(0xFF8E8BF5)],
            ),
            onTap: (ctx) => () => Navigator.of(ctx).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const HelpScreen(),
                  ),
                ),
          ),
        ],
      ),
      _SectionData(
        emoji: '⚙️',
        title: 'Konto & Einstellungen',
        gradient: const LinearGradient(
          colors: [Color(0xFF636366), Color(0xFF8E8E93)],
        ),
        tiles: [
          _TileData(
            emoji: '👤',
            title: 'Profil',
            subtitle: 'Daten verwalten',
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF007AFF), Color(0xFF5AC8FA)],
            ),
            onTap: (ctx) => () => Navigator.of(ctx).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ProfileSettingsScreen(),
                  ),
                ),
          ),
          _TileData(
            emoji: '🔧',
            title: 'Einstellungen',
            subtitle: 'Account & Daten',
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF636366), Color(0xFF8E8E93)],
            ),
            onTap: (ctx) => () => Navigator.of(ctx).pushNamed('/settings'),
          ),
          _TileData(
            emoji: '👋',
            title: 'Abmelden',
            subtitle: 'Bis bald!',
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFF3B30), Color(0xFFFF6961)],
            ),
            onTap: (ctx) => () async => AuthService().signOut(),
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final sections = _buildSections();

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
          // ── Header ────────────────────────────────────────────
          FadeSlideIn(
            child: Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.xs,
                bottom: AppSpacing.sm,
              ),
              child: Text(
                'Entdecken',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
              ),
            ),
          ),
          FadeSlideIn(
            delay: const Duration(milliseconds: 60),
            child: Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.xs,
                bottom: AppSpacing.xxl,
              ),
              child: Text(
                'Alle Funktionen auf einen Blick',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                      letterSpacing: -0.1,
                    ),
              ),
            ),
          ),

          // ── Pro Banner ────────────────────────────────────────
          FadeSlideIn(
            delay: const Duration(milliseconds: 120),
            child: _ProBannerCard(),
          ),
          const SizedBox(height: AppSpacing.xxxl),

          // ── Sections with grid tiles ──────────────────────────
          for (final section in sections) ...[
            _GridSection(section: section),
            const SizedBox(height: AppSpacing.xxl),
          ],

          // ── Debug ─────────────────────────────────────────────
          if (kDebugMode) ..._buildDebugSection(context),

          // ── Footer ────────────────────────────────────────────
          const SizedBox(height: AppSpacing.lg),
          FadeSlideIn(
            delay: const Duration(milliseconds: 400),
            child: Center(
              child: Text(
                'Mit ❤️ gebaut für deine Genesung',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w400,
                ),
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
          if (!snapshot.hasData || snapshot.data != AppUserRole.admin) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: _DebugGrid(),
          );
        },
      ),
    ];
  }
}

// ════════════════════════════════════════════════════════════════════════════
// _GridSection – Section header + 2-column animated grid
// ════════════════════════════════════════════════════════════════════════════

class _GridSection extends StatelessWidget {
  const _GridSection({required this.section});

  final _SectionData section;

  @override
  Widget build(BuildContext context) {
    final mainColor = section.gradient.colors.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        FadeSlideIn(
          child: Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.xs,
              bottom: AppSpacing.lg,
            ),
            child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: section.gradient,
                  borderRadius: AppRadius.borderRadiusSm,
                  boxShadow: [
                    BoxShadow(
                      color: mainColor.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    section.emoji,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  section.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: mainColor.withValues(alpha: 0.08),
                  borderRadius: AppRadius.borderRadiusPill,
                ),
                child: Text(
                  '${section.tiles.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: mainColor,
                  ),
                ),
              ),
            ],
          ),
          ),
        ),

        // 2-column grid
        _buildGrid(context),
      ],
    );
  }

  Widget _buildGrid(BuildContext context) {
    final tiles = section.tiles;
    final List<Widget> rows = [];

    for (int i = 0; i < tiles.length; i += 2) {
      final left = tiles[i];
      final right = (i + 1 < tiles.length) ? tiles[i + 1] : null;

      rows.add(
        Padding(
          padding: EdgeInsets.only(
            bottom: i + 2 < tiles.length ? AppSpacing.md : 0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _GridTile(data: left)),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: right != null
                    ? _GridTile(data: right)
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      );
    }

    return Column(children: rows);
  }
}

// ════════════════════════════════════════════════════════════════════════════
// _GridTile – Premium glass card with gradient icon, shimmer & haptic press
// ════════════════════════════════════════════════════════════════════════════

class _GridTile extends StatelessWidget {
  const _GridTile({required this.data});

  final _TileData data;

  @override
  Widget build(BuildContext context) {
    final tile = data;
    final gradColors = tile.gradient.colors;
    final mainColor = gradColors.first;
    final isPro = tile.isProFeature &&
        !(ProServices.maybeOf(context)?.entitlementService.isPro ?? false);

    return PressableScale(
      onTap: () {
        Haptic.selection();
        tile.onTap(context)();
      },
      scaleFactor: 0.94,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: AppRadius.borderRadiusLg,
          border: Border.all(
            color: mainColor.withValues(alpha: 0.10),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: mainColor.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
              spreadRadius: -4,
            ),
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: GlassContainer(
          borderRadius: AppRadius.borderRadiusLg,
          variant: GlassVariant.medium,
          elevation: GlassElevation.flat,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emoji icon with gradient background
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _EmojiIcon(
                    emoji: tile.emoji,
                    gradient: tile.gradient,
                    mainColor: mainColor,
                  ),
                  if (isPro)
                    _ProBadge()
                  else
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: mainColor.withValues(alpha: 0.4),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Title
              Text(
                tile.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),

              // Subtitle
              Text(
                tile.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary.withValues(alpha: 0.85),
                  height: 1.3,
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              // Bottom accent line
              Container(
                height: 3,
                width: 28,
                decoration: BoxDecoration(
                  gradient: tile.gradient,
                  borderRadius: AppRadius.borderRadiusPill,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// _AnimatedEmojiIcon – Floating emoji with subtle breathing glow
// ════════════════════════════════════════════════════════════════════════════

class _EmojiIcon extends StatelessWidget {
  const _EmojiIcon({
    required this.emoji,
    required this.gradient,
    required this.mainColor,
  });

  final String emoji;
  final LinearGradient gradient;
  final Color mainColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: AppRadius.borderRadiusMd,
        boxShadow: [
          BoxShadow(
            color: mainColor.withValues(alpha: 0.20),
            blurRadius: 12,
            offset: const Offset(0, 3),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Center(
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// _ProBadge – Premium PRO label for grid tiles
// ════════════════════════════════════════════════════════════════════════════

class _ProBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
        ),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF007AFF).withValues(alpha: 0.25),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Text(
        'PRO',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// _DebugGrid – Debug tools in grid layout (debug mode only)
// ════════════════════════════════════════════════════════════════════════════

class _DebugGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.xs,
            bottom: AppSpacing.lg,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF9500), Color(0xFFFFBB4D)],
                  ),
                  borderRadius: AppRadius.borderRadiusSm,
                ),
                child: const Center(
                  child: Text('🐛', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Debug-Tools',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _GridTile(
                data: _TileData(
                  emoji: '🧪',
                  title: 'Firebase Test',
                  subtitle: 'Firestore & Rules',
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFF9500), Color(0xFFFFBE76)],
                  ),
                  onTap: (ctx) =>
                      () => Navigator.of(ctx).pushNamed('/debug/firebase'),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _GridTile(
                data: _TileData(
                  emoji: '🔍',
                  title: 'Role Debug',
                  subtitle: 'UID & Rolle',
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFF9500), Color(0xFFFFBE76)],
                  ),
                  onTap: (ctx) =>
                      () => Navigator.of(ctx).pushNamed('/role-debug'),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// _ProBannerCard – Prominent Pro upsell on the Mehr / Discover screen
// ════════════════════════════════════════════════════════════════════════════

class _ProBannerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final pro = ProServices.maybeOf(context);
    if (pro == null) return const SizedBox.shrink();

    return ValueListenableBuilder(
      valueListenable: pro.entitlementService.entitlement,
      builder: (context, entitlement, _) {
        if (entitlement.isPro) {
          return _ProActiveCard();
        }
        return _ProUpsellBanner();
      },
    );
  }
}

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
                _BulletPoint(text: 'Angehörige einladen & gemeinsam begleiten'),
                const SizedBox(height: 6),
                _BulletPoint(text: 'Timeline besser organisieren'),
                const SizedBox(height: 6),
                _BulletPoint(text: 'Alle Funktionen ohne Einschränkung'),
                const SizedBox(height: AppSpacing.xl),
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
