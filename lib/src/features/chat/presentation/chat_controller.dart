import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../auth/domain/app_user.dart';
import '../domain/chat_inbox_segment.dart';
import '../domain/chat_conversation.dart';
import '../domain/chat_message.dart';
import '../domain/chat_message_type.dart';
import '../domain/chat_repository.dart';

class ChatController extends ChangeNotifier {
  ChatController({
    required ChatRepository repository,
  }) : _repository = repository;

  final ChatRepository _repository;
  StreamSubscription<Object?>? _eventSubscription;

  AppUser? _currentUser;
  bool _isBusy = false;
  String? _errorMessage;
  List<ChatConversation> _conversations = const <ChatConversation>[];
  List<ChatMessage> _messages = const <ChatMessage>[];
  String? _selectedConversationId;
  final Map<String, String> _drafts = <String, String>{};

  bool get isBusy => _isBusy;
  String? get errorMessage => _errorMessage;
  List<ChatConversation> get conversations => _conversations;
  List<ChatMessage> get messages => _messages;
  int get totalUnreadCount =>
      _conversations.fold(0, (sum, item) => sum + item.unreadCount);
  ChatConversation? get selectedConversation {
    final id = _selectedConversationId;
    if (id == null) {
      return null;
    }
    for (final conversation in _conversations) {
      if (conversation.id == id) {
        return conversation;
      }
    }
    return null;
  }

  String draftFor(String conversationId) => _drafts[conversationId] ?? '';
  int conversationCountForSegment(ChatInboxSegment segment) {
    return _conversations.where((item) => item.segment == segment).length;
  }

  int unreadCountForSegment(ChatInboxSegment segment) {
    return _conversations
        .where((item) => item.segment == segment)
        .fold(0, (sum, item) => sum + item.unreadCount);
  }

  Future<void> syncUser(AppUser user) async {
    final previousUser = _currentUser;
    final needsReset = previousUser?.id != user.id;
    final selectedConversationId = _selectedConversationId;
    _currentUser = user;
    if (needsReset) {
      _selectedConversationId = null;
      _messages = const <ChatMessage>[];
      await _eventSubscription?.cancel();
      _eventSubscription = _repository.watchEvents(user: user).listen((_) {
        _handleRealtimeRefresh();
      });
    }

    await _refreshConversations();
    if (!needsReset && selectedConversationId != null) {
      await openConversation(selectedConversationId);
    }
  }

  Future<void> openConversation(String conversationId) async {
    final user = _currentUser;
    if (user == null) {
      return;
    }

    _isBusy = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedConversationId = conversationId;
      _messages = await _repository.loadMessages(
        user: user,
        conversationId: conversationId,
      );
      await _repository.markConversationRead(
        user: user,
        conversationId: conversationId,
      );
      _conversations = await _repository.loadConversations(user: user);
    } catch (_) {
      _errorMessage = '当前无法加载这个会话，请稍后再试。';
    }

    _isBusy = false;
    notifyListeners();
  }

  void closeConversation() {
    _selectedConversationId = null;
    _messages = const <ChatMessage>[];
    notifyListeners();
  }

  void updateDraft({
    required String conversationId,
    required String value,
  }) {
    _drafts[conversationId] = value;
  }

  Future<bool> sendMessage(
    String text, {
    ChatMessageType type = ChatMessageType.text,
    String? mediaUrl,
    String? metadataLabel,
  }) async {
    final user = _currentUser;
    final conversationId = _selectedConversationId;
    final conversation = selectedConversation;
    if (user == null || conversationId == null) {
      return false;
    }
    if (!_canSendMessage(user, conversation)) {
      _errorMessage = '请先完成手机号认证后再开始私聊；系统引导会话仍可继续使用。';
      notifyListeners();
      return false;
    }
    if (text.trim().isEmpty) {
      _errorMessage = '请输入消息内容后再发送。';
      notifyListeners();
      return false;
    }
    if (text.trim().length > 280) {
      _errorMessage = '当前单条消息最多支持 280 个字符。';
      notifyListeners();
      return false;
    }

    _isBusy = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.sendMessage(
        user: user,
        conversationId: conversationId,
        text: text,
        type: type,
        mediaUrl: mediaUrl,
        metadataLabel: metadataLabel,
      );
      _drafts.remove(conversationId);
      _messages = await _repository.loadMessages(
        user: user,
        conversationId: conversationId,
      );
      _conversations = await _repository.loadConversations(user: user);
      _isBusy = false;
      notifyListeners();
      return true;
    } catch (_) {
      _errorMessage = '当前无法发送消息，请稍后再试。';
      _isBusy = false;
      notifyListeners();
      return false;
    }
  }

  bool canSendToSelectedConversation(AppUser user) {
    return _canSendMessage(user, selectedConversation);
  }

  Future<bool> createConversation({
    required String title,
    required String subtitle,
    required String categoryLabel,
    required ChatInboxSegment segment,
  }) async {
    final user = _currentUser;
    if (user == null) {
      return false;
    }
    _isBusy = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final conversation = await _repository.createConversation(
        user: user,
        title: title,
        subtitle: subtitle,
        categoryLabel: categoryLabel,
        segment: segment.name,
      );
      _conversations = await _repository.loadConversations(user: user);
      _selectedConversationId = conversation.id;
      _messages = await _repository.loadMessages(
        user: user,
        conversationId: conversation.id,
      );
      _isBusy = false;
      notifyListeners();
      return true;
    } catch (_) {
      _errorMessage = '当前无法创建会话，请稍后再试。';
      _isBusy = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> togglePinned(String conversationId) async {
    final user = _currentUser;
    if (user == null) {
      return;
    }
    await _repository.togglePinned(
      user: user,
      conversationId: conversationId,
    );
    _conversations = await _repository.loadConversations(user: user);
    notifyListeners();
  }

  Future<void> deleteConversation(String conversationId) async {
    final user = _currentUser;
    if (user == null) {
      return;
    }
    await _repository.deleteConversation(
      user: user,
      conversationId: conversationId,
    );
    if (_selectedConversationId == conversationId) {
      _selectedConversationId = null;
      _messages = const <ChatMessage>[];
    }
    _conversations = await _repository.loadConversations(user: user);
    notifyListeners();
  }

  Future<void> markAllRead() async {
    final user = _currentUser;
    if (user == null) {
      return;
    }
    await _repository.markAllRead(user: user);
    _conversations = await _repository.loadConversations(user: user);
    notifyListeners();
  }

  Future<void> _refreshConversations() async {
    final user = _currentUser;
    if (user == null) {
      _conversations = const <ChatConversation>[];
      _messages = const <ChatMessage>[];
      _selectedConversationId = null;
      notifyListeners();
      return;
    }

    _isBusy = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _conversations = await _repository.loadConversations(user: user);
    } catch (_) {
      _errorMessage = '当前无法加载聊天列表，请稍后再试。';
    }

    _isBusy = false;
    notifyListeners();
  }

  Future<void> _handleRealtimeRefresh() async {
    final user = _currentUser;
    if (user == null) {
      return;
    }
    _conversations = await _repository.loadConversations(user: user);
    final conversationId = _selectedConversationId;
    if (conversationId != null) {
      _messages = await _repository.loadMessages(
        user: user,
        conversationId: conversationId,
      );
    }
    notifyListeners();
  }

  bool _canSendMessage(AppUser user, ChatConversation? conversation) {
    if (conversation == null) {
      return false;
    }
    if (_isGuidedConversation(conversation)) {
      return true;
    }
    return user.canSendPrivateMessages;
  }

  bool _isGuidedConversation(ChatConversation conversation) {
    return conversation.segment == ChatInboxSegment.system ||
        conversation.id == 'concierge' ||
        conversation.id.startsWith('concierge-');
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }
}
