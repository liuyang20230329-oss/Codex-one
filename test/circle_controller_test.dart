import 'package:codex_one/src/core/persistence/json_preferences_store.dart';
import 'package:codex_one/src/features/auth/domain/account_verification.dart';
import 'package:codex_one/src/features/auth/domain/app_user.dart';
import 'package:codex_one/src/features/auth/domain/verification_status.dart';
import 'package:codex_one/src/features/circle/data/demo_circle_repository.dart';
import 'package:codex_one/src/features/circle/domain/circle_post.dart';
import 'package:codex_one/src/features/circle/presentation/circle_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CircleController', () {
    late CircleController controller;

    const user = AppUser(
      id: 'circle-user',
      name: '刘洋',
      email: 'liuyang@example.com',
      avatarKey: 'aurora',
      verification: AccountVerification(
        phoneStatus: VerificationStatus.verified,
        identityStatus: VerificationStatus.verified,
        faceStatus: VerificationStatus.verified,
      ),
    );

    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final store = await JsonPreferencesStore.create();
      controller = CircleController(
        repository: DemoCircleRepository(store: store),
      );
      await controller.syncUser(user);
    });

    tearDown(() {
      controller.dispose();
    });

    test('loads seeded posts and prepends a published post', () async {
      expect(controller.posts, isNotEmpty);
      final originalCount = controller.posts.length;

      final post = await controller.publishPost(
        const CirclePostInput(
          content: '测试发布一条真实仓库动态。',
          location: '上海·徐汇·武康路',
          attachments: <CirclePostAttachment>[
            CirclePostAttachment(
              label: '图片 2张',
              type: CircleAttachmentType.image,
            ),
          ],
        ),
      );

      expect(post, isNotNull);
      expect(controller.posts.length, originalCount + 1);
      expect(controller.posts.first.content, '测试发布一条真实仓库动态。');
      expect(controller.posts.first.attachmentLabels, <String>['图片 2张']);
    });

    test('loads detail and updates count after adding a comment', () async {
      final detail = await controller.loadPostDetail('circle-1');

      expect(detail, isNotNull);
      expect(detail!.comments, isNotEmpty);
      final originalCount = detail.comments.length;

      final updated = await controller.addComment(
        postId: 'circle-1',
        content: '这条夜景动态的氛围感很好。',
      );

      expect(updated, isNotNull);
      expect(updated!.comments.length, originalCount + 1);
      expect(updated.comments.last.content, '这条夜景动态的氛围感很好。');
      expect(
        controller.posts.firstWhere((item) => item.id == 'circle-1').comments,
        originalCount + 1,
      );
    });

    test('supports reply comment and reporting flow', () async {
      final detail = await controller.loadPostDetail('circle-1');
      final replyTarget = detail!.comments.first;

      final updated = await controller.addComment(
        postId: 'circle-1',
        content: '收到，我晚点来听。',
        parentCommentId: replyTarget.id,
      );

      expect(updated, isNotNull);
      expect(updated!.comments.last.parentCommentId, replyTarget.id);

      final reported = await controller.reportPost(
        postId: 'circle-1',
        reason: '骚扰或冒犯',
      );

      expect(reported, isTrue);
    });
  });
}
