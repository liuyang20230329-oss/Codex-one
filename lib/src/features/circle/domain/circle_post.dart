enum CircleAttachmentType {
  image('image'),
  voice('voice'),
  work('work'),
  location('location'),
  video('video'),
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

String _relativeTimeLabel(DateTime time) {
  final now = DateTime.now();
  final difference = now.difference(time);
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
  final month = time.month.toString().padLeft(2, '0');
  final day = time.day.toString().padLeft(2, '0');
  return '${time.year}-$month-$day';
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
    this.visibility = 'public',
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
  final String visibility;

  List<String> get attachmentLabels {
    return attachments.map((item) => item.label).toList(growable: false);
  }

  String get createdAtLabel => _relativeTimeLabel(createdAt);

  CirclePost copyWith({
    String? id,
    String? authorName,
    String? location,
    String? content,
    DateTime? createdAt,
    List<CirclePostAttachment>? attachments,
    String? verificationLabel,
    String? distance,
    int? likes,
    int? comments,
    String? visibility,
  }) {
    return CirclePost(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      location: location ?? this.location,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      attachments: attachments ?? this.attachments,
      verificationLabel: verificationLabel ?? this.verificationLabel,
      distance: distance ?? this.distance,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      visibility: visibility ?? this.visibility,
    );
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
      'visibility': visibility,
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
          .map(
            (item) => CirclePostAttachment.fromJson(
              item.cast<String, Object?>(),
            ),
          )
          .toList(growable: false),
      verificationLabel: json['verificationLabel'] as String? ?? '待认证',
      distance: json['distance'] as String? ?? '附近',
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      comments: (json['comments'] as num?)?.toInt() ?? 0,
      visibility: json['visibility'] as String? ?? 'public',
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
      visibility: json['visibility'] as String? ?? 'public',
    );
  }
}

class CircleComment {
  const CircleComment({
    required this.id,
    required this.authorName,
    required this.content,
    required this.createdAt,
    this.parentCommentId,
  });

  final String id;
  final String authorName;
  final String content;
  final DateTime createdAt;
  final String? parentCommentId;

  bool get isReply => parentCommentId != null && parentCommentId!.isNotEmpty;
  String get createdAtLabel => _relativeTimeLabel(createdAt);

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'authorName': authorName,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      if (parentCommentId != null) 'parentCommentId': parentCommentId,
    };
  }

  factory CircleComment.fromJson(Map<String, Object?> json) {
    return CircleComment(
      id: json['id'] as String? ?? '',
      authorName: json['authorName'] as String? ?? '匿名用户',
      content: json['content'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      parentCommentId: json['parentCommentId'] as String?,
    );
  }

  factory CircleComment.fromApiJson(Map<String, Object?> json) {
    return CircleComment(
      id: json['id'] as String? ?? '',
      authorName: json['author_name'] as String? ??
          json['authorName'] as String? ??
          '匿名用户',
      content: json['content'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      parentCommentId: json['parent_comment_id'] as String? ??
          json['parentCommentId'] as String?,
    );
  }
}

class CirclePostDetail {
  const CirclePostDetail({
    required this.post,
    required this.comments,
  });

  final CirclePost post;
  final List<CircleComment> comments;

  CirclePostDetail copyWith({
    CirclePost? post,
    List<CircleComment>? comments,
  }) {
    return CirclePostDetail(
      post: post ?? this.post,
      comments: comments ?? this.comments,
    );
  }

  factory CirclePostDetail.fromJson(Map<String, Object?> json) {
    return CirclePostDetail(
      post: CirclePost.fromJson(
        (json['post'] as Map?)?.cast<String, Object?>() ?? <String, Object?>{},
      ),
      comments: ((json['comments'] as List?) ?? const <Object?>[])
          .whereType<Map>()
          .map(
            (item) => CircleComment.fromJson(item.cast<String, Object?>()),
          )
          .toList(growable: false),
    );
  }

  factory CirclePostDetail.fromApiJson(Map<String, Object?> json) {
    return CirclePostDetail(
      post: CirclePost.fromApiJson(
        (json['post'] as Map?)?.cast<String, Object?>() ?? <String, Object?>{},
      ),
      comments: ((json['comments'] as List?) ?? const <Object?>[])
          .whereType<Map>()
          .map(
            (item) => CircleComment.fromApiJson(item.cast<String, Object?>()),
          )
          .toList(growable: false),
    );
  }
}
