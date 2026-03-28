import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/persistence/json_preferences_store.dart';
import '../domain/account_verification.dart';
import '../domain/app_user.dart';
import '../domain/auth_exception.dart';
import '../domain/auth_repository.dart';
import '../domain/phone_verification_session.dart';
import '../domain/profile_media_work.dart';
import '../domain/social_login_provider.dart';
import '../domain/user_gender.dart';
import '../domain/verification_status.dart';
import 'account_flow_helpers.dart';
import 'account_json_codec.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    required FirebaseAuth auth,
    JsonPreferencesStore? store,
  })  : _auth = auth,
        _store = store,
        _currentUser = _mapUser(auth.currentUser, null);

  final FirebaseAuth _auth;
  final JsonPreferencesStore? _store;
  AppUser? _currentUser;
  PhoneVerificationSession? _pendingPhoneSession;

  static const _localUserStatePrefix = 'firebase_auth_user_state_v3_';

  @override
  AppUser? get currentUser {
    final authUser = _auth.currentUser;
    if (authUser == null) {
      _currentUser = null;
      return null;
    }

    _currentUser = _restoreLocalState(_mapUser(authUser, _currentUser));
    return _currentUser;
  }

  @override
  Future<AppUser> signIn({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: syntheticEmailForPhone(phoneNumber),
        password: password,
      );
      final user = credential.user ?? _auth.currentUser;
      if (user == null) {
        throw const AuthException('Firebase 未返回用户信息。');
      }
      _pendingPhoneSession = null;
      _currentUser = _restoreLocalState(_mapUser(user, _currentUser));
      return _currentUser!;
    } on FirebaseAuthException catch (error) {
      throw AuthException(_messageFor(error));
    }
  }

  @override
  Future<AppUser> signUp({
    required String name,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: syntheticEmailForPhone(phoneNumber),
        password: password,
      );
      final user = credential.user ?? _auth.currentUser;
      if (user == null) {
        throw const AuthException('Firebase 未返回用户信息。');
      }
      await user.updateDisplayName(name.trim());
      await user.reload();
      final refreshed = _auth.currentUser ?? user;
      _currentUser = _restoreLocalState(
        _mapUser(
          refreshed,
          AppUser(
            id: refreshed.uid,
            name: name.trim(),
            email: syntheticEmailForPhone(phoneNumber),
            avatarKey: defaultAvatarKeyFor(phoneNumber),
            verification: const AccountVerification().copyWith(
              phoneNumber: maskPhoneNumber(phoneNumber),
            ),
          ),
        ),
      );
      await _persistLocalState();
      return _currentUser!;
    } on FirebaseAuthException catch (error) {
      throw AuthException(_messageFor(error));
    }
  }

  @override
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
  }) async {
    final user = _requireCurrentUser();
    final trimmedName = name?.trim();
    if (_auth.currentUser != null &&
        trimmedName != null &&
        trimmedName.isNotEmpty) {
      await _auth.currentUser!.updateDisplayName(trimmedName);
      await _auth.currentUser!.reload();
    }

    final nextAvatarKey = avatarKey ?? user.avatarKey;
    final nextVerification = nextAvatarKey == user.avatarKey
        ? user.verification
        : user.verification.copyWith(
            faceStatus: VerificationStatus.notStarted,
            clearFaceMatchScore: true,
            clearFaceVerifiedAt: true,
          );
    _currentUser = user.copyWith(
      name:
          trimmedName == null || trimmedName.isEmpty ? user.name : trimmedName,
      avatarKey: nextAvatarKey,
      gender: gender,
      birthYear: birthYear,
      birthMonth: birthMonth,
      city: city?.trim().isNotEmpty == true ? city!.trim() : user.city,
      signature: signature?.trim().isNotEmpty == true
          ? signature!.trim()
          : user.signature,
      introVideoTitle: introVideoTitle?.trim().isNotEmpty == true
          ? introVideoTitle!.trim()
          : user.introVideoTitle,
      introVideoSummary: introVideoSummary?.trim().isNotEmpty == true
          ? introVideoSummary!.trim()
          : user.introVideoSummary,
      works: works,
      verification: nextVerification,
    );
    await _persistLocalState();
    return _currentUser!;
  }

  @override
  Future<PhoneVerificationSession> requestPhoneVerification({
    required String phoneNumber,
  }) async {
    _requireCurrentUser();
    _pendingPhoneSession = createPhoneVerificationSession(phoneNumber);
    return _pendingPhoneSession!;
  }

  @override
  Future<AppUser> confirmPhoneVerification({
    required String sessionId,
    required String code,
  }) async {
    final session = _pendingPhoneSession;
    if (session == null || session.sessionId != sessionId) {
      throw const AuthException('请先发起手机号认证。');
    }
    if (session.isExpired) {
      throw const AuthException('验证码已过期。');
    }
    if (code.trim() != session.debugCode) {
      throw const AuthException('验证码不正确。');
    }

    final user = _requireCurrentUser();
    _currentUser = user.copyWith(
      verification: applyPhoneVerification(
        current: user.verification,
        phoneNumber: session.phoneNumber,
      ),
    );
    _pendingPhoneSession = null;
    await _persistLocalState();
    return _currentUser!;
  }

  @override
  Future<AppUser> submitIdentityVerification({
    required String legalName,
    required String idNumber,
  }) async {
    final normalizedName = legalName.trim();
    final normalizedId = normalizeIdNumber(idNumber);
    if (normalizedName.length < 2) {
      throw const AuthException('请输入真实姓名。');
    }
    if (!RegExp(r'^\d{17}[\dX]$').hasMatch(normalizedId)) {
      throw const AuthException('请输入有效的 18 位身份证号。');
    }

    final user = _requireCurrentUser();
    _currentUser = user.copyWith(
      verification: applyIdentityVerification(
        current: user.verification,
        legalName: normalizedName,
        idNumber: normalizedId,
      ),
    );
    await _persistLocalState();
    return _currentUser!;
  }

  @override
  Future<AppUser> completeFaceVerification() async {
    final user = _requireCurrentUser();
    if (!user.verification.canRunFaceVerification) {
      throw const AuthException('请先完成身份证实名认证，再进行本人认证。');
    }

    _currentUser = user.copyWith(
      verification: applyFaceVerification(current: user.verification),
    );
    await _persistLocalState();
    return _currentUser!;
  }

  @override
  Future<void> requestPasswordReset({
    required String phoneNumber,
  }) async {
    _pendingPhoneSession = createPhoneVerificationSession(phoneNumber);
  }

  @override
  Future<void> confirmPasswordReset({
    required String phoneNumber,
    required String code,
    required String newPassword,
  }) async {
    final session = _pendingPhoneSession;
    if (session == null || session.phoneNumber != normalizePhoneNumber(phoneNumber)) {
      throw const AuthException('请先发送验证码。');
    }
    if (session.debugCode != code.trim()) {
      throw const AuthException('验证码不正确。');
    }

    final email = syntheticEmailForPhone(phoneNumber);
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (error) {
      throw AuthException(_messageFor(error));
    }
  }

  @override
  Future<Never> triggerSocialLogin(SocialLoginProvider provider) {
    throw AuthException('${provider.label}登录待配置，请先使用手机号登录。');
  }

  @override
  Future<void> signOut() async {
    _pendingPhoneSession = null;
    _currentUser = null;
    await _auth.signOut();
  }

  AppUser _requireCurrentUser() {
    final user = currentUser;
    if (user == null) {
      throw const AuthException('请先登录后再继续。');
    }
    return user;
  }

  AppUser? _restoreLocalState(AppUser? user) {
    if (user == null) {
      return null;
    }
    final stored = _store?.readObjectSync('$_localUserStatePrefix${user.id}');
    if (stored == null) {
      return user;
    }
    final restored = appUserFromJson(stored);
    return user.copyWith(
      name: restored.name.isEmpty ? user.name : restored.name,
      avatarKey: restored.avatarKey,
      gender: restored.gender,
      birthYear: restored.birthYear,
      birthMonth: restored.birthMonth,
      city: restored.city,
      signature: restored.signature,
      introVideoTitle: restored.introVideoTitle,
      introVideoSummary: restored.introVideoSummary,
      works: restored.works,
      verification: restored.verification,
    );
  }

  Future<void> _persistLocalState() async {
    final user = _currentUser;
    if (_store == null || user == null) {
      return;
    }
    await _store.writeJson(
      '$_localUserStatePrefix${user.id}',
      appUserToJson(user),
    );
  }

  static AppUser? _mapUser(User? user, AppUser? previousUser) {
    if (user == null) {
      return null;
    }
    final previousMatches = previousUser != null && previousUser.id == user.uid;
    final phoneAlias = user.email?.split('@').first ?? user.uid;
    return AppUser(
      id: user.uid,
      name: user.displayName?.trim().isNotEmpty == true
          ? user.displayName!.trim()
          : '用户${phoneAlias.substring(0, phoneAlias.length > 4 ? 4 : phoneAlias.length)}',
      email: user.email ?? syntheticEmailForPhone(phoneAlias),
      avatarKey: previousMatches
          ? previousUser.avatarKey
          : defaultAvatarKeyFor(phoneAlias),
      gender: previousMatches ? previousUser.gender : UserGender.undisclosed,
      birthYear: previousMatches ? previousUser.birthYear : null,
      birthMonth: previousMatches ? previousUser.birthMonth : null,
      city: previousMatches ? previousUser.city : AppUser.defaultCity,
      signature:
          previousMatches ? previousUser.signature : AppUser.defaultSignature,
      introVideoTitle: previousMatches
          ? previousUser.introVideoTitle
          : AppUser.defaultIntroVideoTitle,
      introVideoSummary: previousMatches
          ? previousUser.introVideoSummary
          : AppUser.defaultIntroVideoSummary,
      works: previousMatches ? previousUser.works : const <ProfileMediaWork>[],
      verification: previousMatches
          ? previousUser.verification
          : const AccountVerification(),
    );
  }

  String _messageFor(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return '该手机号已被注册。';
      case 'invalid-email':
        return '当前 Firebase 兼容账号格式无效。';
      case 'user-not-found':
        return '该手机号尚未注册账号。';
      case 'wrong-password':
      case 'invalid-credential':
        return '密码不正确，请重试。';
      case 'weak-password':
        return '请使用更强的密码。';
      case 'network-request-failed':
        return '网络异常导致认证中断，请稍后再试。';
      default:
        return error.message ?? '认证失败，请稍后再试。';
    }
  }
}
