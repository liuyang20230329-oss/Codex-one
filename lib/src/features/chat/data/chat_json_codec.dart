import '../domain/chat_message.dart';

Map<String, Object?> chatMessageToJson(ChatMessage message) {
  return <String, Object?>{
    'id': message.id,
    'conversationId': message.conversationId,
    'senderId': message.senderId,
    'senderName': message.senderName,
    'text': message.text,
    'createdAt': message.createdAt.toIso8601String(),
    'deliveryStatus': message.deliveryStatus,
  };
}

ChatMessage chatMessageFromJson(Map<String, Object?> json) {
  return ChatMessage(
    id: json['id'] as String? ?? '',
    conversationId: json['conversationId'] as String? ?? '',
    senderId: json['senderId'] as String? ?? '',
    senderName: json['senderName'] as String? ?? '',
    text: json['text'] as String? ?? '',
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    deliveryStatus: json['deliveryStatus'] as String? ?? 'Delivered',
  );
}
