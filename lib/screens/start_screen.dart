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
      physics: adaptiveScrollPhysics,
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: topPadding + AppSpacing.xl,
        bottom: 120,
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TopBar(),
          SizedBox(height: AppSpacing.huge),
          _OperationCard(),
          SizedBox(height: AppSpacing.xxl),
          _CountdownCard(),
          SizedBox(height: AppSpacing.xxl),
          _ChecklistCard(),
          SizedBox(height: AppSpacing.huge),
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
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: AppRadius.borderRadiusLg,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'M',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.lg),

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
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ],
          ),
        ),

        _IconBubble(
          icon: Icons.notifications_none_rounded,
          badgeCount: 2,
          onTap: () {},
        ),
        const SizedBox(width: AppSpacing.sm),

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
        padding: const EdgeInsets.all(AppSpacing.sm + 2),
        borderRadius: AppRadius.borderRadiusMd,
        variant: GlassVariant.thin,
        elevation: GlassElevation.low,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon, size: 22, color: AppColors.grey700),
            if (badgeCount != null && badgeCount! > 0)
              Positioned(
                top: -6,
                right: -6,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.error, Color(0xFFFF6B6B)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.error.withValues(alpha: 0.35),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
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

// ── Current operation card (HERO) ────────────────────────────────────────────

class _OperationCard extends StatelessWidget {
  const _OperationCard();

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'active_op_card',
      flightShuttleBuilder: _heroFlightShuttle,
      child: Material(
        type: MaterialType.transparency,
        child: PressableScale(
          onTap: () {
            Haptic.light();
            Navigator.of(context).push(
              PageRouteBuilder<void>(
                transitionDuration: const Duration(milliseconds: 400),
                reverseTransitionDuration: const Duration(milliseconds: 350),
                pageBuilder: (context, a1, a2) => const OperationDetailScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: CurvedAnimation(
                      parent: animation,
                      curve: const Interval(0.3, 1.0),
                    ),
                    child: child,
                  );
                },
              ),
            );
          },
          child: GlassContainer(
            padding: const EdgeInsets.all(28),
            borderRadius: AppRadius.borderRadiusXxl,
            variant: GlassVariant.thick,
            elevation: GlassElevation.high,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _OperationCardHeader(context: context),
                const SizedBox(height: AppSpacing.xl),
                Container(
                  height: 0.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.grey200.withValues(alpha: 0),
                        AppColors.grey200.withValues(alpha: 0.8),
                        AppColors.grey200.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                _DetailRow(
                  icon: Icons.calendar_today_rounded,
                  label: 'Datum',
                  value: '24. April 2026',
                ),
                const SizedBox(height: AppSpacing.lg),
                _DetailRow(
                  icon: Icons.local_hospital_rounded,
                  label: 'Klinik',
                  value: 'Universitätsklinikum München',
                ),
                const SizedBox(height: AppSpacing.lg),
                _DetailRow(
                  icon: Icons.person_rounded,
                  label: 'Arzt',
                  value: 'Dr. med. Julia Schneider',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shared header row used in both the dashboard card and detail screen hero.
class _OperationCardHeader extends StatelessWidget {
  const _OperationCardHeader({required this.context});

  final BuildContext context;

  @override
  Widget build(BuildContext _) {
    return Row(
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
              Text(
                'Aktuelle Operation',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Knie‑Arthroskopie',
                style: Theme.of(context).textTheme.headlineMedium,
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
      child: Material(
        type: MaterialType.transparency,
        child: child,
      ),
    ),
    child: toHero.child,
  );
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
    final tt = Theme.of(context).textTheme;
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.05),
            borderRadius: AppRadius.borderRadiusSm,
          ),
          child: Icon(icon, size: 16, color: AppColors.grey500),
        ),
        const SizedBox(width: AppSpacing.md),
        SizedBox(
          width: 52,
          child: Text(label, style: tt.labelSmall),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            value,
            style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
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
      padding: const EdgeInsets.all(AppSpacing.xxl),
      borderRadius: AppRadius.borderRadiusXxl,
      variant: GlassVariant.medium,
      elevation: GlassElevation.medium,
      child: Row(
        children: [
          // Countdown bubble with gradient + glow
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0A84FF), Color(0xFF5AC8FA)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                  spreadRadius: -2,
                ),
                BoxShadow(
                  color: AppColors.primaryLight.withValues(alpha: 0.15),
                  blurRadius: 40,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$days',
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                  letterSpacing: -1.0,
                  height: 1,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xl),

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

          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: AppRadius.borderRadiusSm,
            ),
            child: const Icon(
              Icons.timer_outlined,
              size: 20,
              color: AppColors.grey400,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Checklist progress card ──────────────────────────────────────────────────

class _ChecklistCard extends StatefulWidget {
  const _ChecklistCard();

  @override
  State<_ChecklistCard> createState() => _ChecklistCardState();
}

class _ChecklistCardState extends State<_ChecklistCard> {
  static const _totalSteps = 8;

  final _items = [
    _CheckData('Aufklärungsgespräch', true),
    _CheckData('Blutwerte abgeben', true),
    _CheckData('Nüchtern‑Hinweise lesen', true),
    _CheckData('Einwilligung unterschreiben', false),
  ];

  int get _completedSteps => _items.where((i) => i.done).length;

  void _toggle(int index) {
    Haptic.selection();
    setState(() => _items[index].done = !_items[index].done);
  }

  @override
  Widget build(BuildContext context) {
    final progress = _totalSteps == 0 ? 0.0 : _completedSteps / _totalSteps;

    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      borderRadius: AppRadius.borderRadiusXxl,
      variant: GlassVariant.medium,
      elevation: GlassElevation.medium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.08),
                  borderRadius: AppRadius.borderRadiusMd,
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.15),
                  ),
                ),
                child: const Icon(
                  Icons.checklist_rounded,
                  color: AppColors.success,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'OP‑Checkliste',
                      style: Theme.of(context).textTheme.titleLarge,
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
          GlassProgressBar(
            value: progress,
            height: 8,
            showPercentage: true,
            label: 'Fortschritt',
          ),
          const SizedBox(height: AppSpacing.xl),

          for (var i = 0; i < _items.length; i++)
            _CheckItem(
              label: _items[i].label,
              done: _items[i].done,
              onToggle: () => _toggle(i),
            ),
        ],
      ),
    );
  }
}

class _CheckData {
  _CheckData(this.label, this.done);
  final String label;
  bool done;
}

class _CheckItem extends StatelessWidget {
  const _CheckItem({
    required this.label,
    required this.done,
    required this.onToggle,
  });

  final String label;
  final bool done;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onToggle,
      scaleFactor: 0.985,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs + 1),
        child: Row(
          children: [
            AnimatedCheckbox(
              value: done,
              activeColor: AppColors.success,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AnimatedDefaultTextStyle(
                duration: MotionDuration.medium,
                curve: MotionCurve.standard,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: done ? FontWeight.w400 : FontWeight.w500,
                  color: done
                      ? AppColors.textSecondary.withValues(alpha: 0.7)
                      : AppColors.textPrimary,
                  decoration: done ? TextDecoration.lineThrough : null,
                  decorationColor: AppColors.grey400.withValues(alpha: 0.5),
                ),
                child: Text(label),
              ),
            ),
          ],
        ),
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
