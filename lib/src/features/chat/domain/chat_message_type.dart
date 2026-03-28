enum ChatMessageType {
  text,
  image,
  voice,
  emoji,
  video,
  location,
  forwarded,
  system,
}

ChatMessageType chatMessageTypeFromName(String? value) {
  return ChatMessageType.values.firstWhere(
    (item) => item.name == value,
    orElse: () => ChatMessageType.text,
  );
}

extension ChatMessageTypeX on ChatMessageType {
  String get label {
    switch (this) {
      case ChatMessageType.text:
        return '文字';
      case ChatMessageType.image:
        return '图片';
      case ChatMessageType.voice:
        return '语音';
      case ChatMessageType.emoji:
        return '表情';
      case ChatMessageType.video:
        return '视频';
      case ChatMessageType.location:
        return '定位';
      case ChatMessageType.forwarded:
        return '转发';
      case ChatMessageType.system:
        return '系统';
    }
  }
}
