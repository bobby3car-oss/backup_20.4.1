import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

/// Severity level for admin confirmation dialogs.
enum AdminActionSeverity { normal, dangerous, destructive }

/// A confirmation dialog for admin actions with severity-aware styling.
///
/// - [normal]: Standard blue confirmation.
/// - [dangerous]: Orange warning.
/// - [destructive]: Red warning with optional text confirmation.
class AdminConfirmationDialog extends StatefulWidget {
  const AdminConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.severity = AdminActionSeverity.normal,
    this.confirmLabel = 'Bestätigen',
    this.cancelLabel = 'Abbrechen',
    this.confirmationText,
  });

  final String title;
  final String message;
  final AdminActionSeverity severity;
  final String confirmLabel;
  final String cancelLabel;

  /// If set, the user must type this exact text to confirm.
  final String? confirmationText;

  /// Shows the dialog and returns `true` if confirmed.
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    AdminActionSeverity severity = AdminActionSeverity.normal,
    String? confirmLabel,
    String? cancelLabel,
    String? confirmationText,
  }) async {
    final l = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AdminConfirmationDialog(
        title: title,
        message: message,
        severity: severity,
        confirmLabel: confirmLabel ?? l.confirm,
        cancelLabel: cancelLabel ?? l.cancel,
        confirmationText: confirmationText,
      ),
    );
    return result ?? false;
  }

  @override
  State<AdminConfirmationDialog> createState() =>
      _AdminConfirmationDialogState();
}

class _AdminConfirmationDialogState extends State<AdminConfirmationDialog> {
  final _controller = TextEditingController();
  bool get _canConfirm =>
      widget.confirmationText == null ||
      _controller.text.trim() == widget.confirmationText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _severityColor(ColorScheme cs) => switch (widget.severity) {
    AdminActionSeverity.normal => cs.primary,
    AdminActionSeverity.dangerous => Colors.orange,
    AdminActionSeverity.destructive => cs.error,
  };

  IconData get _severityIcon => switch (widget.severity) {
    AdminActionSeverity.normal => Icons.help_outline,
    AdminActionSeverity.dangerous => Icons.warning_amber_rounded,
    AdminActionSeverity.destructive => Icons.dangerous_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = _severityColor(cs);

    return AlertDialog(
      icon: Icon(_severityIcon, color: color, size: 36),
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.message),
          if (widget.confirmationText != null) ...[
            const SizedBox(height: 16),
            Text(
              'Gib "${widget.confirmationText}" ein um zu bestätigen:',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: widget.confirmationText,
                isDense: true,
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(widget.cancelLabel),
        ),
        FilledButton(
          onPressed: _canConfirm
              ? () => Navigator.of(context).pop(true)
              : null,
          style: FilledButton.styleFrom(backgroundColor: color),
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
