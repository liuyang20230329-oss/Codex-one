import 'package:flutter/foundation.dart';

import '../../auth/domain/app_user.dart';
import '../domain/circle_post.dart';
import '../domain/circle_repository.dart';

/// Coordinates feed loading and publish actions for the circle tab.
class CircleController extends ChangeNotifier {
  CircleController({
    required CircleRepository repository,
  }) : _repository = repository;

  final CircleRepository _repository;

  AppUser? _currentUser;
  bool _isLoading = false;
  bool _isPublishing = false;
  String? _errorMessage;
  List<CirclePost> _posts = const <CirclePost>[];

  bool get isLoading => _isLoading;
  bool get isPublishing => _isPublishing;
  String? get errorMessage => _errorMessage;
  List<CirclePost> get posts => _posts;

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
      _posts = <CirclePost>[
        post,
        ..._posts.where((item) => item.id != post.id),
      ];
      return post;
    } catch (_) {
      _errorMessage = '当前无法发布动态，请稍后再试。';
      return null;
    } finally {
      _isPublishing = false;
      notifyListeners();
    }
  }
}
