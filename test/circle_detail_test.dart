import 'package:codex_one/src/features/auth/domain/app_user.dart';
import 'package:codex_one/src/features/circle/data/demo_circle_repository.dart';
import 'package:codex_one/src/features/circle/domain/circle_post.dart';
import 'package:codex_one/src/features/circle/presentation/bloc/circle_bloc.dart';
import 'package:codex_one/src/features/circle/presentation/circle_post_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'widget_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('opens circle detail, adds comment, and submits report',
      (tester) async {
    late CircleBloc circleBloc;

    await tester.runAsync(() async {
      final store = await createTestStore(tester);
      circleBloc = CircleBloc(
        repository: DemoCircleRepository(store: store),
      );
      const user = AppUser(
        id: 'circle-user',
        name: '刘洋',
        email: 'liuyang@example.com',
        avatarKey: 'aurora',
      );
      circleBloc.add(const CircleUserSynced(user));
      await circleBloc.stream.firstWhere((s) => !s.isLoading);
    });

    final posts = circleBloc.state.posts;
    final firstPost = posts.isNotEmpty ? posts.first : CirclePost(
      id: 'circle-1',
      authorName: 'Test',
      content: 'Test',
      location: 'Test',
      distance: '1km',
      createdAt: DateTime(2026),
      attachments: const [],
      verificationLabel: '',
      likes: 0,
      comments: 0,
    );

    const user = AppUser(
      id: 'circle-user',
      name: '刘洋',
      email: 'liuyang@example.com',
      avatarKey: 'aurora',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<CircleBloc>.value(
            value: circleBloc,
            child: CirclePostDetailScreen(
              user: user,
              post: firstPost,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.enterText(
      find.byKey(const ValueKey<String>('circle-detail-comment-input')),
      '测试评论：今晚也想去这条街散步。',
    );
    await tester.pump();

    await tester.runAsync(() async {
      await tester.tap(
        find.byKey(const ValueKey<String>('circle-detail-comment-submit')),
      );
      await circleBloc.stream.firstWhere((s) => !s.isSubmittingComment);
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('评论已发送。'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey<String>('circle-detail-report')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('骚扰或冒犯'));

    await tester.runAsync(() async {
      await circleBloc.stream.firstWhere((s) => !s.isReporting);
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('举报已提交，我们会尽快核查。'), findsOneWidget);

    await tester.runAsync(() async {
      await circleBloc.close();
    });
  });
}
