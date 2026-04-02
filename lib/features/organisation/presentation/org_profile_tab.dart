import 'package:flutter/material.dart';

import '../../../auth/auth_service.dart';
import '../../../main.dart';
import '../../pro/domain/org_entitlement.dart';
import '../../pro/presentation/org_paywall_screen.dart';
import '../data/organisation_service.dart';
import '../domain/organisation.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import 'org_billing_section.dart';

/// Profile tab for the organisation dashboard.
class OrgProfileTab extends StatefulWidget {
  const OrgProfileTab({super.key});

  @override
  State<OrgProfileTab> createState() => _OrgProfileTabState();
}

class _OrgProfileTabState extends State<OrgProfileTab> {
  final _service = OrganisationService();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return StreamBuilder<Organisation?>(
      stream: _service.watchOrganisation(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final org = snap.data;
        if (org == null) {
          return GlassPage(
            title: l.sectionProfile,
            titleIcon: Icons.business_rounded,
            titleColor: AppColors.primary,
            showBackButton: false,
            children: [
              GlassContainer(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                borderRadius: AppRadius.borderRadiusLg,
                child: Text(
                  l.orgProfileNotFound,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              FadeSlideIn(
                child: GlassButton(
                  onPressed: () => AuthService().signOut(),
                  icon: Icons.logout_rounded,
                  label: l.logout,
                  variant: GlassButtonVariant.ghost,
                  expand: true,
                ),
              ),
            ],
          );
        }

        return _OrgProfileContent(org: org);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Profile content
// ─────────────────────────────────────────────────────────────────────────────

class _OrgProfileContent extends StatelessWidget {
  const _OrgProfileContent({required this.org});

  final Organisation org;

  String get _initials {
    final name = org.name;
    if (name.isEmpty) return '?';
    final parts = name.split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return GlassPage(
      title: l.sectionProfile,
      titleIcon: Icons.business_rounded,
      titleColor: AppColors.primary,
      showBackButton: false,
      children: [
        // ── Hero Header ────────────────────────────────
        FadeSlideIn(
          child: GlassContainer(
            variant: GlassVariant.thick,
            elevation: GlassElevation.high,
            padding: const EdgeInsets.all(AppSpacing.xxl),
            borderRadius: AppRadius.borderRadiusXl,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  child: Text(
                    _initials,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              org.name,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // PRO badge – shown when org is Pro active
                          Builder(
                            builder: (context) {
                              final orgEnt = ProServices.maybeOf(context)
                                  ?.orgEntitlementService;
                              if (orgEnt == null) {
                                return const SizedBox.shrink();
                              }
                              return ValueListenableBuilder<OrgEntitlement>(
                                valueListenable: orgEnt.entitlement,
                                builder: (_, ent, __) {
                                  if (!ent.isActive) {
                                    return const SizedBox.shrink();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.success
                                            .withValues(alpha: 0.12),
                                        borderRadius:
                                            AppRadius.borderRadiusPill,
                                        border: Border.all(
                                          color: AppColors.success
                                              .withValues(alpha: 0.25),
                                        ),
                                      ),
                                      child: const Text(
                                        'PRO',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.success,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                      if (org.orgType.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          org.orgType,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        org.email,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.xxl),

        // ── Section: Kontaktdaten ──────────────────────
        FadeSlideIn(
          delay: const Duration(milliseconds: 80),
          child: _ProfileSection(
            icon: Icons.contact_phone_rounded,
            iconColor: AppColors.primary,
            title: l.sectionContactData,
            children: [
              _FieldRow(
                icon: Icons.person_outline_rounded,
                label: l.orgRegContactPerson,
                value: org.contactPerson.isNotEmpty
                    ? org.contactPerson
                    : l.nichtHinterlegt,
              ),
              _divider(),
              _FieldRow(
                icon: Icons.email_outlined,
                label: l.fieldEmail,
                value: org.email,
              ),
              if (org.phone != null && org.phone!.isNotEmpty) ...[
                _divider(),
                _FieldRow(
                  icon: Icons.phone_outlined,
                  label: l.orgRegPhone,
                  value: org.phone!,
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // ── Section: Adresse ───────────────────────────
        FadeSlideIn(
          delay: const Duration(milliseconds: 140),
          child: _ProfileSection(
            icon: Icons.location_on_outlined,
            iconColor: AppColors.accent,
            title: l.orgRegAddress,
            children: [
              _FieldRow(
                icon: Icons.location_city_rounded,
                label: l.orgRegAddress,
                value: org.address.isNotEmpty
                    ? org.address
                    : l.nichtHinterlegt,
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // ── Section: Organisation ──────────────────────
        FadeSlideIn(
          delay: const Duration(milliseconds: 200),
          child: _ProfileSection(
            icon: Icons.business_rounded,
            iconColor: AppColors.success,
            title: l.orgRegRoleBadge,
            children: [
              _FieldRow(
                icon: Icons.category_rounded,
                label: l.labelType,
                value: org.orgType.isNotEmpty
                    ? org.orgType
                    : l.nichtHinterlegt,
              ),
              if (org.createdAt != null) ...[
                _divider(),
                _FieldRow(
                  icon: Icons.calendar_today_rounded,
                  label: l.erstelltAm,
                  value: _formatDate(org.createdAt!, l),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // ── Section: Pro-Status ──────────────────────────
        FadeSlideIn(
          delay: const Duration(milliseconds: 230),
          child: _OrgProStatusSection(org: org),
        ),

        const SizedBox(height: AppSpacing.lg),

        // ── Section: Abrechnung ─────────────────────────
        FadeSlideIn(
          delay: const Duration(milliseconds: 260),
          child: OrgBillingSection(orgUid: org.uid),
        ),

        const SizedBox(height: AppSpacing.xxxl),

        // ── Logout ─────────────────────────────────────
        FadeSlideIn(
          delay: const Duration(milliseconds: 290),
          child: GlassButton(
            onPressed: () => AuthService().signOut(),
            icon: Icons.logout_rounded,
            label: l.logout,
            variant: GlassButtonVariant.ghost,
            expand: true,
          ),
        ),

        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  String _formatDate(DateTime date, AppLocalizations l) {
    final months = [
      l.monthJanuary, l.monthFebruary, l.monthMarch, l.monthApril,
      l.monthMay, l.monthJune, l.monthJuly, l.monthAugust,
      l.monthSeptember, l.monthOctober, l.monthNovember, l.monthDecember,
    ];
    return '${date.day}. ${months[date.month - 1]} ${date.year}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared private widgets
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.children,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.xl),
      borderRadius: AppRadius.borderRadiusLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ...children,
        ],
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(value, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _divider() => Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Divider(
        color: AppColors.textSecondary.withValues(alpha: 0.12),
        height: 1,
      ),
    );

// ─────────────────────────────────────────────────────────────────────────────
// Pro status section
// ─────────────────────────────────────────────────────────────────────────────

class _OrgProStatusSection extends StatelessWidget {
  const _OrgProStatusSection({required this.org});

  final Organisation org;

  @override
  Widget build(BuildContext context) {
    final pro = ProServices.maybeOf(context);
    final orgEnt = pro?.orgEntitlementService;

    if (orgEnt == null) return const SizedBox.shrink();

    return ValueListenableBuilder<OrgEntitlement>(
      valueListenable: orgEnt.entitlement,
      builder: (context, ent, _) {
        final l = AppLocalizations.of(context)!;
        return _ProfileSection(
          icon: Icons.workspace_premium_rounded,
          iconColor: ent.isActive
              ? AppColors.success
              : const Color(0xFF007AFF),
          title: l.proStatus,
          children: [
            if (ent.isActive) ...[
              // ── Active Pro ─────────────────────────────
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      borderRadius: AppRadius.borderRadiusPill,
                      border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            size: 14, color: AppColors.success),
                        const SizedBox(width: 6),
                        Text(
                          l.proActiveTitle,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (ent.proExpiresAt != null) ...[
                const SizedBox(height: AppSpacing.md),
                _FieldRow(
                  icon: Icons.event_rounded,
                  label: l.validUntil,
                  value: _formatDate(ent.proExpiresAt!, l),
                ),
              ],
              if (ent.proSource != null || ent.proPlatform != null) ...[
                _divider(),
                _FieldRow(
                  icon: Icons.info_outline_rounded,
                  label: l.source,
                  value: ent.proSource == 'key'
                      ? l.proKey
                      : ent.proPlatform == 'ios'
                          ? 'App Store'
                          : ent.proPlatform == 'android'
                              ? 'Google Play'
                              : ent.proPlatform ?? l.subscription,
                ),
              ],
            ] else ...[
              // ── Free tier ──────────────────────────────
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary.withValues(alpha: 0.10),
                      borderRadius: AppRadius.borderRadiusPill,
                    ),
                    child: Text(
                      l.freeTier,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        final p = ProServices.of(context);
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => OrgPaywallScreen(
                              billingService: p.billingService,
                              orgEntitlementService:
                                  p.orgEntitlementService,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.workspace_premium_rounded,
                          size: 18),
                      label: Text(l.upgradeNow),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF007AFF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Open OrgPaywallScreen – key redemption is
                        // accessible from its footer.
                        final p = ProServices.of(context);
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => OrgPaywallScreen(
                              billingService: p.billingService,
                              orgEntitlementService:
                                  p.orgEntitlementService,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.vpn_key_rounded, size: 18),
                      label: Text(l.redeemKey),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF007AFF),
                        side: const BorderSide(
                          color: Color(0xFF007AFF),
                          width: 1.2,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  static String _formatDate(DateTime date, AppLocalizations l) {
    final months = [
      l.monthJanuary, l.monthFebruary, l.monthMarch, l.monthApril,
      l.monthMay, l.monthJune, l.monthJuly, l.monthAugust,
      l.monthSeptember, l.monthOctober, l.monthNovember, l.monthDecember,
    ];
    return '${date.day}. ${months[date.month - 1]} ${date.year}';
  }
}

