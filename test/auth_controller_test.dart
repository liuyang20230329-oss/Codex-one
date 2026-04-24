import 'package:codex_one/src/core/persistence/json_preferences_store.dart';
import 'package:codex_one/src/features/auth/data/demo_auth_repository.dart';
import 'package:codex_one/src/features/auth/domain/profile_media_work.dart';
import 'package:codex_one/src/features/auth/domain/user_gender.dart';
import 'package:codex_one/src/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_hive_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthBloc', () {
    late AuthBloc bloc;

    setUp(() async {
      await setUpTestHive();
      bloc = AuthBloc(
        repository: await DemoAuthRepository.seeded(
          store: await JsonPreferencesStore.create(),
        ),
      );
    });

    tearDown(() async {
      await bloc.close();
      await tearDownTestHive();
    });

    test('can sign up, keep the authenticated user, and sign out', () async {
      bloc.add(const AuthSignUpRequested(name: 'Liu Yang', phoneNumber: '13800138011', password: 'Password123!'));
      await bloc.stream.firstWhere((s) => !s.isBusy);

      expect(bloc.state.currentUser?.email, '13800138011@37degrees.local');
      expect(bloc.state.status, AuthStatus.authenticated);

      bloc.add(const AuthSignOutRequested());
      await bloc.stream.firstWhere((s) => !s.isBusy);

      expect(bloc.state.currentUser, isNull);
      expect(bloc.state.status, AuthStatus.unauthenticated);
    });

    test('shows a friendly error when the password is incorrect', () async {
      bloc.add(const AuthSignInRequested(phoneNumber: '13800138000', password: 'wrong-password'));
      await bloc.stream.firstWhere((s) => !s.isBusy);

      expect(bloc.state.currentUser, isNull);
      expect(bloc.state.errorMessage, '密码不正确，请重试。');
    });

    test('persists enriched profile fields and works after update', () async {
      bloc.add(const AuthSignUpRequested(name: 'Profile Owner', phoneNumber: '13800138022', password: 'Password123!'));
      await bloc.stream.firstWhere((s) => !s.isBusy);

      bloc.add(AuthProfileUpdated(
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
      ));
      await bloc.stream.firstWhere((s) => !s.isBusy);

      expect(bloc.state.currentUser?.name, '晚风');
      expect(bloc.state.currentUser?.gender, UserGender.female);
      expect(bloc.state.currentUser?.birthYear, 1999);
      expect(bloc.state.currentUser?.birthMonth, 6);
      expect(bloc.state.currentUser?.city, '杭州');
      expect(bloc.state.currentUser?.signature, '喜欢慢一点的语音聊天，也喜欢分享照片。');
      expect(bloc.state.currentUser?.introVideoTitle, '一分钟认识我');
      expect(bloc.state.currentUser?.works.length, 1);
      expect(bloc.state.currentUser?.works.single.type, ProfileMediaWorkType.voice);
    });
  });
}
