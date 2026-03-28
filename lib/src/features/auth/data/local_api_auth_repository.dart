import '../../../core/network/api_client.dart';
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

class LocalApiAuthRepository implements AuthRepository {
  LocalApiAuthRepository({
    required ApiClient client,
    required JsonPreferencesStore store,
  })  : _client = client,
        _store = store {
    final storedToken = _store.readObjectSync(_sessionStoreKey)?['token'] as String?;
    if (storedToken != null && storedToken.isNotEmpty) {
      _client.setToken(storedToken);
    }
    final storedUser = _store.readObjectSync(_sessionStoreKey)?['user'];
    if (storedUser is Map) {
      _currentUser = appUserFromJson(storedUser.cast<String, Object?>());
    }
  }

  static const _sessionStoreKey = 'local_api_auth_session_v1';

  final ApiClient _client;
  final JsonPreferencesStore _store;

  AppUser? _currentUser;
  PhoneVerificationSession? _pendingPhoneSession;

  @override
  AppUser? get currentUser => _currentUser;

  @override
  Future<AppUser> signIn({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final response = await _client.post(
        '/api/v1/auth/login',
        body: <String, Object?>{
          'phoneNumber': normalizePhoneNumber(phoneNumber),
          'password': password,
        },
      );
      return _storeSessionFromResponse(response);
    } on ApiException catch (error) {
      throw AuthException(error.message);
    }
  }

  @override
  Future<AppUser> signUp({
    required String name,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final smsSession = await _client.post(
        '/api/v1/auth/sms/send',
        body: <String, Object?>{
          'phoneNumber': normalizePhoneNumber(phoneNumber),
          'purpose': 'register',
        },
      );
      final debugCode = smsSession['debugCode'] as String? ?? demoSmsCode;
      final response = await _client.post(
        '/api/v1/auth/register',
        body: <String, Object?>{
          'name': name.trim(),
          'phoneNumber': normalizePhoneNumber(phoneNumber),
          'smsCode': debugCode,
          'password': password,
        },
      );
      return _storeSessionFromResponse(response);
    } on ApiException catch (error) {
      throw AuthException(error.message);
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
    try {
      final response = await _client.put(
        '/api/v1/users/me/profile',
        body: <String, Object?>{
          if (name != null) 'name': name,
          if (avatarKey != null) 'avatarKey': avatarKey,
          if (gender != null) 'gender': gender.name,
          if (birthYear != null) 'birthYear': birthYear,
          if (birthMonth != null) 'birthMonth': birthMonth,
          if (city != null) 'city': city,
          if (signature != null) 'signature': signature,
          if (introVideoTitle != null) 'introVideoTitle': introVideoTitle,
          if (introVideoSummary != null)
            'introVideoSummary': introVideoSummary,
          if (works != null) 'works': works.map(profileMediaWorkToJson).toList(),
        },
      );
      final user = _parseUser(response['user'] as Map<String, dynamic>);
      _currentUser = user;
      await _persistSession();
      return user;
    } on ApiException catch (error) {
      throw AuthException(error.message);
    }
  }

  @override
  Future<PhoneVerificationSession> requestPhoneVerification({
    required String phoneNumber,
  }) async {
    try {
      final response = await _client.post(
        '/api/v1/auth/sms/send',
        body: <String, Object?>{
          'phoneNumber': normalizePhoneNumber(phoneNumber),
          'purpose': 'verify-phone',
        },
      );
      final session = PhoneVerificationSession(
        sessionId: response['sessionId'] as String? ??
            'sms-${DateTime.now().millisecondsSinceEpoch}',
        phoneNumber:
            normalizePhoneNumber(response['phoneNumber'] as String? ?? phoneNumber),
        debugCode: response['debugCode'] as String? ?? demoSmsCode,
        expiresAt: DateTime.tryParse(response['expiresAt'] as String? ?? '') ??
            DateTime.now().add(const Duration(minutes: 5)),
      );
      _pendingPhoneSession = session;
      return session;
    } on ApiException catch (error) {
      throw AuthException(error.message);
    }
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

    try {
      final response = await _client.post(
        '/api/v1/auth/phone/confirm',
        body: <String, Object?>{
          'sessionId': sessionId,
          'phoneNumber': session.phoneNumber,
          'code': code.trim(),
        },
      );
      final user = _parseUser(response['user'] as Map<String, dynamic>);
      _currentUser = user;
      _pendingPhoneSession = null;
      await _persistSession();
      return user;
    } on ApiException catch (error) {
      throw AuthException(error.message);
    }
  }

  @override
  Future<AppUser> submitIdentityVerification({
    required String legalName,
    required String idNumber,
  }) async {
    try {
      final response = await _client.post(
        '/api/v1/reviews/identity',
        body: <String, Object?>{
          'legalName': legalName.trim(),
          'idNumber': normalizeIdNumber(idNumber),
        },
      );
      final user = _parseUser(response['user'] as Map<String, dynamic>);
      _currentUser = user;
      await _persistSession();
      return user;
    } on ApiException catch (error) {
      throw AuthException(error.message);
    }
  }

  @override
  Future<AppUser> completeFaceVerification() async {
    try {
      final response = await _client.post('/api/v1/reviews/face');
      final user = _parseUser(response['user'] as Map<String, dynamic>);
      _currentUser = user;
      await _persistSession();
      return user;
    } on ApiException catch (error) {
      throw AuthException(error.message);
    }
  }

  @override
  Future<void> requestPasswordReset({
    required String phoneNumber,
  }) async {
    try {
      await _client.post(
        '/api/v1/auth/password-reset/request',
        body: <String, Object?>{
          'phoneNumber': normalizePhoneNumber(phoneNumber),
        },
      );
    } on ApiException catch (error) {
      throw AuthException(error.message);
    }
  }

  @override
  Future<void> confirmPasswordReset({
    required String phoneNumber,
    required String code,
    required String newPassword,
  }) async {
    try {
      await _client.post(
        '/api/v1/auth/password-reset/confirm',
        body: <String, Object?>{
          'phoneNumber': normalizePhoneNumber(phoneNumber),
          'code': code.trim(),
          'newPassword': newPassword,
        },
      );
    } on ApiException catch (error) {
      throw AuthException(error.message);
    }
  }

  @override
  Future<Never> triggerSocialLogin(SocialLoginProvider provider) async {
    try {
      await _client.post('/api/v1/auth/social/${provider.apiName}');
    } on ApiException catch (error) {
      throw AuthException(error.message);
    }
    throw AuthException('${provider.label}登录待接入，请稍后再试。');
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.post('/api/v1/auth/logout');
    } catch (_) {
      // Keep local sign-out resilient even when the backend is already offline.
    }
    _pendingPhoneSession = null;
    _currentUser = null;
    _client.setToken(null);
    await _store.remove(_sessionStoreKey);
  }

  Future<AppUser> refreshCurrentUser() async {
    try {
      final response = await _client.get('/api/v1/auth/me');
      final user = _parseUser(response['user'] as Map<String, dynamic>);
      _currentUser = user;
      await _persistSession();
      return user;
    } on ApiException catch (error) {
      throw AuthException(error.message);
    }
  }

  AppUser _storeSessionFromResponse(Map<String, dynamic> response) {
    final token = response['token'] as String?;
    if (token == null || token.isEmpty) {
      throw const AuthException('认证服务未返回有效会话。');
    }
    final userPayload = response['user'] as Map<String, dynamic>?;
    if (userPayload == null) {
      throw const AuthException('认证服务未返回用户资料。');
    }
    _client.setToken(token);
    _currentUser = _parseUser(userPayload);
    _persistSession();
    return _currentUser!;
  }

  Future<void> _persistSession() {
    final user = _currentUser;
    final token = _client.token;
    if (user == null || token == null || token.isEmpty) {
      return _store.remove(_sessionStoreKey);
    }
    return _store.writeJson(
      _sessionStoreKey,
      <String, Object?>{
        'token': token,
        'user': appUserToJson(user),
      },
    );
  }

  AppUser _parseUser(Map<String, dynamic> payload) {
    final phoneStatus = _verificationStatusFromName(
      payload['phoneStatus'] as String?,
      fallback: (payload['phoneVerified'] as bool?) == true
          ? VerificationStatus.verified
          : VerificationStatus.notStarted,
    );
    final identityStatus = _verificationStatusFromName(
      payload['identityStatus'] as String?,
      fallback: (payload['identityVerified'] as bool?) == true
          ? VerificationStatus.verified
          : VerificationStatus.notStarted,
    );
    final faceStatus = _verificationStatusFromName(
      payload['faceStatus'] as String?,
      fallback: (payload['faceVerified'] as bool?) == true
          ? VerificationStatus.verified
          : VerificationStatus.notStarted,
    );

    return AppUser(
      id: payload['id'] as String? ?? '',
      name: payload['name'] as String? ?? '新用户',
      email: payload['email'] as String? ??
          syntheticEmailForPhone(payload['phoneNumber'] as String? ?? ''),
      avatarKey: payload['avatarKey'] as String? ??
          defaultAvatarKeyFor(payload['phoneNumber'] as String? ?? ''),
      gender: userGenderFromName(payload['gender'] as String?),
      birthYear: (payload['birthYear'] as num?)?.toInt(),
      birthMonth: (payload['birthMonth'] as num?)?.toInt(),
      city: payload['city'] as String? ?? AppUser.defaultCity,
      signature: payload['signature'] as String? ?? AppUser.defaultSignature,
      introVideoTitle: payload['introVideoTitle'] as String? ??
          AppUser.defaultIntroVideoTitle,
      introVideoSummary: payload['introVideoSummary'] as String? ??
          AppUser.defaultIntroVideoSummary,
      works: ((payload['works'] as List?) ?? const <Object?>[])
          .whereType<Map>()
          .map((item) => profileMediaWorkFromJson(item.cast<String, Object?>()))
          .toList(),
      verification: AccountVerification(
        phoneStatus: phoneStatus,
        identityStatus: identityStatus,
        faceStatus: faceStatus,
        phoneNumber: payload['maskedPhoneNumber'] as String? ??
            payload['phoneNumber'] as String?,
        legalName: payload['legalName'] as String?,
        maskedIdNumber: payload['maskedIdNumber'] as String?,
        faceMatchScore: (payload['faceMatchScore'] as num?)?.toDouble(),
        phoneVerifiedAt:
            DateTime.tryParse(payload['phoneVerifiedAt'] as String? ?? ''),
        identityVerifiedAt:
            DateTime.tryParse(payload['identityVerifiedAt'] as String? ?? ''),
        faceVerifiedAt:
            DateTime.tryParse(payload['faceVerifiedAt'] as String? ?? ''),
      ),
    );
  }

  VerificationStatus _verificationStatusFromName(
    String? name, {
    required VerificationStatus fallback,
  }) {
    return VerificationStatus.values.firstWhere(
      (item) => item.name == name,
      orElse: () => fallback,
    );
  }
}
