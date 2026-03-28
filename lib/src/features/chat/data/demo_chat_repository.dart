import '../../../core/persistence/json_preferences_store.dart';
import '../../auth/data/account_json_codec.dart';
import '../../auth/domain/app_user.dart';
import '../../auth/domain/verification_status.dart';
import '../domain/chat_conversation.dart';
import '../domain/chat_inbox_segment.dart';
import '../domain/chat_message.dart';
import '../domain/chat_message_type.dart';
import '../domain/chat_repository.dart';
import '../domain/chat_repository_event.dart';
import 'chat_json_codec.dart';

class DemoChatRepository implements ChatRepository {
  DemoChatRepository({
    required JsonPreferencesStore store,
  }) : _store = store;

  static const _threadStorePrefix = 'demo_chat_threads_v3_';

  final JsonPreferencesStore _store;
  final Map<String, Map<String, _ConversationThread>> _threadsByUserId =
      <String, Map<String, _ConversationThread>>{};
  final Map<String, AppUser> _lastKnownUsers = <String, AppUser>{};

  @override
  Future<List<ChatConversation>> loadConversations({
    required AppUser user,
  }) async {
    final threads = await _ensureThreadsFor(user);
    final conversations =
        threads.values.map((thread) => thread.toConversation()).toList();
    conversations.sort((left, right) {
      if (left.isPinned != right.isPinned) {
        return right.isPinned ? 1 : -1;
      }
      return right.updatedAt.compareTo(left.updatedAt);
    });
    return conversations;
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
    ChatMessageType type = ChatMessageType.text,
    String? mediaUrl,
    String? metadataLabel,
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
        type: type,
        mediaUrl: mediaUrl,
        metadataLabel: metadataLabel,
      ),
    );
    thread.unreadCount = 0;

    final reply = _autoReplyFor(
      conversationId: conversationId,
      user: user,
      text: trimmedText,
      now: now.add(const Duration(seconds: 1)),
      type: type,
    );
    if (reply != null) {
      thread.messages.add(reply);
      thread.unreadCount = 1;
    }
    await _persistThreads(user.id);
  }

  @override
  Future<ChatConversation> createConversation({
    required AppUser user,
    required String title,
    required String subtitle,
    required String categoryLabel,
    required String segment,
  }) async {
    final threads = await _ensureThreadsFor(user);
    final id = 'thread-${DateTime.now().microsecondsSinceEpoch}';
    final thread = _ConversationThread(
      id: id,
      title: title,
      subtitle: subtitle,
      categoryLabel: categoryLabel,
      segment: chatInboxSegmentFromName(segment),
      messages: <ChatMessage>[
        ChatMessage(
          id: 'welcome-$id',
          conversationId: id,
          senderId: 'system',
          senderName: '37°',
          text: '新的会话已经创建，可以开始聊天了。',
          createdAt: DateTime.now(),
          type: ChatMessageType.system,
        ),
      ],
      unreadCount: 1,
    );
    threads[id] = thread;
    await _persistThreads(user.id);
    return thread.toConversation();
  }

  @override
  Future<void> deleteConversation({
    required AppUser user,
    required String conversationId,
  }) async {
    final threads = await _ensureThreadsFor(user);
    threads.remove(conversationId);
    await _persistThreads(user.id);
  }

  @override
  Future<void> togglePinned({
    required AppUser user,
    required String conversationId,
  }) async {
    final threads = await _ensureThreadsFor(user);
    final thread = threads[conversationId];
    if (thread == null) {
      return;
    }
    thread.isPinned = !thread.isPinned;
    await _persistThreads(user.id);
  }

  @override
  Future<void> markConversationRead({
    required AppUser user,
    required String conversationId,
  }) async {
    final threads = await _ensureThreadsFor(user);
    final thread = threads[conversationId];
    if (thread == null) {
      return;
    }
    thread.unreadCount = 0;
    await _persistThreads(user.id);
  }

  @override
  Future<void> markAllRead({
    required AppUser user,
  }) async {
    final threads = await _ensureThreadsFor(user);
    for (final thread in threads.values) {
      thread.unreadCount = 0;
    }
    await _persistThreads(user.id);
  }

  @override
  Stream<ChatRepositoryEvent> watchEvents({
    required AppUser user,
  }) {
    return const Stream<ChatRepositoryEvent>.empty();
  }

  Future<Map<String, _ConversationThread>> _ensureThreadsFor(AppUser user) async {
    final cached = _threadsByUserId[user.id];
    if (cached != null) {
      if (_appendProfileSyncMessages(user, cached)) {
        await _persistThreads(user.id);
      }
      return cached;
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
    if (stored == null || _appendProfileSyncMessages(user, threads)) {
      await _persistThreads(user.id);
    }
    return threads;
  }

  Map<String, _ConversationThread> _seedThreads() {
    final now = DateTime.now();
    return <String, _ConversationThread>{
      'concierge': _ConversationThread(
        id: 'concierge',
        title: '37° 向导',
        subtitle: '认证、资料与权限提醒',
        categoryLabel: '系统',
        segment: ChatInboxSegment.system,
        unreadCount: 1,
        isPinned: true,
        messages: <ChatMessage>[
          ChatMessage(
            id: 'seed-1',
            conversationId: 'concierge',
            senderId: 'system',
            senderName: '37°',
            text: '欢迎来到 37°。你可以先完善资料和认证，也可以先在这里了解今晚的体验重点。',
            createdAt: now.subtract(const Duration(minutes: 18)),
            type: ChatMessageType.system,
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
            text: '嗨，我也在测试新的聊天流程，等你资料准备好之后就来打个招呼吧。',
            createdAt: now.subtract(const Duration(minutes: 9)),
          ),
        ],
      ),
      'night-owls': _ConversationThread(
        id: 'night-owls',
        title: '37° 观察室',
        subtitle: '体验反馈与高信任交流',
        categoryLabel: '热聊',
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
        title: '桃梨',
        subtitle: '刚刚关注了你',
        categoryLabel: '关注我的',
        segment: ChatInboxSegment.followers,
        unreadCount: 1,
        messages: <ChatMessage>[
          ChatMessage(
            id: 'seed-4',
            conversationId: 'peach',
            senderId: 'peach',
            senderName: '桃梨',
            text: '你好呀，我刚关注了你，看到你的语音作品很有氛围。',
            createdAt: now.subtract(const Duration(minutes: 3)),
          ),
        ],
      ),
      'river': _ConversationThread(
        id: 'river',
        title: '小川',
        subtitle: '你关注的摄影玩家',
        categoryLabel: '我关注的',
        segment: ChatInboxSegment.following,
        messages: <ChatMessage>[
          ChatMessage(
            id: 'seed-5',
            conversationId: 'river',
            senderId: 'river',
            senderName: '小川',
            text: '我今晚会更新一组新照片，晚点来看。',
            createdAt: now.subtract(const Duration(minutes: 2)),
          ),
        ],
      ),
    };
  }

  bool _appendProfileSyncMessages(
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
        previousUser.introVideoTitle != user.introVideoTitle) {
      concierge.addSystemMessage(
        text: '你的资料刚刚更新完成，现在展示名称是“${user.name}”，所在地区是“${user.city}”。',
        createdAt: now,
      );
      changed = true;
    }
    if (!previousUser.verification.phoneStatus.isVerified &&
        user.verification.phoneStatus.isVerified) {
      concierge.addSystemMessage(
        text: '手机号认证已完成，现在可以开始私聊了。',
        createdAt: now.add(const Duration(milliseconds: 1)),
      );
      changed = true;
    }
    if (!previousUser.verification.identityStatus.isVerified &&
        user.verification.identityStatus.isVerified) {
      concierge.addSystemMessage(
        text: '身份证实名认证已完成，现在可以继续进行本人认证。',
        createdAt: now.add(const Duration(milliseconds: 2)),
      );
      changed = true;
    }
    if (!previousUser.verification.faceStatus.isVerified &&
        user.verification.faceStatus.isVerified) {
      concierge.addSystemMessage(
        text: '本人认证已通过，你的信任标识已经生效。',
        createdAt: now.add(const Duration(milliseconds: 3)),
      );
      changed = true;
    }
    if (previousUser.works.length != user.works.length) {
      concierge.addSystemMessage(
        text: user.works.isEmpty
            ? '你的作品列表已清空。'
            : '你刚刚新增了作品《${user.works.first.title}》，它会同步展示在个人主页。',
        createdAt: now.add(const Duration(milliseconds: 4)),
      );
      changed = true;
    }
    return changed;
  }

  ChatMessage? _autoReplyFor({
    required String conversationId,
    required AppUser user,
    required String text,
    required DateTime now,
    required ChatMessageType type,
  }) {
    switch (conversationId) {
      case 'concierge':
        return ChatMessage(
          id: 'auto-${now.microsecondsSinceEpoch}',
          conversationId: conversationId,
          senderId: 'system',
          senderName: '37°',
          text: '已收到你的${type.label}消息。${user.verification.verifiedCount < 3 ? '继续完成剩余认证后，曝光和聊天权限会更完整。' : '你的账号信任闭环已经完成，可以放心继续体验了。'}',
          createdAt: now,
          type: ChatMessageType.system,
        );
      case 'night-owls':
        return ChatMessage(
          id: 'auto-${now.microsecondsSinceEpoch}',
          conversationId: conversationId,
          senderId: 'host',
          senderName: '群主',
          text: '收到，感谢你的反馈，我们正在整理大家的体验意见。',
          createdAt: now,
        );
      default:
        return ChatMessage(
          id: 'auto-${now.microsecondsSinceEpoch}',
          conversationId: conversationId,
          senderId: 'system',
          senderName: conversationId == 'nora' ? '陈诺拉' : '系统回复',
          text: type == ChatMessageType.text
              ? '看到你发来的消息了，晚点继续聊。'
              : '我已经看到你发来的${type.label}内容了。',
          createdAt: now,
        );
    }
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
      final thread = _ConversationThread.fromJson(
        item.cast<String, Object?>(),
      );
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
    await _store.writeJson(
      '$_threadStorePrefix$userId',
      <String, Object?>{
        'threads': threads.values.map((thread) => thread.toJson()).toList(),
        'lastKnownUser': appUserToJson(lastKnownUser),
      },
    );
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
    this.isPinned = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final String categoryLabel;
  final ChatInboxSegment segment;
  final List<ChatMessage> messages;
  int unreadCount;
  bool isPinned;

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
        senderName: '37°',
        text: text,
        createdAt: createdAt,
        type: ChatMessageType.system,
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
      isPinned: isPinned,
      isOnline: segment == ChatInboxSegment.friends ||
          segment == ChatInboxSegment.followers,
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
      'isPinned': isPinned,
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
      isPinned: json['isPinned'] as bool? ?? false,
      messages: messages,
    );
  }
}
