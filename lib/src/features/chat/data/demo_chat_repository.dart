import '../../auth/domain/app_user.dart';
import '../domain/chat_conversation.dart';
import '../domain/chat_message.dart';
import '../domain/chat_repository.dart';

class DemoChatRepository implements ChatRepository {
  final Map<String, Map<String, _ConversationThread>> _threadsByUserId =
      <String, Map<String, _ConversationThread>>{};

  @override
  Future<List<ChatConversation>> loadConversations({
    required AppUser user,
  }) async {
    final threads = _ensureThreadsFor(user);
    return threads.values
        .map((thread) => thread.toConversation())
        .toList()
      ..sort((left, right) => right.updatedAt.compareTo(left.updatedAt));
  }

  @override
  Future<List<ChatMessage>> loadMessages({
    required AppUser user,
    required String conversationId,
  }) async {
    final threads = _ensureThreadsFor(user);
    final thread = threads[conversationId];
    if (thread == null) {
      return const <ChatMessage>[];
    }

    thread.unreadCount = 0;
    return List<ChatMessage>.from(thread.messages)
      ..sort((left, right) => left.createdAt.compareTo(right.createdAt));
  }

  @override
  Future<void> sendMessage({
    required AppUser user,
    required String conversationId,
    required String text,
  }) async {
    final threads = _ensureThreadsFor(user);
    final thread = threads[conversationId];
    if (thread == null) {
      return;
    }

    final message = ChatMessage(
      id: 'msg-${DateTime.now().microsecondsSinceEpoch}',
      conversationId: conversationId,
      senderId: user.id,
      senderName: user.name,
      text: text.trim(),
      createdAt: DateTime.now(),
    );
    thread.messages.add(message);
  }

  Map<String, _ConversationThread> _ensureThreadsFor(AppUser user) {
    return _threadsByUserId.putIfAbsent(user.id, () {
      final now = DateTime.now();
      return <String, _ConversationThread>{
        'concierge': _ConversationThread(
          id: 'concierge',
          title: 'Concierge',
          subtitle: 'Starter onboarding thread',
          categoryLabel: 'System',
          unreadCount: 1,
          messages: <ChatMessage>[
            ChatMessage(
              id: 'seed-1',
              conversationId: 'concierge',
              senderId: 'system',
              senderName: 'Codex One',
              text:
                  'Welcome aboard. Finish your account verification when you are ready, then begin your first chats here.',
              createdAt: now.subtract(const Duration(minutes: 18)),
            ),
          ],
        ),
        'nora': _ConversationThread(
          id: 'nora',
          title: 'Nora Chen',
          subtitle: 'Nearby creative match',
          categoryLabel: 'Direct',
          messages: <ChatMessage>[
            ChatMessage(
              id: 'seed-2',
              conversationId: 'nora',
              senderId: 'nora',
              senderName: 'Nora Chen',
              text:
                  'Hey, I am testing the new text chat flow too. Once your profile is ready, send your first hello here.',
              createdAt: now.subtract(const Duration(minutes: 9)),
            ),
          ],
        ),
        'night-owls': _ConversationThread(
          id: 'night-owls',
          title: 'Night Owls Club',
          subtitle: 'City social beta group',
          categoryLabel: 'Group',
          unreadCount: 2,
          messages: <ChatMessage>[
            ChatMessage(
              id: 'seed-3',
              conversationId: 'night-owls',
              senderId: 'host',
              senderName: 'Group Host',
              text:
                  'Tonight we are collecting feedback on onboarding, profile verification, and first-chat experience.',
              createdAt: now.subtract(const Duration(minutes: 4)),
            ),
          ],
        ),
      };
    });
  }
}

class _ConversationThread {
  _ConversationThread({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.categoryLabel,
    required this.messages,
    this.unreadCount = 0,
  });

  final String id;
  final String title;
  final String subtitle;
  final String categoryLabel;
  final List<ChatMessage> messages;
  int unreadCount;

  DateTime get updatedAt => messages.last.createdAt;

  ChatConversation toConversation() {
    return ChatConversation(
      id: id,
      title: title,
      subtitle: subtitle,
      categoryLabel: categoryLabel,
      lastMessagePreview: messages.last.text,
      updatedAt: updatedAt,
      unreadCount: unreadCount,
    );
  }
}
