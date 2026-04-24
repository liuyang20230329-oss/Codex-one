import 'package:codex_one/src/core/persistence/json_preferences_store.dart';
import 'package:codex_one/src/features/chat/domain/chat_inbox_segment.dart';
import 'package:codex_one/src/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:codex_one/src/features/auth/domain/account_verification.dart';
import 'package:codex_one/src/features/auth/domain/app_user.dart';
import 'package:codex_one/src/features/auth/domain/verification_status.dart';
import 'package:codex_one/src/features/chat/data/demo_chat_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_hive_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ChatBloc', () {
    const user = AppUser(
      id: 'user-1',
      name: 'Liu Yang',
      email: 'liuyang@example.com',
      avatarKey: 'aurora',
    );

    late ChatBloc bloc;

    setUp(() async {
      await setUpTestHive();
      bloc = ChatBloc(
        repository: DemoChatRepository(
          store: await JsonPreferencesStore.create(),
        ),
      );
    });

    tearDown(() async {
      await bloc.close();
      await tearDownTestHive();
    });

    Future<void> syncAndWait(AppUser u) async {
      bloc.add(ChatUserSynced(u));
      await bloc.stream.firstWhere((s) => s.isBusy);
      await bloc.stream.firstWhere((s) => !s.isBusy);
    }

    Future<void> waitForBusyCycle() async {
      await bloc.stream.firstWhere((s) => s.isBusy);
      await bloc.stream.firstWhere((s) => !s.isBusy);
    }

    Future<void> waitForAny() async {
      try {
        await bloc.stream.first.timeout(const Duration(seconds: 3));
      } catch (_) {}
    }

    test('loads seeded conversations for a signed-in user', () async {
      await syncAndWait(user);

      expect(bloc.state.conversations.length, 5);
      expect(bloc.state.conversationCountForSegment(ChatInboxSegment.friends), 1);
      expect(bloc.state.conversationCountForSegment(ChatInboxSegment.hot), 1);
      expect(bloc.state.conversationCountForSegment(ChatInboxSegment.followers), 1);
      expect(bloc.state.conversationCountForSegment(ChatInboxSegment.following), 1);
      expect(bloc.state.totalUnreadCount, 4);
      expect(bloc.state.conversations.first.title, isNotEmpty);
    });

    test('opens a conversation and sends a message with an auto reply', () async {
      final verifiedUser = user.copyWith(
        verification: const AccountVerification(phoneStatus: VerificationStatus.verified),
      );

      await syncAndWait(verifiedUser);
      final conversation = bloc.state.conversations.first;
      bloc.add(ChatConversationOpened(conversation.id));
      await waitForBusyCycle();
      final beforeCount = bloc.state.messages.length;

      bloc.add(const ChatMessageSent('Hello from the test suite.'));
      await waitForBusyCycle();

      expect(bloc.state.messages.length, beforeCount + 2);
      expect(bloc.state.messages.first.text, isNotEmpty);
      expect(bloc.state.messages.last.text, isNotEmpty);
      expect(bloc.state.selectedConversation?.id, conversation.id);
    });

    test('requires phone verification for private chats but keeps concierge open', () async {
      await syncAndWait(user);
      bloc.add(const ChatConversationOpened('nora'));
      await waitForBusyCycle();

      bloc.add(const ChatMessageSent('可以直接私聊吗？'));
      await waitForAny();

      expect(bloc.state.errorMessage, '请先完成手机号认证后再开始私聊；系统引导会话仍可继续使用。');

      bloc.add(const ChatConversationOpened('concierge'));
      await waitForBusyCycle();
      bloc.add(const ChatMessageSent('我先和系统确认流程。'));
      await waitForBusyCycle();

      expect(bloc.state.messages.last.senderName, '37°');
    });

    test('can create a conversation, toggle pin, and delete it', () async {
      final verifiedUser = user.copyWith(
        verification: const AccountVerification(phoneStatus: VerificationStatus.verified),
      );

      await syncAndWait(verifiedUser);

      bloc.add(const ChatConversationCreated(title: '今晚语音测试', subtitle: '刚刚创建', categoryLabel: '热聊', segment: ChatInboxSegment.hot));
      await waitForBusyCycle();

      final conversation = bloc.state.selectedConversation;
      expect(conversation, isNotNull);
      expect(conversation!.title, '今晚语音测试');

      bloc.add(ChatPinToggled(conversation.id));
      await waitForAny();
      expect(bloc.state.conversations.firstWhere((item) => item.id == conversation.id).isPinned, isTrue);

      bloc.add(ChatConversationDeleted(conversation.id));
      await waitForAny();
      expect(bloc.state.conversations.where((item) => item.id == conversation.id), isEmpty);
    });

    test('markAllRead clears unread counters across every segment', () async {
      await syncAndWait(user);
      expect(bloc.state.totalUnreadCount, greaterThan(0));

      bloc.add(const ChatAllMarkedRead());
      await waitForAny();

      expect(bloc.state.totalUnreadCount, 0);
      expect(bloc.state.conversations.every((item) => item.unreadCount == 0), isTrue);
    });
  });
}
