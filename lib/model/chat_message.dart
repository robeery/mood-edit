enum MessageType { user, ai, error }

class ChatMessage {
  final String text;
  final MessageType type;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.type,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isUser => type == MessageType.user;
  bool get isError => type == MessageType.error;
}
