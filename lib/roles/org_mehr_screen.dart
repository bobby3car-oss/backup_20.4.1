import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/auth_service.dart';
import '../features/aftercare/presentation/aftercare_template_list_screen.dart';
import '../features/organisation/presentation/org_patients_tab.dart';
import '../features/organisation/presentation/org_profile_tab.dart';
import '../l10n/app_localizations.dart';
import '../locale/language_picker.dart';
import '../locale/locale_provider.dart';
import '../screens/help_screen.dart';
import '../ui/ui.dart';
import '../ui/theme/app_icons.dart';

// ════════════════════════════════════════════════════════════════════════════
// Data models
// ════════════════════════════════════════════════════════════════════════════

class _BubbleItem {
  const _BubbleItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback Function(BuildContext) onTap;

  bool matches(String q) => title.toLowerCase().contains(q.toLowerCase());
}

class _BubbleGroup {
  _BubbleGroup({required this.title, required this.items});
  final String title;
  final List<_BubbleItem> items;
}

// ════════════════════════════════════════════════════════════════════════════
// OrgMehrScreen
// ════════════════════════════════════════════════════════════════════════════

class OrgMehrScreen extends StatefulWidget {
  const OrgMehrScreen({super.key});

  @override
  State<OrgMehrScreen> createState() => _OrgMehrScreenState();
}

class _OrgMehrScreenState extends State<OrgMehrScreen> {
  String _query = '';
  List<String> _recentIds = [];

  @override
  void initState() {
    super.initState();
    _loadRecents();
  }

  // ── Group definitions ───────────────────────────────────────────────────

  List<_BubbleGroup> _buildGroups() {
    final l = AppLocalizations.of(context)!;
    final localeInfo = LocaleProvider.localeLabels[
        LocaleProvider.of(context).locale.languageCode];

    return [
      // ── 1. Verwaltung ────────────────────────────────────────────────
      _BubbleGroup(title: l.orgManagementSection, items: [
        _BubbleItem(
          icon: Icons.people_outline_rounded,
          title: l.patienten,
          onTap: (ctx) => () => Navigator.of(ctx).push(
                CupertinoPageRoute<void>(
                  builder: (_) => const OrgPatientsTab(),
                ),
              ),
        ),
      ]),

      // ── 2. Vorlagen ──────────────────────────────────────────────────
      _BubbleGroup(title: l.vorlagenTitle, items: [
        _BubbleItem(
          icon: Icons.medical_information_rounded,
          title: 'Nachbehandlung',
          onTap: (ctx) => () {
            final orgUid = FirebaseAuth.instance.currentUser?.uid;
            Navigator.of(ctx).push(
              CupertinoPageRoute<void>(
                builder: (_) => AftercareTemplateListScreen(
                  organizationId: orgUid,
                  isOrganization: true,
                ),
              ),
            );
          },
        ),
      ]),

      // ── 3. Konto ─────────────────────────────────────────────────────
      _BubbleGroup(title: l.settingsAccount, items: [
        _BubbleItem(
          icon: AppIcons.profile,
          title: l.sectionProfile,
          onTap: (ctx) => () => Navigator.of(ctx).push(
                CupertinoPageRoute<void>(
                  builder: (_) => const OrgProfileTab(),
                ),
              ),
        ),
        _BubbleItem(
          icon: AppIcons.settings,
          title: l.settingsTitle,
          onTap: (ctx) =>
              () => Navigator.of(ctx).pushNamed('/settings'),
        ),
        _BubbleItem(
          icon: Icons.language_rounded,
          title: '${localeInfo?.flag ?? '🌐'} ${l.sectionLanguage}',
          onTap: (_) => () => showLanguagePicker(context),
        ),
        _BubbleItem(
          icon: AppIcons.help,
          title: l.sectionHelp,
          onTap: (ctx) => () => Navigator.of(ctx).push(
                CupertinoPageRoute<void>(
                  builder: (_) => const HelpScreen(),
                ),
              ),
        ),
        _BubbleItem(
          icon: CupertinoIcons.arrow_right_circle_fill,
          title: l.logout,
          onTap: (ctx) => () async => AuthService().signOut(),
        ),
      ]),
    ];
  }

  // ── Recent taps ─────────────────────────────────────────────────────────

  Future<void> _loadRecents() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('org_mehr_recent_items') ?? [];
    if (mounted) setState(() => _recentIds = ids);
  }

  Future<void> _recordTap(String itemTitle) async {
    final updated = List<String>.from(_recentIds);
    updated.remove(itemTitle);
    updated.insert(0, itemTitle);
    if (updated.length > 3) updated.length = 3;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('org_mehr_recent_items', updated);
    if (mounted) setState(() => _recentIds = updated);
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final groups = _buildGroups();
    final isSearching = _query.isNotEmpty;

    // Build "Zuletzt genutzt" group from recent taps
    final allFlatItems = groups.expand((g) => g.items).toList();
    final recentItems = _recentIds
        .map((id) {
          final matches = allFlatItems.where((i) => i.title == id);
          return matches.isEmpty ? null : matches.first;
        })
        .whereType<_BubbleItem>()
        .toList();

    // Filter groups by search query
    final l = AppLocalizations.of(context)!;
    final visible = <_BubbleGroup>[];
    if (!isSearching && recentItems.isNotEmpty) {
      visible.add(
          _BubbleGroup(title: l.sectionRecentlyUsed, items: recentItems));
    }
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

    return GlassPage(
      title: l.discoverTitle,
      showBackButton: false,
      scrollableBody: (headerHeight) => GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: ListView(
          physics: adaptiveScrollPhysics,
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: headerHeight + AppSpacing.md,
            bottom: 120,
          ),
          children: [
            // ── Subtitle ────────────────────────────────────────
            FadeSlideIn(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.xs,
                  bottom: AppSpacing.lg,
                ),
                child: Text(
                  l.discoverSubtitle,
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
                child: _OrgProBannerCard(),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            // ── Bubble groups ───────────────────────────────────
            for (var i = 0; i < visible.length; i++) ...[
              FadeSlideIn(
                delay: Duration(milliseconds: isSearching ? 0 : 120 + i * 40),
                child: _GroupPanel(group: visible[i], onItemTapped: _recordTap),
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
                        l.noSearchResults(_query),
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
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// _GroupPanel – Rounded white container with 4-column grid
// ════════════════════════════════════════════════════════════════════════════

class _GroupPanel extends StatelessWidget {
  const _GroupPanel({required this.group, this.onItemTapped});

  final _BubbleGroup group;
  final void Function(String title)? onItemTapped;

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
                            child: _BubbleTile(
                              item: item,
                              onTapped: onItemTapped != null
                                  ? () => onItemTapped!(item.title)
                                  : null,
                            ),
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
  const _BubbleTile({required this.item, this.onTapped});

  final _BubbleItem item;
  final VoidCallback? onTapped;

  static const double _circleSize = 52;
  static const double _iconSize = 22;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: () {
        Haptic.selection();
        onTapped?.call();
        item.onTap(context)();
      },
      scaleFactor: 0.92,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Circle bubble
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
    final l = AppLocalizations.of(context)!;
    return TextField(
      onChanged: onChanged,
      style: const TextStyle(fontSize: 16),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: l.searchHint,
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
// _OrgProBannerCard – All features included for organisations
// ════════════════════════════════════════════════════════════════════════════

class _OrgProBannerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return GlassContainer(
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
                  'Alle Funktionen inklusive',
                  style: tt.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Für Organisationen kostenlos',
                  style: tt.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              borderRadius: AppRadius.borderRadiusPill,
            ),
            child: const Text(
              'PRO',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
