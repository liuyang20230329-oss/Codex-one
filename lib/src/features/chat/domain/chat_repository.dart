import '../../auth/domain/app_user.dart';
import 'chat_conversation.dart';
import 'chat_message.dart';
import 'chat_message_type.dart';
import 'chat_repository_event.dart';

abstract class ChatRepository {
  Future<List<ChatConversation>> loadConversations({
    required AppUser user,
  });

  Future<List<ChatMessage>> loadMessages({
    required AppUser user,
    required String conversationId,
  });

  Future<void> sendMessage({
    required AppUser user,
    required String conversationId,
    required String text,
    ChatMessageType type = ChatMessageType.text,
    String? mediaUrl,
    String? metadataLabel,
  });

  Future<ChatConversation> createConversation({
    required AppUser user,
    required String title,
    required String subtitle,
    required String categoryLabel,
    required String segment,
  });

  Future<void> deleteConversation({
    required AppUser user,
    required String conversationId,
  });

  Future<void> togglePinned({
    required AppUser user,
    required String conversationId,
  });

  Future<void> markConversationRead({
    required AppUser user,
    required String conversationId,
  });

  Future<void> markAllRead({
    required AppUser user,
  });

  Stream<ChatRepositoryEvent> watchEvents({
    required AppUser user,
  });
}
