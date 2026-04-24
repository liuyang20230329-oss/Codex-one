part of 'circle_bloc.dart';

sealed class CircleEvent {
  const CircleEvent();
}

final class CircleUserSynced extends CircleEvent {
  const CircleUserSynced(this.user);

  final AppUser user;
}

final class CirclePostsRefreshed extends CircleEvent {
  const CirclePostsRefreshed();
}

final class CirclePostPublished extends CircleEvent {
  const CirclePostPublished(this.input);

  final CirclePostInput input;
}

final class CirclePostDetailLoaded extends CircleEvent {
  const CirclePostDetailLoaded(this.postId);

  final String postId;
}

final class CircleCommentAdded extends CircleEvent {
  const CircleCommentAdded({
    required this.postId,
    required this.content,
    this.parentCommentId,
  });

  final String postId;
  final String content;
  final String? parentCommentId;
}

final class CirclePostReported extends CircleEvent {
  const CirclePostReported({
    required this.postId,
    required this.reason,
  });

  final String postId;
  final String reason;
}
