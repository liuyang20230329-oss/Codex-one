import 'account_verification.dart';
import 'profile_media_work.dart';
import 'user_gender.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarKey,
    this.gender = UserGender.undisclosed,
    this.birthYear,
    this.birthMonth,
    this.city = '未设置地区',
    this.signature = '这个人很酷，还没有留下签名。',
    this.introVideoTitle = '还没有上传视频介绍',
    this.introVideoSummary = '后续可以用一段视频介绍自己，让更多人更快认识你。',
    this.works = const <ProfileMediaWork>[],
    this.verification = const AccountVerification(),
  });

  final String id;
  final String name;
  final String email;
  final String avatarKey;
  final UserGender gender;
  final int? birthYear;
  final int? birthMonth;
  final String city;
  final String signature;
  final String introVideoTitle;
  final String introVideoSummary;
  final List<ProfileMediaWork> works;
  final AccountVerification verification;

  int get verificationProgress => verification.verifiedCount;
  bool get isVerificationComplete => verification.verifiedCount == 3;
  int? get age {
    final year = birthYear;
    final month = birthMonth;
    if (year == null || month == null) {
      return null;
    }

    final now = DateTime.now();
    var result = now.year - year;
    if (now.month < month) {
      result -= 1;
    }
    return result;
  }

  String get ageLabel => age == null ? '未设置' : '${age!}岁';
  String get birthLabel {
    final year = birthYear;
    final month = birthMonth;
    if (year == null || month == null) {
      return '未设置';
    }
    return '$year年$month月';
  }

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarKey,
    UserGender? gender,
    int? birthYear,
    int? birthMonth,
    String? city,
    String? signature,
    String? introVideoTitle,
    String? introVideoSummary,
    List<ProfileMediaWork>? works,
    AccountVerification? verification,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarKey: avatarKey ?? this.avatarKey,
      gender: gender ?? this.gender,
      birthYear: birthYear ?? this.birthYear,
      birthMonth: birthMonth ?? this.birthMonth,
      city: city ?? this.city,
      signature: signature ?? this.signature,
      introVideoTitle: introVideoTitle ?? this.introVideoTitle,
      introVideoSummary: introVideoSummary ?? this.introVideoSummary,
      works: works ?? this.works,
      verification: verification ?? this.verification,
    );
  }
}
