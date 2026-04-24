import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../auth/domain/app_user.dart';
import '../../domain/chat_conversation.dart';
import '../../domain/chat_inbox_segment.dart';
import '../../domain/chat_message.dart';
import '../../domain/chat_message_type.dart';
import '../../domain/chat_repository.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc({required ChatRepository repository})
      : _repository = repository,
        super(const ChatState()) {
    on<ChatUserSynced>(_onUserSynced);
    on<ChatConversationOpened>(_onConversationOpened);
    on<ChatConversationClosed>(_onConversationClosed);
    on<ChatDraftUpdated>(_onDraftUpdated);
    on<ChatMessageSent>(_onMessageSent);
    on<ChatConversationCreated>(_onConversationCreated);
    on<ChatPinToggled>(_onPinToggled);
    on<ChatConversationDeleted>(_onConversationDeleted);
    on<ChatAllMarkedRead>(_onAllMarkedRead);
    on<_ChatRealtimeRefreshed>(_onRealtimeRefreshed);
  }

  final ChatRepository _repository;
  StreamSubscription<Object?>? _eventSubscription;

  Future<void> _onUserSynced(
    ChatUserSynced event,
    Emitter<ChatState> emit,
  ) async {
    final previousUser = state.currentUser;
    final needsReset = previousUser?.id != event.user.id;
    final selectedConversationId = state.selectedConversationId;

    emit(state.copyWith(currentUser: event.user));

    if (needsReset) {
      emit(state.copyWith(
        clearSelectedConversation: true,
        messages: const <ChatMessage>[],
      ));
      await _eventSubscription?.cancel();
      _eventSubscription = _repository.watchEvents(user: event.user).listen((_) {
        add(const _ChatRealtimeRefreshed());
      });
    }

    await _refreshConversations(emit);
    if (!needsReset && selectedConversationId != null) {
      await _loadMessages(emit, conversationId: selectedConversationId);
    }
  }

  Future<void> _onConversationOpened(
    ChatConversationOpened event,
    Emitter<ChatState> emit,
  ) async {
    final user = state.currentUser;
    if (user == null) return;

    emit(state.copyWith(isBusy: true, clearError: true));
    try {
      final messages = await _repository.loadMessages(
        user: user,
        conversationId: event.conversationId,
      );
      await _repository.markConversationRead(
        user: user,
        conversationId: event.conversationId,
      );
      final conversations = await _repository.loadConversations(user: user);
      emit(state.copyWith(
        isBusy: false,
        messages: messages,
        conversations: conversations,
        selectedConversationId: event.conversationId,
      ));
    } catch (_) {
      emit(state.copyWith(
        isBusy: false,
        errorMessage: '当前无法加载这个会话，请稍后再试。',
      ));
    }
  }

  void _onConversationClosed(
    ChatConversationClosed event,
    Emitter<ChatState> emit,
  ) {
    emit(state.copyWith(
      clearSelectedConversation: true,
      messages: const <ChatMessage>[],
    ));
  }

  void _onDraftUpdated(
    ChatDraftUpdated event,
    Emitter<ChatState> emit,
  ) {
    final updated = Map<String, String>.from(state.drafts);
    updated[event.conversationId] = event.value;
    emit(state.copyWith(drafts: updated));
  }

  Future<void> _onMessageSent(
    ChatMessageSent event,
    Emitter<ChatState> emit,
  ) async {
    final user = state.currentUser;
    final conversationId = state.selectedConversationId;
    final conversation = state.selectedConversation;
    if (user == null || conversationId == null) return;

    if (!_canSendMessage(user, conversation)) {
      emit(state.copyWith(
        errorMessage: '请先完成手机号认证后再开始私聊；系统引导会话仍可继续使用。',
      ));
      return;
    }
    if (event.text.trim().isEmpty) {
      emit(state.copyWith(errorMessage: '请输入消息内容后再发送。'));
      return;
    }
    if (event.text.trim().length > 280) {
      emit(state.copyWith(errorMessage: '当前单条消息最多支持 280 个字符。'));
      return;
    }

    emit(state.copyWith(isBusy: true, clearError: true));
    try {
      await _repository.sendMessage(
        user: user,
        conversationId: conversationId,
        text: event.text,
        type: event.type,
        mediaUrl: event.mediaUrl,
        metadataLabel: event.metadataLabel,
      );
      final updatedDrafts = Map<String, String>.from(state.drafts)
        ..remove(conversationId);
      final messages = await _repository.loadMessages(
        user: user,
        conversationId: conversationId,
      );
      final conversations = await _repository.loadConversations(user: user);
      emit(state.copyWith(
        isBusy: false,
        messages: messages,
        conversations: conversations,
        drafts: updatedDrafts,
      ));
    } catch (_) {
      emit(state.copyWith(
        isBusy: false,
        errorMessage: '当前无法发送消息，请稍后再试。',
      ));
    }
  }

  Future<void> _onConversationCreated(
    ChatConversationCreated event,
    Emitter<ChatState> emit,
  ) async {
    final user = state.currentUser;
    if (user == null) return;

    emit(state.copyWith(isBusy: true, clearError: true));
    try {
      final conversation = await _repository.createConversation(
        user: user,
        title: event.title,
        subtitle: event.subtitle,
        categoryLabel: event.categoryLabel,
        segment: event.segment.name,
      );
      final conversations = await _repository.loadConversations(user: user);
      final messages = await _repository.loadMessages(
        user: user,
        conversationId: conversation.id,
      );
      emit(state.copyWith(
        isBusy: false,
        conversations: conversations,
        selectedConversationId: conversation.id,
        messages: messages,
      ));
    } catch (_) {
      emit(state.copyWith(
        isBusy: false,
        errorMessage: '当前无法创建会话，请稍后再试。',
      ));
    }
  }

  Future<void> _onPinToggled(
    ChatPinToggled event,
    Emitter<ChatState> emit,
  ) async {
    final user = state.currentUser;
    if (user == null) return;
    await _repository.togglePinned(user: user, conversationId: event.conversationId);
    final conversations = await _repository.loadConversations(user: user);
    emit(state.copyWith(conversations: conversations));
  }

  Future<void> _onConversationDeleted(
    ChatConversationDeleted event,
    Emitter<ChatState> emit,
  ) async {
    final user = state.currentUser;
    if (user == null) return;
    await _repository.deleteConversation(user: user, conversationId: event.conversationId);
    final conversations = await _repository.loadConversations(user: user);
    final clearSelected = state.selectedConversationId == event.conversationId;
    emit(state.copyWith(
      conversations: conversations,
      clearSelectedConversation: clearSelected,
      messages: clearSelected ? const <ChatMessage>[] : null,
    ));
  }

  Future<void> _onAllMarkedRead(
    ChatAllMarkedRead event,
    Emitter<ChatState> emit,
  ) async {
    final user = state.currentUser;
    if (user == null) return;
    await _repository.markAllRead(user: user);
    final conversations = await _repository.loadConversations(user: user);
    emit(state.copyWith(conversations: conversations));
  }

  Future<void> _refreshConversations(Emitter<ChatState> emit) async {
    final user = state.currentUser;
    if (user == null) {
      emit(state.copyWith(
        conversations: const <ChatConversation>[],
        messages: const <ChatMessage>[],
        clearSelectedConversation: true,
      ));
      return;
    }

    emit(state.copyWith(isBusy: true, clearError: true));
    try {
      final conversations = await _repository.loadConversations(user: user);
      emit(state.copyWith(isBusy: false, conversations: conversations));
    } catch (_) {
      emit(state.copyWith(
        isBusy: false,
        errorMessage: '当前无法加载聊天列表，请稍后再试。',
      ));
    }
  }

  Future<void> _loadMessages(
    Emitter<ChatState> emit, {
    required String conversationId,
  }) async {
    final user = state.currentUser;
    if (user == null) return;
    try {
      final messages = await _repository.loadMessages(
        user: user,
        conversationId: conversationId,
      );
      emit(state.copyWith(messages: messages));
    } catch (_) {}
  }

  Future<void> _onRealtimeRefreshed(
    _ChatRealtimeRefreshed event,
    Emitter<ChatState> emit,
  ) async {
    final user = state.currentUser;
    if (user == null) return;
    final conversations = await _repository.loadConversations(user: user);
    final conversationId = state.selectedConversationId;
    List<ChatMessage> messages = state.messages;
    if (conversationId != null) {
      messages = await _repository.loadMessages(
        user: user,
        conversationId: conversationId,
      );
    }
    emit(state.copyWith(conversations: conversations, messages: messages));
  }

  bool _canSendMessage(AppUser user, ChatConversation? conversation) {
    if (conversation == null) return false;
    if (_isGuidedConversation(conversation)) return true;
    return user.canSendPrivateMessages;
  }

  bool _isGuidedConversation(ChatConversation conversation) {
    return conversation.segment == ChatInboxSegment.system ||
        conversation.id == 'concierge' ||
        conversation.id.startsWith('concierge-');
  }

  @override
  Future<void> close() {
    _eventSubscription?.cancel();
    return super.close();
  }
}

final class _ChatRealtimeRefreshed extends ChatEvent {
  const _ChatRealtimeRefreshed();
}
