import 'package:flutter/foundation.dart';

import '../../auth/domain/app_user.dart';
import '../domain/circle_post.dart';
import '../domain/circle_repository.dart';

/// Coordinates feed loading plus detail interactions for the circle module.
class CircleController extends ChangeNotifier {
  CircleController({
    required CircleRepository repository,
  }) : _repository = repository;

  final CircleRepository _repository;

  AppUser? _currentUser;
  bool _isLoading = false;
  bool _isPublishing = false;
  bool _isDetailLoading = false;
  bool _isSubmittingComment = false;
  bool _isReporting = false;
  String? _errorMessage;
  String? _detailErrorMessage;
  List<CirclePost> _posts = const <CirclePost>[];
  final Map<String, CirclePostDetail> _detailCache =
      <String, CirclePostDetail>{};

  bool get isLoading => _isLoading;
  bool get isPublishing => _isPublishing;
  bool get isDetailLoading => _isDetailLoading;
  bool get isSubmittingComment => _isSubmittingComment;
  bool get isReporting => _isReporting;
  String? get errorMessage => _errorMessage;
  String? get detailErrorMessage => _detailErrorMessage;
  List<CirclePost> get posts => _posts;

  CirclePostDetail? detailFor(String postId) => _detailCache[postId];

  Future<void> syncUser(AppUser user) async {
    final previousUserId = _currentUser?.id;
    _currentUser = user;
    if (previousUserId != user.id || _posts.isEmpty) {
      await refreshPosts();
    }
  }

  Future<void> refreshPosts() async {
    final user = _currentUser;
    if (user == null) {
      _posts = const <CirclePost>[];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _posts = await _repository.loadPosts(user: user);
    } catch (_) {
      _errorMessage = '当前无法加载圈子列表，请稍后再试。';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<CirclePost?> publishPost(CirclePostInput input) async {
    final user = _currentUser;
    if (user == null) {
      _errorMessage = '当前未识别到登录用户，暂时无法发布动态。';
      notifyListeners();
      return null;
    }

    _isPublishing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final post = await _repository.publishPost(
        user: user,
        input: input,
      );
      _upsertPost(post, insertAtFront: true);
      return post;
    } catch (_) {
      _errorMessage = '当前无法发布动态，请稍后再试。';
      return null;
    } finally {
      _isPublishing = false;
      notifyListeners();
    }
  }

  Future<CirclePostDetail?> loadPostDetail(String postId) async {
    final user = _currentUser;
    if (user == null) {
      _detailErrorMessage = '当前未识别到登录用户，暂时无法查看详情。';
      notifyListeners();
      return null;
    }

    _isDetailLoading = true;
    _detailErrorMessage = null;
    notifyListeners();

    try {
      final detail = await _repository.loadPostDetail(
        user: user,
        postId: postId,
      );
      _detailCache[postId] = detail;
      _upsertPost(detail.post);
      return detail;
    } catch (_) {
      _detailErrorMessage = '当前无法加载动态详情，请稍后再试。';
      return null;
    } finally {
      _isDetailLoading = false;
      notifyListeners();
    }
  }

  Future<CirclePostDetail?> addComment({
    required String postId,
    required String content,
    String? parentCommentId,
  }) async {
    final user = _currentUser;
    if (user == null) {
      _detailErrorMessage = '当前未识别到登录用户，暂时无法发表评论。';
      notifyListeners();
      return null;
    }

    _isSubmittingComment = true;
    _detailErrorMessage = null;
    notifyListeners();

    try {
      final detail = await _repository.addComment(
        user: user,
        postId: postId,
        content: content,
        parentCommentId: parentCommentId,
      );
      _detailCache[postId] = detail;
      _upsertPost(detail.post);
      return detail;
    } catch (_) {
      _detailErrorMessage = '当前无法发表评论，请稍后再试。';
      return null;
    } finally {
      _isSubmittingComment = false;
      notifyListeners();
    }
  }

  Future<bool> reportPost({
    required String postId,
    required String reason,
  }) async {
    final user = _currentUser;
    if (user == null) {
      _detailErrorMessage = '当前未识别到登录用户，暂时无法举报动态。';
      notifyListeners();
      return false;
    }

    _isReporting = true;
    _detailErrorMessage = null;
    notifyListeners();

    try {
      await _repository.reportPost(
        user: user,
        postId: postId,
        reason: reason,
      );
      return true;
    } catch (_) {
      _detailErrorMessage = '当前无法提交举报，请稍后再试。';
      return false;
    } finally {
      _isReporting = false;
      notifyListeners();
    }
  }

  void _upsertPost(CirclePost post, {bool insertAtFront = false}) {
    final existingIndex = _posts.indexWhere((item) => item.id == post.id);
    if (existingIndex == -1) {
      _posts = insertAtFront
          ? <CirclePost>[post, ..._posts]
          : <CirclePost>[
              ..._posts,
              post,
            ];
      return;
    }

    final updated = List<CirclePost>.from(_posts);
    updated[existingIndex] = post;
    if (insertAtFront && existingIndex != 0) {
      final moved = updated.removeAt(existingIndex);
      updated.insert(0, moved);
    }
    _posts = updated;
  }
}
