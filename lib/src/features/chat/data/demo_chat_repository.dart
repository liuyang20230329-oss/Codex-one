import '../../../core/persistence/json_preferences_store.dart';
import '../../auth/data/account_json_codec.dart';
import '../../auth/domain/app_user.dart';
import '../../auth/domain/verification_status.dart';
import '../../../core/widgets/app_profile_avatar.dart';
import '../domain/chat_inbox_segment.dart';
import '../domain/chat_conversation.dart';
import '../domain/chat_message.dart';
import '../domain/chat_repository.dart';
import 'chat_json_codec.dart';

class DemoChatRepository implements ChatRepository {
  DemoChatRepository({
    required JsonPreferencesStore store,
  }) : _store = store;

  static const _threadStorePrefix = 'demo_chat_threads_v2_';

  final JsonPreferencesStore _store;
  final Map<String, Map<String, _ConversationThread>> _threadsByUserId =
      <String, Map<String, _ConversationThread>>{};
  final Map<String, AppUser> _lastKnownUsers = <String, AppUser>{};

  @override
  Future<List<ChatConversation>> loadConversations({
    required AppUser user,
  }) async {
    final threads = await _ensureThreadsFor(user);
    return threads.values.map((thread) => thread.toConversation()).toList()
      ..sort((left, right) => right.updatedAt.compareTo(left.updatedAt));
  }

  @override
  Future<List<ChatMessage>> loadMessages({
    required AppUser user,
    required String conversationId,
  }) async {
    final threads = await _ensureThreadsFor(user);
    final thread = threads[conversationId];
    if (thread == null) {
      return const <ChatMessage>[];
    }

    thread.unreadCount = 0;
    await _persistThreads(user.id);
    return List<ChatMessage>.from(thread.messages)
      ..sort((left, right) => left.createdAt.compareTo(right.createdAt));
  }

  @override
  Future<void> sendMessage({
    required AppUser user,
    required String conversationId,
    required String text,
  }) async {
    final threads = await _ensureThreadsFor(user);
    final thread = threads[conversationId];
    if (thread == null) {
      return;
    }

    final now = DateTime.now();
    final trimmedText = text.trim();
    thread.messages.add(
      ChatMessage(
        id: 'msg-${now.microsecondsSinceEpoch}',
        conversationId: conversationId,
        senderId: user.id,
        senderName: user.name,
        text: trimmedText,
        createdAt: now,
      ),
    );
    thread.unreadCount = 0;

    final reply = _autoReplyFor(
      thread: thread,
      user: user,
      text: trimmedText,
      now: now.add(const Duration(seconds: 1)),
    );
    if (reply != null) {
      thread.messages.add(reply);
      thread.unreadCount = 0;
    }

    await _persistThreads(user.id);
  }

  Future<Map<String, _ConversationThread>> _ensureThreadsFor(
      AppUser user) async {
    final existing = _threadsByUserId[user.id];
    if (existing != null) {
      final changed = _syncUserChanges(user, existing);
      if (changed) {
        await _persistThreads(user.id);
      }
      return existing;
    }

    final stored = await _store.readObject('$_threadStorePrefix${user.id}');
    Map<String, _ConversationThread> threads;
    AppUser? previousUser;

    if (stored == null) {
      threads = _seedThreads();
    } else {
      threads = _threadsFromJson(stored);
      final snapshot =
          (stored['lastKnownUser'] as Map?)?.cast<String, Object?>();
      if (snapshot != null) {
        previousUser = appUserFromJson(snapshot);
      }
      if (threads.isEmpty) {
        threads = _seedThreads();
      }
    }

    _threadsByUserId[user.id] = threads;
    _lastKnownUsers[user.id] = previousUser ?? user;
    final changed = _syncUserChanges(user, threads);
    if (stored == null || changed) {
      await _persistThreads(user.id);
    }
    return threads;
  }

  Map<String, _ConversationThread> _seedThreads() {
    final now = DateTime.now();
    return <String, _ConversationThread>{
      'concierge': _ConversationThread(
        id: 'concierge',
        title: '新手引导',
        subtitle: '账号与聊天引导',
        categoryLabel: '系统',
        segment: ChatInboxSegment.system,
        unreadCount: 1,
        messages: <ChatMessage>[
          ChatMessage(
            id: 'seed-1',
            conversationId: 'concierge',
            senderId: 'system',
            senderName: 'Codex One',
            text: '欢迎来到 Codex One。你可以先完成账号认证，也可以直接从这里开始第一段聊天。',
            createdAt: now.subtract(const Duration(minutes: 18)),
          ),
        ],
      ),
      'nora': _ConversationThread(
        id: 'nora',
        title: '陈诺拉',
        subtitle: '附近的创意匹配',
        categoryLabel: '私聊',
        segment: ChatInboxSegment.friends,
        messages: <ChatMessage>[
          ChatMessage(
            id: 'seed-2',
            conversationId: 'nora',
            senderId: 'nora',
            senderName: '陈诺拉',
            text: '嗨，我也在测试新的文字聊天流程。等你资料准备好之后，就可以先在这里打个招呼。',
            createdAt: now.subtract(const Duration(minutes: 9)),
          ),
        ],
      ),
      'night-owls': _ConversationThread(
        id: 'night-owls',
        title: '夜猫子俱乐部',
        subtitle: '城市社交内测群',
        categoryLabel: '群聊',
        segment: ChatInboxSegment.hot,
        unreadCount: 2,
        messages: <ChatMessage>[
          ChatMessage(
            id: 'seed-3',
            conversationId: 'night-owls',
            senderId: 'host',
            senderName: '群主',
            text: '今晚我们在收集关于新手引导、资料认证和首次聊天体验的反馈。',
            createdAt: now.subtract(const Duration(minutes: 4)),
          ),
        ],
      ),
      'peach': _ConversationThread(
        id: 'peach',
        title: '桃桃',
        subtitle: '刚刚关注了你',
        categoryLabel: '新关注',
        segment: ChatInboxSegment.followers,
        unreadCount: 1,
        messages: <ChatMessage>[
          ChatMessage(
            id: 'seed-4',
            conversationId: 'peach',
            senderId: 'peach',
            senderName: '桃桃',
            text: '你好呀，我刚关注了你，看到你的语音作品很有氛围。',
            createdAt: now.subtract(const Duration(minutes: 3)),
          ),
        ],
      ),
      'river': _ConversationThread(
        id: 'river',
        title: '小川',
        subtitle: '你关注的摄影玩家',
        categoryLabel: '已关注',
        segment: ChatInboxSegment.following,
        messages: <ChatMessage>[
          ChatMessage(
            id: 'seed-5',
            conversationId: 'river',
            senderId: 'river',
            senderName: '小川',
            text: '我今晚会更新一组新照片，晚点来看看。',
            createdAt: now.subtract(const Duration(minutes: 2)),
          ),
        ],
      ),
    };
  }

  bool _syncUserChanges(
    AppUser user,
    Map<String, _ConversationThread> threads,
  ) {
    final previousUser = _lastKnownUsers[user.id];
    _lastKnownUsers[user.id] = user;
    if (previousUser == null) {
      return true;
    }

    final concierge = threads['concierge'];
    if (concierge == null) {
      return false;
    }

    var changed = false;
    final now = DateTime.now();

    if (previousUser.name != user.name ||
        previousUser.avatarKey != user.avatarKey ||
        previousUser.signature != user.signature ||
        previousUser.city != user.city ||
        previousUser.gender != user.gender ||
        previousUser.birthYear != user.birthYear ||
        previousUser.birthMonth != user.birthMonth ||
        previousUser.introVideoTitle != user.introVideoTitle) {
      final avatarLabel = avatarOptionFor(user.avatarKey).label;
      concierge.addSystemMessage(
        text:
            '资料已更新。你现在显示为“${user.name}”，头像主题为“$avatarLabel”，地区为“${user.city}”。',
        createdAt: now,
      );
      changed = true;
    }

    if (!previousUser.verification.phoneStatus.isVerified &&
        user.verification.phoneStatus.isVerified) {
      concierge.addSystemMessage(
        text: '手机号认证已完成，账号找回能力和信任分都会更高。',
        createdAt: now.add(const Duration(milliseconds: 1)),
      );
      changed = true;
    }

    if (!previousUser.verification.identityStatus.isVerified &&
        user.verification.identityStatus.isVerified) {
      concierge.addSystemMessage(
        text: '身份证认证已完成，你现在可以继续进行本人头像/人脸认证。',
        createdAt: now.add(const Duration(milliseconds: 2)),
      );
      changed = true;
    }

    if (!previousUser.verification.faceStatus.isVerified &&
        user.verification.faceStatus.isVerified) {
      concierge.addSystemMessage(
        text: '本人头像认证已完成，你的“本人认证”标记已经生效。',
        createdAt: now.add(const Duration(milliseconds: 3)),
      );
      changed = true;
    }

    if (previousUser.verification.faceStatus.isVerified &&
        !user.verification.faceStatus.isVerified) {
      concierge.addSystemMessage(
        text: '你刚刚更换了头像，因此需要重新完成本人头像认证。',
        createdAt: now.add(const Duration(milliseconds: 4)),
      );
      changed = true;
    }

    if (previousUser.works.length != user.works.length) {
      final latestWork = user.works.isEmpty ? null : user.works.first;
      concierge.addSystemMessage(
        text: latestWork == null
            ? '你清空了个人作品展示，主页会以基础资料为主。'
            : '你新增了作品《${latestWork.title}》，它会同步展示在“我的作品”里。',
        createdAt: now.add(const Duration(milliseconds: 5)),
      );
      changed = true;
    }

    return changed;
  }

  ChatMessage? _autoReplyFor({
    required _ConversationThread thread,
    required AppUser user,
    required String text,
    required DateTime now,
  }) {
    if (thread.id == 'concierge') {
      final verificationCount = user.verification.verifiedCount;
      final guidance = verificationCount < 3
          ? '你现在依然可以继续聊天，后续再补完剩余 ${3 - verificationCount} 项认证即可。'
          : '你的账号信任闭环已经完成，现在可以把重点放在匹配和聊天上了。';
      return ChatMessage(
        id: 'auto-${now.microsecondsSinceEpoch}',
        conversationId: thread.id,
        senderId: 'system',
        senderName: 'Codex One',
        text: '已收到你的消息：“$text”。$guidance',
        createdAt: now,
      );
    }

    if (thread.id == 'nora') {
      return ChatMessage(
        id: 'auto-${now.microsecondsSinceEpoch}',
        conversationId: thread.id,
        senderId: 'nora',
        senderName: '陈诺拉',
        text: '很高兴认识你，${user.name}。我已经看到你刚刚发来的更新了。',
        createdAt: now,
      );
    }

    if (thread.id == 'night-owls') {
      return ChatMessage(
        id: 'auto-${now.microsecondsSinceEpoch}',
        conversationId: thread.id,
        senderId: 'host',
        senderName: '群主',
        text: '收到，感谢你的反馈。我们正在整理这个群里所有人的新手体验意见。',
        createdAt: now,
      );
    }

    if (thread.id == 'peach') {
      return ChatMessage(
        id: 'auto-${now.microsecondsSinceEpoch}',
        conversationId: thread.id,
        senderId: 'peach',
        senderName: '桃桃',
        text: '我这边也在刷广场推荐，等会儿去看看你新发布的内容。',
        createdAt: now,
      );
    }

    if (thread.id == 'river') {
      final latestWork = user.works.isEmpty ? null : user.works.first;
      return ChatMessage(
        id: 'auto-${now.microsecondsSinceEpoch}',
        conversationId: thread.id,
        senderId: 'river',
        senderName: '小川',
        text: latestWork == null
            ? '记得补一下你的作品区，我很想看看你平时拍什么。'
            : '我看到你最近的作品《${latestWork.title}》了，风格很不错。',
        createdAt: now,
      );
    }

    return null;
  }

  Map<String, _ConversationThread> _threadsFromJson(Map<String, Object?> json) {
    final result = <String, _ConversationThread>{};
    final items = json['threads'] as List?;
    if (items == null) {
      return result;
    }

    for (final item in items) {
      if (item is! Map) {
        continue;
      }
      final map = item.cast<String, Object?>();
      final thread = _ConversationThread.fromJson(map);
      result[thread.id] = thread;
    }
    return result;
  }

  Future<void> _persistThreads(String userId) async {
    final threads = _threadsByUserId[userId];
    final lastKnownUser = _lastKnownUsers[userId];
    if (threads == null || lastKnownUser == null) {
      return;
    }

    final payload = <String, Object?>{
      'threads': threads.values.map((thread) => thread.toJson()).toList(),
      'lastKnownUser': appUserToJson(lastKnownUser),
    };
    await _store.writeJson('$_threadStorePrefix$userId', payload);
  }
}

class _ConversationThread {
  _ConversationThread({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.categoryLabel,
    required this.segment,
    required this.messages,
    this.unreadCount = 0,
  });

  final String id;
  final String title;
  final String subtitle;
  final String categoryLabel;
  final ChatInboxSegment segment;
  final List<ChatMessage> messages;
  int unreadCount;

  DateTime get updatedAt => messages.last.createdAt;

  void addSystemMessage({
    required String text,
    required DateTime createdAt,
  }) {
    messages.add(
      ChatMessage(
        id: 'system-${createdAt.microsecondsSinceEpoch}',
        conversationId: id,
        senderId: 'system',
        senderName: 'Codex One',
        text: text,
        createdAt: createdAt,
      ),
    );
    unreadCount += 1;
  }

  ChatConversation toConversation() {
    return ChatConversation(
      id: id,
      title: title,
      subtitle: subtitle,
      categoryLabel: categoryLabel,
      segment: segment,
      lastMessagePreview: messages.last.text,
      updatedAt: updatedAt,
      unreadCount: unreadCount,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'categoryLabel': categoryLabel,
      'segment': segment.name,
      'unreadCount': unreadCount,
      'messages': messages.map(chatMessageToJson).toList(),
    };
  }

  factory _ConversationThread.fromJson(Map<String, Object?> json) {
    final messages = ((json['messages'] as List?) ?? const <Object?>[])
        .whereType<Map>()
        .map((item) => chatMessageFromJson(item.cast<String, Object?>()))
        .toList();
    return _ConversationThread(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      categoryLabel: json['categoryLabel'] as String? ?? '私聊',
      segment: chatInboxSegmentFromName(json['segment'] as String?),
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      messages: messages,
    );
  }
}
