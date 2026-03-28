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
        return '未开始';
      case VerificationStatus.pending:
        return '审核中';
      case VerificationStatus.verified:
        return '已认证';
      case VerificationStatus.rejected:
        return '需处理';
    }
  }

  bool get isVerified => this == VerificationStatus.verified;
}
