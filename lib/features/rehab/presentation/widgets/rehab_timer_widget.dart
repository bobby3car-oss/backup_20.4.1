import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../ui/ui.dart';

/// The current phase of the timer.
enum TimerPhase { idle, work, rest, done }

/// Animated ring timer with work/rest phases.
///
/// Displays a circular ring that counts down seconds per set,
/// inserts rest phases between sets, and reports completion.
class RehabTimerWidget extends StatefulWidget {
  const RehabTimerWidget({
    super.key,
    required this.durationSeconds,
    required this.sets,
    required this.restSeconds,
    required this.onComplete,
  });

  final int durationSeconds;
  final int sets;
  final int restSeconds;
  final void Function(int completedSets, int totalDurationSeconds) onComplete;

  @override
  State<RehabTimerWidget> createState() => _RehabTimerWidgetState();
}

class _RehabTimerWidgetState extends State<RehabTimerWidget>
    with TickerProviderStateMixin {
  late AnimationController _ringController;
  late Animation<double> _ringAnimation;

  TimerPhase _phase = TimerPhase.idle;
  int _currentSet = 0;
  int _secondsRemaining = 0;
  Timer? _ticker;
  bool _isPaused = false;
  int _totalElapsedSeconds = 0;

  // Pulse animation for work phase glow.
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(vsync: this);
    _ringAnimation = const AlwaysStoppedAnimation(1.0);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _ringController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _start() {
    _currentSet = 1;
    _totalElapsedSeconds = 0;
    _startWorkPhase();
  }

  void _startWorkPhase() {
    setState(() {
      _phase = TimerPhase.work;
      _secondsRemaining = widget.durationSeconds;
      _isPaused = false;
    });
    Haptic.medium();
    _pulseController.repeat(reverse: true);
    _startRingAnimation(widget.durationSeconds);
    _startTicker();
  }

  void _startRestPhase() {
    setState(() {
      _phase = TimerPhase.rest;
      _secondsRemaining = widget.restSeconds;
      _isPaused = false;
    });
    Haptic.light();
    _pulseController.stop();
    _pulseController.reset();
    _startRingAnimation(widget.restSeconds);
    _startTicker();
  }

  void _startRingAnimation(int totalSeconds) {
    _ringController.duration = Duration(seconds: totalSeconds);
    _ringAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.linear),
    );
    _ringController.forward(from: 0.0);
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isPaused) return;
      setState(() {
        _secondsRemaining--;
        _totalElapsedSeconds++;
      });

      if (_secondsRemaining <= 3 && _secondsRemaining > 0) {
        Haptic.light();
      }

      if (_secondsRemaining <= 0) {
        _ticker?.cancel();
        _onPhaseEnd();
      }
    });
  }

  void _onPhaseEnd() {
    if (_phase == TimerPhase.work) {
      if (_currentSet < widget.sets) {
        // Start rest phase between sets.
        _startRestPhase();
      } else {
        // All sets done.
        _complete();
      }
    } else if (_phase == TimerPhase.rest) {
      // Rest done — next set.
      _currentSet++;
      _startWorkPhase();
    }
  }

  void _complete() {
    _ticker?.cancel();
    _pulseController.stop();
    _pulseController.reset();
    setState(() => _phase = TimerPhase.done);
    Haptic.medium();
    widget.onComplete(_currentSet, _totalElapsedSeconds);
  }

  void _togglePause() {
    setState(() => _isPaused = !_isPaused);
    if (_isPaused) {
      _ringController.stop();
      _pulseController.stop();
    } else {
      _ringController.forward();
      if (_phase == TimerPhase.work) {
        _pulseController.repeat(reverse: true);
      }
    }
    Haptic.selection();
  }

  void _skip() {
    _ticker?.cancel();
    if (_phase == TimerPhase.work) {
      // Count this set as done, then decide next.
      if (_currentSet < widget.sets) {
        _startRestPhase();
      } else {
        _complete();
      }
    } else if (_phase == TimerPhase.rest) {
      _currentSet++;
      _startWorkPhase();
    }
  }

  void _reset() {
    _ticker?.cancel();
    _ringController.reset();
    _pulseController.stop();
    _pulseController.reset();
    setState(() {
      _phase = TimerPhase.idle;
      _currentSet = 0;
      _secondsRemaining = 0;
      _isPaused = false;
      _totalElapsedSeconds = 0;
    });
    Haptic.selection();
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m > 0) return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    return s.toString();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = _phase == TimerPhase.work || _phase == TimerPhase.rest;
    final ringColor = _phase == TimerPhase.rest
        ? AppColors.success
        : AppColors.primary;
    final phaseLabel = switch (_phase) {
      TimerPhase.idle => 'Bereit',
      TimerPhase.work => 'Aktiv',
      TimerPhase.rest => 'Pause',
      TimerPhase.done => 'Fertig!',
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Ring Timer ──
        SizedBox(
          width: 220,
          height: 220,
          child: AnimatedBuilder(
            animation: Listenable.merge([_ringController, _pulseController]),
            builder: (context, _) {
              return CustomPaint(
                painter: _TimerRingPainter(
                  progress: isActive ? _ringAnimation.value : (_phase == TimerPhase.idle ? 1.0 : 0.0),
                  color: ringColor,
                  pulseValue: _phase == TimerPhase.work ? _pulseAnimation.value : 0.0,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Set dots
                      if (widget.sets > 1) ...[
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(widget.sets, (i) {
                            final done = i < _currentSet - (_phase == TimerPhase.rest ? 0 : 1);
                            final current = i == _currentSet - 1 && _phase == TimerPhase.work;
                            return Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: done
                                    ? ringColor
                                    : current
                                        ? ringColor.withValues(alpha: 0.6)
                                        : AppColors.grey300.withValues(alpha: 0.4),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 8),
                      ],

                      // Phase label
                      Text(
                        phaseLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: ringColor.withValues(alpha: 0.8),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),

                      // Countdown
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, anim) => ScaleTransition(
                          scale: anim,
                          child: child,
                        ),
                        child: Text(
                          isActive ? _formatTime(_secondsRemaining) : (_phase == TimerPhase.idle ? '${widget.durationSeconds}' : '✓'),
                          key: ValueKey<int>(_secondsRemaining),
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -2,
                            height: 1.1,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),

                      // Set counter
                      if (isActive) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Satz $_currentSet/${widget.sets}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),

        // ── Controls ──
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isActive) ...[
              // Reset
              _ControlButton(
                icon: Icons.refresh_rounded,
                label: 'Reset',
                color: AppColors.error,
                onTap: _reset,
              ),
              const SizedBox(width: AppSpacing.xl),
              // Play/Pause
              _ControlButton(
                icon: _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                label: _isPaused ? 'Weiter' : 'Pause',
                color: AppColors.primary,
                isPrimary: true,
                onTap: _togglePause,
              ),
              const SizedBox(width: AppSpacing.xl),
              // Skip
              _ControlButton(
                icon: Icons.skip_next_rounded,
                label: 'Skip',
                color: AppColors.warning,
                onTap: _skip,
              ),
            ] else if (_phase == TimerPhase.idle) ...[
              GlassButton(
                onPressed: _start,
                label: 'Timer starten',
                icon: Icons.play_arrow_rounded,
              ),
            ] else if (_phase == TimerPhase.done) ...[
              GlassButton(
                onPressed: _reset,
                label: 'Nochmal',
                icon: Icons.refresh_rounded,
                variant: GlassButtonVariant.secondary,
              ),
            ],
          ],
        ),
      ],
    );
  }
}

// ============================================================================
// _ControlButton
// ============================================================================

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isPrimary = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: () {
        Haptic.selection();
        onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isPrimary ? 56 : 44,
            height: isPrimary ? 56 : 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isPrimary
                  ? color
                  : color.withValues(alpha: 0.12),
              boxShadow: isPrimary
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              size: isPrimary ? 28 : 22,
              color: isPrimary ? Colors.white : color,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// _TimerRingPainter
// ============================================================================

class _TimerRingPainter extends CustomPainter {
  _TimerRingPainter({
    required this.progress,
    required this.color,
    required this.pulseValue,
  });

  final double progress;
  final Color color;
  final double pulseValue;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) / 2) - 12;
    const strokeWidth = 10.0;

    // Background ring
    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress ring
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );

    // Pulse glow (work phase only)
    if (pulseValue > 0) {
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.08 + pulseValue * 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 6 + (pulseValue * 4)
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_TimerRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.pulseValue != pulseValue;
  }
}
