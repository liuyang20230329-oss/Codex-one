import 'account_verification.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarKey,
    this.verification = const AccountVerification(),
  });

  final String id;
  final String name;
  final String email;
  final String avatarKey;
  final AccountVerification verification;

  int get verificationProgress => verification.verifiedCount;
  bool get isVerificationComplete => verification.verifiedCount == 3;

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarKey,
    AccountVerification? verification,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarKey: avatarKey ?? this.avatarKey,
      verification: verification ?? this.verification,
    );
  }
}
