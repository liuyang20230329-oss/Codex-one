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
