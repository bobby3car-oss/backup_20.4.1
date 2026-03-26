import 'dart:async';

import 'package:flutter/material.dart';

import '../notifications/notification_model.dart';
import '../notifications/notification_repository.dart';
import '../notifications/notification_service.dart';
import '../security/app_route_guard.dart';
import '../ui/ui.dart';
import '../ui/theme/app_icons.dart';
import '../l10n/app_localizations.dart';

/// Full-screen notification center showing all in-app notifications
/// with read/unread status, dismiss, and manual creation.
class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  final _repo = NotificationRepository.instance;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return GlassPage(
      title: l.notifications,
      titleIcon: AppIcons.notifications,
      titleColor: AppColors.warning,
      trailing: _HeaderActions(
        onMarkAllRead: _repo.markAllRead,
        onAdd: () => _showAddDialog(context),
      ),
      scrollableBody: (headerHeight) => StreamBuilder<List<InAppNotification>>(
        stream: _repo.watchAll(),
        builder: (context, snapshot) {
          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return _EmptyState(headerHeight: headerHeight);
          }

          return ListView.builder(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              top: headerHeight + AppSpacing.md,
              bottom: 120,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final notification = items[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _NotificationTile(
                  notification: notification,
                  onTap: () => _onTap(notification),
                  onDismiss: () => _repo.dismiss(notification.id),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _onTap(InAppNotification notification) {
    // Mark as read on tap.
    _repo.markRead(notification.id);

    // Navigate if deeplink provided.
    final route = sanitizeExternalRoute(notification.deeplinkRoute);
    if (route != null) {
      Navigator.of(context).pushNamed(route);
    }
  }

  void _showAddDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddNotificationSheet(),
    );
  }
}

// ── Header actions ───────────────────────────────────────────────────────────

class _HeaderActions extends StatelessWidget {
  const _HeaderActions({required this.onMarkAllRead, required this.onAdd});

  final VoidCallback onMarkAllRead;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onMarkAllRead,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: AppRadius.borderRadiusSm,
            ),
            child: const Icon(
              Icons.done_all_rounded,
              size: 20,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        GestureDetector(
          onTap: onAdd,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.08),
              borderRadius: AppRadius.borderRadiusSm,
            ),
            child: const Icon(
              Icons.add_rounded,
              size: 20,
              color: AppColors.success,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.headerHeight});

  final double headerHeight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: headerHeight + 80,
        left: AppSpacing.xxl,
        right: AppSpacing.xxl,
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: AppRadius.borderRadiusXl,
            ),
            child: const Center(
              child: GlassIcon(
                icon: AppIcons.notifications,
                color: AppIcons.notificationsColor,
                size: 22,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Keine Benachrichtigungen',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Neue Benachrichtigungen erscheinen hier automatisch.',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Notification tile ────────────────────────────────────────────────────────

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  final InAppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;
    final priorityColor = _colorForPriority(notification.priority);
    final typeColor = _colorForType(notification.type);

    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.12),
          borderRadius: AppRadius.borderRadiusLg,
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
      ),
      child: PressableScale(
        onTap: onTap,
        child: GlassContainer(
          padding: const EdgeInsets.all(AppSpacing.lg),
          borderRadius: AppRadius.borderRadiusLg,
          variant: isUnread ? GlassVariant.medium : GlassVariant.thin,
          elevation: isUnread ? GlassElevation.low : GlassElevation.flat,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Icon badge ──
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.12),
                  borderRadius: AppRadius.borderRadiusMd,
                ),
                child: Center(
                  child: GlassIcon(
                    icon: AppIcons.notifications,
                    color: typeColor,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // ── Content ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: AppSpacing.sm),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isUnread
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (notification.priority ==
                                NotificationPriority.critical ||
                            notification.priority == NotificationPriority.high)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: priorityColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    if (notification.body != null &&
                        notification.body!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        notification.body!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isUnread
                              ? AppColors.textSecondary
                              : AppColors.grey400,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        _TypeChip(
                          label: _labelForType(notification.type),
                          color: typeColor,
                        ),
                        const Spacer(),
                        Text(
                          _timeAgo(notification.createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.grey400,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Color _colorForPriority(NotificationPriority priority) {
    return switch (priority) {
      NotificationPriority.critical => AppColors.error,
      NotificationPriority.high => AppColors.warning,
      NotificationPriority.normal => AppColors.primary,
      NotificationPriority.low => AppColors.grey400,
    };
  }

  static Color _colorForType(NotificationType type) {
    return switch (type) {
      NotificationType.taskDue => AppColors.warning,
      NotificationType.taskCompleted => AppColors.success,
      NotificationType.appointmentReminder => AppColors.accent,
      NotificationType.observation => AppColors.primary,
      NotificationType.woundWarning => AppColors.error,
      NotificationType.medication => AppColors.primary,
      NotificationType.custom => AppColors.grey700,
      NotificationType.system => AppColors.grey500,
      NotificationType.questionAnswered => AppColors.success,
    };
  }

  static String _labelForType(NotificationType type) {
    return switch (type) {
      NotificationType.taskDue => 'Aufgabe',
      NotificationType.taskCompleted => 'Erledigt',
      NotificationType.appointmentReminder => 'Termin',
      NotificationType.observation => 'Beobachtung',
      NotificationType.woundWarning => 'Wundalarm',
      NotificationType.medication => 'Medikament',
      NotificationType.custom => 'Erinnerung',
      NotificationType.system => 'System',
      NotificationType.questionAnswered => 'Antwort',
    };
  }

  static String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Jetzt';
    if (diff.inMinutes < 60) return 'vor ${diff.inMinutes} Min';
    if (diff.inHours < 24) return 'vor ${diff.inHours} Std';
    if (diff.inDays == 1) return 'Gestern';
    if (diff.inDays < 7) return 'vor ${diff.inDays} Tagen';
    return '${dateTime.day}.${dateTime.month}.${dateTime.year}';
  }
}

// ── Type chip ────────────────────────────────────────────────────────────────

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: AppRadius.borderRadiusXs,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ── Add notification bottom sheet ────────────────────────────────────────────

class _AddNotificationSheet extends StatefulWidget {
  const _AddNotificationSheet();

  @override
  State<_AddNotificationSheet> createState() => _AddNotificationSheetState();
}

class _AddNotificationSheetState extends State<_AddNotificationSheet> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  DateTime? _scheduledAt;
  bool _isScheduled = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: AppSpacing.xl,
        bottom: bottomInset + AppSpacing.xxl,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Handle ──
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── Title ──
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: AppRadius.borderRadiusSm,
                ),
                child: const Center(
                  child: GlassIcon(
                    icon: AppIcons.clipboard,
                    color: AppIcons.clipboardColor,
                    size: 14,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Neue Erinnerung',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),

          // ── Title field ──
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Titel',
              hintText: 'z.B. Arzt anrufen',
              border: OutlineInputBorder(
                borderRadius: AppRadius.borderRadiusMd,
              ),
              filled: true,
              fillColor: AppColors.grey50,
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Body field ──
          TextField(
            controller: _bodyController,
            decoration: InputDecoration(
              labelText: 'Notiz (optional)',
              hintText: 'Zusätzliche Details…',
              border: OutlineInputBorder(
                borderRadius: AppRadius.borderRadiusMd,
              ),
              filled: true,
              fillColor: AppColors.grey50,
            ),
            maxLines: 2,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Schedule toggle ──
          GlassContainer(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            borderRadius: AppRadius.borderRadiusMd,
            child: Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: 20,
                  color: AppColors.grey600,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    _isScheduled && _scheduledAt != null
                        ? 'Geplant: ${_formatDate(_scheduledAt!)}'
                        : 'Jetzt sofort',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                GestureDetector(
                  onTap: _pickDateTime,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: AppRadius.borderRadiusSm,
                    ),
                    child: Text(
                      _isScheduled ? 'Ändern' : 'Planen',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // ── Submit ──
          GlassButton(
            label: 'Erinnerung erstellen',
            variant: GlassButtonVariant.primary,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledAt ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledAt ?? now),
    );
    if (time == null || !mounted) return;

    setState(() {
      _scheduledAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      _isScheduled = true;
    });
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final body = _bodyController.text.trim();

    try {
      await NotificationService.instance.createCustom(
        title: title,
        body: body.isEmpty ? null : body,
        scheduledAt: _isScheduled ? _scheduledAt : null,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFacingError(e))),
      );
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  static String _formatDate(DateTime dt) {
    final d = '${dt.day}.${dt.month}.${dt.year}';
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$d · $hh:$mm';
  }
}
