import 'package:flutter/material.dart';

import '../../../../ui/ui.dart';
import '../../domain/bella_action.dart';
import '../../domain/chat_message.dart';

/// Confirmation card shown when Bella proposes an action (Pro feature).
class BellaActionCard extends StatelessWidget {
  const BellaActionCard({
    super.key,
    required this.message,
    required this.onConfirm,
    required this.onCancel,
  });

  final ChatMessage message;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final action = message.pendingAction;
    final status = message.actionStatus;
    if (action == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(
        right: 52,
        top: AppSpacing.xs,
        bottom: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: _bgColor(status),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _borderColor(status),
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
              color: _headerColor(status),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Text(
                  action.emoji,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    _headerText(action, status),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _headerTextColor(status),
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                if (status == BellaActionStatus.confirmed)
                  const Icon(Icons.check_circle_rounded,
                      color: Color(0xFF34C759), size: 18),
                if (status == BellaActionStatus.cancelled)
                  Icon(Icons.cancel_rounded,
                      color: Colors.grey.shade400, size: 18),
                if (status == BellaActionStatus.failed)
                  const Icon(Icons.error_rounded,
                      color: Color(0xFFFF3B30), size: 18),
              ],
            ),
          ),

          // Preview fields
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final entry in action.previewFields.entries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 90,
                          child: Text(
                            entry.key,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary
                                  .withValues(alpha: 0.7),
                              letterSpacing: -0.1,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Action buttons (only when pending)
          if (status == BellaActionStatus.pending)
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
                        onCancel();
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
                          'Abbrechen',
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
                        onConfirm();
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
                              color: const Color(0xFFFF6B9D)
                                  .withValues(alpha: 0.30),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_rounded,
                                size: 16, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              action.label,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Status text for completed / cancelled / failed
          if (status == BellaActionStatus.confirmed)
            _statusBar('Eintrag erstellt ✓', const Color(0xFF34C759)),
          if (status == BellaActionStatus.cancelled)
            _statusBar('Abgebrochen', Colors.grey.shade500),
          if (status == BellaActionStatus.failed)
            _statusBar('Fehler beim Erstellen', const Color(0xFFFF3B30)),
        ],
      ),
    );
  }

  Widget _statusBar(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md, 0, AppSpacing.md, AppSpacing.md,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: -0.1,
        ),
      ),
    );
  }

  Color _bgColor(BellaActionStatus? s) => switch (s) {
        BellaActionStatus.confirmed => const Color(0xFFF0FFF4),
        BellaActionStatus.cancelled => Colors.grey.shade50,
        BellaActionStatus.failed => const Color(0xFFFFF5F5),
        _ => Colors.white,
      };

  Color _borderColor(BellaActionStatus? s) => switch (s) {
        BellaActionStatus.confirmed =>
          const Color(0xFF34C759).withValues(alpha: 0.3),
        BellaActionStatus.failed =>
          const Color(0xFFFF3B30).withValues(alpha: 0.3),
        _ => Colors.grey.shade200,
      };

  Color _headerColor(BellaActionStatus? s) => switch (s) {
        BellaActionStatus.confirmed =>
          const Color(0xFF34C759).withValues(alpha: 0.08),
        BellaActionStatus.cancelled =>
          Colors.grey.shade100,
        BellaActionStatus.failed =>
          const Color(0xFFFF3B30).withValues(alpha: 0.08),
        _ => const Color(0xFFFF6B9D).withValues(alpha: 0.08),
      };

  Color _headerTextColor(BellaActionStatus? s) => switch (s) {
        BellaActionStatus.cancelled => AppColors.textSecondary,
        _ => AppColors.textPrimary,
      };

  String _headerText(BellaAction action, BellaActionStatus? status) {
    return switch (status) {
      BellaActionStatus.confirmed => '${action.label} — erstellt',
      BellaActionStatus.cancelled => '${action.label} — abgebrochen',
      BellaActionStatus.failed => '${action.label} — fehlgeschlagen',
      _ => action.label,
    };
  }
}
