import 'package:flutter/foundation.dart';

import '../../auth/domain/app_user.dart';
import '../domain/chat_conversation.dart';
import '../domain/chat_message.dart';
import '../domain/chat_repository.dart';

class ChatController extends ChangeNotifier {
  ChatController({
    required ChatRepository repository,
  }) : _repository = repository;

  final ChatRepository _repository;

  AppUser? _currentUser;
  bool _isBusy = false;
  String? _errorMessage;
  List<ChatConversation> _conversations = const <ChatConversation>[];
  List<ChatMessage> _messages = const <ChatMessage>[];
  String? _selectedConversationId;

  bool get isBusy => _isBusy;
  String? get errorMessage => _errorMessage;
  List<ChatConversation> get conversations => _conversations;
  List<ChatMessage> get messages => _messages;
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

  Future<void> syncUser(AppUser user) async {
    final needsReset = _currentUser?.id != user.id;
    _currentUser = user;
    if (needsReset) {
      _selectedConversationId = null;
      _messages = const <ChatMessage>[];
    }

    await _refreshConversations();
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
      _conversations = await _repository.loadConversations(user: user);
    } catch (_) {
      _errorMessage = 'Unable to load this conversation right now.';
    }

    _isBusy = false;
    notifyListeners();
  }

  void closeConversation() {
    _selectedConversationId = null;
    _messages = const <ChatMessage>[];
    notifyListeners();
  }

  Future<bool> sendMessage(String text) async {
    final user = _currentUser;
    final conversationId = _selectedConversationId;
    if (user == null || conversationId == null) {
      return false;
    }
    if (text.trim().isEmpty) {
      _errorMessage = 'Enter a message before sending.';
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
      );
      _messages = await _repository.loadMessages(
        user: user,
        conversationId: conversationId,
      );
      _conversations = await _repository.loadConversations(user: user);
      _isBusy = false;
      notifyListeners();
      return true;
    } catch (_) {
      _errorMessage = 'Unable to send your message right now.';
      _isBusy = false;
      notifyListeners();
      return false;
    }
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
      _errorMessage = 'Unable to load chats right now.';
    }

    _isBusy = false;
    notifyListeners();
  }
}
