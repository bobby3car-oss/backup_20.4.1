import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../data/family_repository.dart';
import '../domain/linked_family_patient.dart';
import '../../../l10n/app_localizations.dart';

/// Full-screen bubble-chat screen for family member ↔ patient messaging.
///
/// Messages from the current user appear on the right (blue bubbles),
/// messages from the patient appear on the left (grey bubbles).
class FamilyMessageScreen extends StatefulWidget {
  const FamilyMessageScreen({super.key, required this.patient});

  final LinkedFamilyPatient patient;

  @override
  State<FamilyMessageScreen> createState() => _FamilyMessageScreenState();
}

class _FamilyMessageScreenState extends State<FamilyMessageScreen> {
  final _repo = FamilyRepository();
  final _textCtrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return GlassPage(
      title: widget.patient.patientName,
      titleIcon: Icons.message_rounded,
      scrollableBody: (headerHeight) => Column(
        children: [
          SizedBox(height: headerHeight),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _repo.watchMessages(widget.patient.patientId),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snap.data!.docs;
                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 48,
                          color: AppColors.grey400,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Noch keine Nachrichten.\nSchreib die erste!',
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                      ],
                    ),
                  );
                }

                // watchMessages orders descending → reverse for bubble list
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data();
                    final isMe = data['authorUid'] == myUid;
                    final prevData =
                        index < docs.length - 1 ? docs[index + 1].data() : null;
                    final showDate = _isDifferentDay(data, prevData);

                    return Column(
                      children: [
                        if (showDate) _DateSeparator(data: data),
                        _MessageBubble(data: data, isMe: isMe),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          _InputBar(
            controller: _textCtrl,
            sending: _sending,
            onSend: _send,
          ),
          SafeArea(top: false, child: const SizedBox.shrink()),
        ],
      ),
    );
  }

  bool _isDifferentDay(
    Map<String, dynamic> current,
    Map<String, dynamic>? prev,
  ) {
    if (prev == null) return true;
    final curTs = current['createdAt'];
    final prevTs = prev['createdAt'];
    if (curTs is! Timestamp || prevTs is! Timestamp) return false;
    final a = curTs.toDate();
    final b = prevTs.toDate();
    return a.day != b.day || a.month != b.month || a.year != b.year;
  }

  Future<void> _send() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    try {
      await _repo.sendMessage(
        patientId: widget.patient.patientId,
        text: text,
      );
      _textCtrl.clear();
    } catch (e) {
      debugPrint('[FamilyMessage] send failed: $e');
      if (mounted) {
        final l = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.messageSendError)),
        );
      }
    }
    if (mounted) setState(() => _sending = false);
  }
}

// ─── Message Bubble ───────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.data, required this.isMe});

  final Map<String, dynamic> data;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final text = data['text'] as String? ?? '';
    final created = data['createdAt'];
    String time = '';
    if (created is Timestamp) {
      final dt = created.toDate();
      time =
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.72,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isMe ? AppColors.primary : AppColors.grey100,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(AppRadius.md),
                topRight: const Radius.circular(AppRadius.md),
                bottomLeft: Radius.circular(isMe ? AppRadius.md : 4),
                bottomRight: Radius.circular(isMe ? 4 : AppRadius.md),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isMe ? Colors.white : AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe
                        ? Colors.white.withValues(alpha: 0.7)
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Date Separator ───────────────────────────────────────────────────────────

class _DateSeparator extends StatelessWidget {
  const _DateSeparator({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final ts = data['createdAt'];
    if (ts is! Timestamp) return const SizedBox.shrink();
    final dt = ts.toDate();
    final now = DateTime.now();

    String label;
    if (dt.year == now.year &&
        dt.month == now.month &&
        dt.day == now.day) {
      label = 'Heute';
    } else if (dt.year == now.year &&
        dt.month == now.month &&
        dt.day == now.day - 1) {
      label = 'Gestern';
    } else {
      label =
          '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }
}

// ─── Input Bar ────────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.sending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      elevation: GlassElevation.low,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Nachricht...',
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                filled: true,
                fillColor: AppColors.grey100,
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.borderRadiusPill,
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadius.borderRadiusPill,
                  borderSide: BorderSide.none,
                ),
              ),
              maxLines: 4,
              minLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) {
                if (!sending) onSend();
              },
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: sending
                ? const SizedBox(
                    width: 40,
                    height: 40,
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                : GestureDetector(
                    onTap: onSend,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.accent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
