import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/persistence/json_preferences_store.dart';
import 'account_flow_helpers.dart';
import 'account_json_codec.dart';
import '../domain/account_verification.dart';
import '../domain/app_user.dart';
import '../domain/auth_exception.dart';
import '../domain/auth_repository.dart';
import '../domain/phone_verification_session.dart';
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
        throw const AuthException('Firebase did not return a user.');
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
        throw const AuthException('Firebase did not return a user.');
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
    required String name,
    required String avatarKey,
  }) async {
    final user = _requireCurrentUser();
    if (_auth.currentUser != null && name.trim().isNotEmpty) {
      await _auth.currentUser!.updateDisplayName(name.trim());
      await _auth.currentUser!.reload();
    }

    final verification = user.avatarKey == avatarKey
        ? user.verification
        : user.verification.copyWith(
            faceStatus: VerificationStatus.notStarted,
            clearFaceMatchScore: true,
            clearFaceVerifiedAt: true,
          );
    _currentUser = user.copyWith(
      name: name.trim(),
      avatarKey: avatarKey,
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
      throw const AuthException('Start phone verification first.');
    }
    if (session.isExpired) {
      throw const AuthException('This verification code has expired.');
    }
    if (code.trim() != session.debugCode) {
      throw const AuthException('The verification code is incorrect.');
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
      throw const AuthException('Please enter your legal name.');
    }

    final idPattern = RegExp(r'^\d{17}[\dX]$');
    if (!idPattern.hasMatch(normalizedId)) {
      throw const AuthException('Please enter a valid 18-digit ID number.');
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
        'Complete identity verification before face verification.',
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
      throw const AuthException('Please sign in to continue.');
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
      verification: previousMatches
          ? previousUser.verification
          : const AccountVerification(),
    );
  }

  static String _fallbackDisplayName(User user) {
    final email = user.email;
    if (email == null || !email.contains('@')) {
      return 'New user';
    }

    return email.split('@').first;
  }

  String _messageFor(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'operation-not-allowed':
        return 'Email and password sign-in is not enabled in Firebase yet.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account was found for this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'The password is incorrect. Please try again.';
      case 'weak-password':
        return 'Please use a stronger password.';
      case 'network-request-failed':
        return 'A network error interrupted authentication. Please try again.';
      case 'too-many-requests':
        return 'Too many attempts were made. Please wait and try again.';
      default:
        return error.message ?? 'Authentication failed. Please try again.';
    }
  }
}
