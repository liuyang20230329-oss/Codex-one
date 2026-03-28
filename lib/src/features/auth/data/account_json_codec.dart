import '../domain/account_verification.dart';
import '../domain/app_user.dart';
import '../domain/profile_media_work.dart';
import '../domain/user_gender.dart';
import '../domain/verification_status.dart';

Map<String, Object?> appUserToJson(AppUser user) {
  return <String, Object?>{
    'id': user.id,
    'name': user.name,
    'email': user.email,
    'avatarKey': user.avatarKey,
    'gender': user.gender.name,
    'birthYear': user.birthYear,
    'birthMonth': user.birthMonth,
    'city': user.city,
    'signature': user.signature,
    'introVideoTitle': user.introVideoTitle,
    'introVideoSummary': user.introVideoSummary,
    'works': user.works.map(profileMediaWorkToJson).toList(),
    'verification': verificationToJson(user.verification),
  };
}

AppUser appUserFromJson(Map<String, Object?> json) {
  return AppUser(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    email: json['email'] as String? ?? '',
    avatarKey: json['avatarKey'] as String? ?? 'aurora',
    gender: userGenderFromName(json['gender'] as String?),
    birthYear: (json['birthYear'] as num?)?.toInt(),
    birthMonth: (json['birthMonth'] as num?)?.toInt(),
    city: json['city'] as String? ?? '未设置地区',
    signature: json['signature'] as String? ?? '这个人很酷，还没有留下签名。',
    introVideoTitle: json['introVideoTitle'] as String? ?? '还没有上传视频介绍',
    introVideoSummary:
        json['introVideoSummary'] as String? ?? '后续可以用一段视频介绍自己，让更多人更快认识你。',
    works: ((json['works'] as List?) ?? const <Object?>[])
        .whereType<Map>()
        .map((item) => profileMediaWorkFromJson(item.cast<String, Object?>()))
        .toList(),
    verification: verificationFromJson(
      (json['verification'] as Map?)?.cast<String, Object?>() ??
          const <String, Object?>{},
    ),
  );
}

Map<String, Object?> verificationToJson(AccountVerification verification) {
  return <String, Object?>{
    'phoneStatus': verification.phoneStatus.name,
    'identityStatus': verification.identityStatus.name,
    'faceStatus': verification.faceStatus.name,
    'phoneNumber': verification.phoneNumber,
    'legalName': verification.legalName,
    'maskedIdNumber': verification.maskedIdNumber,
    'faceMatchScore': verification.faceMatchScore,
    'phoneVerifiedAt': verification.phoneVerifiedAt?.toIso8601String(),
    'identityVerifiedAt': verification.identityVerifiedAt?.toIso8601String(),
    'faceVerifiedAt': verification.faceVerifiedAt?.toIso8601String(),
  };
}

AccountVerification verificationFromJson(Map<String, Object?> json) {
  return AccountVerification(
    phoneStatus: _statusFromName(json['phoneStatus'] as String?),
    identityStatus: _statusFromName(json['identityStatus'] as String?),
    faceStatus: _statusFromName(json['faceStatus'] as String?),
    phoneNumber: json['phoneNumber'] as String?,
    legalName: json['legalName'] as String?,
    maskedIdNumber: json['maskedIdNumber'] as String?,
    faceMatchScore: (json['faceMatchScore'] as num?)?.toDouble(),
    phoneVerifiedAt: _dateTimeFromString(json['phoneVerifiedAt'] as String?),
    identityVerifiedAt:
        _dateTimeFromString(json['identityVerifiedAt'] as String?),
    faceVerifiedAt: _dateTimeFromString(json['faceVerifiedAt'] as String?),
  );
}

DateTime? _dateTimeFromString(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  return DateTime.tryParse(value);
}

VerificationStatus _statusFromName(String? value) {
  return VerificationStatus.values.firstWhere(
    (status) => status.name == value,
    orElse: () => VerificationStatus.notStarted,
  );
}

Map<String, Object?> profileMediaWorkToJson(ProfileMediaWork work) {
  return <String, Object?>{
    'id': work.id,
    'type': work.type.name,
    'title': work.title,
    'summary': work.summary,
  };
}

ProfileMediaWork profileMediaWorkFromJson(Map<String, Object?> json) {
  return ProfileMediaWork(
    id: json['id'] as String? ?? '',
    type: profileMediaWorkTypeFromName(json['type'] as String?),
    title: json['title'] as String? ?? '',
    summary: json['summary'] as String? ?? '',
  );
}
