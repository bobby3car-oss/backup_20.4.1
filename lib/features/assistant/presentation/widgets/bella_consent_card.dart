import 'package:flutter/material.dart';

import '../../../../ui/ui.dart';
import '../../domain/chat_message.dart';

/// In-chat DSGVO consent card with Ja/Nein buttons.
class BellaConsentCard extends StatelessWidget {
  const BellaConsentCard({
    super.key,
    required this.message,
    required this.onAccept,
    required this.onDecline,
  });

  final ChatMessage message;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final answered = message.consentAnswer;

    return Container(
      margin: const EdgeInsets.only(
        right: 52,
        top: AppSpacing.xs,
        bottom: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: answered == null
              ? const Color(0xFFFF6B9D).withValues(alpha: 0.3)
              : Colors.grey.shade200,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: answered == null
                  ? const Color(0xFFFFF0F5)
                  : answered == true
                      ? const Color(0xFFE8F5E9)
                      : Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Text('🔒', style: TextStyle(fontSize: 18)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    answered == null
                        ? 'Datenschutzhinweis'
                        : answered == true
                            ? 'Einwilligung erteilt'
                            : 'Einwilligung abgelehnt',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: answered == null
                          ? const Color(0xFFC62828)
                          : answered == true
                              ? const Color(0xFF2E7D32)
                              : AppColors.textSecondary,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                if (answered == true)
                  const Icon(Icons.check_circle_rounded,
                      color: Color(0xFF34C759), size: 18),
                if (answered == false)
                  Icon(Icons.cancel_rounded,
                      color: Colors.grey.shade400, size: 18),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              'Der KI-Assistent (Bella AI) nutzt einen externen Dienst '
              '(NVIDIA Corporation, USA), um deine Fragen zu beantworten.\n\n'
              'Dabei werden deine Chat-Nachrichten an diesen Dienst '
              'übermittelt. Es werden keine weiteren personenbezogenen '
              'Daten übertragen.\n\n'
              'Du kannst diese Einwilligung jederzeit in den '
              'Einstellungen widerrufen.\n\n'
              'Rechtsgrundlage: Art. 6 Abs. 1 lit. a, '
              'Art. 9 Abs. 2 lit. a DSGVO.',
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: AppColors.textSecondary.withValues(alpha: 0.85),
                letterSpacing: -0.1,
              ),
            ),
          ),

          // Buttons (only when pending)
          if (answered == null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: PressableScale(
                      onTap: () {
                        Haptic.light();
                        onDecline();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 0.5,
                          ),
                        ),
                        child: const Text(
                          'Nein',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    flex: 2,
                    child: PressableScale(
                      onTap: () {
                        Haptic.medium();
                        onAccept();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.sm),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFFF6B9D),
                              Color(0xFFC44EBB),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  const Color(0xFFFF6B9D).withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Ja, einverstanden',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
