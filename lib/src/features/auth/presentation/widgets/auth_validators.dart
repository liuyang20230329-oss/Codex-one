class AuthValidators {
  static String? name(String? value) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) {
      return 'Please enter a display name.';
    }
    if (normalized.length < 2) {
      return 'Display name must be at least 2 characters.';
    }
    return null;
  }

  static String? email(String? value) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) {
      return 'Please enter your email.';
    }
    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailPattern.hasMatch(normalized)) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  static String? password(String? value) {
    final normalized = value ?? '';
    if (normalized.isEmpty) {
      return 'Please enter your password.';
    }
    if (normalized.length < 8) {
      return 'Password must be at least 8 characters.';
    }
    return null;
  }

  static String? phoneNumber(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return 'Please enter your phone number.';
    }
    if (digits.length != 11) {
      return 'Phone number must be 11 digits.';
    }
    return null;
  }

  static String? verificationCode(String? value) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) {
      return 'Please enter the verification code.';
    }
    if (normalized.length != 6) {
      return 'Verification code must be 6 digits.';
    }
    return null;
  }

  static String? legalName(String? value) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) {
      return 'Please enter your legal name.';
    }
    if (normalized.length < 2) {
      return 'Legal name must be at least 2 characters.';
    }
    return null;
  }

  static String? idNumber(String? value) {
    final normalized = (value ?? '').trim().toUpperCase();
    final idPattern = RegExp(r'^\d{17}[\dX]$');
    if (normalized.isEmpty) {
      return 'Please enter your ID number.';
    }
    if (!idPattern.hasMatch(normalized)) {
      return 'Please enter a valid 18-digit ID number.';
    }
    return null;
  }

  static String? confirmPassword({
    required String? password,
    required String? confirmPassword,
  }) {
    final validation = AuthValidators.password(confirmPassword);
    if (validation != null) {
      return validation;
    }
    if (password != confirmPassword) {
      return 'Passwords do not match.';
    }
    return null;
  }
}
