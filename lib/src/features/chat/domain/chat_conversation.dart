class ChatConversation {
  const ChatConversation({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.categoryLabel,
    required this.lastMessagePreview,
    required this.updatedAt,
    this.unreadCount = 0,
  });

  final String id;
  final String title;
  final String subtitle;
  final String categoryLabel;
  final String lastMessagePreview;
  final DateTime updatedAt;
  final int unreadCount;

  ChatConversation copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? categoryLabel,
    String? lastMessagePreview,
    DateTime? updatedAt,
    int? unreadCount,
  }) {
    return ChatConversation(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      categoryLabel: categoryLabel ?? this.categoryLabel,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      updatedAt: updatedAt ?? this.updatedAt,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
