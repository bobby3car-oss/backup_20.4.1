import 'package:flutter/material.dart';

import '../ui/ui.dart';

import '../features/wound/presentation/wound_hub_screen.dart';
import '../l10n/app_localizations.dart';

class OperationDetailScreen extends StatelessWidget {
  const OperationDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return GlassPage(
      title: l.opDetails,
      titleIcon: Icons.medical_services_rounded,
      trailing: PressableScale(
        onTap: () {},
        scaleFactor: 0.90,
        child: GlassContainer(
          padding: const EdgeInsets.all(AppSpacing.sm + 2),
          borderRadius: AppRadius.borderRadiusMd,
          variant: GlassVariant.thin,
          elevation: GlassElevation.low,
          child: const Icon(
            Icons.edit_outlined,
            size: 18,
            color: AppColors.grey700,
          ),
        ),
      ),
      children: [
        const _HeroHeader(),
        const SizedBox(height: AppSpacing.xxl),
        FadeSlideIn(
          delay: const Duration(milliseconds: 200),
          child: const _InfoCard(),
        ),
        const SizedBox(height: AppSpacing.xxxl),
        FadeSlideIn(
          delay: const Duration(milliseconds: 280),
          child: _SectionTitle(title: l.opActions),
        ),
        const SizedBox(height: AppSpacing.md),
        FadeSlideIn(
          delay: const Duration(milliseconds: 340),
          child: const _ActionGrid(),
        ),
        const SizedBox(height: AppSpacing.xxxl),
        FadeSlideIn(
          delay: const Duration(milliseconds: 400),
          child: _SectionTitle(title: l.opTimeline),
        ),
        const SizedBox(height: AppSpacing.md),
        FadeSlideIn(
          delay: const Duration(milliseconds: 440),
          child: _TimelineCard(),
        ),
      ],
    );
  }
}

// ── Hero header ──────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  const _HeroHeader();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final tt = Theme.of(context).textTheme;

    return Hero(
      tag: 'active_op_card',
      flightShuttleBuilder: _heroFlightShuttle,
      child: Material(
        type: MaterialType.transparency,
        child: GlassContainer(
          padding: const EdgeInsets.all(28),
          borderRadius: AppRadius.borderRadiusXxl,
          variant: GlassVariant.thick,
          elevation: GlassElevation.high,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GlassContainer(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    borderRadius: AppRadius.borderRadiusPill,
                    variant: GlassVariant.thin,
                    elevation: GlassElevation.flat,
                    child: ShaderMask(
                      shaderCallback: (bounds) =>
                          AppColors.primaryGradient.createShader(bounds),
                      child: const Icon(
                        Icons.monitor_heart_outlined,
                        color: AppColors.white,
                        size: 26,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.currentOperation, style: tt.labelMedium),
                        const SizedBox(height: AppSpacing.xs),
                        Text(l.kneeArthroscopy, style: tt.headlineMedium),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.10),
                      borderRadius: AppRadius.borderRadiusPill,
                      border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.20),
                      ),
                    ),
                    child: const Text(
                      'Geplant',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Arthroskopischer Eingriff · rechtes Knie',
                style: tt.bodySmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: AppColors.grey500,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text('24. April 2026 · 08:00 Uhr', style: tt.bodySmall),
                  const SizedBox(width: AppSpacing.lg),
                  Icon(
                    Icons.local_hospital_rounded,
                    size: 14,
                    color: AppColors.grey500,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(l.uniClinicMunich, style: tt.bodySmall),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _heroFlightShuttle(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection direction,
  BuildContext fromContext,
  BuildContext toContext,
) {
  final Hero toHero = toContext.widget as Hero;
  return AnimatedBuilder(
    animation: animation,
    builder: (context, child) => ClipRRect(
      borderRadius: BorderRadius.lerp(
        AppRadius.borderRadiusXxl,
        AppRadius.borderRadiusXxl,
        animation.value,
      )!,
      child: Material(type: MaterialType.transparency, child: child),
    ),
    child: toHero.child,
  );
}

// ── Info card ────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.xl),
      borderRadius: AppRadius.borderRadiusXxl,
      variant: GlassVariant.medium,
      elevation: GlassElevation.medium,
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.medical_services_outlined,
            label: l.opName,
            value: l.kneeArthroscopy,
          ),
          _InfoDivider(),
          _InfoRow(
            icon: Icons.calendar_today_rounded,
            label: l.opDate,
            value: '24. April 2026 · 08:00 Uhr',
          ),
          _InfoDivider(),
          _InfoRow(
            icon: Icons.local_hospital_rounded,
            label: l.opClinic,
            value: l.universitaetsklinikumMuenchen,
          ),
          _InfoDivider(),
          _InfoRow(
            icon: Icons.person_rounded,
            label: l.doctor,
            value: 'Dr. med. Julia Schneider',
          ),
          _InfoDivider(),
          _InfoRow(
            icon: Icons.category_outlined,
            label: l.opType,
            value: 'Arthroskopie (minimal‑invasiv)',
          ),
          _InfoDivider(),
          _InfoRow(
            icon: Icons.flag_outlined,
            label: l.status,
            value: 'Geplant',
            valueColor: AppColors.success,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: AppRadius.borderRadiusSm,
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: tt.labelSmall),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  value,
                  style: tt.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoDivider extends StatelessWidget {
  const _InfoDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.5,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.grey200.withValues(alpha: 0),
            AppColors.grey200.withValues(alpha: 0.6),
            AppColors.grey200.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}

// ── Section title ────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}

// ── Action grid ──────────────────────────────────────────────────────────────

class _ActionGrid extends StatelessWidget {
  const _ActionGrid();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.55,
      children: [
        _ActionTile(
          icon: Icons.folder_outlined,
          label: l.opDocumentsLabel,
          color: AppColors.warning,
          onTap: () {
            Navigator.of(context).pushNamed('/documents');
          },
        ),
        _ActionTile(
          icon: Icons.healing_rounded,
          label: l.opSymptomsLabel,
          color: AppColors.error,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const WoundHubScreen(),
              ),
            );
          },
        ),
        _ActionTile(
          icon: Icons.people_outline_rounded,
          label: l.opManageCaregivers,
          color: AppColors.accent,
          onTap: () {
            Navigator.of(context).pushNamed('/invite-accept');
          },
        ),
      ],
    );
  }


}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: () {
        Haptic.light();
        onTap();
      },
      child: GlassContainer(
        padding: const EdgeInsets.all(AppSpacing.lg),
        borderRadius: AppRadius.borderRadiusLg,
        variant: GlassVariant.thin,
        elevation: GlassElevation.low,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: AppRadius.borderRadiusMd,
                border: Border.all(color: color.withValues(alpha: 0.12)),
              ),
              child: Icon(icon, size: 22, color: color),
            ),
            const Spacer(),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(height: 1.3),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Timeline preview ─────────────────────────────────────────────────────────

class _TimelineCard extends StatelessWidget {
  _TimelineCard();

  static final _events = [
    _TimelineEvent(
      title: 'OP angelegt',
      subtitle: '02. März 2026',
      icon: Icons.add_circle_outline_rounded,
      color: AppColors.primary,
      completed: true,
    ),
    _TimelineEvent(
      title: 'Aufklärungsgespräch',
      subtitle: '10. März 2026',
      icon: Icons.chat_bubble_outline_rounded,
      color: AppColors.success,
      completed: true,
    ),
    _TimelineEvent(
      title: 'Blutwerte abgegeben',
      subtitle: '15. März 2026',
      icon: Icons.bloodtype_outlined,
      color: AppColors.error,
      completed: true,
    ),
    _TimelineEvent(
      title: 'Voruntersuchung',
      subtitle: '10. April 2026',
      icon: Icons.monitor_heart_outlined,
      color: AppColors.warning,
      completed: false,
      isNext: true,
    ),
    _TimelineEvent(
      title: 'OP‑Tag',
      subtitle: '24. April 2026',
      icon: Icons.local_hospital_rounded,
      color: AppColors.accent,
      completed: false,
    ),
    _TimelineEvent(
      title: 'Nachsorge',
      subtitle: 'Nach der OP',
      icon: Icons.healing_rounded,
      color: AppColors.primary,
      completed: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.xl),
      borderRadius: AppRadius.borderRadiusXxl,
      variant: GlassVariant.medium,
      elevation: GlassElevation.medium,
      child: Column(
        children: [
          for (var i = 0; i < _events.length; i++)
            _TimelineRow(event: _events[i], isLast: i == _events.length - 1),
        ],
      ),
    );
  }
}

class _TimelineEvent {
  const _TimelineEvent({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.completed,
    this.isNext = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool completed;
  final bool isNext;
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.event, required this.isLast});

  final _TimelineEvent event;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final tt = Theme.of(context).textTheme;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: event.completed
                        ? event.color.withValues(alpha: 0.14)
                        : event.isNext
                        ? event.color.withValues(alpha: 0.10)
                        : AppColors.grey100,
                    shape: BoxShape.circle,
                    border: event.isNext
                        ? Border.all(color: event.color, width: 2)
                        : null,
                  ),
                  child: Icon(
                    event.completed ? Icons.check_rounded : event.icon,
                    size: 14,
                    color: event.completed || event.isNext
                        ? event.color
                        : AppColors.grey400,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: event.completed
                            ? event.color.withValues(alpha: 0.25)
                            : AppColors.grey200,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: tt.bodyMedium?.copyWith(
                            fontWeight: event.isNext
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: event.completed || event.isNext
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      if (event.isNext)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: event.color.withValues(alpha: 0.10),
                            borderRadius: AppRadius.borderRadiusPill,
                          ),
                          child: Text(
                            l.naechsterSchritt,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: event.color,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(event.subtitle, style: tt.bodySmall),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
