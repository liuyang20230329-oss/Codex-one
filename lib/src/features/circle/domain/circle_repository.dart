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
}
