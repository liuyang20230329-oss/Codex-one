import 'package:codex_one/src/core/persistence/json_preferences_store.dart';
import 'package:codex_one/src/features/auth/domain/app_user.dart';
import 'package:codex_one/src/features/circle/data/demo_circle_repository.dart';
import 'package:codex_one/src/features/circle/presentation/circle_controller.dart';
import 'package:codex_one/src/features/home/presentation/home_screen.dart'
    show CircleTab;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('opens circle detail, adds comment, and submits report',
      (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final store = await JsonPreferencesStore.create();
    final circleController = CircleController(
      repository: DemoCircleRepository(store: store),
    );
    const user = AppUser(
      id: 'circle-user',
      name: '刘洋',
      email: 'liuyang@example.com',
      avatarKey: 'aurora',
    );
    await circleController.syncUser(user);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CircleTab(
            controller: circleController,
            user: user,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey<String>('circle-post-card-circle-1')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('circle-detail-comment-input')),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const ValueKey<String>('circle-detail-comment-input')),
      '测试评论：今晚也想去这条街散步。',
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('circle-detail-comment-submit')),
    );
    await tester.pumpAndSettle();

    expect(find.text('评论已发送。'), findsOneWidget);
    expect(
      circleController.detailFor('circle-1')!.comments.last.content,
      '测试评论：今晚也想去这条街散步。',
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('circle-detail-report')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('骚扰或冒犯'));
    await tester.pumpAndSettle();

    expect(find.text('举报已提交，我们会尽快核查。'), findsOneWidget);

    circleController.dispose();
  });
}
