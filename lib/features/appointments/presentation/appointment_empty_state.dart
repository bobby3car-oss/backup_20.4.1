import 'package:flutter/material.dart';

import '../../../ui/ui.dart';

/// A beautiful empty-state illustration for the appointments list.
///
/// Shows an animated calendar icon, a headline and a subtitle.
class AppointmentEmptyState extends StatefulWidget {
  const AppointmentEmptyState({super.key, this.isFiltered = false, this.onAdd});

  /// When `true`, shows a "no results" message instead of the default one.
  final bool isFiltered;

  /// Optional callback to add a new appointment. Shows a button when set.
  final VoidCallback? onAdd;

  @override
  State<AppointmentEmptyState> createState() => _AppointmentEmptyStateState();
}

class _AppointmentEmptyStateState extends State<AppointmentEmptyState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _bounce;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _bounce = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -12), weight: 30),
      TweenSequenceItem(tween: Tween(begin: -12, end: 0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0, end: -5), weight: 20),
      TweenSequenceItem(tween: Tween(begin: -5, end: 0), weight: 20),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FadeTransition(
      opacity: _fade,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _bounce,
                builder: (_, child) => Transform.translate(
                  offset: Offset(0, _bounce.value),
                  child: child,
                ),
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.18),
                        AppColors.primaryLight.withValues(alpha: 0.10),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.20),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    widget.isFiltered
                        ? Icons.search_off_rounded
                        : Icons.calendar_month_rounded,
                    size: 42,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                widget.isFiltered
                    ? 'Keine Ergebnisse'
                    : 'Noch keine Termine',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.isFiltered
                    ? 'Versuche andere Suchbegriffe oder Filter.'
                    : 'Tippe auf + um deinen ersten Termin hinzuzufügen.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              if (widget.onAdd != null) ...[
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: widget.onAdd,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Termin hinzufügen'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
