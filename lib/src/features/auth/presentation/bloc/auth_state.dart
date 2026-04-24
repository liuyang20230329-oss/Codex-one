part of 'auth_bloc.dart';

enum AuthStatus {
  unauthenticated,
  authenticating,
  authenticated,
}

class AuthState extends Equatable {
  const AuthState({this.status = AuthStatus.unauthenticated, this.currentUser, this.errorMessage, this.pendingPhoneSession});

  final AuthStatus status;
  final AppUser? currentUser;
  final String? errorMessage;
  final PhoneVerificationSession? pendingPhoneSession;

  bool get isBusy => status == AuthStatus.authenticating;

  AuthState copyWith({
    AuthStatus? status,
    AppUser? currentUser,
    String? errorMessage,
    PhoneVerificationSession? pendingPhoneSession,
    bool clearError = false,
    bool clearUser = false,
    bool clearSession = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      currentUser: clearUser ? null : (currentUser ?? this.currentUser),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      pendingPhoneSession: clearSession ? null : (pendingPhoneSession ?? this.pendingPhoneSession),
    );
  }

  @override
  List<Object?> get props => [status, currentUser, errorMessage, pendingPhoneSession];
}
