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
}
