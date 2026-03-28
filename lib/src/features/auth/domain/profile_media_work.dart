enum ProfileMediaWorkType {
  voice,
  video,
  image,
  gif,
}

extension ProfileMediaWorkTypeX on ProfileMediaWorkType {
  String get label {
    switch (this) {
      case ProfileMediaWorkType.voice:
        return '语音';
      case ProfileMediaWorkType.video:
        return '视频';
      case ProfileMediaWorkType.image:
        return '图片';
      case ProfileMediaWorkType.gif:
        return '动图';
    }
  }
}

ProfileMediaWorkType profileMediaWorkTypeFromName(String? value) {
  return ProfileMediaWorkType.values.firstWhere(
    (type) => type.name == value,
    orElse: () => ProfileMediaWorkType.image,
  );
}

class ProfileMediaWork {
  const ProfileMediaWork({
    required this.id,
    required this.type,
    required this.title,
    required this.summary,
  });

  final String id;
  final ProfileMediaWorkType type;
  final String title;
  final String summary;

  ProfileMediaWork copyWith({
    String? id,
    ProfileMediaWorkType? type,
    String? title,
    String? summary,
  }) {
    return ProfileMediaWork(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      summary: summary ?? this.summary,
    );
  }
}
