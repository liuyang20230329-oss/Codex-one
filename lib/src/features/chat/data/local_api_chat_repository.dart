import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../../core/network/api_client.dart';
import '../../auth/domain/app_user.dart';
import '../domain/chat_conversation.dart';
import '../domain/chat_inbox_segment.dart';
import '../domain/chat_message.dart';
import '../domain/chat_message_type.dart';
import '../domain/chat_repository.dart';
import '../domain/chat_repository_event.dart';

class LocalApiChatRepository implements ChatRepository {
  LocalApiChatRepository({
    required ApiClient client,
  }) : _client = client;

  final ApiClient _client;
  final StreamController<ChatRepositoryEvent> _events =
      StreamController<ChatRepositoryEvent>.broadcast();

  WebSocket? _socket;
  String? _connectedUserId;

  @override
  Future<List<ChatConversation>> loadConversations({
    required AppUser user,
  }) async {
    await _ensureSocket(user);
    final response = await _client.get('/api/v1/chat/conversations');
    final items = (response['conversations'] as List? ?? const <Object?>[])
        .whereType<Map>()
        .map((item) => _conversationFromJson(item.cast<String, dynamic>()))
        .toList();
    return items;
  }

  @override
  Future<List<ChatMessage>> loadMessages({
    required AppUser user,
    required String conversationId,
  }) async {
    await _ensureSocket(user);
    final response = await _client.get('/api/v1/chat/messages/$conversationId');
    final items = (response['messages'] as List? ?? const <Object?>[])
        .whereType<Map>()
        .map((item) => _messageFromJson(item.cast<String, dynamic>()))
        .toList();
    return items;
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
    await _ensureSocket(user);
    await _client.post(
      '/api/v1/chat/messages',
      body: <String, Object?>{
        'conversationId': conversationId,
        'text': text,
        'type': type.name,
        if (mediaUrl != null) 'mediaUrl': mediaUrl,
        if (metadataLabel != null) 'metadataLabel': metadataLabel,
      },
    );
  }

  @override
  Future<ChatConversation> createConversation({
    required AppUser user,
    required String title,
    required String subtitle,
    required String categoryLabel,
    required String segment,
  }) async {
    await _ensureSocket(user);
    final response = await _client.post(
      '/api/v1/chat/conversations',
      body: <String, Object?>{
        'title': title,
        'subtitle': subtitle,
        'categoryLabel': categoryLabel,
        'segment': segment,
      },
    );
    return _conversationFromJson(
      (response['conversation'] as Map).cast<String, dynamic>(),
    );
  }

  @override
  Future<void> deleteConversation({
    required AppUser user,
    required String conversationId,
  }) async {
    await _ensureSocket(user);
    await _client.delete('/api/v1/chat/conversations/$conversationId');
  }

  @override
  Future<void> togglePinned({
    required AppUser user,
    required String conversationId,
  }) async {
    await _ensureSocket(user);
    await _client.patch('/api/v1/chat/conversations/$conversationId/pin');
  }

  @override
  Future<void> markConversationRead({
    required AppUser user,
    required String conversationId,
  }) async {
    await _ensureSocket(user);
    await _client.post('/api/v1/chat/conversations/$conversationId/read');
  }

  @override
  Future<void> markAllRead({
    required AppUser user,
  }) async {
    await _ensureSocket(user);
    await _client.post('/api/v1/chat/conversations/read-all');
  }

  @override
  Stream<ChatRepositoryEvent> watchEvents({
    required AppUser user,
  }) {
    unawaited(_ensureSocket(user));
    return _events.stream;
  }

  Future<void> _ensureSocket(AppUser user) async {
    if (_connectedUserId == user.id && _socket != null) {
      return;
    }

    await _socket?.close();
    _socket = null;
    _connectedUserId = user.id;

    try {
      final uri = _client.websocketUri('/ws/chat');
      final socket = await WebSocket.connect(uri.toString());
      _socket = socket;
      socket.listen(
        (data) {
          try {
            final payload = jsonDecode(data as String) as Map<String, dynamic>;
            _events.add(
              ChatRepositoryEvent(
                kind: payload['kind'] as String? ?? 'refresh',
                conversationId: payload['conversationId'] as String?,
              ),
            );
          } catch (_) {
            _events.add(const ChatRepositoryEvent(kind: 'refresh'));
          }
        },
        onDone: () {
          if (_socket == socket) {
            _socket = null;
          }
        },
        onError: (_) {
          if (_socket == socket) {
            _socket = null;
          }
        },
        cancelOnError: true,
      );
    } catch (_) {
      _socket = null;
    }
  }

  ChatConversation _conversationFromJson(Map<String, dynamic> json) {
    return ChatConversation(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      categoryLabel: json['categoryLabel'] as String? ?? '私聊',
      segment: chatInboxSegmentFromName(json['segment'] as String?),
      lastMessagePreview: json['lastMessagePreview'] as String? ?? '',
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      isPinned: json['isPinned'] as bool? ?? false,
      isOnline: json['isOnline'] as bool? ?? false,
    );
  }

  ChatMessage _messageFromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String? ?? '',
      conversationId: json['conversationId'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      senderName: json['senderName'] as String? ?? '',
      text: json['text'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      type: chatMessageTypeFromName(json['type'] as String?),
      deliveryStatus: json['deliveryStatus'] as String? ?? 'Delivered',
      mediaUrl: json['mediaUrl'] as String?,
      metadataLabel: json['metadataLabel'] as String?,
      isRecalled: json['isRecalled'] as bool? ?? false,
    );
  }
}
