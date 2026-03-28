import 'package:codex_one/src/core/persistence/json_preferences_store.dart';
import 'package:codex_one/src/features/auth/domain/account_verification.dart';
import 'package:codex_one/src/features/auth/domain/app_user.dart';
import 'package:codex_one/src/features/auth/domain/verification_status.dart';
import 'package:codex_one/src/features/chat/data/demo_chat_repository.dart';
import 'package:codex_one/src/features/chat/domain/chat_inbox_segment.dart';
import 'package:codex_one/src/features/chat/presentation/chat_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ChatController', () {
    const user = AppUser(
      id: 'user-1',
      name: 'Liu Yang',
      email: 'liuyang@example.com',
      avatarKey: 'aurora',
    );

    test('loads seeded conversations for a signed-in user', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final controller = ChatController(
        repository: DemoChatRepository(
          store: await JsonPreferencesStore.create(),
        ),
      );

      await controller.syncUser(user);

      expect(controller.conversations.length, 5);
      expect(
        controller.conversationCountForSegment(ChatInboxSegment.friends),
        1,
      );
      expect(
        controller.conversationCountForSegment(ChatInboxSegment.hot),
        1,
      );
      expect(
        controller.conversationCountForSegment(ChatInboxSegment.followers),
        1,
      );
      expect(
        controller.conversationCountForSegment(ChatInboxSegment.following),
        1,
      );
      expect(controller.totalUnreadCount, 4);
      expect(controller.conversations.first.title, isNotEmpty);
    });

    test('opens a conversation and sends a message with an auto reply',
        () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final controller = ChatController(
        repository: DemoChatRepository(
          store: await JsonPreferencesStore.create(),
        ),
      );

      final verifiedUser = user.copyWith(
        verification: const AccountVerification(
          phoneStatus: VerificationStatus.verified,
        ),
      );

      await controller.syncUser(verifiedUser);
      final conversation = controller.conversations.first;
      await controller.openConversation(conversation.id);
      final beforeCount = controller.messages.length;

      final sent = await controller.sendMessage('Hello from the test suite.');

      expect(sent, isTrue);
      expect(controller.messages.length, beforeCount + 2);
      expect(controller.messages.first.text, isNotEmpty);
      expect(controller.messages.last.text, isNotEmpty);
      expect(controller.selectedConversation?.id, conversation.id);
    });

    test(
        'requires phone verification for private chats but keeps concierge open',
        () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final controller = ChatController(
        repository: DemoChatRepository(
          store: await JsonPreferencesStore.create(),
        ),
      );

      await controller.syncUser(user);
      await controller.openConversation('nora');

      final privateChatSent = await controller.sendMessage('可以直接私聊吗？');

      expect(privateChatSent, isFalse);
      expect(
        controller.errorMessage,
        '请先完成手机号认证后再开始私聊；系统引导会话仍可继续使用。',
      );

      await controller.openConversation('concierge');
      final systemChatSent = await controller.sendMessage('我先和系统确认流程。');

      expect(systemChatSent, isTrue);
      expect(controller.messages.last.senderName, '37°');
    });

    test('persists chats and links account progress to concierge messages',
        () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final firstStore = await JsonPreferencesStore.create();
      final firstRepository = DemoChatRepository(store: firstStore);

      await firstRepository.loadConversations(user: user);
      final verifiedUser = user.copyWith(
        verification: const AccountVerification(
          phoneStatus: VerificationStatus.verified,
        ),
      );
      final conversationsAfterVerification =
          await firstRepository.loadConversations(user: verifiedUser);

      final conciergeConversation = conversationsAfterVerification.firstWhere(
        (conversation) => conversation.id == 'concierge',
      );
      expect(
        conciergeConversation.lastMessagePreview,
        contains('手机号认证已完成'),
      );

      final restoredRepository = DemoChatRepository(
        store: await JsonPreferencesStore.create(),
      );
      final restoredConversations =
          await restoredRepository.loadConversations(user: verifiedUser);
      final restoredConcierge = restoredConversations.firstWhere(
        (conversation) => conversation.id == 'concierge',
      );

      expect(
        restoredConcierge.lastMessagePreview,
        contains('手机号认证已完成'),
      );
    });
  });
}
