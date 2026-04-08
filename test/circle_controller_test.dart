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
    test('loads seeded posts and prepends a published post', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final store = await JsonPreferencesStore.create();
      final controller = CircleController(
        repository: DemoCircleRepository(store: store),
      );
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

      await controller.syncUser(user);

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

      controller.dispose();
    });
  });
}
