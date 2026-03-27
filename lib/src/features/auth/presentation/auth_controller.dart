import 'package:flutter/foundation.dart';

import '../domain/app_user.dart';
import '../domain/auth_exception.dart';
import '../domain/auth_repository.dart';

enum AuthStatus {
  unauthenticated,
  authenticating,
  authenticated,
}

class AuthController extends ChangeNotifier {
  AuthController({
    required AuthRepository repository,
  }) : _repository = repository;

  final AuthRepository _repository;

  AuthStatus _status = AuthStatus.unauthenticated;
  AppUser? _currentUser;
  String? _errorMessage;

  AuthStatus get status => _status;
  AppUser? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isBusy => _status == AuthStatus.authenticating;

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _authenticate(
      action: () => _repository.signIn(
        email: email,
        password: password,
      ),
    );
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    await _authenticate(
      action: () => _repository.signUp(
        name: name,
        email: email,
        password: password,
      ),
    );
  }

  Future<void> signOut() async {
    _status = AuthStatus.authenticating;
    notifyListeners();

    await _repository.signOut();
    _currentUser = null;
    _errorMessage = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _authenticate({
    required Future<AppUser> Function() action,
  }) async {
    // One shared flow keeps sign-in and sign-up state changes consistent.
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await action();
      _status = AuthStatus.authenticated;
    } on AuthException catch (error) {
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
      _errorMessage = error.message;
    } catch (_) {
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
      _errorMessage = 'Authentication is temporarily unavailable.';
    }

    notifyListeners();
  }
}
