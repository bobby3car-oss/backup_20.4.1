import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../data/doctor_notification_repository.dart';
import '../domain/doctor_notification.dart';

/// Screen showing all doctor notifications, grouped by today / yesterday / older.
class DoctorNotificationScreen extends StatefulWidget {
  const DoctorNotificationScreen({
    super.key,
    this.overrideDoctorUid,
  });

  final String? overrideDoctorUid;

  @override
  State<DoctorNotificationScreen> createState() =>
      _DoctorNotificationScreenState();
}

class _DoctorNotificationScreenState extends State<DoctorNotificationScreen> {
  late final DoctorNotificationRepository _repo;

  @override
  void initState() {
    super.initState();
    _repo = DoctorNotificationRepository(
      overrideDoctorUid: widget.overrideDoctorUid,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassPage(
      title: 'Benachrichtigungen',
      titleIcon: Icons.notifications_rounded,
      trailing: _MarkAllReadButton(repo: _repo),
      scrollableBody: (headerHeight) => StreamBuilder<List<DoctorNotification>>(
        stream: _repo.watchNotifications(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          final notifications = snap.data ?? [];

          if (notifications.isEmpty) {
            return _EmptyState(topPadding: headerHeight);
          }

          final groups = _groupByDate(notifications);

          return ListView.builder(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.xl,
              headerHeight + AppSpacing.md,
              AppSpacing.xl,
              120,
            ),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return _NotificationGroup(
                label: group.label,
                notifications: group.items,
                onTap: (n) => _onNotificationTap(n),
              );
            },
          );
        },
      ),
    );
  }

  void _onNotificationTap(DoctorNotification notification) {
    if (!notification.isRead) {
      _repo.markAsRead(notification.id);
    }
  }

  // ── Grouping ─────────────────────────────────────────────────────

  List<_DateGroup> _groupByDate(List<DoctorNotification> items) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final todayItems = <DoctorNotification>[];
    final yesterdayItems = <DoctorNotification>[];
    final olderItems = <DoctorNotification>[];

    for (final n in items) {
      final d = DateTime(n.createdAt.year, n.createdAt.month, n.createdAt.day);
      if (d == today) {
        todayItems.add(n);
      } else if (d == yesterday) {
        yesterdayItems.add(n);
      } else {
        olderItems.add(n);
      }
    }

    return [
      if (todayItems.isNotEmpty) _DateGroup('Heute', todayItems),
      if (yesterdayItems.isNotEmpty) _DateGroup('Gestern', yesterdayItems),
      if (olderItems.isNotEmpty) _DateGroup('Älter', olderItems),
    ];
  }
}

class _DateGroup {
  const _DateGroup(this.label, this.items);
  final String label;
  final List<DoctorNotification> items;
}

// ─────────────────────────────────────────────────────────────────────────────
// Private widgets
// ─────────────────────────────────────────────────────────────────────────────

class _MarkAllReadButton extends StatelessWidget {
  const _MarkAllReadButton({required this.repo});

  final DoctorNotificationRepository repo;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: repo.watchUnreadCount(),
      builder: (context, snap) {
        final count = snap.data ?? 0;
        if (count == 0) return const SizedBox.shrink();
        return IconButton(
          onPressed: () => repo.markAllAsRead(),
          icon: const Icon(Icons.done_all_rounded),
          tooltip: 'Alle als gelesen markieren',
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.topPadding});

  final double topPadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(top: topPadding + 80),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_off_rounded,
              size: 56,
              color: AppColors.grey400,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Keine Benachrichtigungen',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.grey600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationGroup extends StatelessWidget {
  const _NotificationGroup({
    required this.label,
    required this.notifications,
    required this.onTap,
  });

  final String label;
  final List<DoctorNotification> notifications;
  final ValueChanged<DoctorNotification> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        ...notifications.map((n) => _NotificationTile(
              notification: n,
              onTap: () => onTap(n),
            )),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  final DoctorNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final type = notification.type;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassCard(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Type icon ──
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: type.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(type.icon, color: type.color, size: 20),
                ),
                const SizedBox(width: AppSpacing.md),

                // ── Content ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: notification.isRead
                                    ? FontWeight.normal
                                    : FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            _formatTime(notification.createdAt),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.grey600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        notification.body,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (notification.patientName != null &&
                          notification.patientName!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          notification.patientName!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // ── Unread dot ──
                if (!notification.isRead)
                  Padding(
                    padding: const EdgeInsets.only(
                        left: AppSpacing.sm, top: AppSpacing.xs),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
