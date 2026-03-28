class ChatRepositoryEvent {
  const ChatRepositoryEvent({
    required this.kind,
    this.conversationId,
  });

  final String kind;
  final String? conversationId;
}
