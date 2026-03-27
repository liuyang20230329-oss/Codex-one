import 'app_user.dart';
import 'phone_verification_session.dart';

abstract class AuthRepository {
  AppUser? get currentUser;

  Future<AppUser> signIn({
    required String email,
    required String password,
  });

  Future<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  });

  Future<AppUser> updateProfile({
    required String name,
    required String avatarKey,
  });

  Future<PhoneVerificationSession> requestPhoneVerification({
    required String phoneNumber,
  });

  Future<AppUser> confirmPhoneVerification({
    required String sessionId,
    required String code,
  });

  Future<AppUser> submitIdentityVerification({
    required String legalName,
    required String idNumber,
  });

  Future<AppUser> completeFaceVerification();

  Future<void> signOut();
}
