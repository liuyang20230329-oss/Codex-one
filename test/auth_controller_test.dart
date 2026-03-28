import 'package:codex_one/src/core/persistence/json_preferences_store.dart';
import 'package:codex_one/src/features/auth/data/demo_auth_repository.dart';
import 'package:codex_one/src/features/auth/domain/profile_media_work.dart';
import 'package:codex_one/src/features/auth/domain/user_gender.dart';
import 'package:codex_one/src/features/auth/presentation/auth_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthController', () {
    test('can sign up, keep the authenticated user, and sign out', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final controller = AuthController(
        repository: await DemoAuthRepository.seeded(
          store: await JsonPreferencesStore.create(),
        ),
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
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final controller = AuthController(
        repository: await DemoAuthRepository.seeded(
          store: await JsonPreferencesStore.create(),
        ),
      );

      await controller.signIn(
        email: 'demo@codex.one',
        password: 'wrong-password',
      );

      expect(controller.currentUser, isNull);
      expect(
        controller.errorMessage,
        '密码不正确，请重试。',
      );
    });

    test('persists enriched profile fields and works after update', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final controller = AuthController(
        repository: await DemoAuthRepository.seeded(
          store: await JsonPreferencesStore.create(),
        ),
      );

      await controller.signUp(
        name: 'Profile Owner',
        email: 'profile-owner@example.com',
        password: 'Password123!',
      );

      final updated = await controller.updateProfile(
        name: '晚风',
        avatarKey: 'lagoon',
        gender: UserGender.female,
        birthYear: 1999,
        birthMonth: 6,
        city: '杭州',
        signature: '喜欢慢一点的语音聊天，也喜欢分享照片。',
        introVideoTitle: '一分钟认识我',
        introVideoSummary: '周末会去拍照，也会做一点旅行短视频。',
        works: const <ProfileMediaWork>[
          ProfileMediaWork(
            id: 'work-1',
            type: ProfileMediaWorkType.voice,
            title: '深夜电台',
            summary: '一段适合夜里慢慢听完的语音作品。',
          ),
        ],
      );

      expect(updated, isTrue);

      final restoredController = AuthController(
        repository: await DemoAuthRepository.seeded(
          store: await JsonPreferencesStore.create(),
        ),
      );

      final restoredUser = restoredController.currentUser;
      expect(restoredUser?.name, '晚风');
      expect(restoredUser?.gender, UserGender.female);
      expect(restoredUser?.birthYear, 1999);
      expect(restoredUser?.birthMonth, 6);
      expect(restoredUser?.city, '杭州');
      expect(restoredUser?.signature, '喜欢慢一点的语音聊天，也喜欢分享照片。');
      expect(restoredUser?.introVideoTitle, '一分钟认识我');
      expect(restoredUser?.works.length, 1);
      expect(
        restoredUser?.works.single.type,
        ProfileMediaWorkType.voice,
      );
    });
  });
}
