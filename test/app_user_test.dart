import 'package:codex_one/src/features/auth/domain/app_user.dart';
import 'package:codex_one/src/features/auth/domain/profile_media_work.dart';
import 'package:codex_one/src/features/auth/domain/user_gender.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppUser', () {
    test('computes profile completion from key profile sections', () {
      const emptyUser = AppUser(
        id: 'user-1',
        name: 'Liu Yang',
        email: 'liuyang@example.com',
        avatarKey: 'aurora',
      );

      expect(emptyUser.profileCompletion, closeTo(0.2, 0.0001));
      expect(emptyUser.profileCompletionPercent, 20);

      final enrichedUser = emptyUser.copyWith(
        gender: UserGender.female,
        birthYear: 1998,
        birthMonth: 9,
        signature: '认真介绍自己，也认真回应每一次交流。',
        introVideoTitle: '30 秒认识我',
        introVideoSummary: '用一段短视频介绍我自己。',
        works: const <ProfileMediaWork>[
          ProfileMediaWork(
            id: 'work-1',
            type: ProfileMediaWorkType.video,
            title: '城市夜景',
            summary: '一段关于夜晚城市的短片。',
          ),
        ],
      );

      expect(enrichedUser.profileCompletion, closeTo(1.0, 0.0001));
      expect(enrichedUser.profileCompletionPercent, 100);
    });
  });
}
