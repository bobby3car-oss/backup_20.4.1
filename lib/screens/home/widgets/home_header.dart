import 'package:flutter/material.dart';

import '../../../features/pro/presentation/pro_badge.dart';
import '../../../main.dart';
import '../../../notifications/notification_repository.dart';
import '../../../ui/ui.dart';

/// Compact header row: greeting on left, ProBadge + notification bell on right.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    this.onNotificationTap,
    this.onSosTap,
    required this.greeting,
    this.firstName,
  });

  final VoidCallback? onNotificationTap;
  final VoidCallback? onSosTap;
  final String greeting;
  final String? firstName;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final pro = ProServices.maybeOf(context);
    final name = firstName;

    return Row(
      children: [
        // ── Greeting ──────────────────────────────────────────
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name != null ? '$greeting, $name!' : '$greeting!',
                style: tt.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _dateFormatted(),
                style: tt.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        // ── SOS button ──────────────────────────────────────
        if (onSosTap != null)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: PressableScale(
              onTap: onSosTap!,
              scaleFactor: 0.90,
              child: GlassContainer(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm + 2,
                  vertical: AppSpacing.sm + 2,
                ),
                borderRadius: AppRadius.borderRadiusMd,
                variant: GlassVariant.thin,
                elevation: GlassElevation.low,
                color: const Color(0xFFCC0000).withValues(alpha: 0.1),
                child: const Text(
                  'SOS',
                  style: TextStyle(
                    color: Color(0xFFCC0000),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ),

        // ── Pro badge ─────────────────────────────────────────
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

        // ── Sync indicator ────────────────────────────────────
        const Padding(
          padding: EdgeInsets.only(right: AppSpacing.sm),
          child: SyncIndicator(),
        ),

        // ── Notification bell ─────────────────────────────────
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

  String _dateFormatted() {
    final now = DateTime.now();
    const weekdays = [
      'Montag', 'Dienstag', 'Mittwoch', 'Donnerstag',
      'Freitag', 'Samstag', 'Sonntag',
    ];
    const months = [
      'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
      'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember',
    ];
    return '${weekdays[now.weekday - 1]}, ${now.day}. ${months[now.month - 1]}';
  }
}
