import 'package:codex_one/src/core/persistence/json_preferences_store.dart';
import 'package:codex_one/src/features/auth/data/demo_auth_repository.dart';
import 'package:codex_one/src/features/auth/domain/app_user.dart';
import 'package:codex_one/src/features/auth/domain/profile_media_work.dart';
import 'package:codex_one/src/features/auth/presentation/auth_controller.dart';
import 'package:codex_one/src/features/chat/data/demo_chat_repository.dart';
import 'package:codex_one/src/features/chat/presentation/chat_controller.dart';
import 'package:codex_one/src/features/home/presentation/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Circle publish flow', () {
    testWidgets(
        'uses full-screen selectors for location, image, voice and work',
        (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final store = await JsonPreferencesStore.create();
      final authController = AuthController(
        repository: await DemoAuthRepository.seeded(store: store),
      );
      final chatController = ChatController(
        repository: DemoChatRepository(store: store),
      );
      const user = AppUser(
        id: 'circle-user',
        name: '刘洋',
        email: 'liuyang@example.com',
        avatarKey: 'aurora',
        works: <ProfileMediaWork>[
          ProfileMediaWork(
            id: 'work-voice-1',
            type: ProfileMediaWorkType.voice,
            title: '晚安电台',
            summary: '一段轻陪伴感的语音作品。',
          ),
          ProfileMediaWork(
            id: 'work-image-1',
            type: ProfileMediaWorkType.image,
            title: '城市夜拍',
            summary: '记录下班后的街头灯光。',
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(
            controller: authController,
            chatController: chatController,
            user: user,
            statusLabel: '状态正常',
            statusMessage: '圈子模块测试中',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.bubble_chart_outlined).hitTestable());
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey<String>('circle-open-publish')).hitTestable(),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey<String>('circle-post-content')).hitTestable(),
        findsOneWidget,
      );
      expect(find.text('动图'), findsNothing);
      expect(find.text('网址'), findsNothing);
      final publishScrollable = find.descendant(
        of: find.byKey(const ValueKey<String>('circle-publish-scroll')),
        matching: find.byType(Scrollable),
      ).first;

      await tester.enterText(
        find.byKey(const ValueKey<String>('circle-post-content')),
        '今晚在附近散步，发一条带图片、语音和作品的动态。',
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('当前位置'),
        160,
        scrollable: publishScrollable,
      );
      expect(find.text('当前位置'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey<String>('circle-add-images')),
        240,
        scrollable: publishScrollable,
      );
      expect(find.byKey(const ValueKey<String>('circle-add-images')), findsOneWidget);

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey<String>('circle-add-voice')),
        240,
        scrollable: publishScrollable,
      );
      expect(find.byKey(const ValueKey<String>('circle-add-voice')), findsOneWidget);

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey<String>('circle-select-work')),
        240,
        scrollable: publishScrollable,
      );
      expect(find.byKey(const ValueKey<String>('circle-select-work')), findsOneWidget);

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey<String>('circle-submit-post')),
        240,
        scrollable: publishScrollable,
      );
      await tester.tap(
        find.byKey(const ValueKey<String>('circle-submit-post')).hitTestable(),
      );
      await tester.pumpAndSettle();

      expect(find.text('今晚在附近散步，发一条带图片、语音和作品的动态。'), findsOneWidget);
      expect(find.textContaining('上海·徐汇·武康路'), findsOneWidget);

      authController.dispose();
      chatController.dispose();
    });
  });
}
