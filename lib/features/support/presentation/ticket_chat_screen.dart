import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../data/support_ticket_repository.dart';
import '../domain/support_ticket.dart';
import '../../../l10n/app_localizations.dart';

/// Chat-style messaging screen for a support ticket.
/// Used by both users and admins (controlled via [isAdmin]).
class TicketChatScreen extends StatefulWidget {
  const TicketChatScreen({
    super.key,
    required this.ticketId,
    required this.isAdmin,
  });

  final String ticketId;
  final bool isAdmin;

  @override
  State<TicketChatScreen> createState() => _TicketChatScreenState();
}

class _TicketChatScreenState extends State<TicketChatScreen> {
  final _repo = SupportTicketRepository();
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _repo.markRead(widget.ticketId, isAdmin: widget.isAdmin).catchError((e) {
      debugPrint('[TicketChat] markRead error: $e');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _sending = true);
    try {
      await _repo.sendMessage(
        ticketId: widget.ticketId,
        text: text,
        isAdmin: widget.isAdmin,
      );
      _controller.clear();
      // Scroll to bottom after short delay for the stream to update.
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!mounted) return;
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userFacingError(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return GlassPage(
      title: 'Ticket',
      titleIcon: Icons.support_agent_rounded,
      titleColor: AppColors.accent,
      trailing: widget.isAdmin
          ? PopupMenuButton<String>(
              onSelected: (v) => _handleAction(v),
              itemBuilder: (_) => [
                PopupMenuItem(
                    value: 'inProgress', child: Text(l.inProgress)),
                PopupMenuItem(
                    value: 'resolved', child: Text(l.resolved)),
                PopupMenuItem(
                    value: 'closed', child: Text(l.close)),
              ],
            )
          : PressableScale(
              onTap: () => _closeTicket(),
              scaleFactor: 0.90,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.65),
                  borderRadius: AppRadius.borderRadiusMd,
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.80),
                    width: 0.5,
                  ),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: StreamBuilder<List<TicketMessage>>(
              stream: _repo.watchMessages(widget.ticketId),
              builder: (context, snapshot) {
                final messages = snapshot.data ?? [];
                if (messages.isEmpty) {
                  return Center(
                    child: Text(l.noMessagesYet),
                  );
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = widget.isAdmin
                        ? msg.senderRole == 'admin'
                        : msg.senderRole == 'user';
                    return _MessageBubble(
                      message: msg,
                      isMe: isMe,
                    );
                  },
                );
              },
            ),
          ),

          // Input
          Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              border: Border(top: BorderSide(color: cs.outlineVariant)),
            ),
            padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 4,
                      minLines: 1,
                      decoration: const InputDecoration(
                        hintText: 'Nachricht schreiben…',
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  IconButton(
                    icon: _sending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(Icons.send, color: cs.primary),
                    onPressed: _sending ? null : _send,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAction(String action) async {
    final status = switch (action) {
      'inProgress' => TicketStatus.inProgress,
      'resolved' => TicketStatus.resolved,
      'closed' => TicketStatus.closed,
      _ => null,
    };
    if (status == null) return;
    try {
      await _repo.updateStatus(widget.ticketId, status);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status: ${status.label}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userFacingError(e))),
        );
      }
    }
  }

  Future<void> _closeTicket() async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.ticketCloseConfirm),
        content: Text(l.ticketCloseExplanation),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.cancel)),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l.close)),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _repo.closeTicket(widget.ticketId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.ticketClosed)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userFacingError(e))),
        );
      }
    }
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMe});

  final TicketMessage message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe
              ? cs.primaryContainer
              : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  message.senderRole == 'admin' ? 'Support' : 'Du',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: cs.primary,
                  ),
                ),
              ),
            Text(message.text),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}. '
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}
