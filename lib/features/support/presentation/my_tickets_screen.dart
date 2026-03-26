import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../data/support_ticket_repository.dart';
import '../domain/support_ticket.dart';
import 'ticket_chat_screen.dart';
import 'create_ticket_screen.dart';
import '../../../ui/theme/app_icons.dart';
import '../../../l10n/app_localizations.dart';

/// Shows the user's support tickets with option to create new ones.
class MyTicketsScreen extends StatelessWidget {
  const MyTicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final repo = SupportTicketRepository();

    return GlassPage(
      title: l.myTickets,
      titleIcon: AppIcons.support,
      titleColor: AppColors.accent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const CreateTicketScreen(),
          ),
        ),
        icon: const Icon(Icons.add),
        label: Text(l.ticketNew),
      ),
      children: [
        StreamBuilder<List<SupportTicket>>(
          stream: repo.watchMyTickets(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final tickets = snapshot.data ?? [];
            if (tickets.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.inbox_outlined,
                          size: 48,
                          color: AppColors.textSecondary.withValues(alpha: 0.4)),
                      const SizedBox(height: 12),
                      const Text(
                        'Noch keine Tickets.\nErstelle ein neues Ticket, um uns zu kontaktieren.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Column(
                children: [
                  for (final ticket in tickets)
                    _TicketCard(ticket: ticket),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.ticket});

  final SupportTicket ticket;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final statusColor = switch (ticket.status) {
      TicketStatus.open => Colors.orange,
      TicketStatus.inProgress => cs.primary,
      TicketStatus.resolved => Colors.green,
      TicketStatus.closed => Colors.grey,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: ticket.unreadByUser
            ? Badge(
                smallSize: 10,
                child: Text(ticket.category.icon,
                    style: const TextStyle(fontSize: 24)),
              )
            : Text(ticket.category.icon,
                style: const TextStyle(fontSize: 24)),
        title: Text(ticket.subject, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                ticket.status.label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _formatDate(ticket.updatedAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) =>
                  TicketChatScreen(ticketId: ticket.id, isAdmin: false),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
}
