import 'package:codex_one/src/features/auth/domain/app_user.dart';
import 'package:codex_one/src/features/chat/data/demo_chat_repository.dart';
import 'package:codex_one/src/features/chat/presentation/chat_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatController', () {
    const user = AppUser(
      id: 'user-1',
      name: 'Liu Yang',
      email: 'liuyang@example.com',
      avatarKey: 'aurora',
    );

    test('loads seeded conversations for a signed-in user', () async {
      final controller = ChatController(
        repository: DemoChatRepository(),
      );

      await controller.syncUser(user);

      expect(controller.conversations.length, 3);
      expect(controller.conversations.first.title, isNotEmpty);
    });

    test('opens a conversation and sends a message', () async {
      final controller = ChatController(
        repository: DemoChatRepository(),
      );

      await controller.syncUser(user);
      final conversation = controller.conversations.first;
      await controller.openConversation(conversation.id);
      final beforeCount = controller.messages.length;

      final sent = await controller.sendMessage('Hello from the test suite.');

      expect(sent, isTrue);
      expect(controller.messages.length, beforeCount + 1);
      expect(controller.messages.last.text, 'Hello from the test suite.');
      expect(controller.selectedConversation?.id, conversation.id);
    });
  });
}
