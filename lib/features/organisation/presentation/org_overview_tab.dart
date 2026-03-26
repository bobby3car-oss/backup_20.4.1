import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../data/organisation_service.dart';
import '../domain/organisation.dart';
import '../domain/org_doctor.dart';
import '../../../l10n/app_localizations.dart';

/// Overview tab for the organisation dashboard.
class OrgOverviewTab extends StatefulWidget {
  const OrgOverviewTab({super.key});

  @override
  State<OrgOverviewTab> createState() => _OrgOverviewTabState();
}

class _OrgOverviewTabState extends State<OrgOverviewTab> {
  final _service = OrganisationService();

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Guten Morgen';
    if (hour < 18) return 'Guten Tag';
    return 'Guten Abend';
  }

  String get _todayFormatted {
    final now = DateTime.now();
    const weekdays = [
      'Montag', 'Dienstag', 'Mittwoch', 'Donnerstag',
      'Freitag', 'Samstag', 'Sonntag',
    ];
    const months = [
      'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
      'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember',
    ];
    return '${weekdays[now.weekday - 1]}, ${now.day}. ${months[now.month - 1]} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        child: SafeArea(
          child: StreamBuilder<Organisation?>(
            stream: _service.watchOrganisation(),
            builder: (context, orgSnap) {
              final org = orgSnap.data;
              final orgName = org?.name ?? '';

              return StreamBuilder<List<OrgDoctor>>(
                stream: _service.watchDoctors(),
                builder: (context, doctorsSnap) {
                  final doctors = doctorsSnap.data ?? [];
                  final activeDoctors =
                      doctors.where((d) => d.isActive).toList();

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.lg,
                      AppSpacing.xl,
                      120,
                    ),
                    children: [
                      // ── Greeting ─────────────────────────────
                      FadeSlideIn(
                        child: Text(
                          orgName.isNotEmpty
                              ? '$_greeting, $orgName'
                              : _greeting,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 60),
                        child: Text(
                          _todayFormatted,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xxl),

                      // ── Stats cards ──────────────────────────
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 120),
                        child: _StatsGrid(
                          doctorCount: activeDoctors.length,
                          totalDoctors: doctors.length,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // ── Organisation info ────────────────────
                      if (org != null) ...[
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 180),
                          child: _OrgInfoCard(org: org),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],

                      // ── Recent doctors ───────────────────────
                      if (doctors.isNotEmpty) ...[
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 240),
                          child: _SectionHeader(
                            icon: Icons.medical_services_rounded,
                            title: 'Ärzte',
                            trailing: Text(
                              '${activeDoctors.length} aktiv',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ...doctors.take(5).indexed.map((e) => FadeSlideIn(
                              delay:
                                  Duration(milliseconds: 300 + e.$1 * 60),
                              child: _DoctorQuickCard(doctor: e.$2),
                            )),
                      ],
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private widgets
// ─────────────────────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.doctorCount,
    required this.totalDoctors,
  });

  final int doctorCount;
  final int totalDoctors;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.medical_services_rounded,
            label: 'Ärzte',
            value: '$doctorCount',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _StatCard(
            icon: Icons.people_rounded,
            label: 'Gesamt',
            value: '$totalDoctors',
            color: AppColors.accent,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppRadius.borderRadiusLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrgInfoCard extends StatelessWidget {
  const _OrgInfoCard({required this.org});

  final Organisation org;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.xl),
      borderRadius: AppRadius.borderRadiusLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.business_rounded,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                l.orgRegRoleBadge,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (org.orgType.isNotEmpty)
            _InfoRow(label: 'Typ', value: org.orgType),
          if (org.contactPerson.isNotEmpty)
            _InfoRow(label: l.orgRegContactPerson, value: org.contactPerson),
          if (org.address.isNotEmpty)
            _InfoRow(label: l.orgRegAddress, value: org.address),
          if (org.email.isNotEmpty)
            _InfoRow(label: l.fieldEmail, value: org.email),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class _DoctorQuickCard extends StatelessWidget {
  const _DoctorQuickCard({required this.doctor});

  final OrgDoctor doctor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassCard(
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              child: Text(
                _initials(doctor.name),
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (doctor.specialty.isNotEmpty)
                    Text(
                      doctor.specialty,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: doctor.isActive
                    ? AppColors.success.withValues(alpha: 0.12)
                    : AppColors.textSecondary.withValues(alpha: 0.12),
                borderRadius: AppRadius.borderRadiusSm,
              ),
              child: Text(
                doctor.isActive ? 'Aktiv' : doctor.status,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: doctor.isActive
                      ? AppColors.success
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }
}
