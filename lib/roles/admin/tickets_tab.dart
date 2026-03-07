import 'package:flutter/material.dart';

import '../../features/support/data/support_ticket_repository.dart';
import '../../features/support/domain/support_ticket.dart';
import '../../features/support/presentation/ticket_chat_screen.dart';

class TicketsTab extends StatefulWidget {
  const TicketsTab({super.key});

  @override
  State<TicketsTab> createState() => _TicketsTabState();
}

class _TicketsTabState extends State<TicketsTab> {
  final _repo = SupportTicketRepository();
  TicketStatus? _statusFilter;
  TicketCategory? _categoryFilter;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<int>(
          stream: _repo.watchOpenTicketCount(),
          builder: (context, snap) {
            final count = snap.data ?? 0;
            return count > 0
                ? Text('Tickets ($count offen)')
                : const Text('Tickets');
          },
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search, size: 20),
                hintText: 'Suche nach Betreff, E-Mail…',
                isDense: true,
              ),
              onChanged: (v) =>
                  setState(() => _searchQuery = v.trim().toLowerCase()),
            ),
          ),

          // Filter chips
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Status filters
                  FilterChip(
                    label: const Text('Alle'),
                    selected: _statusFilter == null,
                    onSelected: (_) =>
                        setState(() => _statusFilter = null),
                  ),
                  const SizedBox(width: 6),
                  ...TicketStatus.values.map((s) => Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: FilterChip(
                          label: Text(s.label),
                          selected: _statusFilter == s,
                          onSelected: (_) =>
                              setState(() => _statusFilter = s),
                        ),
                      )),
                  const SizedBox(width: 8),
                  // Category filters
                  ...TicketCategory.values.map((c) => Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: FilterChip(
                          label: Text(c.icon),
                          tooltip: c.label,
                          selected: _categoryFilter == c,
                          onSelected: (_) => setState(() {
                            _categoryFilter =
                                _categoryFilter == c ? null : c;
                          }),
                        ),
                      )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Ticket list
          Expanded(
            child: StreamBuilder<List<SupportTicket>>(
              stream: _repo.watchAllTickets(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                var tickets = snapshot.data ?? [];

                // Apply filters
                if (_statusFilter != null) {
                  tickets = tickets
                      .where((t) => t.status == _statusFilter)
                      .toList();
                }
                if (_categoryFilter != null) {
                  tickets = tickets
                      .where((t) => t.category == _categoryFilter)
                      .toList();
                }
                if (_searchQuery.isNotEmpty) {
                  tickets = tickets.where((t) {
                    final haystack =
                        '${t.subject} ${t.userEmail} ${t.userId}'
                            .toLowerCase();
                    return haystack.contains(_searchQuery);
                  }).toList();
                }

                if (tickets.isEmpty) {
                  return Center(
                    child: Text(
                      'Keine Tickets.',
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: tickets.length,
                  itemBuilder: (context, index) =>
                      _AdminTicketCard(
                    ticket: tickets[index],
                    repo: _repo,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminTicketCard extends StatelessWidget {
  const _AdminTicketCard({required this.ticket, required this.repo});

  final SupportTicket ticket;
  final SupportTicketRepository repo;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final statusColor = switch (ticket.status) {
      TicketStatus.open => Colors.orange,
      TicketStatus.inProgress => cs.primary,
      TicketStatus.resolved => Colors.green,
      TicketStatus.closed => Colors.grey,
    };
    final priorityColor = switch (ticket.priority) {
      TicketPriority.low => Colors.grey,
      TicketPriority.medium => Colors.orange,
      TicketPriority.high => Colors.red,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          repo.markRead(ticket.id, isAdmin: true);
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) =>
                  TicketChatScreen(ticketId: ticket.id, isAdmin: true),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Category + unread badge
              if (ticket.unreadByAdmin)
                Badge(
                  smallSize: 10,
                  child: Text(ticket.category.icon,
                      style: const TextStyle(fontSize: 24)),
                )
              else
                Text(ticket.category.icon,
                    style: const TextStyle(fontSize: 24)),

              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.subject,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: ticket.unreadByAdmin
                                ? FontWeight.bold
                                : FontWeight.w500,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ticket.userEmail,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _Chip(ticket.status.label, statusColor),
                        const SizedBox(width: 6),
                        _Chip(ticket.priority.label, priorityColor),
                        const Spacer(),
                        Text(
                          _formatDate(ticket.updatedAt),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Priority quick-change
              PopupMenuButton<TicketPriority>(
                icon: Icon(Icons.flag, size: 18, color: priorityColor),
                tooltip: 'Priorität ändern',
                onSelected: (p) => repo.updatePriority(ticket.id, p),
                itemBuilder: (_) => TicketPriority.values
                    .map((p) => PopupMenuItem(
                          value: p,
                          child: Text(p.label),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.';
}

class _Chip extends StatelessWidget {
  const _Chip(this.label, this.color);
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}
