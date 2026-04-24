part of 'chat_bloc.dart';

class ChatState extends Equatable {
  const ChatState({
    this.currentUser,
    this.isBusy = false,
    this.errorMessage,
    this.conversations = const <ChatConversation>[],
    this.messages = const <ChatMessage>[],
    this.selectedConversationId,
    this.drafts = const <String, String>{},
  });

  final AppUser? currentUser;
  final bool isBusy;
  final String? errorMessage;
  final List<ChatConversation> conversations;
  final List<ChatMessage> messages;
  final String? selectedConversationId;
  final Map<String, String> drafts;

  int get totalUnreadCount =>
      conversations.fold(0, (sum, item) => sum + item.unreadCount);

  ChatConversation? get selectedConversation {
    final id = selectedConversationId;
    if (id == null) return null;
    for (final conversation in conversations) {
      if (conversation.id == id) return conversation;
    }
    return null;
  }

  String draftFor(String conversationId) => drafts[conversationId] ?? '';

  int conversationCountForSegment(ChatInboxSegment segment) {
    return conversations.where((item) => item.segment == segment).length;
  }

  int unreadCountForSegment(ChatInboxSegment segment) {
    return conversations
        .where((item) => item.segment == segment)
        .fold(0, (sum, item) => sum + item.unreadCount);
  }

  bool canSendToSelectedConversation(AppUser user) {
    final conversation = selectedConversation;
    if (conversation == null) return false;
    if (_isGuidedConversation(conversation)) return true;
    return user.canSendPrivateMessages;
  }

  bool _isGuidedConversation(ChatConversation conversation) {
    return conversation.segment == ChatInboxSegment.system ||
        conversation.id == 'concierge' ||
        conversation.id.startsWith('concierge-');
  }

  ChatState copyWith({
    AppUser? currentUser,
    bool? isBusy,
    String? errorMessage,
    bool clearError = false,
    List<ChatConversation>? conversations,
    List<ChatMessage>? messages,
    String? selectedConversationId,
    bool clearSelectedConversation = false,
    Map<String, String>? drafts,
  }) {
    return ChatState(
      currentUser: currentUser ?? this.currentUser,
      isBusy: isBusy ?? this.isBusy,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      conversations: conversations ?? this.conversations,
      messages: messages ?? this.messages,
      selectedConversationId: clearSelectedConversation
          ? null
          : (selectedConversationId ?? this.selectedConversationId),
      drafts: drafts ?? this.drafts,
    );
  }

  @override
  List<Object?> get props => [
        currentUser,
        isBusy,
        errorMessage,
        conversations,
        messages,
        selectedConversationId,
        drafts,
      ];
}
