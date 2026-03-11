import 'package:flutter/cupertino.dart';

import '../../../navigation/quick_actions_config.dart';
import '../../../ui/ui.dart';

class HomeQuickActionsRow extends StatelessWidget {
  const HomeQuickActionsRow({super.key, required this.onMorePressed});

  final VoidCallback onMorePressed;

  @override
  Widget build(BuildContext context) {
    final dockItems = primaryDockActions;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: adaptiveScrollPhysics,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          for (var i = 0; i < dockItems.length; i++) ...[
            _QuickActionChip(item: dockItems[i]),
            const SizedBox(width: AppSpacing.sm),
          ],
          _MoreActionChip(onTap: onMorePressed),
          const SizedBox(width: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({required this.item});

  final QuickActionItem item;

  static const _accentColors = <String, Color>{
    'wound': Color(0xFFFF6B6B),
    'pain': Color(0xFFD97706),
    'documents': Color(0xFF1D4ED8),
    'appointments': Color(0xFF059669),
    'voice': Color(0xFF7C3AED),
    'rehab': Color(0xFF34C759),
    'doctor-report': Color(0xFF00C7BE),
    'photos': Color(0xFF0A84FF),
  };

  @override
  Widget build(BuildContext context) {
    final accent = _accentColors[item.id] ?? AppColors.primary;
    return PressableScale(
      onTap: () => navigateToNamedRoute(context, item.routeName),
      scaleFactor: 0.94,
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        borderRadius: AppRadius.borderRadiusPill,
        variant: GlassVariant.thin,
        elevation: GlassElevation.low,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: accent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.35),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs + 2),
            GlassIcon(icon: item.icon, color: item.iconColor, size: 14),
            const SizedBox(width: AppSpacing.xs + 2),
            Text(
              item.title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                letterSpacing: 0.1,
              ),
            ),
            if (item.isProFeature) ...[
              const SizedBox(width: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.14),
                  borderRadius: AppRadius.borderRadiusPill,
                ),
                child: const Text(
                  'PRO',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: AppColors.warning,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MoreActionChip extends StatelessWidget {
  const _MoreActionChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      scaleFactor: 0.94,
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        borderRadius: AppRadius.borderRadiusPill,
        variant: GlassVariant.thin,
        elevation: GlassElevation.low,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GlassIcon(icon: CupertinoIcons.plus, color: AppColors.primary, size: 14),
            const SizedBox(width: AppSpacing.xs + 2),
            Text(
              'Mehr…',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
