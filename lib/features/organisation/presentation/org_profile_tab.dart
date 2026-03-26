import 'package:flutter/material.dart';

import '../../../auth/auth_service.dart';
import '../../../ui/ui.dart';
import '../data/organisation_service.dart';
import '../domain/organisation.dart';
import '../../../l10n/app_localizations.dart';

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
            title: 'Profil',
            titleIcon: Icons.business_rounded,
            titleColor: AppColors.primary,
            showBackButton: false,
            children: [
              GlassContainer(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                borderRadius: AppRadius.borderRadiusLg,
                child: Text(
                  'Organisationsprofil nicht gefunden.',
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
      title: 'Profil',
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
                      Text(
                        org.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
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
            title: 'Kontaktdaten',
            children: [
              _FieldRow(
                icon: Icons.person_outline_rounded,
                label: l.orgRegContactPerson,
                value: org.contactPerson.isNotEmpty
                    ? org.contactPerson
                    : 'Nicht hinterlegt',
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
                    : 'Nicht hinterlegt',
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
                label: 'Typ',
                value: org.orgType.isNotEmpty
                    ? org.orgType
                    : 'Nicht hinterlegt',
              ),
              if (org.createdAt != null) ...[
                _divider(),
                _FieldRow(
                  icon: Icons.calendar_today_rounded,
                  label: 'Erstellt am',
                  value: _formatDate(org.createdAt!),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.xxxl),

        // ── Logout ─────────────────────────────────────
        FadeSlideIn(
          delay: const Duration(milliseconds: 260),
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

  String _formatDate(DateTime date) {
    const months = [
      'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
      'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember',
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
