import 'package:flutter/material.dart';

import '../../../ui/ui.dart';

/// A brief toast overlay showing XP earned, with an optional confetti burst.
/// Used after challenge completion.
class XpToast {
  /// Show a brief XP toast at the top of the screen. Auto-dismisses after 2s.
  static void show(
    BuildContext context, {
    required int xp,
    String? label,
  }) {
    final overlay = Overlay.of(context);
    late final OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _XpToastWidget(
        xp: xp,
        label: label,
        onDismiss: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }
}

class _XpToastWidget extends StatefulWidget {
  const _XpToastWidget({
    required this.xp,
    this.label,
    required this.onDismiss,
  });

  final int xp;
  final String? label;
  final VoidCallback onDismiss;

  @override
  State<_XpToastWidget> createState() => _XpToastWidgetState();
}

class _XpToastWidgetState extends State<_XpToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideIn;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeIn = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 25),
    ]).animate(_ctrl);

    _slideIn = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween(begin: const Offset(0, -1), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 20,
      ),
      TweenSequenceItem(tween: ConstantTween(Offset.zero), weight: 55),
      TweenSequenceItem(
        tween: Tween(begin: Offset.zero, end: const Offset(0, -0.5))
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 25,
      ),
    ]).animate(_ctrl);

    _ctrl.forward().then((_) => widget.onDismiss());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top + AppSpacing.xl;

    return Positioned(
      top: top,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideIn,
        child: FadeTransition(
          opacity: _fadeIn,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: AppRadius.borderRadiusPill,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bolt_rounded, size: 20, color: AppColors.white),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    widget.label ?? '+${widget.xp} XP',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
