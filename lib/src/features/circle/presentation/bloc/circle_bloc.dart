import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../auth/domain/app_user.dart';
import '../../domain/circle_post.dart';
import '../../domain/circle_repository.dart';

part 'circle_event.dart';
part 'circle_state.dart';

class CircleBloc extends Bloc<CircleEvent, CircleState> {
  CircleBloc({required CircleRepository repository})
      : _repository = repository,
        super(const CircleState()) {
    on<CircleUserSynced>(_onUserSynced);
    on<CirclePostsRefreshed>(_onPostsRefreshed);
    on<CirclePostPublished>(_onPostPublished);
    on<CirclePostDetailLoaded>(_onPostDetailLoaded);
    on<CircleCommentAdded>(_onCommentAdded);
    on<CirclePostReported>(_onPostReported);
  }

  final CircleRepository _repository;

  Future<void> _onUserSynced(
    CircleUserSynced event,
    Emitter<CircleState> emit,
  ) async {
    final previousUserId = state.currentUser?.id;
    emit(state.copyWith(currentUser: event.user));
    if (previousUserId != event.user.id || state.posts.isEmpty) {
      await _refreshPosts(emit);
    }
  }

  Future<void> _onPostsRefreshed(
    CirclePostsRefreshed event,
    Emitter<CircleState> emit,
  ) async {
    await _refreshPosts(emit);
  }

  Future<void> _onPostPublished(
    CirclePostPublished event,
    Emitter<CircleState> emit,
  ) async {
    final user = state.currentUser;
    if (user == null) {
      emit(state.copyWith(errorMessage: '当前未识别到登录用户，暂时无法发布动态。'));
      return;
    }

    emit(state.copyWith(isPublishing: true, clearError: true));
    try {
      final post = await _repository.publishPost(user: user, input: event.input);
      final updatedPosts = _upsertPost(state.posts, post, insertAtFront: true);
      emit(state.copyWith(isPublishing: false, posts: updatedPosts));
    } catch (_) {
      emit(state.copyWith(
        isPublishing: false,
        errorMessage: '当前无法发布动态，请稍后再试。',
      ));
    }
  }

  Future<void> _onPostDetailLoaded(
    CirclePostDetailLoaded event,
    Emitter<CircleState> emit,
  ) async {
    final user = state.currentUser;
    if (user == null) {
      emit(state.copyWith(detailErrorMessage: '当前未识别到登录用户，暂时无法查看详情。'));
      return;
    }

    emit(state.copyWith(isDetailLoading: true, clearDetailError: true));
    try {
      final detail = await _repository.loadPostDetail(
        user: user,
        postId: event.postId,
      );
      final updatedCache = Map<String, CirclePostDetail>.from(state.detailCache)
        ..[event.postId] = detail;
      final updatedPosts = _upsertPost(state.posts, detail.post);
      emit(state.copyWith(
        isDetailLoading: false,
        detailCache: updatedCache,
        posts: updatedPosts,
      ));
    } catch (_) {
      emit(state.copyWith(
        isDetailLoading: false,
        detailErrorMessage: '当前无法加载动态详情，请稍后再试。',
      ));
    }
  }

  Future<void> _onCommentAdded(
    CircleCommentAdded event,
    Emitter<CircleState> emit,
  ) async {
    final user = state.currentUser;
    if (user == null) {
      emit(state.copyWith(detailErrorMessage: '当前未识别到登录用户，暂时无法发表评论。'));
      return;
    }

    emit(state.copyWith(isSubmittingComment: true, clearDetailError: true));
    try {
      final detail = await _repository.addComment(
        user: user,
        postId: event.postId,
        content: event.content,
        parentCommentId: event.parentCommentId,
      );
      final updatedCache = Map<String, CirclePostDetail>.from(state.detailCache)
        ..[event.postId] = detail;
      final updatedPosts = _upsertPost(state.posts, detail.post);
      emit(state.copyWith(
        isSubmittingComment: false,
        detailCache: updatedCache,
        posts: updatedPosts,
      ));
    } catch (_) {
      emit(state.copyWith(
        isSubmittingComment: false,
        detailErrorMessage: '当前无法发表评论，请稍后再试。',
      ));
    }
  }

  Future<void> _onPostReported(
    CirclePostReported event,
    Emitter<CircleState> emit,
  ) async {
    final user = state.currentUser;
    if (user == null) {
      emit(state.copyWith(detailErrorMessage: '当前未识别到登录用户，暂时无法举报动态。'));
      return;
    }

    emit(state.copyWith(isReporting: true, clearDetailError: true));
    try {
      await _repository.reportPost(
        user: user,
        postId: event.postId,
        reason: event.reason,
      );
      emit(state.copyWith(isReporting: false));
    } catch (_) {
      emit(state.copyWith(
        isReporting: false,
        detailErrorMessage: '当前无法提交举报，请稍后再试。',
      ));
    }
  }

  Future<void> _refreshPosts(Emitter<CircleState> emit) async {
    final user = state.currentUser;
    if (user == null) {
      emit(state.copyWith(posts: const <CirclePost>[]));
      return;
    }

    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final posts = await _repository.loadPosts(user: user);
      emit(state.copyWith(isLoading: false, posts: posts));
    } catch (_) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: '当前无法加载圈子列表，请稍后再试。',
      ));
    }
  }

  List<CirclePost> _upsertPost(
    List<CirclePost> posts,
    CirclePost post, {
    bool insertAtFront = false,
  }) {
    final existingIndex = posts.indexWhere((item) => item.id == post.id);
    if (existingIndex == -1) {
      return insertAtFront
          ? <CirclePost>[post, ...posts]
          : <CirclePost>[...posts, post];
    }
    final updated = List<CirclePost>.from(posts);
    updated[existingIndex] = post;
    if (insertAtFront && existingIndex != 0) {
      final moved = updated.removeAt(existingIndex);
      updated.insert(0, moved);
    }
    return updated;
  }
}
