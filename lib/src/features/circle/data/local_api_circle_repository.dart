import '../../../core/network/api_client.dart';
import '../../auth/domain/app_user.dart';
import '../domain/circle_post.dart';
import '../domain/circle_repository.dart';

class LocalApiCircleRepository implements CircleRepository {
  LocalApiCircleRepository({
    required ApiClient client,
  }) : _client = client;

  final ApiClient _client;

  @override
  Future<List<CirclePost>> loadPosts({
    required AppUser user,
  }) async {
    final response = await _client.get('/api/v1/circle/posts');
    final items = (response['posts'] as List? ?? const <Object?>[])
        .whereType<Map>()
        .map(
          (item) => CirclePost.fromApiJson(item.cast<String, Object?>()),
        )
        .toList(growable: false);
    return items;
  }

  @override
  Future<CirclePost> publishPost({
    required AppUser user,
    required CirclePostInput input,
  }) async {
    final response = await _client.post(
      '/api/v1/circle/posts',
      body: input.toJson(),
    );
    final payload = response['post'];
    if (payload is! Map) {
      throw const ApiException('圈子服务没有返回可用的动态数据。');
    }
    return CirclePost.fromApiJson(payload.cast<String, Object?>());
  }

  @override
  Future<CirclePostDetail> loadPostDetail({
    required AppUser user,
    required String postId,
  }) async {
    final response = await _client.get('/api/v1/circle/posts/$postId');
    return CirclePostDetail.fromApiJson(response);
  }

  @override
  Future<CirclePostDetail> addComment({
    required AppUser user,
    required String postId,
    required String content,
    String? parentCommentId,
  }) async {
    await _client.post(
      '/api/v1/circle/posts/$postId/comments',
      body: <String, Object?>{
        'content': content,
        if (parentCommentId != null) 'parentCommentId': parentCommentId,
      },
    );
    return loadPostDetail(user: user, postId: postId);
  }

  @override
  Future<void> reportPost({
    required AppUser user,
    required String postId,
    required String reason,
  }) async {
    await _client.post(
      '/api/v1/circle/posts/$postId/reports',
      body: <String, Object?>{
        'reason': reason,
      },
    );
  }
}
