import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../features/admin_notifications/data/admin_notification_repository.dart';
import '../../features/admin_notifications/domain/admin_notification.dart';

class AdminNotificationsTab extends StatefulWidget {
  const AdminNotificationsTab({
    super.key,
    this.onNavigateToTickets,
    this.onNavigateToDoctors,
    this.onNavigateToOrgs,
  });

  /// Callback to navigate to the tickets tab when a ticket notification is tapped.
  final VoidCallback? onNavigateToTickets;

  /// Callback to navigate to the doctors tab when a doctor notification is tapped.
  final VoidCallback? onNavigateToDoctors;

  /// Callback to navigate to the orgs tab when an org notification is tapped.
  final VoidCallback? onNavigateToOrgs;

  @override
  State<AdminNotificationsTab> createState() => _AdminNotificationsTabState();
}

class _AdminNotificationsTabState extends State<AdminNotificationsTab> {
  final _repo = AdminNotificationRepository();
  AdminNotificationType? _typeFilter;
  bool _unreadOnly = false;

  static final _dateFmt = DateFormat('dd.MM.yyyy HH:mm');

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<int>(
          stream: _repo.watchUnreadCount(),
          builder: (context, snap) {
            final count = snap.data ?? 0;
            return count > 0
                ? Text('Benachrichtigungen ($count neu)')
                : const Text('Benachrichtigungen');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Alle als gelesen markieren',
            onPressed: () => _repo.markAllRead(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('Alle'),
                    selected: _typeFilter == null && !_unreadOnly,
                    onSelected: (_) => setState(() {
                      _typeFilter = null;
                      _unreadOnly = false;
                    }),
                  ),
                  const SizedBox(width: 6),
                  FilterChip(
                    label: const Text('Ungelesen'),
                    selected: _unreadOnly,
                    onSelected: (_) =>
                        setState(() => _unreadOnly = !_unreadOnly),
                  ),
                  const SizedBox(width: 6),
                  ...AdminNotificationType.values.map((t) => Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: FilterChip(
                          label: Text('${t.icon} ${t.label}'),
                          selected: _typeFilter == t,
                          onSelected: (_) => setState(() {
                            _typeFilter = _typeFilter == t ? null : t;
                          }),
                        ),
                      )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Notifications list
          Expanded(
            child: StreamBuilder<List<AdminNotification>>(
              stream: _repo.watchAll(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                var items = snapshot.data ?? [];

                // Apply filters.
                if (_typeFilter != null) {
                  items = items.where((n) => n.type == _typeFilter).toList();
                }
                if (_unreadOnly) {
                  items = items.where((n) => !n.isRead).toList();
                }

                if (items.isEmpty) {
                  return Center(
                    child: Text(
                      'Keine Benachrichtigungen.',
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: items.length,
                  itemBuilder: (context, index) => _NotificationCard(
                    notification: items[index],
                    repo: _repo,
                    dateFmt: _dateFmt,
                    onTap: () => _handleTap(items[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _handleTap(AdminNotification notification) {
    // Mark as read.
    if (!notification.isRead) {
      _repo.markRead(notification.id);
    }

    // Navigate to relevant tab based on type.
    switch (notification.type) {
      case AdminNotificationType.supportTicket:
      case AdminNotificationType.supportTicketMessage:
        widget.onNavigateToTickets?.call();
      case AdminNotificationType.doctorRegistration:
        widget.onNavigateToDoctors?.call();
      case AdminNotificationType.orgRegistration:
        widget.onNavigateToOrgs?.call();
    }
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.repo,
    required this.dateFmt,
    this.onTap,
  });

  final AdminNotification notification;
  final AdminNotificationRepository repo;
  final DateFormat dateFmt;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isUnread = !notification.isRead;

    return Card(
      color: isUnread ? cs.primaryContainer.withValues(alpha: 0.15) : null,
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type icon
              Text(
                notification.type.icon,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight:
                                      isUnread ? FontWeight.bold : null,
                                ),
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: cs.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          dateFmt.format(notification.createdAt),
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                        const Spacer(),
                        Text(
                          notification.type.label,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Actions
              PopupMenuButton<String>(
                itemBuilder: (_) => [
                  if (isUnread)
                    const PopupMenuItem(
                      value: 'read',
                      child: Text('Als gelesen markieren'),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Löschen'),
                  ),
                ],
                onSelected: (action) {
                  switch (action) {
                    case 'read':
                      repo.markRead(notification.id);
                    case 'delete':
                      repo.delete(notification.id);
                  }
                },
                icon: Icon(
                  Icons.more_vert,
                  size: 18,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
