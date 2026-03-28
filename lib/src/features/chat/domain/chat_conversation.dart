import 'chat_inbox_segment.dart';

class ChatConversation {
  const ChatConversation({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.categoryLabel,
    required this.segment,
    required this.lastMessagePreview,
    required this.updatedAt,
    this.unreadCount = 0,
    this.isPinned = false,
    this.isOnline = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final String categoryLabel;
  final ChatInboxSegment segment;
  final String lastMessagePreview;
  final DateTime updatedAt;
  final int unreadCount;
  final bool isPinned;
  final bool isOnline;

  ChatConversation copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? categoryLabel,
    ChatInboxSegment? segment,
    String? lastMessagePreview,
    DateTime? updatedAt,
    int? unreadCount,
    bool? isPinned,
    bool? isOnline,
  }) {
    return ChatConversation(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      categoryLabel: categoryLabel ?? this.categoryLabel,
      segment: segment ?? this.segment,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      updatedAt: updatedAt ?? this.updatedAt,
      unreadCount: unreadCount ?? this.unreadCount,
      isPinned: isPinned ?? this.isPinned,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}
