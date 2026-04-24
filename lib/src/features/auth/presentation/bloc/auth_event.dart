part of 'auth_bloc.dart';

sealed class AuthEvent {
  const AuthEvent();
}

final class AuthSignInRequested extends AuthEvent {
  const AuthSignInRequested({required this.phoneNumber, required this.password});
  final String phoneNumber;
  final String password;
}

final class AuthSignUpRequested extends AuthEvent {
  const AuthSignUpRequested({required this.name, required this.phoneNumber, required this.password});
  final String name;
  final String phoneNumber;
  final String password;
}

final class AuthPasswordResetRequested extends AuthEvent {
  const AuthPasswordResetRequested({required this.phoneNumber});
  final String phoneNumber;
}

final class AuthPasswordResetConfirmed extends AuthEvent {
  const AuthPasswordResetConfirmed({required this.phoneNumber, required this.code, required this.newPassword});
  final String phoneNumber;
  final String code;
  final String newPassword;
}

final class AuthSocialLoginTriggered extends AuthEvent {
  const AuthSocialLoginTriggered(this.provider);
  final SocialLoginProvider provider;
}

final class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

final class AuthProfileUpdated extends AuthEvent {
  const AuthProfileUpdated({this.name, this.avatarKey, this.gender, this.birthYear, this.birthMonth, this.city, this.signature, this.introVideoTitle, this.introVideoSummary, this.works});
  final String? name;
  final String? avatarKey;
  final UserGender? gender;
  final int? birthYear;
  final int? birthMonth;
  final String? city;
  final String? signature;
  final String? introVideoTitle;
  final String? introVideoSummary;
  final List<ProfileMediaWork>? works;
}

final class AuthPhoneVerificationRequested extends AuthEvent {
  const AuthPhoneVerificationRequested({required this.phoneNumber});
  final String phoneNumber;
}

final class AuthPhoneVerificationConfirmed extends AuthEvent {
  const AuthPhoneVerificationConfirmed({required this.code});
  final String code;
}

final class AuthIdentityVerificationSubmitted extends AuthEvent {
  const AuthIdentityVerificationSubmitted({required this.legalName, required this.idNumber});
  final String legalName;
  final String idNumber;
}

final class AuthFaceVerificationCompleted extends AuthEvent {
  const AuthFaceVerificationCompleted();
}

final class AuthErrorCleared extends AuthEvent {
  const AuthErrorCleared();
}
