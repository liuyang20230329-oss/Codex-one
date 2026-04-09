import '../../../core/persistence/json_preferences_store.dart';
import '../../auth/domain/app_user.dart';
import '../domain/circle_post.dart';
import '../domain/circle_repository.dart';

/// Keeps the circle tab usable when the app falls back to demo mode.
class DemoCircleRepository implements CircleRepository {
  DemoCircleRepository({
    required JsonPreferencesStore store,
  }) : _store = store;

  static const _postsStorePrefix = 'demo_circle_posts_v2_';
  static const _commentsStorePrefix = 'demo_circle_comments_v2_';
  static const _reportsStorePrefix = 'demo_circle_reports_v1_';

  final JsonPreferencesStore _store;
  final Map<String, List<CirclePost>> _cachedPosts =
      <String, List<CirclePost>>{};
  final Map<String, Map<String, List<CircleComment>>> _cachedComments =
      <String, Map<String, List<CircleComment>>>{};

  @override
  Future<List<CirclePost>> loadPosts({
    required AppUser user,
  }) async {
    await _ensureSeeded(user.id);
    return List<CirclePost>.from(_cachedPosts[user.id] ?? const <CirclePost>[]);
  }

  @override
  Future<CirclePost> publishPost({
    required AppUser user,
    required CirclePostInput input,
  }) async {
    await _ensureSeeded(user.id);
    final posts = List<CirclePost>.from(_cachedPosts[user.id] ?? const []);
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
      visibility: input.visibility,
    );
    posts.insert(0, post);
    _cachedPosts[user.id] = posts;
    _cachedComments[user.id]![post.id] = <CircleComment>[];
    await _persistPosts(user.id, posts);
    await _persistComments(user.id, _cachedComments[user.id]!);
    return post;
  }

  @override
  Future<CirclePostDetail> loadPostDetail({
    required AppUser user,
    required String postId,
  }) async {
    await _ensureSeeded(user.id);
    final posts = _cachedPosts[user.id] ?? const <CirclePost>[];
    final post = posts.firstWhere(
      (item) => item.id == postId,
      orElse: () => throw StateError('Circle post not found: $postId'),
    );
    final comments =
        List<CircleComment>.from(_cachedComments[user.id]![postId] ?? const []);
    return CirclePostDetail(
      post: post.copyWith(comments: comments.length),
      comments: comments,
    );
  }

  @override
  Future<CirclePostDetail> addComment({
    required AppUser user,
    required String postId,
    required String content,
    String? parentCommentId,
  }) async {
    await _ensureSeeded(user.id);
    final commentsByPost = _cachedComments[user.id]!;
    final postComments =
        List<CircleComment>.from(commentsByPost[postId] ?? const []);
    final comment = CircleComment(
      id: 'demo-comment-${DateTime.now().microsecondsSinceEpoch}',
      authorName: user.name,
      content: content,
      createdAt: DateTime.now(),
      parentCommentId: parentCommentId,
    );
    postComments.add(comment);
    commentsByPost[postId] = postComments;
    await _persistComments(user.id, commentsByPost);

    final posts = List<CirclePost>.from(_cachedPosts[user.id] ?? const []);
    final updatedPosts = posts
        .map((item) => item.id == postId
            ? item.copyWith(comments: postComments.length)
            : item)
        .toList(growable: false);
    _cachedPosts[user.id] = updatedPosts;
    await _persistPosts(user.id, updatedPosts);

    final updatedPost = updatedPosts.firstWhere((item) => item.id == postId);
    return CirclePostDetail(
      post: updatedPost,
      comments: List<CircleComment>.from(postComments),
    );
  }

  @override
  Future<void> reportPost({
    required AppUser user,
    required String postId,
    required String reason,
  }) async {
    final reports =
        await _store.readList('$_reportsStorePrefix${user.id}') ?? <Object?>[];
    await _store.writeJson(
      '$_reportsStorePrefix${user.id}',
      <Object?>[
        ...reports,
        <String, Object?>{
          'postId': postId,
          'reason': reason,
          'createdAt': DateTime.now().toIso8601String(),
        },
      ],
    );
  }

  Future<void> _ensureSeeded(String userId) async {
    if (_cachedPosts.containsKey(userId) &&
        _cachedComments.containsKey(userId)) {
      return;
    }

    final storedPosts = await _store.readList('$_postsStorePrefix$userId');
    final storedComments =
        await _store.readObject('$_commentsStorePrefix$userId');

    final posts = storedPosts == null
        ? _seedPosts()
        : storedPosts
            .whereType<Map>()
            .map(
              (item) => CirclePost.fromJson(item.cast<String, Object?>()),
            )
            .toList(growable: true);
    final comments = storedComments == null
        ? _seedComments()
        : storedComments.map<String, List<CircleComment>>((key, value) {
            final list = value is List ? value : const <Object?>[];
            return MapEntry<String, List<CircleComment>>(
              key.toString(),
              list
                  .whereType<Map>()
                  .map(
                    (item) =>
                        CircleComment.fromJson(item.cast<String, Object?>()),
                  )
                  .toList(growable: true),
            );
          });

    _cachedPosts[userId] = posts;
    _cachedComments[userId] = comments;
    await _persistPosts(userId, posts);
    await _persistComments(userId, comments);
  }

  Future<void> _persistPosts(String userId, List<CirclePost> posts) {
    return _store.writeJson(
      '$_postsStorePrefix$userId',
      posts.map((item) => item.toJson()).toList(),
    );
  }

  Future<void> _persistComments(
    String userId,
    Map<String, List<CircleComment>> commentsByPost,
  ) {
    return _store.writeJson(
      '$_commentsStorePrefix$userId',
      commentsByPost.map<String, Object?>(
        (key, value) => MapEntry<String, Object?>(
          key,
          value.map((item) => item.toJson()).toList(),
        ),
      ),
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
        comments: 2,
      ),
      CirclePost(
        id: 'circle-2',
        authorName: '林雾',
        location: '杭州·西湖',
        content: '刚刚录了一段晚安语音，适合睡前听，欢迎来圈子里互动。',
        createdAt: now.subtract(const Duration(minutes: 18)),
        attachments: const <CirclePostAttachment>[
          CirclePostAttachment(
            label: '语音 26秒',
            type: CircleAttachmentType.voice,
          ),
        ],
        verificationLabel: '实名',
        distance: '2.4km',
        likes: 15,
        comments: 1,
      ),
      CirclePost(
        id: 'circle-3',
        authorName: '桃梨',
        location: '苏州·园区',
        content: '刚整理好一组最近拍的城市夜色作品，想看看大家更喜欢哪一版。',
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
        comments: 0,
      ),
    ];
  }

  Map<String, List<CircleComment>> _seedComments() {
    final now = DateTime.now();
    return <String, List<CircleComment>>{
      'circle-1': <CircleComment>[
        CircleComment(
          id: 'comment-1',
          authorName: '阿泽',
          content: '夜景氛围很好，语音开麦的话我在。',
          createdAt: now.subtract(const Duration(minutes: 3)),
        ),
        CircleComment(
          id: 'comment-2',
          authorName: '若梦',
          content: '武康路这段真的很适合拍照，想看你后面的图。',
          createdAt: now.subtract(const Duration(minutes: 2)),
          parentCommentId: 'comment-1',
        ),
      ],
      'circle-2': <CircleComment>[
        CircleComment(
          id: 'comment-3',
          authorName: '小川',
          content: '这条晚安语音很有陪伴感。',
          createdAt: now.subtract(const Duration(minutes: 10)),
        ),
      ],
      'circle-3': <CircleComment>[],
    };
  }
}
