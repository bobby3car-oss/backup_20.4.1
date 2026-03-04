import 'package:flutter/material.dart';

import '../ui/ui.dart';
import 'operation_timeline_screen.dart';
import 'wound_documentation_screen.dart';

class OperationDetailScreen extends StatelessWidget {
  const OperationDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      body: const _Body(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: topPadding + AppSpacing.sm,
        bottom: AppSpacing.huge,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AppBar(),
          const SizedBox(height: AppSpacing.xxl),
          const _HeroCard(),
          const SizedBox(height: AppSpacing.lg),
          const _InfoCard(),
          const SizedBox(height: AppSpacing.xxl),
          _SectionTitle(title: 'Aktionen'),
          const SizedBox(height: AppSpacing.md),
          const _ActionGrid(),
          const SizedBox(height: AppSpacing.xxl),
          _SectionTitle(title: 'Zeitlicher Verlauf'),
          const SizedBox(height: AppSpacing.md),
          const _TimelineCard(),
        ],
      ),
    );
  }
}

// ── Custom app bar ───────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: GlassContainer(
            padding: const EdgeInsets.all(AppSpacing.sm),
            borderRadius: AppRadius.borderRadiusMd,
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            'OP Details',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: GlassContainer(
            padding: const EdgeInsets.all(AppSpacing.sm),
            borderRadius: AppRadius.borderRadiusMd,
            child: const Icon(
              Icons.edit_outlined,
              size: 18,
              color: AppColors.grey700,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Hero card ────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.xl),
      borderRadius: AppRadius.borderRadiusXl,
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: AppRadius.borderRadiusLg,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.28),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.monitor_heart_outlined,
              size: 28,
              color: AppColors.white,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Knie‑Arthroskopie', style: tt.headlineSmall),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Arthroskopischer Eingriff · rechtes Knie',
                  style: tt.bodySmall,
                ),
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
    );
  }
}

// ── Info card with all fields ────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.xl),
      borderRadius: AppRadius.borderRadiusXl,
      child: Column(
        children: const [
          _InfoRow(
            icon: Icons.medical_services_outlined,
            label: 'OP Name',
            value: 'Knie‑Arthroskopie',
          ),
          _InfoDivider(),
          _InfoRow(
            icon: Icons.calendar_today_rounded,
            label: 'Datum',
            value: '24. April 2026 · 08:00 Uhr',
          ),
          _InfoDivider(),
          _InfoRow(
            icon: Icons.local_hospital_rounded,
            label: 'Klinik',
            value: 'Universitätsklinikum München',
          ),
          _InfoDivider(),
          _InfoRow(
            icon: Icons.person_rounded,
            label: 'Arzt',
            value: 'Dr. med. Julia Schneider',
          ),
          _InfoDivider(),
          _InfoRow(
            icon: Icons.category_outlined,
            label: 'OP Typ',
            value: 'Arthroskopie (minimal‑invasiv)',
          ),
          _InfoDivider(),
          _InfoRow(
            icon: Icons.flag_outlined,
            label: 'Status',
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: AppRadius.borderRadiusSm,
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: valueColor ?? AppColors.textPrimary,
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
    return Divider(
      height: 1,
      thickness: 0.5,
      color: AppColors.grey200.withValues(alpha: 0.5),
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
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.55,
      children: [
        _ActionTile(
          icon: Icons.checklist_rounded,
          label: 'Checkliste\nöffnen',
          color: AppColors.success,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const OperationTimelineScreen(),
              ),
            );
          },
        ),
        _ActionTile(
          icon: Icons.folder_outlined,
          label: 'Dokumente',
          color: AppColors.warning,
          onTap: () => _snack(context, 'Dokumente'),
        ),
        _ActionTile(
          icon: Icons.healing_rounded,
          label: 'Symptome',
          color: AppColors.error,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const WoundDocumentationScreen(),
              ),
            );
          },
        ),
        _ActionTile(
          icon: Icons.people_outline_rounded,
          label: 'Angehörige\nverwalten',
          color: AppColors.accent,
          onTap: () => _snack(context, 'Angehörige'),
        ),
      ],
    );
  }

  void _snack(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label – kommt bald')),
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
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.all(AppSpacing.lg),
        borderRadius: AppRadius.borderRadiusLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: AppRadius.borderRadiusMd,
              ),
              child: Icon(icon, size: 22, color: color),
            ),
            const Spacer(),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Timeline preview ─────────────────────────────────────────────────────────

class _TimelineCard extends StatelessWidget {
  const _TimelineCard();

  static const _events = [
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
      borderRadius: AppRadius.borderRadiusXl,
      child: Column(
        children: [
          for (var i = 0; i < _events.length; i++) ...[
            _TimelineRow(event: _events[i], isLast: i == _events.length - 1),
          ],
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
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Left rail ────────────────────────────────────────
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
                    event.completed
                        ? Icons.check_rounded
                        : event.icon,
                    size: 14,
                    color: event.completed
                        ? event.color
                        : event.isNext
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

          // ── Content ──────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isLast ? 0 : AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: TextStyle(
                            fontSize: 15,
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
                            'Nächster Schritt',
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
                  Text(
                    event.subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
