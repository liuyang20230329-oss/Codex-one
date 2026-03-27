class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.createdAt,
    this.deliveryStatus = 'Delivered',
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime createdAt;
  final String deliveryStatus;
}
