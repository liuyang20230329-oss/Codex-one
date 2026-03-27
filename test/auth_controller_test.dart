import 'package:codex_one/src/features/auth/data/demo_auth_repository.dart';
import 'package:codex_one/src/features/auth/presentation/auth_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthController', () {
    test('can sign up, keep the authenticated user, and sign out', () async {
      final controller = AuthController(
        repository: DemoAuthRepository.seeded(),
      );

      await controller.signUp(
        name: 'Liu Yang',
        email: 'liuyang@example.com',
        password: 'Password123!',
      );

      expect(controller.currentUser?.email, 'liuyang@example.com');
      expect(controller.status, AuthStatus.authenticated);

      await controller.signOut();

      expect(controller.currentUser, isNull);
      expect(controller.status, AuthStatus.unauthenticated);
    });

    test('shows a friendly error when the password is incorrect', () async {
      final controller = AuthController(
        repository: DemoAuthRepository.seeded(),
      );

      await controller.signIn(
        email: 'demo@codex.one',
        password: 'wrong-password',
      );

      expect(controller.currentUser, isNull);
      expect(
        controller.errorMessage,
        'The password is incorrect. Please try again.',
      );
    });
  });
}
