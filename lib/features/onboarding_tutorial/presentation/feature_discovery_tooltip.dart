import 'package:flutter/material.dart';

import '../../../ui/theme/colors.dart';
import '../../../ui/theme/spacing.dart';
import '../data/tutorial_preferences.dart';

/// A tooltip wrapper that shows a one-time discovery hint when the user
/// first visits a feature.
///
/// Usage:
/// ```dart
/// FeatureDiscoveryTooltip(
///   featureName: 'wound_doc',
///   message: 'Tipp: Fotografiere deine Wunde immer aus dem gleichen Winkel',
///   child: WoundDocWidget(),
/// )
/// ```
class FeatureDiscoveryTooltip extends StatefulWidget {
  const FeatureDiscoveryTooltip({
    super.key,
    required this.featureName,
    required this.message,
    required this.child,
    this.icon = Icons.lightbulb_outline_rounded,
    this.tipPrefix = 'Tipp',
  });

  final String featureName;
  final String message;
  final Widget child;
  final IconData icon;
  final String tipPrefix;

  @override
  State<FeatureDiscoveryTooltip> createState() =>
      _FeatureDiscoveryTooltipState();
}

class _FeatureDiscoveryTooltipState extends State<FeatureDiscoveryTooltip>
    with SingleTickerProviderStateMixin {
  bool _show = false;
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    _checkFeature();
  }

  Future<void> _checkFeature() async {
    final discovered = await TutorialPreferences.instance
        .isFeatureDiscovered(widget.featureName);
    if (!discovered && mounted) {
      setState(() => _show = true);
      _animController.forward();
      // Auto-dismiss after 8 seconds
      Future.delayed(const Duration(seconds: 8), _dismiss);
    }
  }

  void _dismiss() {
    if (!mounted || !_show) return;
    _animController.reverse().then((_) {
      if (mounted) setState(() => _show = false);
    });
    TutorialPreferences.instance.markFeatureDiscovered(widget.featureName);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_show)
          SlideTransition(
            position: _slideAnim,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: _DiscoveryBanner(
                icon: widget.icon,
                tipPrefix: widget.tipPrefix,
                message: widget.message,
                onDismiss: _dismiss,
              ),
            ),
          ),
        Flexible(child: widget.child),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _DiscoveryBanner extends StatelessWidget {
  const _DiscoveryBanner({
    required this.icon,
    required this.tipPrefix,
    required this.message,
    required this.onDismiss,
  });

  final IconData icon;
  final String tipPrefix;
  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 13, height: 1.4),
                children: [
                  TextSpan(
                    text: '$tipPrefix: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextSpan(
                    text: message,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          GestureDetector(
            onTap: onDismiss,
            child: const Icon(
              Icons.close_rounded,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
