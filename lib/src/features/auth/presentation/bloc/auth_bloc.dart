import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/app_user.dart';
import '../../domain/auth_exception.dart' as auth_ex;
import '../../domain/auth_repository.dart';
import '../../domain/profile_media_work.dart';
import '../../domain/phone_verification_session.dart';
import '../../domain/social_login_provider.dart';
import '../../domain/user_gender.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthRepository repository})
      : _repository = repository,
        super(AuthState(
          status: repository.currentUser == null
              ? AuthStatus.unauthenticated
              : AuthStatus.authenticated,
          currentUser: repository.currentUser,
        )) {
    on<AuthSignInRequested>(_onSignIn);
    on<AuthSignUpRequested>(_onSignUp);
    on<AuthPasswordResetRequested>(_onPasswordResetRequested);
    on<AuthPasswordResetConfirmed>(_onPasswordResetConfirmed);
    on<AuthSocialLoginTriggered>(_onSocialLoginTriggered);
    on<AuthSignOutRequested>(_onSignOut);
    on<AuthProfileUpdated>(_onProfileUpdated);
    on<AuthPhoneVerificationRequested>(_onPhoneVerificationRequested);
    on<AuthPhoneVerificationConfirmed>(_onPhoneVerificationConfirmed);
    on<AuthIdentityVerificationSubmitted>(_onIdentityVerificationSubmitted);
    on<AuthFaceVerificationCompleted>(_onFaceVerificationCompleted);
    on<AuthErrorCleared>(_onErrorCleared);
  }

  final AuthRepository _repository;

  Future<void> _onSignIn(AuthSignInRequested event, Emitter<AuthState> emit) async {
    await _authenticate(emit: emit, action: () => _repository.signIn(phoneNumber: event.phoneNumber, password: event.password));
  }

  Future<void> _onSignUp(AuthSignUpRequested event, Emitter<AuthState> emit) async {
    await _authenticate(emit: emit, action: () => _repository.signUp(name: event.name, phoneNumber: event.phoneNumber, password: event.password));
  }

  Future<void> _onPasswordResetRequested(AuthPasswordResetRequested event, Emitter<AuthState> emit) async {
    await _runVoidMutation(emit: emit, action: () => _repository.requestPasswordReset(phoneNumber: event.phoneNumber), successMessage: '验证码已发送，请继续完成重置密码。');
  }

  Future<void> _onPasswordResetConfirmed(AuthPasswordResetConfirmed event, Emitter<AuthState> emit) async {
    await _runVoidMutation(emit: emit, action: () => _repository.confirmPasswordReset(phoneNumber: event.phoneNumber, code: event.code, newPassword: event.newPassword), successMessage: '密码已更新，请使用新密码重新登录。');
  }

  Future<void> _onSocialLoginTriggered(AuthSocialLoginTriggered event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.authenticating, clearError: true));
    try {
      await _repository.triggerSocialLogin(event.provider);
    } on auth_ex.AuthException catch (error) {
      emit(state.copyWith(errorMessage: error.message));
    } catch (_) {
      emit(state.copyWith(errorMessage: '${event.provider.label}登录暂时不可用，请稍后再试。'));
    }
    emit(state.copyWith(status: state.currentUser == null ? AuthStatus.unauthenticated : AuthStatus.authenticated));
  }

  Future<void> _onSignOut(AuthSignOutRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.authenticating));
    await _repository.signOut();
    emit(state.copyWith(status: AuthStatus.unauthenticated, clearUser: true, clearError: true, clearSession: true));
  }

  Future<void> _onProfileUpdated(AuthProfileUpdated event, Emitter<AuthState> emit) async {
    await _runAuthenticatedMutation(
      emit: emit,
      action: () => _repository.updateProfile(name: event.name, avatarKey: event.avatarKey, gender: event.gender, birthYear: event.birthYear, birthMonth: event.birthMonth, city: event.city, signature: event.signature, introVideoTitle: event.introVideoTitle, introVideoSummary: event.introVideoSummary, works: event.works),
      onSuccess: (user, emit) { emit(state.copyWith(currentUser: user)); },
    );
  }

  Future<void> _onPhoneVerificationRequested(AuthPhoneVerificationRequested event, Emitter<AuthState> emit) async {
    await _runAuxiliaryMutation<PhoneVerificationSession>(
      emit: emit,
      action: () => _repository.requestPhoneVerification(phoneNumber: event.phoneNumber),
      onSuccess: (session, emit) { emit(state.copyWith(pendingPhoneSession: session)); },
    );
  }

  Future<void> _onPhoneVerificationConfirmed(AuthPhoneVerificationConfirmed event, Emitter<AuthState> emit) async {
    final session = state.pendingPhoneSession;
    if (session == null) { emit(state.copyWith(errorMessage: '请先发起手机号认证。')); return; }
    await _runAuthenticatedMutation(
      emit: emit,
      action: () => _repository.confirmPhoneVerification(sessionId: session.sessionId, code: event.code),
      onSuccess: (user, emit) { emit(state.copyWith(currentUser: user, clearSession: true)); },
    );
  }

  Future<void> _onIdentityVerificationSubmitted(AuthIdentityVerificationSubmitted event, Emitter<AuthState> emit) async {
    await _runAuthenticatedMutation(
      emit: emit,
      action: () => _repository.submitIdentityVerification(legalName: event.legalName, idNumber: event.idNumber),
      onSuccess: (user, emit) { emit(state.copyWith(currentUser: user)); },
    );
  }

  Future<void> _onFaceVerificationCompleted(AuthFaceVerificationCompleted event, Emitter<AuthState> emit) async {
    await _runAuthenticatedMutation(
      emit: emit,
      action: _repository.completeFaceVerification,
      onSuccess: (user, emit) { emit(state.copyWith(currentUser: user)); },
    );
  }

  void _onErrorCleared(AuthErrorCleared event, Emitter<AuthState> emit) {
    if (state.errorMessage == null) return;
    emit(state.copyWith(clearError: true));
  }

  Future<void> _authenticate({required Emitter<AuthState> emit, required Future<AppUser> Function() action}) async {
    emit(state.copyWith(status: AuthStatus.authenticating, clearError: true));
    try {
      final user = await action();
      emit(state.copyWith(status: AuthStatus.authenticated, currentUser: user, clearSession: true));
    } on auth_ex.AuthException catch (error) {
      emit(state.copyWith(status: AuthStatus.unauthenticated, clearUser: true, clearSession: true, errorMessage: error.message));
    } catch (_) {
      emit(state.copyWith(status: AuthStatus.unauthenticated, clearUser: true, clearSession: true, errorMessage: '认证服务暂时不可用，请稍后再试。'));
    }
  }

  Future<void> _runAuthenticatedMutation({required Emitter<AuthState> emit, required Future<AppUser> Function() action, required void Function(AppUser, Emitter<AuthState>) onSuccess}) async {
    emit(state.copyWith(status: AuthStatus.authenticating, clearError: true));
    try {
      final user = await action();
      onSuccess(user, emit);
      emit(state.copyWith(status: AuthStatus.authenticated));
    } on auth_ex.AuthException catch (error) {
      emit(state.copyWith(errorMessage: error.message, status: state.currentUser == null ? AuthStatus.unauthenticated : AuthStatus.authenticated));
    } catch (_) {
      emit(state.copyWith(errorMessage: '认证服务暂时不可用，请稍后再试。', status: state.currentUser == null ? AuthStatus.unauthenticated : AuthStatus.authenticated));
    }
  }

  Future<T?> _runAuxiliaryMutation<T>({required Emitter<AuthState> emit, required Future<T> Function() action, required void Function(T, Emitter<AuthState>) onSuccess}) async {
    emit(state.copyWith(status: AuthStatus.authenticating, clearError: true));
    try {
      final result = await action();
      onSuccess(result, emit);
      emit(state.copyWith(status: state.currentUser == null ? AuthStatus.unauthenticated : AuthStatus.authenticated));
      return result;
    } on auth_ex.AuthException catch (error) {
      emit(state.copyWith(errorMessage: error.message, status: state.currentUser == null ? AuthStatus.unauthenticated : AuthStatus.authenticated));
      return null;
    } catch (_) {
      emit(state.copyWith(errorMessage: '认证服务暂时不可用，请稍后再试。', status: state.currentUser == null ? AuthStatus.unauthenticated : AuthStatus.authenticated));
      return null;
    }
  }

  Future<bool> _runVoidMutation({required Emitter<AuthState> emit, required Future<void> Function() action, required String successMessage}) async {
    emit(state.copyWith(status: AuthStatus.authenticating, clearError: true));
    try {
      await action();
      emit(state.copyWith(errorMessage: successMessage, status: state.currentUser == null ? AuthStatus.unauthenticated : AuthStatus.authenticated));
      return true;
    } on auth_ex.AuthException catch (error) {
      emit(state.copyWith(errorMessage: error.message, status: state.currentUser == null ? AuthStatus.unauthenticated : AuthStatus.authenticated));
      return false;
    } catch (_) {
      emit(state.copyWith(errorMessage: '认证服务暂时不可用，请稍后再试。', status: state.currentUser == null ? AuthStatus.unauthenticated : AuthStatus.authenticated));
      return false;
    }
  }
}
