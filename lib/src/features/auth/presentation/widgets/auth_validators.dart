class AuthValidators {
  static String? name(String? value) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) {
      return '请输入昵称。';
    }
    if (normalized.length < 2) {
      return '昵称至少需要 2 个字符。';
    }
    return null;
  }

  static String? email(String? value) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) {
      return '请输入邮箱地址。';
    }
    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailPattern.hasMatch(normalized)) {
      return '请输入有效的邮箱地址。';
    }
    return null;
  }

  static String? password(String? value) {
    final normalized = value ?? '';
    if (normalized.isEmpty) {
      return '请输入密码。';
    }
    if (normalized.length < 8) {
      return '密码至少需要 8 位。';
    }
    return null;
  }

  static String? phoneNumber(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return '请输入手机号。';
    }
    if (digits.length != 11) {
      return '手机号必须是 11 位数字。';
    }
    return null;
  }

  static String? verificationCode(String? value) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) {
      return '请输入验证码。';
    }
    if (normalized.length != 6) {
      return '验证码必须是 6 位。';
    }
    return null;
  }

  static String? legalName(String? value) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) {
      return '请输入真实姓名。';
    }
    if (normalized.length < 2) {
      return '真实姓名至少需要 2 个字符。';
    }
    return null;
  }

  static String? idNumber(String? value) {
    final normalized = (value ?? '').trim().toUpperCase();
    final idPattern = RegExp(r'^\d{17}[\dX]$');
    if (normalized.isEmpty) {
      return '请输入身份证号。';
    }
    if (!idPattern.hasMatch(normalized)) {
      return '请输入有效的18位身份证号。';
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
      return '两次输入的密码不一致。';
    }
    return null;
  }
}
