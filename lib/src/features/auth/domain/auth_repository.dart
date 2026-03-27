import 'app_user.dart';

abstract class AuthRepository {
  AppUser? get currentUser;

  Future<AppUser> signIn({
    required String email,
    required String password,
  });

  Future<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  });

  Future<void> signOut();
}
