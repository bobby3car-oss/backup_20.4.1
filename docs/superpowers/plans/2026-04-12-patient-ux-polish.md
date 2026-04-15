# Patient UX & Polishing Implementation Plan

**Goal:** Transform the patient aftercare plan view into a polished, medical-grade experience with today-focus, progress tracking, micro-interactions, status overlays, and error handling.

**Architecture:** 6 new presentation widgets extracted into a `widgets/` subdirectory, 1 new service method, integration into existing `PatientPlanViewScreen`. All widgets are composable and self-contained.

**Tech Stack:** Flutter/Dart, existing Glass UI system (`GlassCard`, `GlassProgressBar`, `AnimatedCheckbox`), existing `PatientAftercareProgressService` for item completion, existing `Haptic` for feedback.

---

### Task 1: ConfettiBurst Widget

**Files:**
- Create: `lib/features/aftercare/presentation/widgets/confetti_burst.dart`

- [ ] **Step 1: Create ConfettiBurst widget**

```dart
// lib/features/aftercare/presentation/widgets/confetti_burst.dart
import 'dart:math';
import 'package:flutter/material.dart';

/// A brief radial confetti burst animation.
///
/// Call [trigger] on the state to play. Auto-disposes.
/// Renders as an overlay on top of [child].
class ConfettiBurst extends StatefulWidget {
  const ConfettiBurst({super.key, required this.child});
  final Widget child;

  @override
  State<ConfettiBurst> createState() => ConfettiBurstState();
}

class ConfettiBurstState extends State<ConfettiBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _triggered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() => _triggered = false);
        }
      });
  }

  void trigger() {
    if (_triggered) return;
    setState(() => _triggered = true);
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        widget.child,
        if (_triggered)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _ConfettiPainter(
                      progress: _controller.value,
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.progress});
  final double progress;

  static final _random = Random(42); // fixed seed for consistent burst
  static final _particles = List.generate(12, (i) {
    final angle = (i / 12) * 2 * pi + _random.nextDouble() * 0.3;
    final speed = 40.0 + _random.nextDouble() * 25.0;
    final color = [
      const Color(0xFF34C759), // success
      const Color(0xFF007AFF), // primary
      const Color(0xFFFF9500), // warning
      const Color(0xFF5AC8FA), // accent
      const Color(0xFFFF2D55), // pink
      const Color(0xFFAF52DE), // purple
    ][i % 6];
    final size = 3.0 + _random.nextDouble() * 3.0;
    return _Particle(angle: angle, speed: speed, color: color, size: size);
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final opacity = (1.0 - progress).clamp(0.0, 1.0);

    for (final p in _particles) {
      final distance = p.speed * progress;
      final dx = center.dx + cos(p.angle) * distance;
      final dy = center.dy + sin(p.angle) * distance - (progress * 10);
      final paint = Paint()
        ..color = p.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(dx, dy), p.size * (1 - progress * 0.5), paint);
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}

class _Particle {
  const _Particle({
    required this.angle,
    required this.speed,
    required this.color,
    required this.size,
  });
  final double angle;
  final double speed;
  final Color color;
  final double size;
}
```

- [ ] **Step 2: Verify no errors**

Run: `dart analyze lib/features/aftercare/presentation/widgets/confetti_burst.dart`
Expected: No issues found

- [ ] **Step 3: Commit**

```bash
git add lib/features/aftercare/presentation/widgets/confetti_burst.dart
git commit -m "feat(aftercare): add ConfettiBurst micro-interaction widget"
```

---

### Task 2: AftercareErrorRetry Widget

**Files:**
- Create: `lib/features/aftercare/presentation/widgets/error_retry_widget.dart`

- [ ] **Step 1: Create error retry widget**

```dart
// lib/features/aftercare/presentation/widgets/error_retry_widget.dart
import 'package:flutter/material.dart';

import '../../../../ui/ui.dart';

/// Friendly error state with icon, message, and retry button.
///
/// Used when a stream or future fails in the aftercare plan screens.
class AftercareErrorRetry extends StatelessWidget {
  const AftercareErrorRetry({
    super.key,
    this.message = 'Daten konnten nicht geladen werden.',
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: AppColors.grey400,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Bitte überprüfe deine Verbindung.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.grey500,
                  ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              GlassButton(
                onPressed: onRetry!,
                label: 'Erneut versuchen',
                icon: Icons.refresh_rounded,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Verify no errors**

Run: `dart analyze lib/features/aftercare/presentation/widgets/error_retry_widget.dart`
Expected: No issues found

- [ ] **Step 3: Commit**

```bash
git add lib/features/aftercare/presentation/widgets/error_retry_widget.dart
git commit -m "feat(aftercare): add AftercareErrorRetry widget"
```

---

### Task 3: MedicalDisclaimer Widget

**Files:**
- Create: `lib/features/aftercare/presentation/widgets/medical_disclaimer.dart`

- [ ] **Step 1: Create medical disclaimer widgets**

```dart
// lib/features/aftercare/presentation/widgets/medical_disclaimer.dart
import 'package:flutter/material.dart';

import '../../../../ui/ui.dart';

/// Footer disclaimer for the patient plan view.
///
/// Reminds patients that the plan is informational and
/// does not replace medical advice.
class MedicalDisclaimerFooter extends StatelessWidget {
  const MedicalDisclaimerFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.8,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                Icons.info_outline_rounded,
                size: 14,
                color: AppColors.grey500,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Dieser Plan dient als Orientierung und ersetzt keine '
                'ärztliche Diagnose oder Behandlung. '
                'Bei Unsicherheit kontaktiere bitte deinen Arzt.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      height: 1.5,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Inline warning shown once per phase if it contains critical items.
///
/// Critical categories: wound, dressing, sutureRemoval, medication.
class MedicalInlineWarning extends StatelessWidget {
  const MedicalInlineWarning({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 12,
            color: AppColors.warning,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              'Bei Bedenken kontaktiere deinen Arzt.',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                    fontSize: 11,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Verify no errors**

Run: `dart analyze lib/features/aftercare/presentation/widgets/medical_disclaimer.dart`
Expected: No issues found

- [ ] **Step 3: Commit**

```bash
git add lib/features/aftercare/presentation/widgets/medical_disclaimer.dart
git commit -m "feat(aftercare): add medical disclaimer widgets"
```

---

### Task 4: PlanStatusBanner Widget

**Files:**
- Create: `lib/features/aftercare/presentation/widgets/plan_status_banner.dart`

- [ ] **Step 1: Create plan status banner widget**

```dart
// lib/features/aftercare/presentation/widgets/plan_status_banner.dart
import 'package:flutter/material.dart';

import '../../../../ui/ui.dart';
import '../../domain/patient_aftercare_plan.dart';
import '../../domain/plan_status.dart';

/// Status-aware banner for paused, completed, and cancelled plans.
///
/// Returns `null` for active/draft/scheduled plans (no banner needed).
/// Returns a GlassCard with appropriate styling for other statuses.
class PlanStatusBanner extends StatelessWidget {
  const PlanStatusBanner({super.key, required this.plan});

  final PatientAftercarePlan plan;

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  @override
  Widget build(BuildContext context) {
    return switch (plan.status) {
      PlanStatus.paused => _buildPausedBanner(context),
      PlanStatus.completed => _buildCompletedBanner(context),
      PlanStatus.cancelled => _buildCancelledBanner(context),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildPausedBanner(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: AppRadius.borderRadiusMd,
        border: Border(
          left: BorderSide(color: AppColors.warning, width: 3),
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pause_circle_rounded, size: 20, color: AppColors.warning),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Plan pausiert',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.warning,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Dein Arzt hat den Plan vorübergehend pausiert. '
            'Du wirst benachrichtigt, sobald es weitergeht.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
          ),
          if (plan.pauseReason != null && plan.pauseReason!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Grund: ${plan.pauseReason}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompletedBanner(BuildContext context) {
    final totalItems = plan.phases.fold<int>(0, (s, p) => s + p.items.length);
    final duration = plan.completedAt != null
        ? plan.completedAt!.difference(plan.surgeryDate).inDays
        : null;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        borderRadius: AppRadius.borderRadiusMd,
        border: Border(
          left: BorderSide(color: AppColors.success, width: 3),
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.task_alt_rounded, size: 20, color: AppColors.success),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Plan abgeschlossen',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.xs,
            children: [
              if (plan.completedAt != null)
                _BannerChip(
                  icon: Icons.calendar_today_rounded,
                  label: 'Abgeschlossen: ${_fmt(plan.completedAt!)}',
                ),
              if (duration != null)
                _BannerChip(
                  icon: Icons.timer_outlined,
                  label: '$duration Tage',
                ),
              _BannerChip(
                icon: Icons.checklist_rounded,
                label: '$totalItems Aufgaben',
              ),
            ],
          ),
          if (plan.completionSummary != null &&
              plan.completionSummary!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.06),
                borderRadius: AppRadius.borderRadiusSm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Arzt-Kommentar:',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    plan.completionSummary!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCancelledBanner(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: AppRadius.borderRadiusMd,
        border: Border(
          left: BorderSide(color: AppColors.error, width: 3),
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.cancel_rounded, size: 20, color: AppColors.error),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Plan abgebrochen',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (plan.cancelledAt != null) ...[
            Text(
              'Abgebrochen am: ${_fmt(plan.cancelledAt!)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
          if (plan.cancelReason != null && plan.cancelReason!.isNotEmpty) ...[
            Text(
              'Grund: ${plan.cancelReason}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          Text(
            'Bei Fragen kontaktiere bitte deinen behandelnden Arzt.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }
}

class _BannerChip extends StatelessWidget {
  const _BannerChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.grey500),
        const SizedBox(width: 3),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Verify no errors**

Run: `dart analyze lib/features/aftercare/presentation/widgets/plan_status_banner.dart`
Expected: No issues found

- [ ] **Step 3: Commit**

```bash
git add lib/features/aftercare/presentation/widgets/plan_status_banner.dart
git commit -m "feat(aftercare): add PlanStatusBanner for paused/completed/cancelled"
```

---

### Task 5: TodayHeroSection Widget

**Files:**
- Create: `lib/features/aftercare/presentation/widgets/today_hero_section.dart`

- [ ] **Step 1: Create today hero section widget**

This is the most complex widget. It:
- Computes which items are "today" based on surgeryDate + day offsets
- Shows a progress summary
- Lists today's items with interactive checkboxes
- Handles edge cases (no tasks today, before surgery, all done)

```dart
// lib/features/aftercare/presentation/widgets/today_hero_section.dart
import 'package:flutter/material.dart';

import '../../../../ui/ui.dart';
import '../../domain/aftercare_item.dart';
import '../../domain/aftercare_item_category.dart';
import '../../domain/aftercare_item_progress.dart';
import '../../domain/patient_aftercare_plan.dart';
import '../../domain/plan_status.dart';
import 'confetti_burst.dart';

/// Hero section showing today's tasks with interactive checkboxes.
///
/// Computes "today" by comparing [DateTime.now()] against the plan's
/// surgery date + each item's [startDayOffset] / [endDayOffset].
class TodayHeroSection extends StatelessWidget {
  const TodayHeroSection({
    super.key,
    required this.plan,
    required this.progress,
    required this.onToggleItem,
    this.confettiKey,
  });

  final PatientAftercarePlan plan;
  final AftercareItemProgress progress;
  final Future<void> Function(String itemId) onToggleItem;
  final GlobalKey<ConfettiBurstState>? confettiKey;

  @override
  Widget build(BuildContext context) {
    final daysSinceSurgery =
        DateTime.now().difference(plan.surgeryDate).inDays;

    // Before surgery — show pre-op message.
    if (daysSinceSurgery < 0) {
      return _buildPreOpCard(context);
    }

    // Collect today's items across all phases.
    final todayItems = <_TodayItem>[];
    for (final phase in plan.phases) {
      for (final item in phase.items) {
        if (_isItemForToday(item, phase.startDayOffset, daysSinceSurgery)) {
          todayItems.add(_TodayItem(
            item: item,
            phaseName: phase.title,
            isCompleted: progress.isCompleted(item.id),
          ));
        }
      }
    }

    if (todayItems.isEmpty) {
      return _buildNoTasksCard(context);
    }

    final completedCount = todayItems.where((t) => t.isCompleted).length;
    final totalCount = todayItems.length;
    final allDone = completedCount == totalCount;
    final fraction = totalCount > 0 ? completedCount / totalCount : 0.0;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.today_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Heute',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const Spacer(),
              Text(
                '$completedCount von $totalCount ✓',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: allDone ? AppColors.success : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          GlassProgressBar(
            value: fraction,
            height: 4,
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.success],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Items
          for (final todayItem in todayItems)
            _TodayItemTile(
              todayItem: todayItem,
              onToggle: () => onToggleItem(todayItem.item.id),
              isPlanActive: plan.status == PlanStatus.active,
            ),

          // All done message
          if (allDone) ...[
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: Text(
                'Alles geschafft! 🎉',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _isItemForToday(AftercareItem item, int phaseStartOffset, int daysSinceSurgery) {
    // 1. exactDate takes priority
    if (item.exactDate != null) {
      final now = DateTime.now();
      return item.exactDate!.year == now.year &&
          item.exactDate!.month == now.month &&
          item.exactDate!.day == now.day;
    }

    // 2. Item-level day offset (absolute from surgery)
    if (item.startDayOffset != null) {
      final effectiveEnd = item.endDayOffset ?? item.startDayOffset!;
      return daysSinceSurgery >= item.startDayOffset! &&
          daysSinceSurgery <= effectiveEnd;
    }

    // 3. Fall back to phase offset for time-bound items
    if (item.isTimeBound) {
      final phaseEnd = plan.phases
          .firstWhere(
            (p) => p.items.contains(item),
            orElse: () => plan.phases.first,
          )
          .endDayOffset;
      final effectiveEnd = phaseEnd ?? phaseStartOffset;
      return daysSinceSurgery >= phaseStartOffset &&
          daysSinceSurgery <= effectiveEnd;
    }

    return false;
  }

  Widget _buildPreOpCard(BuildContext context) {
    final fmt =
        '${plan.surgeryDate.day.toString().padLeft(2, '0')}.${plan.surgeryDate.month.toString().padLeft(2, '0')}.${plan.surgeryDate.year}';
    return GlassCard(
      child: Column(
        children: [
          Icon(Icons.event_rounded, size: 32, color: AppColors.primary),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Dein Plan startet am $fmt',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'Gute Besserung!',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.grey500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoTasksCard(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.today_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Heute',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Icon(Icons.event_available_rounded, size: 28, color: AppColors.grey400),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Heute keine Aufgaben.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          Text(
            'Genieße deinen Tag!',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.grey500,
                ),
          ),
        ],
      ),
    );
  }
}

class _TodayItemTile extends StatelessWidget {
  const _TodayItemTile({
    required this.todayItem,
    required this.onToggle,
    required this.isPlanActive,
  });

  final _TodayItem todayItem;
  final VoidCallback onToggle;
  final bool isPlanActive;

  static const _criticalCategories = {
    AftercareItemCategory.wound,
    AftercareItemCategory.dressing,
    AftercareItemCategory.sutureRemoval,
    AftercareItemCategory.medication,
  };

  @override
  Widget build(BuildContext context) {
    final item = todayItem.item;
    final done = todayItem.isCompleted;
    final isCritical = _criticalCategories.contains(item.category);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      decoration: isCritical && !done
          ? BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: AppColors.warning.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
            )
          : null,
      child: Opacity(
        opacity: done ? 0.6 : 1.0,
        child: Padding(
          padding: EdgeInsets.only(
            left: isCritical && !done ? AppSpacing.sm : 0,
            top: AppSpacing.xxs,
            bottom: AppSpacing.xxs,
          ),
          child: Row(
            children: [
              AnimatedCheckbox(
                value: done,
                onChanged: isPlanActive ? (_) {
                  Haptic.medium();
                  onToggle();
                } : null,
                size: 22,
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                item.category.icon,
                size: 14,
                color: isCritical && !done
                    ? AppColors.warning
                    : done
                        ? AppColors.grey400
                        : AppColors.grey500,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  item.title.isNotEmpty ? item.title : item.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        decoration: done ? TextDecoration.lineThrough : null,
                        decorationColor:
                            AppColors.textSecondary.withValues(alpha: 0.6),
                        color: done
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                        fontWeight: done ? FontWeight.w400 : FontWeight.w500,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodayItem {
  const _TodayItem({
    required this.item,
    required this.phaseName,
    required this.isCompleted,
  });
  final AftercareItem item;
  final String phaseName;
  final bool isCompleted;
}
```

- [ ] **Step 2: Verify no errors**

Run: `dart analyze lib/features/aftercare/presentation/widgets/today_hero_section.dart`
Expected: No issues found

- [ ] **Step 3: Commit**

```bash
git add lib/features/aftercare/presentation/widgets/today_hero_section.dart
git commit -m "feat(aftercare): add TodayHeroSection with interactive checkboxes"
```

---

### Task 6: Add getCurrentPatientPlan Service Method

**Files:**
- Modify: `lib/features/aftercare/data/patient_aftercare_plan_service.dart` (around line 285)

The existing `getActivePlan()` only queries `status == active`. The patient plan view needs to also show paused, completed, and cancelled plans. Add a new method.

- [ ] **Step 1: Add getCurrentPatientPlan method**

Add after the existing `getActivePlan` method (around line 298):

```dart
  /// Streams the current plan for a patient, including paused/completed/cancelled.
  ///
  /// Unlike [getActivePlan], this returns the plan regardless of lifecycle status,
  /// excluding only drafts, scheduled, and archived plans.
  /// Priority: active > paused > completed > cancelled (returns first match).
  Stream<PatientAftercarePlan?> getCurrentPatientPlan(String patientId) {
    return _firestore
        .collection(_collection)
        .where('patientId', isEqualTo: patientId)
        .where('status', whereIn: [
          PlanStatus.active.name,
          PlanStatus.paused.name,
          PlanStatus.completed.name,
          PlanStatus.cancelled.name,
        ])
        .orderBy('activatedAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return null;
      final doc = snap.docs.first;
      return PatientAftercarePlan.fromJson({...doc.data(), 'id': doc.id});
    });
  }
```

- [ ] **Step 2: Verify no errors**

Run: `dart analyze lib/features/aftercare/data/patient_aftercare_plan_service.dart`
Expected: No issues found

- [ ] **Step 3: Commit**

```bash
git add lib/features/aftercare/data/patient_aftercare_plan_service.dart
git commit -m "feat(aftercare): add getCurrentPatientPlan including paused/completed/cancelled"
```

---

### Task 7: Integrate into PatientPlanViewScreen

**Files:**
- Modify: `lib/features/aftercare/presentation/patient_plan_view_screen.dart`

This is the integration task. The screen needs:
1. Switch from `getActivePlan` to `getCurrentPatientPlan`
2. Add nested `StreamBuilder` for progress
3. Insert `TodayHeroSection` at top
4. Add `GlassProgressBar` in title card
5. Insert `PlanStatusBanner` for non-active plans
6. Wrap plan body in `Opacity` + `IgnorePointer` when paused/cancelled
7. Add `MedicalDisclaimerFooter` after phases
8. Add `MedicalInlineWarning` in phase cards
9. Replace error display with `AftercareErrorRetry`
10. Add phase progress counters

Full replacement of `_PatientPlanViewScreenState.build()`, `_ActivePlanBody`, and `_PatientPhaseCard`.

- [ ] **Step 1: Add imports and update state**

Add imports at the top of the file (after existing imports):

```dart
import '../data/patient_aftercare_progress_service.dart';
import '../domain/aftercare_item_progress.dart';
import '../domain/plan_status.dart';
import 'widgets/confetti_burst.dart';
import 'widgets/error_retry_widget.dart';
import 'widgets/medical_disclaimer.dart';
import 'widgets/plan_status_banner.dart';
import 'widgets/today_hero_section.dart';
```

Add to state class:

```dart
late final PatientAftercareProgressService _progressService;
final _confettiKey = GlobalKey<ConfettiBurstState>();
```

Add in `initState`:

```dart
_progressService = PatientAftercareProgressService();
```

- [ ] **Step 2: Update build method to use getCurrentPatientPlan**

Replace the `StreamBuilder` in `build()` to use `getCurrentPatientPlan` instead of `getActivePlan`.

Replace error display with:
```dart
AftercareErrorRetry(
  message: 'Plan konnte nicht geladen werden.',
  onRetry: () => setState(() {}),
)
```

- [ ] **Step 3: Update _ActivePlanBody to include progress stream**

Add a nested `StreamBuilder<AftercareItemProgress>` inside `_ActivePlanBody` that streams from `progressService.watchProgress(plan.id)`.

The body receives the progress and passes it down to:
- `TodayHeroSection` (for today computation + checkboxes)
- `GlassProgressBar` (for overall progress)
- `_PatientPhaseCard` (for per-phase progress counters)

- [ ] **Step 4: Add TodayHeroSection at top of plan body**

Insert before the title card:
```dart
FadeSlideIn(
  child: TodayHeroSection(
    plan: plan,
    progress: progress,
    onToggleItem: (itemId) async {
      await progressService.toggleItemCompleted(
        planId: plan.id,
        itemId: itemId,
      );
    },
    confettiKey: _confettiKey,
  ),
),
const SizedBox(height: AppSpacing.md),
```

- [ ] **Step 5: Add GlassProgressBar in title card**

After the InfoChips `Wrap`, before the PDF button:
```dart
const SizedBox(height: AppSpacing.md),
GlassProgressBar(
  value: totalItems > 0
      ? progress.completedCount / totalItems
      : 0.0,
  height: 6,
  gradient: const LinearGradient(
    colors: [Color(0xFF007AFF), Color(0xFF34C759)],
  ),
  label: '${progress.completedCount} von $totalItems erledigt',
  showPercentage: true,
),
```

- [ ] **Step 6: Add PlanStatusBanner + status-aware wrapping**

Insert `PlanStatusBanner` after the title card. When plan is paused or cancelled, wrap the remaining body in `Opacity(opacity: 0.5)` and `IgnorePointer()`.

When plan is cancelled, don't show the phases at all—only the banner + archive link.

- [ ] **Step 7: Add MedicalDisclaimerFooter + phasecard inline warnings**

Insert `MedicalDisclaimerFooter` after the last phase card, before the archive link.

Update `_PatientPhaseCard` to:
1. Accept `AftercareItemProgress` and show per-phase progress (e.g., "3/5")
2. Show `MedicalInlineWarning` if the phase contains any critical-category items
3. Apply critical item styling (left border + warning icon color)
4. Apply completed item styling (opacity 0.6, strikethrough)

- [ ] **Step 8: Update status badge in title card**

Replace the hardcoded "Aktiv" badge with a dynamic status badge that shows the plan's actual status:
```dart
Container(
  padding: const EdgeInsets.symmetric(
    horizontal: AppSpacing.sm,
    vertical: AppSpacing.xxs,
  ),
  decoration: BoxDecoration(
    color: _statusColor(plan.status).withValues(alpha: 0.12),
    borderRadius: AppRadius.borderRadiusSm,
  ),
  child: Text(
    plan.status.displayName,
    style: Theme.of(context).textTheme.labelSmall?.copyWith(
      color: _statusColor(plan.status),
      fontWeight: FontWeight.w600,
      fontSize: 11,
    ),
  ),
)
```

With helper:
```dart
Color _statusColor(PlanStatus status) => switch (status) {
  PlanStatus.active => AppColors.success,
  PlanStatus.paused => AppColors.warning,
  PlanStatus.completed => AppColors.success,
  PlanStatus.cancelled => AppColors.error,
  _ => AppColors.grey500,
};
```

- [ ] **Step 9: Verify no errors**

Run: `dart analyze lib/features/aftercare/presentation/patient_plan_view_screen.dart`
Expected: No issues found

- [ ] **Step 10: Commit**

```bash
git add lib/features/aftercare/presentation/patient_plan_view_screen.dart
git commit -m "feat(aftercare): integrate UX polish into PatientPlanViewScreen"
```

---

### Task 8: Update Archive Screen Error Handling

**Files:**
- Modify: `lib/features/aftercare/presentation/patient_plan_view_screen.dart` (archive section)

- [ ] **Step 1: Replace archive error display**

Replace the plain text error in `_PatientArchiveScreen` with `AftercareErrorRetry`:
```dart
if (snapshot.hasError) {
  return Padding(
    padding: EdgeInsets.only(top: headerHeight + AppSpacing.huge),
    child: AftercareErrorRetry(
      message: 'Frühere Pläne konnten nicht geladen werden.',
      onRetry: () => (context as Element).markNeedsBuild(),
    ),
  );
}
```

- [ ] **Step 2: Add no-plan medical disclaimer**

In the existing empty state (where `plan == null`), add a medical disclaimer hint:
```dart
const SizedBox(height: AppSpacing.lg),
Opacity(
  opacity: 0.7,
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.info_outline_rounded, size: 13, color: AppColors.grey500),
      const SizedBox(width: AppSpacing.xs),
      Text(
        'Bei Fragen wende dich an deinen Arzt.',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.grey500,
              fontSize: 11,
            ),
      ),
    ],
  ),
),
```

- [ ] **Step 3: Verify no errors**

Run: `dart analyze lib/features/aftercare/presentation/patient_plan_view_screen.dart`
Expected: No issues found

- [ ] **Step 4: Commit**

```bash
git add lib/features/aftercare/presentation/patient_plan_view_screen.dart
git commit -m "feat(aftercare): improve archive & empty state UX"
```

---

### Task 9: Final Verification

- [ ] **Step 1: Full analyze**

Run: `dart analyze lib/features/aftercare/`
Expected: No issues found

- [ ] **Step 2: Check for broader breakage**

Run: `dart analyze lib/ 2>&1 | head -30`
Expected: Only pre-existing issues, no new errors

- [ ] **Step 3: Verify all presentation files**

Run: `dart analyze lib/features/aftercare/presentation/`
Expected: No issues found

- [ ] **Step 4: Final commit**

```bash
git add -A
git commit -m "feat(aftercare): patient UX polish — today view, progress, animations, status banners, medical disclaimers, error handling"
```
