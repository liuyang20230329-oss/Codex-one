import 'dart:async';

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

class DemoAuthRepository implements AuthRepository {
  DemoAuthRepository._({
    required Map<String, _StoredAccount> accounts,
    required JsonPreferencesStore? store,
    AppUser? currentUser,
  })  : _accounts = accounts,
        _store = store,
        _currentUser = currentUser;

  static const _accountsStoreKey = 'demo_auth_accounts_v3';
  static const _currentUserStoreKey = 'demo_auth_current_user_phone_v3';

  static Future<DemoAuthRepository> seeded({
    JsonPreferencesStore? store,
  }) async {
    final accounts = await _loadAccounts(store);
    if (accounts.isEmpty) {
      const demoPhone = '13800138000';
      accounts[demoPhone] = _StoredAccount(
        phoneNumber: demoPhone,
        user: buildAccountUser(
          id: 'demo-user',
          name: '演示用户',
          email: 'demo@codex.one',
          avatarKey: 'aurora',
          gender: UserGender.male,
          birthYear: 1998,
          birthMonth: 9,
          city: '上海',
          signature: '偏爱语音陪伴，也喜欢和真诚的人聊到深夜。',
          introVideoTitle: '30 秒认识我',
          introVideoSummary: '喜欢电影、Livehouse 和周末夜骑，欢迎来找我打招呼。',
          works: const <ProfileMediaWork>[
            ProfileMediaWork(
              id: 'demo-work-1',
              type: ProfileMediaWorkType.voice,
              title: '晚安电台',
              summary: '一段轻松陪伴向的语音作品。',
            ),
            ProfileMediaWork(
              id: 'demo-work-2',
              type: ProfileMediaWorkType.video,
              title: '城市夜拍',
              summary: '用视频记录下班后的城市灯光。',
            ),
          ],
          verification: applyPhoneVerification(
            current: const AccountVerification(),
            phoneNumber: demoPhone,
          ),
        ),
        password: 'Password123!',
      );
      await _persistAccounts(store, accounts);
    }

    final currentPhone = await _loadCurrentUserPhone(store);
    return DemoAuthRepository._(
      accounts: accounts,
      store: store,
      currentUser: currentPhone == null ? null : accounts[currentPhone]?.user,
    );
  }

  final Map<String, _StoredAccount> _accounts;
  final JsonPreferencesStore? _store;
  AppUser? _currentUser;
  PhoneVerificationSession? _pendingPhoneSession;

  @override
  AppUser? get currentUser => _currentUser;

  @override
  Future<AppUser> signIn({
    required String phoneNumber,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final normalizedPhone = normalizePhoneNumber(phoneNumber);
    final account = _accounts[normalizedPhone];
    if (account == null) {
      throw const AuthException('该手机号尚未注册账号。');
    }
    if (account.password != password) {
      throw const AuthException('密码不正确，请重试。');
    }

    _pendingPhoneSession = null;
    _currentUser = account.user;
    await _persistState();
    return _currentUser!;
  }

  @override
  Future<AppUser> signUp({
    required String name,
    required String phoneNumber,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    final normalizedPhone = normalizePhoneNumber(phoneNumber);
    if (_accounts.containsKey(normalizedPhone)) {
      throw const AuthException('该手机号已被注册。');
    }

    final user = buildAccountUser(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.trim(),
      email: syntheticEmailForPhone(normalizedPhone),
      verification: const AccountVerification().copyWith(
        phoneNumber: maskPhoneNumber(normalizedPhone),
      ),
    );
    _accounts[normalizedPhone] = _StoredAccount(
      phoneNumber: normalizedPhone,
      user: user,
      password: password,
    );
    _currentUser = user;
    await _persistState();
    return user;
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
    await Future<void>.delayed(const Duration(milliseconds: 320));
    final user = _requireSignedInUser();
    final nextAvatarKey = avatarKey ?? user.avatarKey;
    final nextVerification = nextAvatarKey == user.avatarKey
        ? user.verification
        : user.verification.copyWith(
            faceStatus: VerificationStatus.notStarted,
            clearFaceMatchScore: true,
            clearFaceVerifiedAt: true,
          );
    final updatedUser = user.copyWith(
      name: name?.trim().isNotEmpty == true ? name!.trim() : user.name,
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
    _storeCurrentUser(updatedUser);
    await _persistState();
    return updatedUser;
  }

  @override
  Future<PhoneVerificationSession> requestPhoneVerification({
    required String phoneNumber,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 280));
    _requireSignedInUser();
    _pendingPhoneSession = createPhoneVerificationSession(phoneNumber);
    return _pendingPhoneSession!;
  }

  @override
  Future<AppUser> confirmPhoneVerification({
    required String sessionId,
    required String code,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 360));
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

    final user = _requireSignedInUser();
    final updatedUser = user.copyWith(
      verification: applyPhoneVerification(
        current: user.verification,
        phoneNumber: session.phoneNumber,
      ),
    );
    _storeCurrentUser(updatedUser);
    _pendingPhoneSession = null;
    await _persistState();
    return updatedUser;
  }

  @override
  Future<AppUser> submitIdentityVerification({
    required String legalName,
    required String idNumber,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 460));
    final normalizedName = legalName.trim();
    final normalizedId = normalizeIdNumber(idNumber);
    if (normalizedName.length < 2) {
      throw const AuthException('请输入真实姓名。');
    }
    if (!RegExp(r'^\d{17}[\dX]$').hasMatch(normalizedId)) {
      throw const AuthException('请输入有效的 18 位身份证号。');
    }

    final user = _requireSignedInUser();
    final updatedUser = user.copyWith(
      verification: applyIdentityVerification(
        current: user.verification,
        legalName: normalizedName,
        idNumber: normalizedId,
      ),
    );
    _storeCurrentUser(updatedUser);
    await _persistState();
    return updatedUser;
  }

  @override
  Future<AppUser> completeFaceVerification() async {
    await Future<void>.delayed(const Duration(milliseconds: 520));
    final user = _requireSignedInUser();
    if (!user.verification.canRunFaceVerification) {
      throw const AuthException('请先完成身份证实名认证，再进行本人认证。');
    }

    final updatedUser = user.copyWith(
      verification: applyFaceVerification(current: user.verification),
    );
    _storeCurrentUser(updatedUser);
    await _persistState();
    return updatedUser;
  }

  @override
  Future<void> requestPasswordReset({
    required String phoneNumber,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final normalizedPhone = normalizePhoneNumber(phoneNumber);
    if (!_accounts.containsKey(normalizedPhone)) {
      throw const AuthException('该手机号尚未注册账号。');
    }
    _pendingPhoneSession = createPhoneVerificationSession(normalizedPhone);
  }

  @override
  Future<void> confirmPasswordReset({
    required String phoneNumber,
    required String code,
    required String newPassword,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 360));
    final normalizedPhone = normalizePhoneNumber(phoneNumber);
    final session = _pendingPhoneSession;
    if (session == null || session.phoneNumber != normalizedPhone) {
      throw const AuthException('请先发送验证码。');
    }
    if (session.isExpired) {
      throw const AuthException('验证码已过期。');
    }
    if (session.debugCode != code.trim()) {
      throw const AuthException('验证码不正确。');
    }
    final account = _accounts[normalizedPhone];
    if (account == null) {
      throw const AuthException('该手机号尚未注册账号。');
    }
    _accounts[normalizedPhone] = account.copyWith(password: newPassword);
    _pendingPhoneSession = null;
    await _persistState();
  }

  @override
  Future<Never> triggerSocialLogin(SocialLoginProvider provider) {
    throw AuthException('${provider.label}登录待接入，请先使用手机号登录。');
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    _pendingPhoneSession = null;
    _currentUser = null;
    await _persistState();
  }

  AppUser _requireSignedInUser() {
    final user = _currentUser;
    if (user == null) {
      throw const AuthException('请先登录后再继续。');
    }
    return user;
  }

  void _storeCurrentUser(AppUser user) {
    final matchingEntry = _accounts.entries
        .where((entry) => entry.value.user.id == user.id)
        .cast<MapEntry<String, _StoredAccount>?>()
        .firstWhere(
          (entry) => entry != null,
          orElse: () => null,
        );
    if (matchingEntry == null) {
      throw const AuthException('未找到对应账号。');
    }
    _accounts[matchingEntry.key] = matchingEntry.value.copyWith(user: user);
    _currentUser = user;
  }

  Future<void> _persistState() async {
    await _persistAccounts(_store, _accounts);
    if (_store == null) {
      return;
    }
    final currentPhone = _accounts.entries
        .where((entry) => entry.value.user.id == _currentUser?.id)
        .cast<MapEntry<String, _StoredAccount>?>()
        .firstWhere(
          (entry) => entry != null,
          orElse: () => null,
        )
        ?.key;
    if (currentPhone == null) {
      await _store.remove(_currentUserStoreKey);
      return;
    }
    await _store.writeJson(_currentUserStoreKey, <String, Object?>{
      'phoneNumber': currentPhone,
    });
  }

  static Future<Map<String, _StoredAccount>> _loadAccounts(
    JsonPreferencesStore? store,
  ) async {
    final storedList = await store?.readList(_accountsStoreKey);
    final accounts = <String, _StoredAccount>{};
    if (storedList == null) {
      return accounts;
    }

    for (final item in storedList) {
      if (item is! Map) {
        continue;
      }
      final map = item.cast<String, Object?>();
      final userMap = (map['user'] as Map?)?.cast<String, Object?>();
      final password = map['password'] as String?;
      final phoneNumber = normalizePhoneNumber(
        map['phoneNumber'] as String? ?? '',
      );
      if (userMap == null || password == null || phoneNumber.isEmpty) {
        continue;
      }
      accounts[phoneNumber] = _StoredAccount(
        phoneNumber: phoneNumber,
        user: appUserFromJson(userMap),
        password: password,
      );
    }
    return accounts;
  }

  static Future<void> _persistAccounts(
    JsonPreferencesStore? store,
    Map<String, _StoredAccount> accounts,
  ) async {
    if (store == null) {
      return;
    }

    await store.writeJson(
      _accountsStoreKey,
      accounts.values
          .map(
            (account) => <String, Object?>{
              'phoneNumber': account.phoneNumber,
              'user': appUserToJson(account.user),
              'password': account.password,
            },
          )
          .toList(),
    );
  }

  static Future<String?> _loadCurrentUserPhone(
    JsonPreferencesStore? store,
  ) async {
    final stored = await store?.readObject(_currentUserStoreKey);
    final phoneNumber = stored?['phoneNumber'] as String?;
    if (phoneNumber == null) {
      return null;
    }
    final normalized = normalizePhoneNumber(phoneNumber);
    return normalized.isEmpty ? null : normalized;
  }
}

class _StoredAccount {
  const _StoredAccount({
    required this.phoneNumber,
    required this.user,
    required this.password,
  });

  final String phoneNumber;
  final AppUser user;
  final String password;

  _StoredAccount copyWith({
    String? phoneNumber,
    AppUser? user,
    String? password,
  }) {
    return _StoredAccount(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      user: user ?? this.user,
      password: password ?? this.password,
    );
  }
}
