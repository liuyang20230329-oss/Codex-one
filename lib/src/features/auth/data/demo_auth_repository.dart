import 'dart:async';

import 'account_flow_helpers.dart';
import '../domain/app_user.dart';
import '../domain/auth_exception.dart';
import '../domain/auth_repository.dart';
import '../domain/phone_verification_session.dart';
import '../domain/verification_status.dart';

class DemoAuthRepository implements AuthRepository {
  DemoAuthRepository() : _accounts = <String, _StoredAccount>{};

  factory DemoAuthRepository.seeded() {
    final repository = DemoAuthRepository();
    repository._accounts['demo@codex.one'] = _StoredAccount(
      user: buildAccountUser(
        id: 'demo-user',
        name: 'Codex Demo',
        email: 'demo@codex.one',
        avatarKey: 'aurora',
      ),
      password: 'Password123!',
    );
    return repository;
  }

  final Map<String, _StoredAccount> _accounts;
  AppUser? _currentUser;
  PhoneVerificationSession? _pendingPhoneSession;

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
    return _currentUser!;
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _pendingPhoneSession = null;
    _currentUser = null;
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
