enum ChatInboxSegment {
  friends,
  hot,
  followers,
  following,
  system,
}

extension ChatInboxSegmentX on ChatInboxSegment {
  String get label {
    switch (this) {
      case ChatInboxSegment.friends:
        return '好友';
      case ChatInboxSegment.hot:
        return '热聊';
      case ChatInboxSegment.followers:
        return '关注我的';
      case ChatInboxSegment.following:
        return '我关注的';
      case ChatInboxSegment.system:
        return '系统';
    }
  }
}

ChatInboxSegment chatInboxSegmentFromName(String? value) {
  return ChatInboxSegment.values.firstWhere(
    (segment) => segment.name == value,
    orElse: () => ChatInboxSegment.friends,
  );
}
