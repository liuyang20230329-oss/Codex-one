part of 'circle_bloc.dart';

class CircleState extends Equatable {
  const CircleState({
    this.currentUser,
    this.isLoading = false,
    this.isPublishing = false,
    this.isDetailLoading = false,
    this.isSubmittingComment = false,
    this.isReporting = false,
    this.errorMessage,
    this.detailErrorMessage,
    this.posts = const <CirclePost>[],
    this.detailCache = const <String, CirclePostDetail>{},
  });

  final AppUser? currentUser;
  final bool isLoading;
  final bool isPublishing;
  final bool isDetailLoading;
  final bool isSubmittingComment;
  final bool isReporting;
  final String? errorMessage;
  final String? detailErrorMessage;
  final List<CirclePost> posts;
  final Map<String, CirclePostDetail> detailCache;

  CirclePostDetail? detailFor(String postId) => detailCache[postId];

  CircleState copyWith({
    AppUser? currentUser,
    bool? isLoading,
    bool? isPublishing,
    bool? isDetailLoading,
    bool? isSubmittingComment,
    bool? isReporting,
    String? errorMessage,
    bool clearError = false,
    String? detailErrorMessage,
    bool clearDetailError = false,
    List<CirclePost>? posts,
    Map<String, CirclePostDetail>? detailCache,
  }) {
    return CircleState(
      currentUser: currentUser ?? this.currentUser,
      isLoading: isLoading ?? this.isLoading,
      isPublishing: isPublishing ?? this.isPublishing,
      isDetailLoading: isDetailLoading ?? this.isDetailLoading,
      isSubmittingComment: isSubmittingComment ?? this.isSubmittingComment,
      isReporting: isReporting ?? this.isReporting,
      errorMessage:
          clearError ? null : (errorMessage ?? this.errorMessage),
      detailErrorMessage: clearDetailError
          ? null
          : (detailErrorMessage ?? this.detailErrorMessage),
      posts: posts ?? this.posts,
      detailCache: detailCache ?? this.detailCache,
    );
  }

  @override
  List<Object?> get props => [
        currentUser,
        isLoading,
        isPublishing,
        isDetailLoading,
        isSubmittingComment,
        isReporting,
        errorMessage,
        detailErrorMessage,
        posts,
        detailCache,
      ];
}
