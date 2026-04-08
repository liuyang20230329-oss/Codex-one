enum CircleAttachmentType {
  image('image'),
  voice('voice'),
  work('work'),
  other('other');

  const CircleAttachmentType(this.apiName);

  final String apiName;

  static CircleAttachmentType fromApiName(String? value) {
    for (final item in CircleAttachmentType.values) {
      if (item.apiName == value) {
        return item;
      }
    }
    return CircleAttachmentType.other;
  }
}

/// A compact attachment descriptor used by the circle feed and publish flow.
class CirclePostAttachment {
  const CirclePostAttachment({
    required this.label,
    required this.type,
    this.url,
  });

  final String label;
  final CircleAttachmentType type;
  final String? url;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'label': label,
      'type': type.apiName,
      if (url != null) 'url': url,
    };
  }

  factory CirclePostAttachment.fromJson(Map<String, Object?> json) {
    return CirclePostAttachment(
      label: json['label'] as String? ?? '附件',
      type: CircleAttachmentType.fromApiName(json['type'] as String?),
      url: json['url'] as String?,
    );
  }
}

/// Payload sent when a user publishes a new circle post.
class CirclePostInput {
  const CirclePostInput({
    required this.content,
    required this.location,
    this.visibility = 'public',
    this.attachments = const <CirclePostAttachment>[],
  });

  final String content;
  final String location;
  final String visibility;
  final List<CirclePostAttachment> attachments;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'content': content,
      'location': location,
      'visibility': visibility,
      'attachments': attachments.map((item) => item.toJson()).toList(),
    };
  }
}

/// Feed item shown in the circle tab.
class CirclePost {
  const CirclePost({
    required this.id,
    required this.authorName,
    required this.location,
    required this.content,
    required this.createdAt,
    required this.attachments,
    required this.verificationLabel,
    required this.distance,
    required this.likes,
    required this.comments,
  });

  final String id;
  final String authorName;
  final String location;
  final String content;
  final DateTime createdAt;
  final List<CirclePostAttachment> attachments;
  final String verificationLabel;
  final String distance;
  final int likes;
  final int comments;

  List<String> get attachmentLabels {
    return attachments.map((item) => item.label).toList(growable: false);
  }

  String get createdAtLabel {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    if (difference.inMinutes < 1) {
      return '刚刚';
    }
    if (difference.inHours < 1) {
      return '${difference.inMinutes}分钟前';
    }
    if (difference.inDays < 1) {
      return '${difference.inHours}小时前';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    }
    final month = createdAt.month.toString().padLeft(2, '0');
    final day = createdAt.day.toString().padLeft(2, '0');
    return '${createdAt.year}-$month-$day';
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'authorName': authorName,
      'location': location,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'attachments': attachments.map((item) => item.toJson()).toList(),
      'verificationLabel': verificationLabel,
      'distance': distance,
      'likes': likes,
      'comments': comments,
    };
  }

  factory CirclePost.fromJson(Map<String, Object?> json) {
    return CirclePost(
      id: json['id'] as String? ?? '',
      authorName: json['authorName'] as String? ?? '新用户',
      location: json['location'] as String? ?? '未设置位置',
      content: json['content'] as String? ?? '分享了一条新的圈子动态。',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      attachments: ((json['attachments'] as List?) ?? const <Object?>[])
          .whereType<Map>()
          .map((item) => CirclePostAttachment.fromJson(
                item.cast<String, Object?>(),
              ))
          .toList(growable: false),
      verificationLabel: json['verificationLabel'] as String? ?? '待认证',
      distance: json['distance'] as String? ?? '附近',
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      comments: (json['comments'] as num?)?.toInt() ?? 0,
    );
  }

  factory CirclePost.fromApiJson(Map<String, Object?> json) {
    final media = ((json['media'] as List?) ?? const <Object?>[])
        .whereType<Map>()
        .map((item) {
      final typed = item.cast<String, Object?>();
      return CirclePostAttachment(
        label:
            typed['label'] as String? ?? typed['media_type'] as String? ?? '附件',
        type: CircleAttachmentType.fromApiName(
          typed['media_type'] as String?,
        ),
        url: typed['url'] as String?,
      );
    }).toList(growable: false);
    final attachmentLabels =
        ((json['attachments'] as List?) ?? const <Object?>[])
            .whereType<String>();

    return CirclePost(
      id: json['id'] as String? ?? '',
      authorName: json['authorName'] as String? ?? '新用户',
      location: json['location'] as String? ?? '未设置位置',
      content: json['content'] as String? ?? '分享了一条新的圈子动态。',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      attachments: media.isNotEmpty
          ? media
          : attachmentLabels
              .map(
                (label) => CirclePostAttachment(
                  label: label,
                  type: CircleAttachmentType.other,
                ),
              )
              .toList(growable: false),
      verificationLabel: json['verificationLabel'] as String? ?? '待认证',
      distance: json['distance'] as String? ?? '附近',
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      comments: (json['comments'] as num?)?.toInt() ?? 0,
    );
  }
}
