part of 'chat_bloc.dart';

sealed class ChatEvent {
  const ChatEvent();
}

final class ChatUserSynced extends ChatEvent {
  const ChatUserSynced(this.user);

  final AppUser user;
}

final class ChatConversationOpened extends ChatEvent {
  const ChatConversationOpened(this.conversationId);

  final String conversationId;
}

final class ChatConversationClosed extends ChatEvent {
  const ChatConversationClosed();
}

final class ChatDraftUpdated extends ChatEvent {
  const ChatDraftUpdated({
    required this.conversationId,
    required this.value,
  });

  final String conversationId;
  final String value;
}

final class ChatMessageSent extends ChatEvent {
  const ChatMessageSent(
    this.text, {
    this.type = ChatMessageType.text,
    this.mediaUrl,
    this.metadataLabel,
  });

  final String text;
  final ChatMessageType type;
  final String? mediaUrl;
  final String? metadataLabel;
}

final class ChatConversationCreated extends ChatEvent {
  const ChatConversationCreated({
    required this.title,
    required this.subtitle,
    required this.categoryLabel,
    required this.segment,
  });

  final String title;
  final String subtitle;
  final String categoryLabel;
  final ChatInboxSegment segment;
}

final class ChatPinToggled extends ChatEvent {
  const ChatPinToggled(this.conversationId);

  final String conversationId;
}

final class ChatConversationDeleted extends ChatEvent {
  const ChatConversationDeleted(this.conversationId);

  final String conversationId;
}

final class ChatAllMarkedRead extends ChatEvent {
  const ChatAllMarkedRead();
}
