import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../firebase_options.dart';
import '../brand/app_brand.dart';
import '../persistence/json_preferences_store.dart';
import '../../features/auth/data/demo_auth_repository.dart';
import '../../features/auth/data/firebase_auth_repository.dart';
import '../../features/auth/domain/auth_repository.dart';
import '../../features/chat/data/demo_chat_repository.dart';
import '../../features/chat/domain/chat_repository.dart';

enum AuthBackend {
  firebase,
  demo,
}

class AppBootstrapResult {
  const AppBootstrapResult({
    required this.repository,
    required this.chatRepository,
    required this.backend,
    required this.statusLabel,
    required this.statusMessage,
  });

  final AuthRepository repository;
  final ChatRepository chatRepository;
  final AuthBackend backend;
  final String statusLabel;
  final String statusMessage;
}

class AppBootstrap {
  static Future<AppBootstrapResult> initialize() async {
    final store = await JsonPreferencesStore.create();
    final options = DefaultFirebaseOptions.currentPlatform;
    if (!_hasRealFirebaseValues(options)) {
      return AppBootstrapResult(
        repository: await DemoAuthRepository.seeded(store: store),
        chatRepository: DemoChatRepository(store: store),
        backend: AuthBackend.demo,
        statusLabel: '演示认证模式',
        statusMessage:
            '当前还没有配置 Firebase。你可以先在 ${AppBrand.appName} 里使用演示模式测试完整流程；后续替换 lib/firebase_options.dart 或执行 flutterfire configure 后，就能启用真实的邮箱密码登录。',
      );
    }

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: options,
        );
      }

      return AppBootstrapResult(
        repository: FirebaseAuthRepository(
          auth: FirebaseAuth.instance,
          store: store,
        ),
        chatRepository: DemoChatRepository(store: store),
        backend: AuthBackend.firebase,
        statusLabel: 'Firebase 认证已启用',
        statusMessage: '当前邮箱密码登录已经连接到 Firebase Authentication。',
      );
    } catch (_) {
      return AppBootstrapResult(
        repository: await DemoAuthRepository.seeded(store: store),
        chatRepository: DemoChatRepository(store: store),
        backend: AuthBackend.demo,
        statusLabel: '演示认证模式',
        statusMessage:
            'Firebase 初始化失败，应用已自动回退到演示模式。请检查 Firebase 配置后重新执行 flutterfire configure。',
      );
    }
  }

  static bool _hasRealFirebaseValues(FirebaseOptions options) {
    return !_isPlaceholder(options.apiKey) &&
        !_isPlaceholder(options.appId) &&
        !_isPlaceholder(options.messagingSenderId) &&
        !_isPlaceholder(options.projectId);
  }

  static bool _isPlaceholder(String value) {
    return value.startsWith('REPLACE_WITH_');
  }
}
