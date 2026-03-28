import 'package:flutter/foundation.dart';

import '../domain/app_user.dart';
import '../domain/auth_exception.dart';
import '../domain/auth_repository.dart';
import '../domain/profile_media_work.dart';
import '../domain/phone_verification_session.dart';
import '../domain/user_gender.dart';

enum AuthStatus {
  unauthenticated,
  authenticating,
  authenticated,
}

class AuthController extends ChangeNotifier {
  AuthController({
    required AuthRepository repository,
  })  : _repository = repository,
        _currentUser = repository.currentUser,
        _status = repository.currentUser == null
            ? AuthStatus.unauthenticated
            : AuthStatus.authenticated;

  final AuthRepository _repository;

  AuthStatus _status;
  AppUser? _currentUser;
  String? _errorMessage;
  PhoneVerificationSession? _pendingPhoneSession;

  AuthStatus get status => _status;
  AppUser? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  PhoneVerificationSession? get pendingPhoneSession => _pendingPhoneSession;
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
    _pendingPhoneSession = null;
    _errorMessage = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> updateProfile({
    String? name,
    String? avatarKey,
    UserGender? gender,
    int? birthYear,
    int? birthMonth,
    String? city,
    String? signature,
    String? introVideoTitle,
    String? introVideoSummary,
    List<ProfileMediaWork>? works,
  }) async {
    return _runAuthenticatedMutation(
      action: () => _repository.updateProfile(
        name: name,
        avatarKey: avatarKey,
        gender: gender,
        birthYear: birthYear,
        birthMonth: birthMonth,
        city: city,
        signature: signature,
        introVideoTitle: introVideoTitle,
        introVideoSummary: introVideoSummary,
        works: works,
      ),
      onSuccess: (user) {
        _currentUser = user;
      },
    );
  }

  Future<PhoneVerificationSession?> requestPhoneVerification({
    required String phoneNumber,
  }) async {
    return _runAuxiliaryMutation(
      action: () => _repository.requestPhoneVerification(
        phoneNumber: phoneNumber,
      ),
      onSuccess: (session) {
        _pendingPhoneSession = session;
      },
    );
  }

  Future<bool> confirmPhoneVerification({
    required String code,
  }) async {
    final session = _pendingPhoneSession;
    if (session == null) {
      _errorMessage = '请先发起手机号认证。';
      notifyListeners();
      return false;
    }

    return _runAuthenticatedMutation(
      action: () => _repository.confirmPhoneVerification(
        sessionId: session.sessionId,
        code: code,
      ),
      onSuccess: (user) {
        _currentUser = user;
        _pendingPhoneSession = null;
      },
    );
  }

  Future<bool> submitIdentityVerification({
    required String legalName,
    required String idNumber,
  }) async {
    return _runAuthenticatedMutation(
      action: () => _repository.submitIdentityVerification(
        legalName: legalName,
        idNumber: idNumber,
      ),
      onSuccess: (user) {
        _currentUser = user;
      },
    );
  }

  Future<bool> completeFaceVerification() async {
    return _runAuthenticatedMutation(
      action: _repository.completeFaceVerification,
      onSuccess: (user) {
        _currentUser = user;
      },
    );
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
      _pendingPhoneSession = null;
      _status = AuthStatus.authenticated;
    } on AuthException catch (error) {
      _currentUser = null;
      _pendingPhoneSession = null;
      _status = AuthStatus.unauthenticated;
      _errorMessage = error.message;
    } catch (_) {
      _currentUser = null;
      _pendingPhoneSession = null;
      _status = AuthStatus.unauthenticated;
      _errorMessage = '认证服务暂时不可用，请稍后再试。';
    }

    notifyListeners();
  }

  Future<bool> _runAuthenticatedMutation({
    required Future<AppUser> Function() action,
    required void Function(AppUser user) onSuccess,
  }) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await action();
      onSuccess(user);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on AuthException catch (error) {
      _errorMessage = error.message;
      _status = _currentUser == null
          ? AuthStatus.unauthenticated
          : AuthStatus.authenticated;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = '认证服务暂时不可用，请稍后再试。';
      _status = _currentUser == null
          ? AuthStatus.unauthenticated
          : AuthStatus.authenticated;
      notifyListeners();
      return false;
    }
  }

  Future<T?> _runAuxiliaryMutation<T>({
    required Future<T> Function() action,
    required void Function(T result) onSuccess,
  }) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await action();
      onSuccess(result);
      _status = _currentUser == null
          ? AuthStatus.unauthenticated
          : AuthStatus.authenticated;
      notifyListeners();
      return result;
    } on AuthException catch (error) {
      _errorMessage = error.message;
      _status = _currentUser == null
          ? AuthStatus.unauthenticated
          : AuthStatus.authenticated;
      notifyListeners();
      return null;
    } catch (_) {
      _errorMessage = '认证服务暂时不可用，请稍后再试。';
      _status = _currentUser == null
          ? AuthStatus.unauthenticated
          : AuthStatus.authenticated;
      notifyListeners();
      return null;
    }
  }
}
