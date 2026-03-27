import 'dart:async';

import 'account_flow_helpers.dart';
import 'account_json_codec.dart';
import '../domain/app_user.dart';
import '../domain/auth_exception.dart';
import '../domain/auth_repository.dart';
import '../domain/phone_verification_session.dart';
import '../domain/verification_status.dart';
import '../../../core/persistence/json_preferences_store.dart';

class DemoAuthRepository implements AuthRepository {
  DemoAuthRepository._({
    required Map<String, _StoredAccount> accounts,
    AppUser? currentUser,
    JsonPreferencesStore? store,
  })  : _accounts = accounts,
        _currentUser = currentUser,
        _store = store;

  static const _accountsStoreKey = 'demo_auth_accounts_v2';
  static const _currentUserStoreKey = 'demo_auth_current_user_email_v2';

  static Future<DemoAuthRepository> seeded({
    JsonPreferencesStore? store,
  }) async {
    final accounts = await _loadAccounts(store);
    if (accounts.isEmpty) {
      accounts['demo@codex.one'] = _StoredAccount(
        user: buildAccountUser(
          id: 'demo-user',
          name: 'Codex Demo',
          email: 'demo@codex.one',
          avatarKey: 'aurora',
        ),
        password: 'Password123!',
      );
      await _persistAccounts(store, accounts);
    }

    final currentUserEmail = await _loadCurrentUserEmail(store);
    final currentUser = currentUserEmail == null
        ? null
        : accounts[currentUserEmail]?.user;

    return DemoAuthRepository._(
      accounts: accounts,
      currentUser: currentUser,
      store: store,
    );
  }

  final Map<String, _StoredAccount> _accounts;
  AppUser? _currentUser;
  PhoneVerificationSession? _pendingPhoneSession;
  final JsonPreferencesStore? _store;

  @override
  AppUser? get currentUser => _currentUser;

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 650));

    final normalizedEmail = email.trim().toLowerCase();
    final account = _accounts[normalizedEmail];
    if (account == null) {
      throw const AuthException('No account was found for this email.');
    }
    if (account.password != password) {
      throw const AuthException('The password is incorrect. Please try again.');
    }

    _pendingPhoneSession = null;
    _currentUser = account.user;
    await _persistState();
    return _currentUser!;
  }

  @override
  Future<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 850));

    final normalizedEmail = email.trim().toLowerCase();
    if (_accounts.containsKey(normalizedEmail)) {
      throw const AuthException('This email is already registered.');
    }

    final account = _StoredAccount(
      user: buildAccountUser(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name.trim(),
        email: normalizedEmail,
      ),
      password: password,
    );
    _accounts[normalizedEmail] = account;
    _currentUser = account.user;
    await _persistState();
    return _currentUser!;
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _pendingPhoneSession = null;
    _currentUser = null;
    await _persistState();
  }

  @override
  Future<AppUser> updateProfile({
    required String name,
    required String avatarKey,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 320));
    final user = _requireSignedInUser();
    final verification = user.avatarKey == avatarKey
        ? user.verification
        : user.verification.copyWith(
            faceStatus: VerificationStatus.notStarted,
            clearFaceMatchScore: true,
            clearFaceVerifiedAt: true,
          );
    final updatedUser = user.copyWith(
      name: name.trim(),
      avatarKey: avatarKey,
      verification: verification,
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
      throw const AuthException('Start phone verification first.');
    }
    if (session.isExpired) {
      throw const AuthException('This verification code has expired.');
    }
    if (code.trim() != session.debugCode) {
      throw const AuthException('The verification code is incorrect.');
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
    await Future<void>.delayed(const Duration(milliseconds: 480));
    _requireSignedInUser();
    final normalizedName = legalName.trim();
    final normalizedId = normalizeIdNumber(idNumber);
    if (normalizedName.length < 2) {
      throw const AuthException('Please enter your legal name.');
    }
    final idPattern = RegExp(r'^\d{17}[\dX]$');
    if (!idPattern.hasMatch(normalizedId)) {
      throw const AuthException('Please enter a valid 18-digit ID number.');
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
      throw const AuthException(
        'Complete identity verification before face verification.',
      );
    }

    final updatedUser = user.copyWith(
      verification: applyFaceVerification(
        current: user.verification,
      ),
    );
    _storeCurrentUser(updatedUser);
    await _persistState();
    return updatedUser;
  }

  AppUser _requireSignedInUser() {
    final user = _currentUser;
    if (user == null) {
      throw const AuthException('Please sign in to continue.');
    }
    return user;
  }

  void _storeCurrentUser(AppUser user) {
    final key = user.email.trim().toLowerCase();
    final account = _accounts[key];
    if (account == null) {
      throw const AuthException('This account could not be found.');
    }

    _accounts[key] = account.copyWith(user: user);
    _currentUser = user;
  }

  Future<void> _persistState() async {
    await _persistAccounts(_store, _accounts);
    final currentEmail = _currentUser?.email.trim().toLowerCase();
    if (_store == null) {
      return;
    }
    if (currentEmail == null) {
      await _store.remove(_currentUserStoreKey);
      return;
    }
    await _store.writeJson(_currentUserStoreKey, <String, Object?>{
      'email': currentEmail,
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
      if (userMap == null || password == null) {
        continue;
      }

      final user = appUserFromJson(userMap);
      accounts[user.email.trim().toLowerCase()] = _StoredAccount(
        user: user,
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

    final payload = accounts.values.map((account) {
      return <String, Object?>{
        'user': appUserToJson(account.user),
        'password': account.password,
      };
    }).toList();
    await store.writeJson(_accountsStoreKey, payload);
  }

  static Future<String?> _loadCurrentUserEmail(
    JsonPreferencesStore? store,
  ) async {
    final stored = await store?.readObject(_currentUserStoreKey);
    final email = stored?['email'] as String?;
    return email?.trim().toLowerCase();
  }
}

class _StoredAccount {
  const _StoredAccount({
    required this.user,
    required this.password,
  });

  final AppUser user;
  final String password;

  _StoredAccount copyWith({
    AppUser? user,
    String? password,
  }) {
    return _StoredAccount(
      user: user ?? this.user,
      password: password ?? this.password,
    );
  }
}
