enum UserGender {
  female,
  male,
  nonBinary,
  undisclosed,
}

extension UserGenderX on UserGender {
  String get label {
    switch (this) {
      case UserGender.female:
        return '女';
      case UserGender.male:
        return '男';
      case UserGender.nonBinary:
        return '多元';
      case UserGender.undisclosed:
        return '未设置';
    }
  }
}

UserGender userGenderFromName(String? value) {
  return UserGender.values.firstWhere(
    (gender) => gender.name == value,
    orElse: () => UserGender.undisclosed,
  );
}
