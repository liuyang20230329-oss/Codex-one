import 'app_user.dart';
import 'profile_media_work.dart';
import 'phone_verification_session.dart';
import 'social_login_provider.dart';
import 'user_gender.dart';

abstract class AuthRepository {
  AppUser? get currentUser;

  Future<AppUser> signIn({
    required String phoneNumber,
    required String password,
  });

  Future<AppUser> signUp({
    required String name,
    required String phoneNumber,
    required String password,
  });

  Future<AppUser> updateProfile({
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

  Future<void> requestPasswordReset({
    required String phoneNumber,
  });

  Future<void> confirmPasswordReset({
    required String phoneNumber,
    required String code,
    required String newPassword,
  });

  Future<Never> triggerSocialLogin(SocialLoginProvider provider);

  Future<void> signOut();
}
