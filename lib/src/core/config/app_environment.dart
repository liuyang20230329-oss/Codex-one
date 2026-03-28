enum AppMode {
  demo,
  localApi,
  firebaseLegacy,
}

class AppEnvironment {
  const AppEnvironment._();

  static const String _modeValue = String.fromEnvironment(
    'APP_MODE',
    defaultValue: 'localApi',
  );

  static const String localApiBaseUrl = String.fromEnvironment(
    'LOCAL_API_BASE_URL',
    defaultValue: 'http://127.0.0.1:3001',
  );

  static AppMode get appMode {
    switch (_modeValue) {
      case 'demo':
        return AppMode.demo;
      case 'firebaseLegacy':
        return AppMode.firebaseLegacy;
      case 'localApi':
      default:
        return AppMode.localApi;
    }
  }
}
