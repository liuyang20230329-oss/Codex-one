import '../domain/account_verification.dart';
import '../domain/app_user.dart';
import '../domain/phone_verification_session.dart';
import '../domain/verification_status.dart';

const String demoSmsCode = '246810';

const List<String> avatarKeys = <String>[
  'aurora',
  'sunset',
  'lagoon',
  'ember',
  'graphite',
];

AppUser buildAccountUser({
  required String id,
  required String name,
  required String email,
  String? avatarKey,
  AccountVerification verification = const AccountVerification(),
}) {
  return AppUser(
    id: id,
    name: name.trim(),
    email: email.trim().toLowerCase(),
    avatarKey: avatarKey ?? defaultAvatarKeyFor(email),
    verification: verification,
  );
}

String defaultAvatarKeyFor(String seed) {
  final normalized = seed.trim();
  if (normalized.isEmpty) {
    return avatarKeys.first;
  }

  final codeUnits = normalized.codeUnits.fold<int>(
    0,
    (sum, unit) => sum + unit,
  );
  return avatarKeys[codeUnits % avatarKeys.length];
}

PhoneVerificationSession createPhoneVerificationSession(String phoneNumber) {
  final normalized = normalizePhoneNumber(phoneNumber);
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  return PhoneVerificationSession(
    sessionId: 'sms-$timestamp',
    phoneNumber: normalized,
    debugCode: demoSmsCode,
    expiresAt: DateTime.now().add(const Duration(minutes: 5)),
  );
}

AccountVerification applyPhoneVerification({
  required AccountVerification current,
  required String phoneNumber,
}) {
  return current.copyWith(
    phoneStatus: VerificationStatus.verified,
    phoneNumber: maskPhoneNumber(phoneNumber),
    phoneVerifiedAt: DateTime.now(),
  );
}

AccountVerification applyIdentityVerification({
  required AccountVerification current,
  required String legalName,
  required String idNumber,
}) {
  return current.copyWith(
    identityStatus: VerificationStatus.verified,
    legalName: legalName.trim(),
    maskedIdNumber: maskIdNumber(idNumber),
    identityVerifiedAt: DateTime.now(),
    faceStatus: VerificationStatus.notStarted,
    clearFaceMatchScore: true,
    clearFaceVerifiedAt: true,
  );
}

AccountVerification applyFaceVerification({
  required AccountVerification current,
}) {
  return current.copyWith(
    faceStatus: VerificationStatus.verified,
    faceMatchScore: 0.984,
    faceVerifiedAt: DateTime.now(),
  );
}

String normalizePhoneNumber(String value) {
  final digits = value.replaceAll(RegExp(r'\D'), '');
  return digits;
}

String maskPhoneNumber(String value) {
  final normalized = normalizePhoneNumber(value);
  if (normalized.length < 7) {
    return normalized;
  }

  return '${normalized.substring(0, 3)}****${normalized.substring(normalized.length - 4)}';
}

String normalizeIdNumber(String value) {
  return value.trim().toUpperCase();
}

String maskIdNumber(String value) {
  final normalized = normalizeIdNumber(value);
  if (normalized.length < 8) {
    return normalized;
  }

  return '${normalized.substring(0, 4)}********${normalized.substring(normalized.length - 4)}';
}
