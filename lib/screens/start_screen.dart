import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../notifications/notification_repository.dart';
import '../ui/ui.dart';
import 'notification_center_screen.dart';
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
              const SizedBox(height: AppSpacing.xxs),
              Text(
                '2 Aufgaben heute',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        _NotificationBell(),
        const SizedBox(width: AppSpacing.sm),

        _IconBubble(icon: Icons.person_outline_rounded, onTap: () {}),
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

// ── Notification bell with live unread count ─────────────────────────────────

class _NotificationBell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: NotificationRepository.instance.watchUnreadCount(),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        return _IconBubble(
          icon: Icons.notifications_none_rounded,
          badgeCount: count > 0 ? count : null,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const NotificationCenterScreen(),
              ),
            );
          },
        );
      },
    );
  }
}

// ── Icon bubble (notification / profile) ─────────────────────────────────────

class _IconBubble extends StatelessWidget {
  const _IconBubble({required this.icon, required this.onTap, this.badgeCount});

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
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
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
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0A84FF),
                  Color(0xFF1449B0),
                  Color(0xFF1E3A8A),
                ],
                stops: [0.0, 0.55, 1.0],
              ),
              borderRadius: AppRadius.borderRadiusXxl,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0A84FF).withValues(alpha: 0.35),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                  spreadRadius: -4,
                ),
                BoxShadow(
                  color: const Color(0xFF1E3A8A).withValues(alpha: 0.18),
                  blurRadius: 48,
                  offset: const Offset(0, 20),
                  spreadRadius: 2,
                ),
              ],
            ),
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
                        AppColors.white.withValues(alpha: 0),
                        AppColors.white.withValues(alpha: 0.25),
                        AppColors.white.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                _DetailRow(
                  icon: Icons.calendar_today_rounded,
                  label: 'Datum',
                  value: '24. April 2026',
                  onDark: true,
                ),
                const SizedBox(height: AppSpacing.lg),
                _DetailRow(
                  icon: Icons.local_hospital_rounded,
                  label: 'Klinik',
                  value: 'Universitätsklinikum München',
                  onDark: true,
                ),
                const SizedBox(height: AppSpacing.lg),
                _DetailRow(
                  icon: Icons.person_rounded,
                  label: 'Arzt',
                  value: 'Dr. med. Julia Schneider',
                  onDark: true,
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
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.15),
            borderRadius: AppRadius.borderRadiusPill,
            border: Border.all(
              color: AppColors.white.withValues(alpha: 0.20),
            ),
          ),
          child: const Icon(
            Icons.monitor_heart_outlined,
            color: AppColors.white,
            size: 26,
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Aktuelle Operation',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.white.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Knie‑Arthroskopie',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ),
        const _PulsingStatusBadge(),
      ],
    );
  }
}

class _PulsingStatusBadge extends StatefulWidget {
  const _PulsingStatusBadge();

  @override
  State<_PulsingStatusBadge> createState() => _PulsingStatusBadgeState();
}

class _PulsingStatusBadgeState extends State<_PulsingStatusBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.15),
        borderRadius: AppRadius.borderRadiusPill,
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, _) => Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF34D399),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF34D399).withValues(
                      alpha: 0.3 + _ctrl.value * 0.5,
                    ),
                    blurRadius: 4 + _ctrl.value * 4,
                    spreadRadius: _ctrl.value * 2,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          const Text(
            'Geplant',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ],
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onDark = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final iconBg = onDark
        ? AppColors.white.withValues(alpha: 0.12)
        : AppColors.primary.withValues(alpha: 0.05);
    final iconColor = onDark
        ? AppColors.white.withValues(alpha: 0.85)
        : AppColors.grey500;
    final labelColor = onDark
        ? AppColors.white.withValues(alpha: 0.6)
        : null;
    final valueColor = onDark
        ? AppColors.white.withValues(alpha: 0.95)
        : null;

    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: AppRadius.borderRadiusSm,
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: AppSpacing.md),
        SizedBox(
          width: 52,
          child: Text(
            label,
            style: tt.labelSmall?.copyWith(color: labelColor),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            value,
            style: tt.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: valueColor,
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
    // Progress: 90 days total → how many weeks are done
    const totalDays = 90;
    final elapsed = (totalDays - days).clamp(0, totalDays);
    final progress = elapsed / totalDays;

    return GlassContainer(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.xl + AppSpacing.sm,
      ),
      borderRadius: AppRadius.borderRadiusXxl,
      variant: GlassVariant.medium,
      elevation: GlassElevation.medium,
      child: Row(
        children: [
          // Countdown ring + number
          SizedBox(
            width: 88,
            height: 88,
            child: CustomPaint(
              painter: _CountdownRingPainter(
                progress: progress,
                trackColor: AppColors.grey200.withValues(alpha: 0.6),
                progressGradientColors: const [
                  Color(0xFF0A84FF),
                  Color(0xFF5AC8FA),
                ],
                strokeWidth: 5,
              ),
              child: Center(
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF0A84FF), Color(0xFF5AC8FA)],
                  ).createShader(bounds),
                  child: Text(
                    '$days',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white,
                      letterSpacing: -2.0,
                      height: 1,
                    ),
                  ),
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
        ],
      ),
    );
  }
}

class _CountdownRingPainter extends CustomPainter {
  _CountdownRingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressGradientColors,
    this.strokeWidth = 5,
  });

  final double progress;
  final Color trackColor;
  final List<Color> progressGradientColors;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    if (progress > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      final sweepAngle = 2 * math.pi * progress;
      final gradPaint = Paint()
        ..shader = SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: -math.pi / 2 + sweepAngle,
          colors: progressGradientColors,
        ).createShader(rect)
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawArc(
        rect,
        -math.pi / 2,
        sweepAngle,
        false,
        gradPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_CountdownRingPainter old) =>
      old.progress != progress || old.trackColor != trackColor;
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
              // Donut progress ring
              SizedBox(
                width: 56,
                height: 56,
                child: CustomPaint(
                  painter: _DonutProgressPainter(
                    progress: progress,
                    trackColor: AppColors.success.withValues(alpha: 0.12),
                    progressColor: AppColors.success,
                    strokeWidth: 5,
                  ),
                  child: Center(
                    child: Text(
                      '${(progress * 100).round()}%',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.success,
                        letterSpacing: -0.5,
                      ),
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

// ── Check item padding improved ─────────────────────────────────────

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
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            AnimatedCheckbox(value: done, activeColor: AppColors.success),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AnimatedDefaultTextStyle(
                duration: MotionDuration.medium,
                curve: MotionCurve.standard,
                style: TextStyle(
                  fontSize: 15,
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
    return Column(
      children: [
        GlassButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const OperationDetailScreen(),
              ),
            );
          },
          label: 'OP Details ansehen',
          icon: Icons.arrow_forward_rounded,
          expand: true,
        ),
        const SizedBox(height: AppSpacing.md),
        GlassButton(
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
      ],
    );
  }
}

// ── Donut progress painter ───────────────────────────────────────────────────

class _DonutProgressPainter extends CustomPainter {
  _DonutProgressPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    this.strokeWidth = 5,
  });

  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      final sweepAngle = 2 * math.pi * progress;
      final progressPaint = Paint()
        ..color = progressColor
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_DonutProgressPainter old) =>
      old.progress != progress || old.trackColor != trackColor;
}
