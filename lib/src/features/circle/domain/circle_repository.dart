import '../../auth/domain/app_user.dart';
import 'circle_post.dart';

abstract class CircleRepository {
  Future<List<CirclePost>> loadPosts({
    required AppUser user,
  });

  Future<CirclePost> publishPost({
    required AppUser user,
    required CirclePostInput input,
  });

  Future<CirclePostDetail> loadPostDetail({
    required AppUser user,
    required String postId,
  });

  Future<CirclePostDetail> addComment({
    required AppUser user,
    required String postId,
    required String content,
    String? parentCommentId,
  });

  Future<void> reportPost({
    required AppUser user,
    required String postId,
    required String reason,
  });
}
