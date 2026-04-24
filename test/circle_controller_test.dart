import 'package:codex_one/src/core/persistence/json_preferences_store.dart';
import 'package:codex_one/src/features/auth/domain/account_verification.dart';
import 'package:codex_one/src/features/auth/domain/app_user.dart';
import 'package:codex_one/src/features/auth/domain/verification_status.dart';
import 'package:codex_one/src/features/circle/data/demo_circle_repository.dart';
import 'package:codex_one/src/features/circle/domain/circle_post.dart';
import 'package:codex_one/src/features/circle/presentation/bloc/circle_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_hive_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CircleBloc', () {
    late CircleBloc bloc;

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

    Future<void> waitForIdle() async {
      await bloc.stream.firstWhere((s) => s.isLoading || s.isPublishing || s.isDetailLoading || s.isSubmittingComment || s.isReporting);
      await bloc.stream.firstWhere((s) => !s.isLoading && !s.isPublishing && !s.isDetailLoading && !s.isSubmittingComment && !s.isReporting);
    }

    setUp(() async {
      await setUpTestHive();
      bloc = CircleBloc(
        repository: DemoCircleRepository(store: await JsonPreferencesStore.create()),
      );
      bloc.add(const CircleUserSynced(user));
      await waitForIdle();
    });

    tearDown(() async {
      await bloc.close();
      await tearDownTestHive();
    });

    test('loads seeded posts and prepends a published post', () async {
      expect(bloc.state.posts, isNotEmpty);
      final originalCount = bloc.state.posts.length;

      bloc.add(const CirclePostPublished(CirclePostInput(
        content: '测试发布一条真实仓库动态。',
        location: '上海·徐汇·武康路',
        attachments: <CirclePostAttachment>[
          CirclePostAttachment(label: '图片 2', type: CircleAttachmentType.image),
        ],
      )));
      await waitForIdle();

      expect(bloc.state.posts.length, originalCount + 1);
      expect(bloc.state.posts.first.content, '测试发布一条真实仓库动态。');
      expect(bloc.state.posts.first.attachmentLabels, <String>['图片 2']);
    });

    test('loads detail and updates count after adding a comment', () async {
      bloc.add(const CirclePostDetailLoaded('circle-1'));
      await waitForIdle();

      final detail = bloc.state.detailFor('circle-1');
      expect(detail, isNotNull);
      expect(detail!.comments, isNotEmpty);
      final originalCount = detail.comments.length;

      bloc.add(const CircleCommentAdded(postId: 'circle-1', content: '这条夜景动态的氛围感很好。'));
      await waitForIdle();

      final updated = bloc.state.detailFor('circle-1');
      expect(updated, isNotNull);
      expect(updated!.comments.length, originalCount + 1);
      expect(updated.comments.last.content, '这条夜景动态的氛围感很好。');
      expect(bloc.state.posts.firstWhere((item) => item.id == 'circle-1').comments, originalCount + 1);
    });

    test('supports reply comment and reporting flow', () async {
      bloc.add(const CirclePostDetailLoaded('circle-1'));
      await waitForIdle();
      final detail = bloc.state.detailFor('circle-1');
      final replyTarget = detail!.comments.first;

      bloc.add(CircleCommentAdded(postId: 'circle-1', content: '收到，我晚点来听。', parentCommentId: replyTarget.id));
      await waitForIdle();

      final updated = bloc.state.detailFor('circle-1');
      expect(updated, isNotNull);
      expect(updated!.comments.last.parentCommentId, replyTarget.id);

      bloc.add(const CirclePostReported(postId: 'circle-1', reason: '骚扰或冒犯'));
      await waitForIdle();

      expect(bloc.state.detailErrorMessage, isNull);
    });
  });
}
