import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../auth/auth_service.dart';
import '../auth/guest_data_migration_service.dart';
import 'onboarding/login_screen.dart';
import '../auth/user_profile_service.dart';
import '../main.dart';
import '../ui/ui.dart';
import '../features/doctor_invite/presentation/connect_doctor_screen.dart';
import '../features/documents/presentation/documents_screen.dart';
import 'caregiver_screen.dart' show CaregiverScreen;
import 'family_member_hub_screen.dart';
import 'linked_doctors_screen.dart';
import 'help_screen.dart';
import 'notification_settings_screen.dart';
import 'profile_settings_screen.dart';
import 'progress_screen.dart';
import 'symptom_checker_screen.dart';
import '../features/vitals/presentation/vitals_screen.dart';
import '../features/wound/presentation/wound_hub_screen.dart';
import '../ui/theme/app_icons.dart';

// ════════════════════════════════════════════════════════════════════════════
// Data models
// ════════════════════════════════════════════════════════════════════════════

class _BubbleItem {
  const _BubbleItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isProFeature = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback Function(BuildContext) onTap;
  final bool isProFeature;

  bool matches(String q) => title.toLowerCase().contains(q.toLowerCase());
}

class _BubbleGroup {
  _BubbleGroup({required this.title, required this.items});
  final String title;
  final List<_BubbleItem> items;
}

// ════════════════════════════════════════════════════════════════════════════
// MehrScreen
// ════════════════════════════════════════════════════════════════════════════

class MehrScreen extends StatefulWidget {
  const MehrScreen({super.key});

  @override
  State<MehrScreen> createState() => _MehrScreenState();
}

class _MehrScreenState extends State<MehrScreen> {
  String _query = '';

  // ── Group definitions ───────────────────────────────────────────────────

  List<_BubbleGroup> _buildGroups() {
    return [
      // ── 1. Sicherheit ────────────────────────────────────────────────
      _BubbleGroup(title: 'Sicherheit', items: [
        _BubbleItem(
          icon: AppIcons.redFlags,
          title: 'Red Flags',
          onTap: (ctx) => () => Navigator.of(ctx).pushNamed('/alerts'),
        ),
        _BubbleItem(
          icon: AppIcons.info,
          title: 'Symptom-Check',
          onTap: (ctx) => () => Navigator.of(ctx).push(
                MaterialPageRoute<void>(
                    builder: (_) => const SymptomCheckerScreen()),
              ),
        ),
      ]),

      // ── 2. Gesundheit ────────────────────────────────────────────────
      _BubbleGroup(title: 'Gesundheit', items: [
        _BubbleItem(
          icon: AppIcons.vitals,
          title: 'Vitalwerte',
          onTap: (ctx) => () => Navigator.of(ctx).push(
                MaterialPageRoute<void>(
                    builder: (_) => const VitalsScreen()),
              ),
        ),
        _BubbleItem(
          icon: AppIcons.pain,
          title: 'Schmerz',
          onTap: (ctx) => () => Navigator.of(ctx).pushNamed('/pain'),
        ),
        _BubbleItem(
          icon: AppIcons.wound,
          title: 'Wunddoku',
          onTap: (ctx) => () => Navigator.of(ctx).push(
                MaterialPageRoute<void>(
                    builder: (_) => const WoundHubScreen()),
              ),
        ),
        _BubbleItem(
          icon: AppIcons.dining,
          title: 'Ernährung',
          onTap: (ctx) => () => Navigator.of(ctx).pushNamed('/nutrition'),
        ),
        _BubbleItem(
          icon: AppIcons.medication,
          title: 'Medikamente',
          onTap: (ctx) => () => Navigator.of(ctx).pushNamed('/meds'),
        ),
      ]),

      // ── 3. Dokumentation ─────────────────────────────────────────────
      _BubbleGroup(title: 'Dokumentation', items: [
        _BubbleItem(
          icon: AppIcons.documents,
          title: 'Dokumente',
          onTap: (ctx) => () => Navigator.of(ctx).push(
                MaterialPageRoute<void>(
                    builder: (_) => const DocumentsScreen()),
              ),
        ),
        _BubbleItem(
          icon: AppIcons.photos,
          title: 'Fotos',
          onTap: (ctx) => () => Navigator.of(ctx).pushNamed('/photos'),
        ),
        _BubbleItem(
          icon: AppIcons.questions,
          title: 'Arztfragen',
          onTap: (ctx) =>
              () => Navigator.of(ctx).pushNamed('/doctor-questions'),
        ),
        _BubbleItem(
          icon: AppIcons.voice,
          title: 'Sprachnotizen',
          isProFeature: true,
          onTap: (ctx) => () => Navigator.of(ctx).pushNamed('/speech'),
        ),
        _BubbleItem(
          icon: AppIcons.doctor,
          title: 'Arztbericht',
          isProFeature: true,
          onTap: (ctx) =>
              () => Navigator.of(ctx).pushNamed('/doctor-report'),
        ),
      ]),

      // ── 4. OP & Planung ──────────────────────────────────────────────
      _BubbleGroup(title: 'OP & Planung', items: [
        _BubbleItem(
          icon: AppIcons.diary,
          title: 'OP-Infos',
          onTap: (ctx) => () => Navigator.of(ctx).pushNamed('/op-info'),
        ),
        _BubbleItem(
          icon: AppIcons.packing,
          title: 'Packliste',
          onTap: (ctx) => () => Navigator.of(ctx).pushNamed('/packing'),
        ),
        _BubbleItem(
          icon: AppIcons.appointments,
          title: 'Termine',
          onTap: (ctx) =>
              () => Navigator.of(ctx).pushNamed('/appointments'),
        ),
        _BubbleItem(
          icon: AppIcons.rehab,
          title: 'Rehabilitation',
          isProFeature: true,
          onTap: (ctx) => () => Navigator.of(ctx).pushNamed('/rehab'),
        ),
      ]),

      // ── 5. Auswertung ────────────────────────────────────────────────
      _BubbleGroup(title: 'Auswertung', items: [
        _BubbleItem(
          icon: AppIcons.analytics,
          title: 'Analytics',
          isProFeature: true,
          onTap: (ctx) => () => Navigator.of(ctx).pushNamed('/analytics'),
        ),
        _BubbleItem(
          icon: AppIcons.progress,
          title: 'Fortschritt',
          isProFeature: true,
          onTap: (ctx) => () => Navigator.of(ctx).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ProgressScreen(),
                ),
              ),
        ),
      ]),

      // ── 6. Personen ──────────────────────────────────────────────────
      _BubbleGroup(title: 'Personen', items: [
        _BubbleItem(
          icon: AppIcons.family,
          title: 'Angehörige',
          isProFeature: true,
          onTap: (ctx) => () async {
            if (!await GuestDataMigrationService.requireAuth(ctx,
                reason:
                    'Um Angehörige einzuladen, benötigst du ein Konto.')) {
              return;
            }
            if (!ctx.mounted) return;
            Navigator.of(ctx).push(
              MaterialPageRoute<void>(
                builder: (_) => const CaregiverScreen(),
              ),
            );
          },
        ),
        _BubbleItem(
          icon: AppIcons.doctor,
          title: 'Arzt verbinden',
          onTap: (ctx) => () async {
            if (!await GuestDataMigrationService.requireAuth(ctx,
                reason:
                    'Um einen Arzt zu verbinden, benötigst du ein Konto.')) {
              return;
            }
            if (!ctx.mounted) return;
            Navigator.of(ctx).push(
              MaterialPageRoute<void>(
                builder: (_) => const ConnectDoctorScreen(),
              ),
            );
          },
        ),
        _BubbleItem(
          icon: AppIcons.doctor,
          title: 'Meine Ärzte',
          onTap: (ctx) => () async {
            if (!await GuestDataMigrationService.requireAuth(ctx,
                reason:
                    'Um Ärzte zu verwalten, benötigst du ein Konto.')) {
              return;
            }
            if (!ctx.mounted) return;
            Navigator.of(ctx).push(
              MaterialPageRoute<void>(
                builder: (_) => const LinkedDoctorsScreen(),
              ),
            );
          },
        ),
        _BubbleItem(
          icon: AppIcons.family,
          title: 'Begleiten',
          onTap: (ctx) => () async {
            if (!await GuestDataMigrationService.requireAuth(ctx,
                reason:
                    'Um Patienten zu begleiten, benötigst du ein Konto.')) {
              return;
            }
            if (!ctx.mounted) return;
            Navigator.of(ctx).push(
              MaterialPageRoute<void>(
                builder: (_) => const FamilyMemberHubScreen(),
              ),
            );
          },
        ),
      ]),

      // ── 7. Konto ─────────────────────────────────────────────────────
      _BubbleGroup(title: 'Konto', items: [
        _BubbleItem(
          icon: AppIcons.profile,
          title: 'Profil',
          onTap: (ctx) => () async {
            if (!await GuestDataMigrationService.requireAuth(ctx,
                reason:
                    'Um dein Profil zu verwalten, benötigst du ein Konto.')) {
              return;
            }
            if (!ctx.mounted) return;
            Navigator.of(ctx).push(
              MaterialPageRoute<void>(
                builder: (_) => const ProfileSettingsScreen(),
              ),
            );
          },
        ),
        _BubbleItem(
          icon: AppIcons.notifications,
          title: 'Mitteilungen',
          onTap: (ctx) => () async {
            if (!await GuestDataMigrationService.requireAuth(ctx,
                reason:
                    'Für Push-Benachrichtigungen benötigst du ein Konto.')) {
              return;
            }
            if (!ctx.mounted) return;
            Navigator.of(ctx).push(
              MaterialPageRoute<void>(
                builder: (_) => const NotificationSettingsScreen(),
              ),
            );
          },
        ),
        _BubbleItem(
          icon: AppIcons.settings,
          title: 'Einstellungen',
          onTap: (ctx) => () => Navigator.of(ctx).pushNamed('/settings'),
        ),
        _BubbleItem(
          icon: AppIcons.messages,
          title: 'Hilfe',
          onTap: (ctx) => () => Navigator.of(ctx).push(
                MaterialPageRoute<void>(
                  builder: (_) => const HelpScreen(),
                ),
              ),
        ),
        if (FirebaseAuth.instance.currentUser != null)
          _BubbleItem(
            icon: CupertinoIcons.arrow_right_circle_fill,
            title: 'Abmelden',
            onTap: (ctx) => () async => AuthService().signOut(),
          )
        else
          _BubbleItem(
            icon: AppIcons.privacy,
            title: 'Anmelden',
            onTap: (ctx) => () {
              Navigator.of(ctx).push(
                MaterialPageRoute<void>(
                  builder: (_) => const LoginScreen(),
                ),
              );
            },
          ),
      ]),
    ];
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final groups = _buildGroups();
    final isSearching = _query.isNotEmpty;

    // Filter groups by search query
    final visible = <_BubbleGroup>[];
    for (final g in groups) {
      if (isSearching) {
        final matched = g.items.where((i) => i.matches(_query)).toList();
        if (matched.isNotEmpty) {
          visible.add(_BubbleGroup(title: g.title, items: matched));
        }
      } else {
        visible.add(g);
      }
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: ListView(
          physics: adaptiveScrollPhysics,
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: topPadding + AppSpacing.xl,
            bottom: 120,
          ),
          children: [
            // ── Header ──────────────────────────────────────────
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
                  bottom: AppSpacing.lg,
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

            // ── Search ──────────────────────────────────────────
            FadeSlideIn(
              delay: const Duration(milliseconds: 90),
              child: _SearchField(
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Pro banner ──────────────────────────────────────
            if (!isSearching) ...[
              FadeSlideIn(
                delay: const Duration(milliseconds: 120),
                child: _ProBannerCard(),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            // ── Bubble groups ───────────────────────────────────
            for (var i = 0; i < visible.length; i++) ...[
              FadeSlideIn(
                delay: Duration(milliseconds: isSearching ? 0 : 150 + i * 40),
                child: _GroupPanel(group: visible[i]),
              ),
              if (i < visible.length - 1)
                const SizedBox(height: AppSpacing.lg),
            ],

            // ── Empty search state ──────────────────────────────
            if (isSearching && visible.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xxxl),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        CupertinoIcons.search,
                        size: 44,
                        color: AppColors.grey300,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Keine Treffer für „$_query"',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ],
                  ),
                ),
              ),

            // ── Debug ───────────────────────────────────────────
            if (kDebugMode && !isSearching) ..._buildDebugSection(context),

            // ── Footer ──────────────────────────────────────────
            const SizedBox(height: AppSpacing.xl),
            if (!isSearching)
              FadeSlideIn(
                delay: const Duration(milliseconds: 400),
                child: Center(
                  child: Text(
                    'Mit Liebe gebaut für deine Genesung',
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
            padding: const EdgeInsets.only(top: AppSpacing.lg),
            child: _DebugPanel(),
          );
        },
      ),
    ];
  }
}

// ════════════════════════════════════════════════════════════════════════════
// _GroupPanel – Rounded container with a grid of bubble tiles
// ════════════════════════════════════════════════════════════════════════════

class _GroupPanel extends StatelessWidget {
  const _GroupPanel({required this.group});

  final _BubbleGroup group;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section label
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.sm,
            bottom: AppSpacing.sm,
          ),
          child: Text(
            group.title.toUpperCase(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary.withValues(alpha: 0.7),
              letterSpacing: 0.5,
            ),
          ),
        ),
        // Panel container
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.grey200.withValues(alpha: 0.5),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 2),
                spreadRadius: -4,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.lg,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                const columns = 4;
                final tileWidth = (constraints.maxWidth -
                        (columns - 1) * AppSpacing.sm) /
                    columns;

                return Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.lg,
                  children: group.items
                      .map((item) => SizedBox(
                            width: tileWidth,
                            child: _BubbleTile(item: item),
                          ))
                      .toList(),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// _BubbleTile – Single circular icon with label
// ════════════════════════════════════════════════════════════════════════════

class _BubbleTile extends StatelessWidget {
  const _BubbleTile({required this.item});

  final _BubbleItem item;

  static const double _circleSize = 52;
  static const double _iconSize = 22;

  @override
  Widget build(BuildContext context) {
    final isPro = item.isProFeature &&
        !(ProServices.maybeOf(context)?.entitlementService.isPro ?? false);

    return PressableScale(
      onTap: () {
        Haptic.selection();
        item.onTap(context)();
      },
      scaleFactor: 0.92,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Circle bubble
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: _circleSize,
                height: _circleSize,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.icon,
                  size: _iconSize,
                  color: AppColors.primary,
                ),
              ),
              // Pro badge
              if (isPro)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.warning,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.white,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      CupertinoIcons.star_fill,
                      size: 9,
                      color: AppColors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          // Label
          Text(
            item.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// _SearchField
// ════════════════════════════════════════════════════════════════════════════

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      style: const TextStyle(fontSize: 16),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Suchen…',
        hintStyle: TextStyle(
          color: AppColors.textSecondary.withValues(alpha: 0.6),
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 14, right: 8),
          child: Icon(
            CupertinoIcons.search,
            size: 18,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 38, minHeight: 0),
        filled: true,
        fillColor: AppColors.grey100,
        contentPadding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.lg,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// _DebugPanel – Admin debug tools (debug mode only)
// ════════════════════════════════════════════════════════════════════════════

class _DebugPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = <_BubbleItem>[
      _BubbleItem(
        icon: CupertinoIcons.flame_fill,
        title: 'Firebase Test',
        onTap: (ctx) => () => Navigator.of(ctx).pushNamed('/debug/firebase'),
      ),
      _BubbleItem(
        icon: CupertinoIcons.person_crop_circle_badge_checkmark,
        title: 'Role Debug',
        onTap: (ctx) => () => Navigator.of(ctx).pushNamed('/role-debug'),
      ),
      _BubbleItem(
        icon: CupertinoIcons.rectangle_stack_fill,
        title: 'Ads Admin',
        onTap: (ctx) => () => Navigator.of(ctx).pushNamed('/debug/ads-admin'),
      ),
    ];

    return _GroupPanel(
      group: _BubbleGroup(title: 'Debug-Tools', items: items),
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
                    GlassIcon(
                        icon: AppIcons.pro,
                        color: AppIcons.proColor,
                        size: 19),
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
                const _BulletPoint(
                    text: 'Angehörige einladen & gemeinsam begleiten'),
                const SizedBox(height: 6),
                const _BulletPoint(text: 'Timeline besser organisieren'),
                const SizedBox(height: 6),
                const _BulletPoint(
                    text: 'Alle Funktionen ohne Einschränkung'),
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
