import 'package:flutter/material.dart';

import '../ui/ui.dart';
import 'operation_detail_screen.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: _DashboardBody(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _DashboardBody extends StatelessWidget {
  const _DashboardBody();

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: topPadding + AppSpacing.lg,
        bottom: 120,
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TopBar(),
          SizedBox(height: AppSpacing.xxl),
          _OperationCard(),
          SizedBox(height: AppSpacing.lg),
          _CountdownCard(),
          SizedBox(height: AppSpacing.lg),
          _ChecklistCard(),
          SizedBox(height: AppSpacing.xxl),
          _ActionButtons(),
        ],
      ),
    );
  }
}

// ── Top bar ──────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ── Avatar ──────────────────────────────────────────────
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: AppRadius.borderRadiusLg,
          ),
          child: const Center(
            child: Text(
              'M',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),

        // ── Greeting ────────────────────────────────────────────
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greetingText(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                'Hallo, Max',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
        ),

        // ── Notification bell ───────────────────────────────────
        _IconBubble(
          icon: Icons.notifications_none_rounded,
          badgeCount: 2,
          onTap: () {},
        ),
        const SizedBox(width: AppSpacing.sm),

        // ── Profile icon ────────────────────────────────────────
        _IconBubble(
          icon: Icons.person_outline_rounded,
          onTap: () {},
        ),
      ],
    );
  }

  static String _greetingText() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Guten Morgen';
    if (hour < 18) return 'Guten Tag';
    return 'Guten Abend';
  }
}

// ── Icon bubble (notification / profile) ─────────────────────────────────────

class _IconBubble extends StatelessWidget {
  const _IconBubble({
    required this.icon,
    required this.onTap,
    this.badgeCount,
  });

  final IconData icon;
  final VoidCallback onTap;
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.all(AppSpacing.sm),
        borderRadius: AppRadius.borderRadiusMd,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon, size: 22, color: AppColors.grey700),
            if (badgeCount != null && badgeCount! > 0)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$badgeCount',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Current operation card ───────────────────────────────────────────────────

class _OperationCard extends StatelessWidget {
  const _OperationCard();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.xl),
      borderRadius: AppRadius.borderRadiusXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──────────────────────────────────────
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: AppRadius.borderRadiusMd,
                ),
                child: const Icon(
                  Icons.monitor_heart_outlined,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Aktuelle Operation', style: tt.bodySmall),
                    const SizedBox(height: AppSpacing.xxs),
                    Text('Knie‑Arthroskopie', style: tt.titleLarge),
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
                child: Text(
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

          // ── Divider ─────────────────────────────────────────
          Divider(
            height: 1,
            thickness: 0.5,
            color: AppColors.grey200.withValues(alpha: 0.6),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Detail rows ─────────────────────────────────────
          _DetailRow(
            icon: Icons.calendar_today_rounded,
            label: 'Datum',
            value: '24. April 2026',
          ),
          const SizedBox(height: AppSpacing.md),
          _DetailRow(
            icon: Icons.local_hospital_rounded,
            label: 'Klinik',
            value: 'Universitätsklinikum München',
          ),
          const SizedBox(height: AppSpacing.md),
          _DetailRow(
            icon: Icons.person_rounded,
            label: 'Arzt',
            value: 'Dr. med. Julia Schneider',
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.grey500),
        const SizedBox(width: AppSpacing.md),
        SizedBox(
          width: 52,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Countdown card ───────────────────────────────────────────────────────────

class _CountdownCard extends StatelessWidget {
  const _CountdownCard();

  @override
  Widget build(BuildContext context) {
    final opDate = DateTime(2026, 4, 24);
    final remaining = opDate.difference(DateTime.now());
    final days = remaining.inDays.clamp(0, 9999);

    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.xl),
      borderRadius: AppRadius.borderRadiusXl,
      child: Row(
        children: [
          // ── Countdown number ────────────────────────────────
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: AppRadius.borderRadiusXl,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.30),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$days',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xl),

          // ── Label ──────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  days == 1 ? 'Tag bis zur OP' : 'Tage bis zur OP',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '24. April 2026 · 08:00 Uhr',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

          Icon(
            Icons.timer_outlined,
            size: 24,
            color: AppColors.grey400,
          ),
        ],
      ),
    );
  }
}

// ── Checklist progress card ──────────────────────────────────────────────────

class _ChecklistCard extends StatelessWidget {
  const _ChecklistCard();

  static const _totalSteps = 8;
  static const _completedSteps = 3;
  static const _progress = _completedSteps / _totalSteps;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.xl),
      borderRadius: AppRadius.borderRadiusXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.10),
                  borderRadius: AppRadius.borderRadiusMd,
                ),
                child: const Icon(
                  Icons.checklist_rounded,
                  color: AppColors.success,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'OP‑Checkliste',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      '$_completedSteps von $_totalSteps erledigt',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const GlassProgressBar(
            value: _progress,
            height: 10,
            showPercentage: true,
            label: 'Fortschritt',
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Preview items ──────────────────────────────────
          _CheckItem(label: 'Aufklärungsgespräch', done: true),
          _CheckItem(label: 'Blutwerte abgeben', done: true),
          _CheckItem(label: 'Nüchtern‑Hinweise lesen', done: true),
          _CheckItem(label: 'Einwilligung unterschreiben', done: false),
        ],
      ),
    );
  }
}

class _CheckItem extends StatelessWidget {
  const _CheckItem({required this.label, required this.done});

  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Icon(
            done
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            size: 20,
            color: done ? AppColors.success : AppColors.grey400,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: done ? FontWeight.w400 : FontWeight.w500,
                color: done ? AppColors.textSecondary : AppColors.textPrimary,
                decoration: done ? TextDecoration.lineThrough : null,
                decorationColor: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Action buttons ───────────────────────────────────────────────────────────

class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GlassButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const OperationDetailScreen(),
                ),
              );
            },
            label: 'OP Details',
            icon: Icons.info_outline_rounded,
            expand: true,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: GlassButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Neue OP – kommt bald')),
              );
            },
            label: 'Neue OP',
            icon: Icons.add_rounded,
            variant: GlassButtonVariant.secondary,
            expand: true,
          ),
        ),
      ],
    );
  }
}
