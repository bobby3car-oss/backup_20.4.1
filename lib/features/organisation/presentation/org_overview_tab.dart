import 'package:flutter/material.dart';

import '../../../main.dart';
import '../../../ui/ui.dart';
import '../../doctor_patients/domain/linked_patient.dart';
import '../../pro/data/org_entitlement_service.dart';
import '../../pro/domain/org_entitlement.dart';
import '../../pro/presentation/org_paywall_screen.dart';
import '../data/organisation_service.dart';
import '../domain/organisation.dart';
import '../domain/org_doctor.dart';
import '../domain/org_stats.dart';
import '../../../l10n/app_localizations.dart';

/// Overview tab for the organisation dashboard.
class OrgOverviewTab extends StatefulWidget {
  const OrgOverviewTab({super.key});

  @override
  State<OrgOverviewTab> createState() => _OrgOverviewTabState();
}

class _OrgOverviewTabState extends State<OrgOverviewTab> {
  final _service = OrganisationService();
  late final OrgEntitlementService _orgEntitlement;

  // ── Aggregated stats ───────────────────────────────────────
  OrgStatsData _stats = OrgStatsData.empty;
  bool _statsLoading = true;

  /// Breakpoint above which the desktop layout is used.
  static const _kDesktopBreakpoint = 900.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _orgEntitlement = ProServices.of(context).orgEntitlementService;
  }

  @override
  void initState() {
    super.initState();
    _loadAggregatedStats();
  }

  Future<void> _loadAggregatedStats() async {
    try {
      final stats = await _service.getOrgStats();
      if (mounted) {
        setState(() {
          _stats = stats;
          _statsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _statsLoading = false);
    }
  }

  String _greeting(AppLocalizations l) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l.greetingMorning;
    if (hour < 18) return l.greetingDay;
    return l.greetingEvening;
  }

  String _todayFormatted(AppLocalizations l) {
    final now = DateTime.now();
    final weekdays = [
      l.weekdayMonday, l.weekdayTuesday, l.weekdayWednesday, l.weekdayThursday,
      l.weekdayFriday, l.weekdaySaturday, l.weekdaySunday,
    ];
    final months = [
      l.monthJanuary, l.monthFebruary, l.monthMarch, l.monthApril, l.monthMay, l.monthJune,
      l.monthJuly, l.monthAugust, l.monthSeptember, l.monthOctober, l.monthNovember, l.monthDecember,
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

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide =
                          constraints.maxWidth >= _kDesktopBreakpoint;
                      return isWide
                          ? _buildWideLayout(
                              theme, org, orgName, doctors, activeDoctors)
                          : _buildNarrowLayout(
                              theme, org, orgName, doctors, activeDoctors);
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // ── Narrow (mobile) layout – unchanged linear ListView ──────────
  Widget _buildNarrowLayout(
    ThemeData theme,
    Organisation? org,
    String orgName,
    List<OrgDoctor> doctors,
    List<OrgDoctor> activeDoctors,
  ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, 120,
      ),
      children: [
        ..._buildProBanner(context),
        ..._buildGreeting(theme, orgName),
        const SizedBox(height: AppSpacing.xxl),
        ..._buildStatsSection(activeDoctors, doctors),
        const SizedBox(height: AppSpacing.lg),
        ..._buildPhaseSection(),
        const SizedBox(height: AppSpacing.xl),
        ..._buildOrgInfoSection(org),
        ..._buildDoctorsSection(theme, doctors, activeDoctors),
      ],
    );
  }

  // ── Wide (desktop) layout – 2-column grid ──────────────────────
  Widget _buildWideLayout(
    ThemeData theme,
    Organisation? org,
    String orgName,
    List<OrgDoctor> doctors,
    List<OrgDoctor> activeDoctors,
  ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, 120,
      ),
      children: [
        ..._buildProBanner(context),
        ..._buildGreeting(theme, orgName),
        const SizedBox(height: AppSpacing.xxl),

        // Stats in a 4-column row on desktop
        FadeSlideIn(
          delay: const Duration(milliseconds: 120),
          child: _StatsGrid(
            doctorCount: activeDoctors.length,
            totalDoctors: doctors.length,
            stats: _stats,
            statsLoading: _statsLoading,
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Phase distribution bar
        ..._buildPhaseSection(),

        const SizedBox(height: AppSpacing.xl),

        // Two-column row: left = org info, right = recent doctors
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (org != null)
                Expanded(
                  child: FadeSlideIn(
                    delay: const Duration(milliseconds: 180),
                    child: _OrgInfoCard(org: org),
                  ),
                ),
              if (org != null && doctors.isNotEmpty)
                const SizedBox(width: AppSpacing.xl),
              if (doctors.isNotEmpty)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildDoctorsColumn(
                        theme, doctors, activeDoctors),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Shared section builders ─────────────────────────────────────

  List<Widget> _buildProBanner(BuildContext context) {
    // Doctors & orgs get all features for free – never show upsell.
    if (_orgEntitlement.isPro) return const [SizedBox.shrink()];
    return [
      ValueListenableBuilder<OrgEntitlement>(
        valueListenable: _orgEntitlement.entitlement,
        builder: (context, ent, _) {
          if (ent.isActive) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: FadeSlideIn(
              child: _OrgProUpsellBanner(
                onTap: () {
                  final pro = ProServices.of(context);
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => OrgPaywallScreen(
                        billingService: pro.billingService,
                        orgEntitlementService: pro.orgEntitlementService,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    ];
  }

  List<Widget> _buildGreeting(ThemeData theme, String orgName) {
    final l = AppLocalizations.of(context)!;
    return [
      FadeSlideIn(
        child: Text(
          orgName.isNotEmpty ? '${_greeting(l)}, $orgName' : _greeting(l),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.xs),
      FadeSlideIn(
        delay: const Duration(milliseconds: 60),
        child: Text(
          _todayFormatted(l),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildStatsSection(
    List<OrgDoctor> activeDoctors,
    List<OrgDoctor> doctors,
  ) {
    return [
      FadeSlideIn(
        delay: const Duration(milliseconds: 120),
        child: _StatsGrid(
          doctorCount: activeDoctors.length,
          totalDoctors: doctors.length,
          stats: _stats,
          statsLoading: _statsLoading,
        ),
      ),
    ];
  }

  List<Widget> _buildPhaseSection() {
    if (_statsLoading || _stats.totalPatients == 0) return [];
    return [
      FadeSlideIn(
        delay: const Duration(milliseconds: 150),
        child: _PhaseDistribution(phases: _stats.patientsByPhase),
      ),
    ];
  }

  List<Widget> _buildOrgInfoSection(Organisation? org) {
    if (org == null) return [];
    return [
      FadeSlideIn(
        delay: const Duration(milliseconds: 180),
        child: _OrgInfoCard(org: org),
      ),
      const SizedBox(height: AppSpacing.lg),
    ];
  }

  List<Widget> _buildDoctorsSection(
    ThemeData theme,
    List<OrgDoctor> doctors,
    List<OrgDoctor> activeDoctors,
  ) {
    if (doctors.isEmpty) return [];
    final l = AppLocalizations.of(context)!;
    return [
      FadeSlideIn(
        delay: const Duration(milliseconds: 240),
        child: _SectionHeader(
          icon: Icons.medical_services_rounded,
          title: l.sectionDoctors,
          trailing: Text(
            l.countActive(activeDoctors.length),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.sm),
      ...doctors.take(5).indexed.map((e) => FadeSlideIn(
            delay: Duration(milliseconds: 300 + e.$1 * 60),
            child: _DoctorQuickCard(doctor: e.$2),
          )),
    ];
  }

  List<Widget> _buildDoctorsColumn(
    ThemeData theme,
    List<OrgDoctor> doctors,
    List<OrgDoctor> activeDoctors,
  ) {
    final l = AppLocalizations.of(context)!;
    return [
      FadeSlideIn(
        delay: const Duration(milliseconds: 240),
        child: _SectionHeader(
          icon: Icons.medical_services_rounded,
          title: l.sectionDoctors,
          trailing: Text(
            l.countActive(activeDoctors.length),
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.sm),
      ...doctors.take(5).indexed.map((e) => FadeSlideIn(
            delay: Duration(milliseconds: 300 + e.$1 * 60),
            child: _DoctorQuickCard(doctor: e.$2),
          )),
    ];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private widgets
// ─────────────────────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.doctorCount,
    required this.totalDoctors,
    required this.stats,
    required this.statsLoading,
  });

  final int doctorCount;
  final int totalDoctors;
  final OrgStatsData stats;
  final bool statsLoading;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    final cards = [
      _StatCard(
        icon: Icons.medical_services_rounded,
        label: l.aerzte,
        value: '$doctorCount',
        color: AppColors.primary,
      ),
      _StatCard(
        icon: Icons.people_rounded,
        label: l.totalPatients,
        value: statsLoading ? '…' : '${stats.totalPatients}',
        color: AppColors.accent,
      ),
      _StatCard(
        icon: Icons.bolt_rounded,
        label: l.activePatients,
        value: statsLoading ? '…' : '${stats.activePatients}',
        color: AppColors.warning,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // 3 columns on all screen sizes
        return Row(
          children: [
            for (int i = 0; i < cards.length; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.md),
              Expanded(child: cards[i]),
            ],
          ],
        );
      },
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
    final numValue = int.tryParse(value);
    return GlassContainer(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutBack,
            builder: (_, scale, child) => Transform.scale(
              scale: scale,
              child: child,
            ),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          numValue != null
              ? TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: numValue),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (_, val, _) => Text(
                    '$val',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                  ),
                )
              : Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
            _InfoRow(label: l.fieldType, value: org.orgType),
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
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
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
    final l = AppLocalizations.of(context)!;
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
                doctor.isActive ? l.statusActive : doctor.status,
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

// ─────────────────────────────────────────────────────────────────────────────
// Phase distribution
// ─────────────────────────────────────────────────────────────────────────────

class _PhaseDistribution extends StatelessWidget {
  const _PhaseDistribution({required this.phases});

  final Map<PatientPhase, int> phases;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final phaseConfig = <PatientPhase, (String, Color, IconData)>{
      PatientPhase.preOp: (l.phasePreOp, const Color(0xFF007AFF), Icons.schedule_rounded),
      PatientPhase.opDay: (l.phaseOpDay, const Color(0xFFFF9500), Icons.local_hospital_rounded),
      PatientPhase.postOp: (l.phasePostOp, const Color(0xFF34C759), Icons.healing_rounded),
      PatientPhase.discharged: (l.phaseDischarged, const Color(0xFF8E8E93), Icons.check_circle_outline_rounded),
    };
    final theme = Theme.of(context);
    final total = phases.values.fold<int>(0, (a, b) => a + b);
    if (total == 0) return const SizedBox.shrink();

    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.xl),
      borderRadius: AppRadius.borderRadiusLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pie_chart_rounded,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                l.phaseDistribution,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Stacked horizontal bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 24,
              child: Row(
                children: [
                  for (final phase in PatientPhase.values)
                    if ((phases[phase] ?? 0) > 0)
                      Expanded(
                        flex: phases[phase]!,
                        child: Container(
                          color: phaseConfig[phase]!.$2,
                          alignment: Alignment.center,
                          child: phases[phase]! * 100 ~/ total >= 12
                              ? Text(
                                  '${phases[phase]}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                        ),
                      ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Legend
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.sm,
            children: [
              for (final phase in PatientPhase.values)
                _PhaseLegendItem(
                  label: phaseConfig[phase]!.$1,
                  color: phaseConfig[phase]!.$2,
                  icon: phaseConfig[phase]!.$3,
                  count: phases[phase] ?? 0,
                  total: total,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PhaseLegendItem extends StatelessWidget {
  const _PhaseLegendItem({
    required this.label,
    required this.color,
    required this.icon,
    required this.count,
    required this.total,
  });

  final String label;
  final Color color;
  final IconData icon;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = total > 0 ? (count * 100 / total).round() : 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: $count ($percent%)',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pro upsell banner
// ─────────────────────────────────────────────────────────────────────────────

class _OrgProUpsellBanner extends StatelessWidget {
  const _OrgProUpsellBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border(
              left: BorderSide(
                color: const Color(0xFF007AFF),
                width: 3,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              const Text('🏥', style: TextStyle(fontSize: 24)),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.praxisPro,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF007AFF),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l.praxisProSubtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                l.upgradeNowArrow,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: const Color(0xFF007AFF),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

