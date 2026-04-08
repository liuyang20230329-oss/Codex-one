import '../../../core/persistence/json_preferences_store.dart';
import '../../auth/domain/app_user.dart';
import '../domain/circle_post.dart';
import '../domain/circle_repository.dart';

/// Keeps the circle tab usable when the app falls back to demo mode.
class DemoCircleRepository implements CircleRepository {
  DemoCircleRepository({
    required JsonPreferencesStore store,
  }) : _store = store;

  static const _postsStorePrefix = 'demo_circle_posts_v1_';

  final JsonPreferencesStore _store;
  final Map<String, List<CirclePost>> _cachedPosts =
      <String, List<CirclePost>>{};

  @override
  Future<List<CirclePost>> loadPosts({
    required AppUser user,
  }) async {
    final cached = _cachedPosts[user.id];
    if (cached != null) {
      return List<CirclePost>.from(cached);
    }

    final stored = await _store.readList('$_postsStorePrefix${user.id}');
    final posts = stored == null
        ? _seedPosts()
        : stored
            .whereType<Map>()
            .map(
              (item) => CirclePost.fromJson(item.cast<String, Object?>()),
            )
            .toList(growable: true);
    _cachedPosts[user.id] = posts;
    return List<CirclePost>.from(posts);
  }

  @override
  Future<CirclePost> publishPost({
    required AppUser user,
    required CirclePostInput input,
  }) async {
    final posts = List<CirclePost>.from(
      await loadPosts(user: user),
    );
    final post = CirclePost(
      id: 'demo-circle-${DateTime.now().microsecondsSinceEpoch}',
      authorName: user.name,
      location: input.location,
      content: input.content,
      createdAt: DateTime.now(),
      attachments: input.attachments,
      verificationLabel: user.canAppearInRecommendations ? '真人' : '待认证',
      distance: '附近',
      likes: 0,
      comments: 0,
    );
    posts.insert(0, post);
    _cachedPosts[user.id] = posts;
    await _persistPosts(user.id, posts);
    return post;
  }

  Future<void> _persistPosts(String userId, List<CirclePost> posts) {
    return _store.writeJson(
      '$_postsStorePrefix$userId',
      posts.map((item) => item.toJson()).toList(),
    );
  }

  List<CirclePost> _seedPosts() {
    final now = DateTime.now();
    return <CirclePost>[
      CirclePost(
        id: 'circle-1',
        authorName: '小川',
        location: '上海·徐汇',
        content: '今晚在武康路散步，拍到了很舒服的夜景，想找人一起语音聊聊天。',
        createdAt: now.subtract(const Duration(minutes: 5)),
        attachments: const <CirclePostAttachment>[
          CirclePostAttachment(
            label: '图片 3张',
            type: CircleAttachmentType.image,
          ),
          CirclePostAttachment(
            label: '语音 18秒',
            type: CircleAttachmentType.voice,
          ),
        ],
        verificationLabel: '真人',
        distance: '0.8km',
        likes: 26,
        comments: 8,
      ),
      CirclePost(
        id: 'circle-2',
        authorName: '林雾',
        location: '杭州·西湖',
        content: '刚刚录了一段晚安语音，适合睡前听，欢迎来圈子里互动。',
        createdAt: now.subtract(const Duration(minutes: 18)),
        attachments: const <CirclePostAttachment>[
          CirclePostAttachment(
            label: '语音',
            type: CircleAttachmentType.voice,
          ),
        ],
        verificationLabel: '实名',
        distance: '2.4km',
        likes: 15,
        comments: 4,
      ),
      CirclePost(
        id: 'circle-3',
        authorName: '桃桃',
        location: '苏州·园区',
        content: '刚整理好一组最近拍的城市夜色作品，想放进圈子里看看大家更喜欢哪一版。',
        createdAt: now.subtract(const Duration(hours: 1)),
        attachments: const <CirclePostAttachment>[
          CirclePostAttachment(
            label: '作品 2个',
            type: CircleAttachmentType.work,
          ),
        ],
        verificationLabel: '真人',
        distance: '4.1km',
        likes: 34,
        comments: 12,
      ),
    ];
  }
}
