import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/persistence/json_preferences_store.dart';
import 'account_flow_helpers.dart';
import 'account_json_codec.dart';
import '../domain/account_verification.dart';
import '../domain/app_user.dart';
import '../domain/auth_exception.dart';
import '../domain/profile_media_work.dart';
import '../domain/auth_repository.dart';
import '../domain/phone_verification_session.dart';
import '../domain/user_gender.dart';
import '../domain/verification_status.dart';

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
  static const _localUserStatePrefix = 'firebase_auth_user_state_v2_';

  @override
  AppUser? get currentUser {
    final authUser = _auth.currentUser;
    if (authUser == null) {
      _currentUser = null;
      return null;
    }

    _currentUser = _mapUser(authUser, _currentUser);
    _currentUser = _restoreLocalState(_currentUser);
    return _currentUser;
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user ?? _auth.currentUser;
      if (user == null) {
        throw const AuthException('Firebase 未返回用户信息。');
      }

      _pendingPhoneSession = null;
      _currentUser = _mapUser(user, _currentUser);
      _currentUser = _restoreLocalState(_currentUser);
      return _currentUser!;
    } on FirebaseAuthException catch (error) {
      throw AuthException(_messageFor(error));
    }
  }

  @override
  Future<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user ?? _auth.currentUser;
      if (user == null) {
        throw const AuthException('Firebase 未返回用户信息。');
      }

      if (name.trim().isNotEmpty) {
        await user.updateDisplayName(name.trim());
        await user.reload();
      }

      final refreshedUser = _auth.currentUser ?? user;
      _currentUser = _mapUser(refreshedUser, _currentUser);
      _currentUser = _restoreLocalState(_currentUser);
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
    final verification = user.avatarKey == nextAvatarKey
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
      verification: verification,
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

    final idPattern = RegExp(r'^\d{17}[\dX]$');
    if (!idPattern.hasMatch(normalizedId)) {
      throw const AuthException('请输入有效的18位身份证号。');
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
      throw const AuthException(
        '请先完成身份证认证，再进行人脸认证。',
      );
    }

    _currentUser = user.copyWith(
      verification: applyFaceVerification(current: user.verification),
    );
    await _persistLocalState();
    return _currentUser!;
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

    final stored = _store?.readObjectSync(
      '$_localUserStatePrefix${user.id}',
    );
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

    final displayName = user.displayName?.trim();
    final fallbackName = _fallbackDisplayName(user);
    final previousMatches = previousUser != null && previousUser.id == user.uid;
    return AppUser(
      id: user.uid,
      name: displayName == null || displayName.isEmpty
          ? fallbackName
          : displayName,
      email: user.email ?? '',
      avatarKey: previousMatches
          ? previousUser.avatarKey
          : defaultAvatarKeyFor(user.email ?? user.uid),
      gender: previousMatches ? previousUser.gender : UserGender.undisclosed,
      birthYear: previousMatches ? previousUser.birthYear : null,
      birthMonth: previousMatches ? previousUser.birthMonth : null,
      city: previousMatches ? previousUser.city : '未设置地区',
      signature: previousMatches ? previousUser.signature : '这个人很酷，还没有留下签名。',
      introVideoTitle:
          previousMatches ? previousUser.introVideoTitle : '还没有上传视频介绍',
      introVideoSummary: previousMatches
          ? previousUser.introVideoSummary
          : '后续可以用一段视频介绍自己，让更多人更快认识你。',
      works: previousMatches ? previousUser.works : const <ProfileMediaWork>[],
      verification: previousMatches
          ? previousUser.verification
          : const AccountVerification(),
    );
  }

  static String _fallbackDisplayName(User user) {
    final email = user.email;
    if (email == null || !email.contains('@')) {
      return '新用户';
    }

    return email.split('@').first;
  }

  String _messageFor(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return '该邮箱已被注册。';
      case 'invalid-email':
        return '请输入有效的邮箱地址。';
      case 'operation-not-allowed':
        return 'Firebase 还没有开启邮箱密码登录。';
      case 'user-disabled':
        return '该账号已被停用。';
      case 'user-not-found':
        return '该邮箱未注册账号。';
      case 'wrong-password':
      case 'invalid-credential':
        return '密码不正确，请重试。';
      case 'weak-password':
        return '请使用更强的密码。';
      case 'network-request-failed':
        return '网络异常导致认证中断，请稍后再试。';
      case 'too-many-requests':
        return '尝试次数过多，请稍后再试。';
      default:
        return error.message ?? '认证失败，请稍后再试。';
    }
  }
}
