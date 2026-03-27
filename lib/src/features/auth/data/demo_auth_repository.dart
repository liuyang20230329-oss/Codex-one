import 'dart:async';

import '../domain/app_user.dart';
import '../domain/auth_exception.dart';
import '../domain/auth_repository.dart';

class DemoAuthRepository implements AuthRepository {
  DemoAuthRepository({
    Map<String, _StoredAccount>? accounts,
  }) : _accounts = accounts ?? <String, _StoredAccount>{};

  factory DemoAuthRepository.seeded() {
    return DemoAuthRepository(
      accounts: <String, _StoredAccount>{
        'demo@codex.one': const _StoredAccount(
          id: 'demo-user',
          name: 'Codex Demo',
          email: 'demo@codex.one',
          password: 'Password123!',
        ),
      },
    );
  }

  final Map<String, _StoredAccount> _accounts;

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 650));

    final normalizedEmail = email.trim().toLowerCase();
    final account = _accounts[normalizedEmail];
    if (account == null) {
      throw const AuthException('这个邮箱还没有注册。');
    }
    if (account.password != password) {
      throw const AuthException('密码不正确，请重试。');
    }

    return account.toUser();
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
      throw const AuthException('这个邮箱已经注册过了。');
    }

    final account = _StoredAccount(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      email: normalizedEmail,
      password: password,
    );
    _accounts[normalizedEmail] = account;
    return account.toUser();
  }

  @override
  Future<void> signOut() {
    return Future<void>.delayed(const Duration(milliseconds: 250));
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
