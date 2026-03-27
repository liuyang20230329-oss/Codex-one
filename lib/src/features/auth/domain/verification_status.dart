enum VerificationStatus {
  notStarted,
  pending,
  verified,
  rejected,
}

extension VerificationStatusX on VerificationStatus {
  String get label {
    switch (this) {
      case VerificationStatus.notStarted:
        return 'Not started';
      case VerificationStatus.pending:
        return 'Pending review';
      case VerificationStatus.verified:
        return 'Verified';
      case VerificationStatus.rejected:
        return 'Needs attention';
    }
  }

  bool get isVerified => this == VerificationStatus.verified;
}
