import 'bella_action.dart';

/// A single message in the assistant chat.
enum ChatRole { user, assistant }

class ChatMessage {
  ChatMessage({
    required this.role,
    required this.text,
    required this.timestamp,
    this.pendingAction,
    this.actionStatus,
    this.showProUpsell = false,
  });

  final ChatRole role;
  String text;
  final DateTime timestamp;

  /// A structured action proposed by Bella (Pro feature).
  BellaAction? pendingAction;

  /// Status of the pending action (null when no action).
  BellaActionStatus? actionStatus;

  /// Whether this message should show an inline Pro upsell card.
  bool showProUpsell;
}
