import 'verification_status.dart';

class AccountVerification {
  const AccountVerification({
    this.phoneStatus = VerificationStatus.notStarted,
    this.identityStatus = VerificationStatus.notStarted,
    this.faceStatus = VerificationStatus.notStarted,
    this.phoneNumber,
    this.legalName,
    this.maskedIdNumber,
    this.faceMatchScore,
    this.phoneVerifiedAt,
    this.identityVerifiedAt,
    this.faceVerifiedAt,
  });

  final VerificationStatus phoneStatus;
  final VerificationStatus identityStatus;
  final VerificationStatus faceStatus;
  final String? phoneNumber;
  final String? legalName;
  final String? maskedIdNumber;
  final double? faceMatchScore;
  final DateTime? phoneVerifiedAt;
  final DateTime? identityVerifiedAt;
  final DateTime? faceVerifiedAt;

  int get verifiedCount {
    return <VerificationStatus>[
      phoneStatus,
      identityStatus,
      faceStatus,
    ].where((status) => status.isVerified).length;
  }

  double get completion => verifiedCount / 3;
  bool get canRunFaceVerification => identityStatus.isVerified;

  AccountVerification copyWith({
    VerificationStatus? phoneStatus,
    VerificationStatus? identityStatus,
    VerificationStatus? faceStatus,
    String? phoneNumber,
    String? legalName,
    String? maskedIdNumber,
    double? faceMatchScore,
    DateTime? phoneVerifiedAt,
    DateTime? identityVerifiedAt,
    DateTime? faceVerifiedAt,
    bool clearPhoneNumber = false,
    bool clearLegalName = false,
    bool clearMaskedIdNumber = false,
    bool clearFaceMatchScore = false,
    bool clearPhoneVerifiedAt = false,
    bool clearIdentityVerifiedAt = false,
    bool clearFaceVerifiedAt = false,
  }) {
    return AccountVerification(
      phoneStatus: phoneStatus ?? this.phoneStatus,
      identityStatus: identityStatus ?? this.identityStatus,
      faceStatus: faceStatus ?? this.faceStatus,
      phoneNumber: clearPhoneNumber ? null : (phoneNumber ?? this.phoneNumber),
      legalName: clearLegalName ? null : (legalName ?? this.legalName),
      maskedIdNumber: clearMaskedIdNumber
          ? null
          : (maskedIdNumber ?? this.maskedIdNumber),
      faceMatchScore: clearFaceMatchScore
          ? null
          : (faceMatchScore ?? this.faceMatchScore),
      phoneVerifiedAt: clearPhoneVerifiedAt
          ? null
          : (phoneVerifiedAt ?? this.phoneVerifiedAt),
      identityVerifiedAt: clearIdentityVerifiedAt
          ? null
          : (identityVerifiedAt ?? this.identityVerifiedAt),
      faceVerifiedAt: clearFaceVerifiedAt
          ? null
          : (faceVerifiedAt ?? this.faceVerifiedAt),
    );
  }
}
