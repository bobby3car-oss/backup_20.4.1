/// A single message in the assistant chat.
enum ChatRole { user, assistant }

class ChatMessage {
  ChatMessage({
    required this.role,
    required this.text,
    required this.timestamp,
  });

  final ChatRole role;
  String text;
  final DateTime timestamp;
}
