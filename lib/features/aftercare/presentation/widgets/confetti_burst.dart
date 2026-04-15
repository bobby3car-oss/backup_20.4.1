import 'dart:math';

import 'package:flutter/material.dart';

/// A brief radial confetti burst animation.
///
/// Call [trigger] on the state to play once. Auto-resets after completion.
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
                    painter: _ConfettiPainter(progress: _controller.value),
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

  static final _random = Random(42);
  static final _particles = List.generate(12, (i) {
    final angle = (i / 12) * 2 * pi + _random.nextDouble() * 0.3;
    final speed = 40.0 + _random.nextDouble() * 25.0;
    final color = [
      const Color(0xFF34C759),
      const Color(0xFF007AFF),
      const Color(0xFFFF9500),
      const Color(0xFF5AC8FA),
      const Color(0xFFFF2D55),
      const Color(0xFFAF52DE),
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
