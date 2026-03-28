enum SocialLoginProvider {
  wechat,
  qq,
}

extension SocialLoginProviderX on SocialLoginProvider {
  String get label {
    switch (this) {
      case SocialLoginProvider.wechat:
        return '微信';
      case SocialLoginProvider.qq:
        return 'QQ';
    }
  }

  String get apiName {
    switch (this) {
      case SocialLoginProvider.wechat:
        return 'wechat';
      case SocialLoginProvider.qq:
        return 'qq';
    }
  }
}
