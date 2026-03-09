import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../ui/ui.dart';
import 'bella_overlay_controller.dart';

/// A small, round floating button (🐰) that hovers on the screen.
///
/// The user can drag it to reposition. Tapping toggles the Bella AI
/// chat overlay open or closed.
class BellaFab extends StatefulWidget {
  const BellaFab({super.key, required this.controller});

  final BellaOverlayController controller;

  @override
  State<BellaFab> createState() => _BellaFabState();
}

class _BellaFabState extends State<BellaFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breathe;
  Offset? _position;

  static const double _size = 56;

  @override
  void initState() {
    super.initState();
    _breathe = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathe.dispose();
    super.dispose();
  }

  Offset _defaultPosition(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Offset(
      mq.size.width - _size - AppSpacing.lg,
      mq.size.height - _size - mq.padding.bottom - 100,
    );
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _position = (_position ?? _defaultPosition(context)) + details.delta;
    });
  }

  void _onPanEnd(DragEndDetails _) {
    // Snap to nearest horizontal edge.
    if (_position == null) return;
    final mq = MediaQuery.of(context);
    final mid = mq.size.width / 2;
    final dx = _position!.dx + _size / 2 < mid
        ? AppSpacing.lg
        : mq.size.width - _size - AppSpacing.lg;
    // Clamp vertical.
    final dy = _position!.dy.clamp(
      mq.padding.top + AppSpacing.lg,
      mq.size.height - _size - mq.padding.bottom - AppSpacing.lg,
    );
    setState(() => _position = Offset(dx, dy.toDouble()));
  }

  @override
  Widget build(BuildContext context) {
    final pos = _position ?? _defaultPosition(context);

    return AnimatedPositioned(
      duration: MotionDuration.medium,
      curve: MotionCurve.standard,
      left: pos.dx,
      top: pos.dy,
      child: GestureDetector(
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: AnimatedBuilder(
          animation: _breathe,
          builder: (context, child) {
            final scale = 1.0 + _breathe.value * 0.04;
            return Transform.scale(scale: scale, child: child);
          },
          child: PressableScale(
            onTap: () {
              HapticFeedback.lightImpact();
              widget.controller.toggle();
            },
            child: Container(
              width: _size,
              height: _size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B9D).withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/bella_avatar.png',
                  width: _size,
                  height: _size,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
