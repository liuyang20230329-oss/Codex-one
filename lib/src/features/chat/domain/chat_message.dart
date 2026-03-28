import 'chat_message_type.dart';

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.createdAt,
    this.type = ChatMessageType.text,
    this.deliveryStatus = 'Delivered',
    this.mediaUrl,
    this.metadataLabel,
    this.isRecalled = false,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime createdAt;
  final ChatMessageType type;
  final String deliveryStatus;
  final String? mediaUrl;
  final String? metadataLabel;
  final bool isRecalled;

  ChatMessage copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? senderName,
    String? text,
    DateTime? createdAt,
    ChatMessageType? type,
    String? deliveryStatus,
    String? mediaUrl,
    String? metadataLabel,
    bool? isRecalled,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      metadataLabel: metadataLabel ?? this.metadataLabel,
      isRecalled: isRecalled ?? this.isRecalled,
    );
  }
}
