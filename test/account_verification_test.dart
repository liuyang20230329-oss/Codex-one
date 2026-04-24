import 'package:codex_one/src/core/persistence/json_preferences_store.dart';
import 'package:codex_one/src/features/auth/data/demo_auth_repository.dart';
import 'package:codex_one/src/features/auth/domain/verification_status.dart';
import 'package:codex_one/src/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_hive_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Account verification flow', () {
    late AuthBloc bloc;

    Future<void> createBloc() async {
      await setUpTestHive();
      bloc = AuthBloc(
        repository: await DemoAuthRepository.seeded(
          store: await JsonPreferencesStore.create(),
        ),
      );
    }

    tearDown(() async {
      await bloc.close();
      await tearDownTestHive();
    });

    test('can verify phone with the demo code', () async {
      await createBloc();
      bloc.add(const AuthSignUpRequested(name: 'Liu Yang', phoneNumber: '13800138031', password: 'Password123!'));
      await bloc.stream.firstWhere((s) => !s.isBusy);
      bloc.add(const AuthPhoneVerificationRequested(phoneNumber: '13800138000'));
      await bloc.stream.firstWhere((s) => !s.isBusy);
      final session = bloc.state.pendingPhoneSession;
      expect(session, isNotNull);
      bloc.add(AuthPhoneVerificationConfirmed(code: session!.debugCode));
      await bloc.stream.firstWhere((s) => !s.isBusy);
      expect(bloc.state.currentUser?.verification.phoneStatus, VerificationStatus.verified);
      expect(bloc.state.currentUser?.verification.phoneNumber, '138****8000');
    });

    test('requires identity verification before face verification', () async {
      await createBloc();
      bloc.add(const AuthSignInRequested(phoneNumber: '13800138000', password: 'Password123!'));
      await bloc.stream.firstWhere((s) => !s.isBusy);
      bloc.add(const AuthFaceVerificationCompleted());
      await bloc.stream.firstWhere((s) => !s.isBusy);
      expect(bloc.state.errorMessage, '请先完成身份证实名认证，再进行本人认证。');
      expect(bloc.state.currentUser?.verification.faceStatus, VerificationStatus.notStarted);
    });

    test('identity plus face verification completes the trust flow', () async {
      await createBloc();
      bloc.add(const AuthSignInRequested(phoneNumber: '13800138000', password: 'Password123!'));
      await bloc.stream.firstWhere((s) => !s.isBusy);
      bloc.add(const AuthIdentityVerificationSubmitted(legalName: 'Liu Yang', idNumber: '110105199001018211'));
      await bloc.stream.firstWhere((s) => !s.isBusy);
      bloc.add(const AuthFaceVerificationCompleted());
      await bloc.stream.firstWhere((s) => !s.isBusy);
      expect(bloc.state.currentUser?.verification.identityStatus, VerificationStatus.verified);
      expect(bloc.state.currentUser?.verification.faceStatus, VerificationStatus.verified);
      expect(bloc.state.currentUser?.verification.faceMatchScore, closeTo(0.984, 0.0001));
    });

    test('changing the avatar resets face verification', () async {
      await createBloc();
      bloc.add(const AuthSignInRequested(phoneNumber: '13800138000', password: 'Password123!'));
      await bloc.stream.firstWhere((s) => !s.isBusy);
      bloc.add(const AuthIdentityVerificationSubmitted(legalName: 'Liu Yang', idNumber: '110105199001018211'));
      await bloc.stream.firstWhere((s) => !s.isBusy);
      bloc.add(const AuthFaceVerificationCompleted());
      await bloc.stream.firstWhere((s) => !s.isBusy);
      bloc.add(const AuthProfileUpdated(name: 'Liu Yang', avatarKey: 'ember'));
      await bloc.stream.firstWhere((s) => !s.isBusy);
      expect(bloc.state.currentUser?.verification.faceStatus, VerificationStatus.notStarted);
      expect(bloc.state.currentUser?.verification.faceMatchScore, isNull);
    });

    test('persists demo account progress across repository recreation', () async {
      await createBloc();
      bloc.add(const AuthSignUpRequested(name: 'Persistent User', phoneNumber: '13800138041', password: 'Password123!'));
      await bloc.stream.firstWhere((s) => !s.isBusy);
      bloc.add(const AuthPhoneVerificationRequested(phoneNumber: '13800138000'));
      await bloc.stream.firstWhere((s) => !s.isBusy);
      final session = bloc.state.pendingPhoneSession;
      bloc.add(AuthPhoneVerificationConfirmed(code: session!.debugCode));
      await bloc.stream.firstWhere((s) => !s.isBusy);
      await bloc.close();
      final restoredBloc = AuthBloc(
        repository: await DemoAuthRepository.seeded(
          store: await JsonPreferencesStore.create(),
        ),
      );
      expect(restoredBloc.state.currentUser?.email, '13800138041@37degrees.local');
      expect(restoredBloc.state.currentUser?.verification.phoneStatus, VerificationStatus.verified);
      await restoredBloc.close();
    });
  });
}
