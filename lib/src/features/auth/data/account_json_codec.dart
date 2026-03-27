import '../domain/account_verification.dart';
import '../domain/app_user.dart';
import '../domain/verification_status.dart';

Map<String, Object?> appUserToJson(AppUser user) {
  return <String, Object?>{
    'id': user.id,
    'name': user.name,
    'email': user.email,
    'avatarKey': user.avatarKey,
    'verification': verificationToJson(user.verification),
  };
}

AppUser appUserFromJson(Map<String, Object?> json) {
  return AppUser(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    email: json['email'] as String? ?? '',
    avatarKey: json['avatarKey'] as String? ?? 'aurora',
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
