import 'package:firebase_auth/firebase_auth.dart';

import '../domain/app_user.dart';
import '../domain/auth_exception.dart';
import '../domain/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    required FirebaseAuth auth,
  }) : _auth = auth;

  final FirebaseAuth _auth;

  @override
  AppUser? get currentUser => _mapUser(_auth.currentUser);

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

      return _mapUser(user)!;
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
      return _mapUser(refreshedUser)!;
    } on FirebaseAuthException catch (error) {
      throw AuthException(_messageFor(error));
    }
  }

  @override
  Future<void> signOut() {
    return _auth.signOut();
  }

  AppUser? _mapUser(User? user) {
    if (user == null) {
      return null;
    }

    final displayName = user.displayName?.trim();
    return AppUser(
      id: user.uid,
      name: displayName == null || displayName.isEmpty
          ? _fallbackDisplayName(user)
          : displayName,
      email: user.email ?? '',
    );
  }

  String _fallbackDisplayName(User user) {
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
