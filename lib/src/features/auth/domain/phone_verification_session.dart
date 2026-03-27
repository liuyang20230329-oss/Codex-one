class PhoneVerificationSession {
  const PhoneVerificationSession({
    required this.sessionId,
    required this.phoneNumber,
    required this.debugCode,
    required this.expiresAt,
  });

  final String sessionId;
  final String phoneNumber;
  final String debugCode;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
