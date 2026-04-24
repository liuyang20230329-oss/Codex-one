import 'package:codex_one/src/features/auth/data/demo_auth_repository.dart';
import 'package:codex_one/src/features/auth/domain/app_user.dart';
import 'package:codex_one/src/features/auth/domain/profile_media_work.dart';
import 'package:codex_one/src/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:codex_one/src/features/chat/data/demo_chat_repository.dart';
import 'package:codex_one/src/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:codex_one/src/features/circle/data/demo_circle_repository.dart';
import 'package:codex_one/src/features/circle/presentation/bloc/circle_bloc.dart';
import 'package:codex_one/src/features/home/presentation/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'widget_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Circle publish flow', () {
    testWidgets(
      'uses full-screen selectors and publishes through the bloc',
      (tester) async {
        late AuthBloc authBloc;
        late ChatBloc chatBloc;
        late CircleBloc circleBloc;

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

        await tester.runAsync(() async {
          final store = await createTestStore(tester);
          authBloc = AuthBloc(
            repository: await DemoAuthRepository.seeded(store: store),
          );
          chatBloc = ChatBloc(
            repository: DemoChatRepository(store: store),
          );
          circleBloc = CircleBloc(
            repository: DemoCircleRepository(store: store),
          );

          chatBloc.add(const ChatUserSynced(user));
          await chatBloc.stream.firstWhere((s) => !s.isBusy);

          circleBloc.add(const CircleUserSynced(user));
          await circleBloc.stream.firstWhere((s) => !s.isLoading);
        });

        await tester.pumpWidget(
          MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>.value(value: authBloc),
              BlocProvider<ChatBloc>.value(value: chatBloc),
              BlocProvider<CircleBloc>.value(value: circleBloc),
            ],
            child: MaterialApp(
              home: HomeScreen(
                user: user,
                statusLabel: '状态正常',
                statusMessage: '圈子模块测试。',
              ),
            ),
          ),
        );

        await tester.runAsync(() async {
          await chatBloc.stream.firstWhere((s) => !s.isBusy);
          await circleBloc.stream.firstWhere((s) => !s.isLoading);
        });
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        await tester
            .tap(find.byIcon(Icons.bubble_chart_outlined).hitTestable());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        await tester.tap(
          find
              .byKey(const ValueKey<String>('circle-open-publish'))
              .hitTestable(),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(
          find
              .byKey(const ValueKey<String>('circle-post-content'))
              .hitTestable(),
          findsOneWidget,
        );

        await tester.enterText(
          find.byKey(const ValueKey<String>('circle-post-content')),
          '今晚在附近散步，发一条带图片、语音和作品的动态。',
        );
        await tester.pump();

        final publishScrollable = find
            .descendant(
              of: find.byKey(const ValueKey<String>('circle-publish-scroll')),
              matching: find.byType(Scrollable),
            )
            .first;

        await tester.scrollUntilVisible(
          find.byKey(const ValueKey<String>('circle-submit-post')),
          400,
          scrollable: publishScrollable,
        );

        // _submit() uses Future.delayed(240ms) then Navigator.pop.
        // Run in real-async so the delay resolves, then pump the route change.
        await tester.runAsync(() async {
          await tester.tap(
            find
                .byKey(const ValueKey<String>('circle-submit-post'))
                .hitTestable(),
          );
          await Future.delayed(const Duration(milliseconds: 500));
        });
        await tester.pump();

        // _openPublishScreen receives the pop result, adds
        // CirclePostPublished, and awaits bloc.stream.firstWhere(!isPublishing).
        await tester.runAsync(() async {
          await circleBloc.stream
              .firstWhere((s) => !s.isPublishing)
              .timeout(const Duration(seconds: 5));
        });
        await tester.pump();
        await tester.pump(const Duration(seconds: 2));

        final circleScrollable = find.byType(Scrollable).first;
        await tester.scrollUntilVisible(
          find.text('今晚在附近散步，发一条带图片、语音和作品的动态。'),
          240,
          scrollable: circleScrollable,
        );

        expect(
          find.text('今晚在附近散步，发一条带图片、语音和作品的动态。'),
          findsOneWidget,
        );

        await tester.runAsync(() async {
          await authBloc.close();
          await chatBloc.close();
          await circleBloc.close();
        });
      },
    );
  });
}
