import 'bella_action.dart';
import 'wound_analysis_result.dart';

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
    this.woundAnalysis,
    this.attachedImagePaths,
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

  /// Structured wound analysis result (Pro feature).
  WoundAnalysisResult? woundAnalysis;

  /// Local image paths attached to this message (wound photos).
  List<String>? attachedImagePaths;
}
