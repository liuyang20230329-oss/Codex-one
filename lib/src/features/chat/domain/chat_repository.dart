import '../../auth/domain/app_user.dart';
import 'chat_conversation.dart';
import 'chat_message.dart';

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
  });
}
