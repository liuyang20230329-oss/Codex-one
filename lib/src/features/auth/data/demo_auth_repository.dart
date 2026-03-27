import 'dart:async';

import '../domain/app_user.dart';
import '../domain/auth_exception.dart';
import '../domain/auth_repository.dart';

class DemoAuthRepository implements AuthRepository {
  DemoAuthRepository() : _accounts = <String, _StoredAccount>{};

  factory DemoAuthRepository.seeded() {
    final repository = DemoAuthRepository();
    repository._accounts['demo@codex.one'] = const _StoredAccount(
      id: 'demo-user',
      name: 'Codex Demo',
      email: 'demo@codex.one',
      password: 'Password123!',
    );
    return repository;
  }

  final Map<String, _StoredAccount> _accounts;
  AppUser? _currentUser;

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

    _currentUser = account.toUser();
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
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      email: normalizedEmail,
      password: password,
    );
    _accounts[normalizedEmail] = account;
    _currentUser = account.toUser();
    return _currentUser!;
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _currentUser = null;
  }
}

class _StoredAccount {
  const _StoredAccount({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
  });

  final String id;
  final String name;
  final String email;
  final String password;

  AppUser toUser() {
    return AppUser(
      id: id,
      name: name,
      email: email,
    );
  }
}
