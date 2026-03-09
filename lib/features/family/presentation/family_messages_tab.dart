import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../firebase/firebase_paths.dart';
import '../../../ui/ui.dart';
import '../data/family_repository.dart';
import '../domain/linked_family_patient.dart';
import 'family_message_screen.dart';

/// Conversations list tab for family member accounts.
///
/// Shows a card per linked patient with a live preview of the most-recent
/// message and its timestamp. Tapping navigates to the full chat screen.
class FamilyMessagesTab extends StatelessWidget {
  const FamilyMessagesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassPage(
      title: 'Nachrichten',
      titleEmoji: '💬',
      titleColor: AppColors.primary,
      showBackButton: false,
      horizontalPadding: AppSpacing.lg,
      children: [
        StreamBuilder<List<LinkedFamilyPatient>>(
          stream: FamilyRepository().watchLinkedPatients(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final patients = snap.data ?? [];
            if (patients.isEmpty) {
              return const _NoConversations();
            }
            return GlassContainer(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (int i = 0; i < patients.length; i++) ...[
                    _ConversationTile(
                      patient: patients[i],
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              FamilyMessageScreen(patient: patients[i]),
                        ),
                      ),
                    ),
                    if (i < patients.length - 1)
                      const Divider(height: 1, thickness: 0.5),
                  ],
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 100),
      ],
    );
  }
}

// ─── Conversation Tile ────────────────────────────────────────────────────────

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.patient, required this.onTap});

  final LinkedFamilyPatient patient;
  final VoidCallback onTap;

  Stream<QuerySnapshot<Map<String, dynamic>>> get _latestMessage =>
      FirebaseFirestore.instance
          .collection(
            '${FirestorePaths.patientDoc(patient.patientId)}/messages',
          )
          .orderBy('createdAt', descending: true)
          .limit(1)
          .snapshots();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                patient.avatarInitials,
                style: tt.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Content (single StreamBuilder for both time + preview)
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _latestMessage,
                builder: (context, snap) {
                  final hasMsg =
                      snap.hasData && snap.data!.docs.isNotEmpty;
                  final msgData =
                      hasMsg ? snap.data!.docs.first.data() : null;
                  final previewText = msgData?['text'] as String? ?? '';
                  final authorName =
                      msgData?['authorName'] as String? ?? '';
                  final ts = msgData?['createdAt'];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              patient.patientName,
                              style: tt.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (ts != null)
                            Text(
                              _formatTimestamp(ts),
                              style: tt.labelSmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasMsg
                            ? '$authorName: $previewText'
                            : 'Noch keine Nachrichten',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tt.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(dynamic ts) {
    if (ts is! Timestamp) return '';
    final dt = ts.toDate();
    final now = DateTime.now();
    if (dt.year == now.year &&
        dt.month == now.month &&
        dt.day == now.day) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.';
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _NoConversations extends StatelessWidget {
  const _NoConversations();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.chat_bubble_outline_rounded,
            size: 64,
            color: AppColors.grey400,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Noch keine Gespräche',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Sobald du mit einem Patienten verbunden bist,\n'
            'kannst du hier Nachrichten senden.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
