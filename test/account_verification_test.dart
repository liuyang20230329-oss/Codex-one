import 'package:codex_one/src/features/auth/data/demo_auth_repository.dart';
import 'package:codex_one/src/features/auth/domain/verification_status.dart';
import 'package:codex_one/src/features/auth/presentation/auth_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Account verification flow', () {
    test('can verify phone with the demo code', () async {
      final controller = AuthController(
        repository: DemoAuthRepository.seeded(),
      );

      await controller.signUp(
        name: 'Liu Yang',
        email: 'liuyang@example.com',
        password: 'Password123!',
      );

      final session = await controller.requestPhoneVerification(
        phoneNumber: '13800138000',
      );

      expect(session, isNotNull);

      final success = await controller.confirmPhoneVerification(
        code: session!.debugCode,
      );

      expect(success, isTrue);
      expect(
        controller.currentUser?.verification.phoneStatus,
        VerificationStatus.verified,
      );
      expect(
        controller.currentUser?.verification.phoneNumber,
        '138****8000',
      );
    });

    test('requires identity verification before face verification', () async {
      final controller = AuthController(
        repository: DemoAuthRepository.seeded(),
      );

      await controller.signIn(
        email: 'demo@codex.one',
        password: 'Password123!',
      );

      final success = await controller.completeFaceVerification();

      expect(success, isFalse);
      expect(
        controller.errorMessage,
        'Complete identity verification before face verification.',
      );
      expect(
        controller.currentUser?.verification.faceStatus,
        VerificationStatus.notStarted,
      );
    });

    test('identity plus face verification completes the trust flow', () async {
      final controller = AuthController(
        repository: DemoAuthRepository.seeded(),
      );

      await controller.signIn(
        email: 'demo@codex.one',
        password: 'Password123!',
      );

      final idSuccess = await controller.submitIdentityVerification(
        legalName: 'Liu Yang',
        idNumber: '110105199001018211',
      );
      final faceSuccess = await controller.completeFaceVerification();

      expect(idSuccess, isTrue);
      expect(faceSuccess, isTrue);
      expect(
        controller.currentUser?.verification.identityStatus,
        VerificationStatus.verified,
      );
      expect(
        controller.currentUser?.verification.faceStatus,
        VerificationStatus.verified,
      );
      expect(
        controller.currentUser?.verification.faceMatchScore,
        closeTo(0.984, 0.0001),
      );
    });

    test('changing the avatar resets face verification', () async {
      final controller = AuthController(
        repository: DemoAuthRepository.seeded(),
      );

      await controller.signIn(
        email: 'demo@codex.one',
        password: 'Password123!',
      );
      await controller.submitIdentityVerification(
        legalName: 'Liu Yang',
        idNumber: '110105199001018211',
      );
      await controller.completeFaceVerification();

      final updated = await controller.updateProfile(
        name: 'Liu Yang',
        avatarKey: 'ember',
      );

      expect(updated, isTrue);
      expect(
        controller.currentUser?.verification.faceStatus,
        VerificationStatus.notStarted,
      );
      expect(controller.currentUser?.verification.faceMatchScore, isNull);
    });
  });
}
