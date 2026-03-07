import 'package:flutter/material.dart';

import '../../../features/pro/presentation/pro_badge.dart';
import '../../../main.dart';
import '../../../notifications/notification_repository.dart';
import '../../../ui/ui.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, this.onNotificationTap});

  final VoidCallback? onNotificationTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final pro = ProServices.maybeOf(context);

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: AppRadius.borderRadiusLg,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.monitor_heart_outlined,
              size: 24,
              color: AppColors.white,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        ShaderMask(
          shaderCallback: (bounds) =>
              AppColors.primaryGradient.createShader(bounds),
          child: Text(
            'Operationsbegleiter',
            style: tt.titleLarge?.copyWith(color: AppColors.white),
          ),
        ),
        const Spacer(),
        if (pro != null)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: ProBadge(
              entitlementService: pro.entitlementService,
              onTap: () {
                if (pro.entitlementService.isPro) {
                  Navigator.of(context).pushNamed('/pro-status');
                } else {
                  Navigator.of(context).pushNamed(
                    '/paywall',
                    arguments: const {'source': 'header_badge'},
                  );
                }
              },
            ),
          ),
        PressableScale(
          onTap: onNotificationTap ??
              () => Navigator.of(context).pushNamed('/notifications'),
          scaleFactor: 0.90,
          child: StreamBuilder<int>(
            stream: NotificationRepository.instance.watchUnreadCount(),
            builder: (context, snap) {
              final count = snap.data ?? 0;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  GlassContainer(
                    padding: const EdgeInsets.all(AppSpacing.sm + 2),
                    borderRadius: AppRadius.borderRadiusMd,
                    variant: GlassVariant.thin,
                    elevation: GlassElevation.low,
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      size: 22,
                      color: AppColors.grey700,
                    ),
                  ),
                  if (count > 0)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          count > 9 ? '9+' : '$count',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
