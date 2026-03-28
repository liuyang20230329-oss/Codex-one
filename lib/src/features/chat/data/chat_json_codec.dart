import '../domain/chat_message.dart';
import '../domain/chat_message_type.dart';

Map<String, Object?> chatMessageToJson(ChatMessage message) {
  return <String, Object?>{
    'id': message.id,
    'conversationId': message.conversationId,
    'senderId': message.senderId,
    'senderName': message.senderName,
    'text': message.text,
    'createdAt': message.createdAt.toIso8601String(),
    'type': message.type.name,
    'deliveryStatus': message.deliveryStatus,
    'mediaUrl': message.mediaUrl,
    'metadataLabel': message.metadataLabel,
    'isRecalled': message.isRecalled,
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
    type: chatMessageTypeFromName(json['type'] as String?),
    deliveryStatus: json['deliveryStatus'] as String? ?? 'Delivered',
    mediaUrl: json['mediaUrl'] as String?,
    metadataLabel: json['metadataLabel'] as String?,
    isRecalled: json['isRecalled'] as bool? ?? false,
  );
}
