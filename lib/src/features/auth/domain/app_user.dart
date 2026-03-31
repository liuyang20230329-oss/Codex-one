import 'account_verification.dart';
import 'profile_media_work.dart';
import 'user_gender.dart';
import 'verification_status.dart';

/// Immutable user aggregate used by the app shell, account center, square,
/// circle, and chat features.
class AppUser {
  static const String defaultCity = '未设置地区';
  static const String defaultSignature = '这个人很酷，还没有留下签名。';
  static const String defaultIntroVideoTitle = '还没有上传视频介绍';
  static const String defaultIntroVideoSummary = '后续可以用一段视频介绍自己，让更多人更快认识你。';

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarKey,
    this.gender = UserGender.undisclosed,
    this.birthYear,
    this.birthMonth,
    this.city = defaultCity,
    this.signature = defaultSignature,
    this.introVideoTitle = defaultIntroVideoTitle,
    this.introVideoSummary = defaultIntroVideoSummary,
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
  bool get canSendPrivateMessages => verification.phoneStatus.isVerified;
  bool get canAppearInRecommendations => verification.faceStatus.isVerified;
  bool get hasCustomSignature => signature.trim() != defaultSignature;
  bool get hasIntroVideo => introVideoTitle.trim() != defaultIntroVideoTitle;

  /// Age is derived from the configured birth year/month so profile editing
  /// only needs to store one canonical birthday payload.
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

  /// Completeness is intentionally weighted toward media and self-introduction,
  /// because those fields matter most for social conversion in this prototype.
  double get profileCompletion {
    var score = 0.0;
    if (avatarKey.trim().isNotEmpty) {
      score += 0.2;
    }
    if (gender != UserGender.undisclosed) {
      score += 0.1;
    }
    if (age != null) {
      score += 0.1;
    }
    if (hasCustomSignature) {
      score += 0.1;
    }
    if (hasIntroVideo) {
      score += 0.2;
    }
    if (works.isNotEmpty) {
      score += 0.3;
    }
    return score.clamp(0.0, 1.0);
  }

  int get profileCompletionPercent => (profileCompletion * 100).round();

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
