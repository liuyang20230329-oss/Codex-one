import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../firebase_options.dart';
import '../../features/auth/data/demo_auth_repository.dart';
import '../../features/auth/data/firebase_auth_repository.dart';
import '../../features/auth/data/local_api_auth_repository.dart';
import '../../features/auth/domain/auth_repository.dart';
import '../../features/chat/data/demo_chat_repository.dart';
import '../../features/chat/data/local_api_chat_repository.dart';
import '../../features/chat/domain/chat_repository.dart';
import '../brand/app_brand.dart';
import '../config/app_environment.dart';
import '../network/api_client.dart';
import '../persistence/json_preferences_store.dart';

/// The runtime backend currently serving auth and chat for the app session.
enum AuthBackend {
  firebase,
  demo,
  localApi,
}

/// Bundles repositories and user-facing status copy for app startup.
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

/// Chooses the correct repository stack for the current environment and
/// gracefully falls back when external services are unavailable.
class AppBootstrap {
  static Future<AppBootstrapResult> initialize() async {
    final store = await JsonPreferencesStore.create();
    final client = ApiClient(baseUrl: AppEnvironment.localApiBaseUrl);

    switch (AppEnvironment.appMode) {
      case AppMode.localApi:
        if (await client.ping()) {
          return AppBootstrapResult(
            repository: LocalApiAuthRepository(
              client: client,
              store: store,
            ),
            chatRepository: LocalApiChatRepository(client: client),
            backend: AuthBackend.localApi,
            statusLabel: '本地 API 模式',
            statusMessage:
                '当前已接入 local-api（${AppEnvironment.localApiBaseUrl}），可直接联调手机号认证、聊天 REST/WebSocket 和后台接口能力。',
          );
        }
        return AppBootstrapResult(
          repository: await DemoAuthRepository.seeded(store: store),
          chatRepository: DemoChatRepository(store: store),
          backend: AuthBackend.demo,
          statusLabel: '本地 API 未连通，已回退演示模式',
          statusMessage:
              '没有连接到 local-api（${AppEnvironment.localApiBaseUrl}），应用已自动回退到本地演示数据。桌面端可直接起本地服务；真机联调时请把 LOCAL_API_BASE_URL 指向电脑局域网地址。',
        );
      case AppMode.firebaseLegacy:
        return _initializeFirebase(store);
      case AppMode.demo:
        return AppBootstrapResult(
          repository: await DemoAuthRepository.seeded(store: store),
          chatRepository: DemoChatRepository(store: store),
          backend: AuthBackend.demo,
          statusLabel: '演示模式',
          statusMessage: '当前使用内置演示数据，可完整体验登录注册、认证流程、聊天与资料编辑。',
        );
    }
  }

  static Future<AppBootstrapResult> _initializeFirebase(
    JsonPreferencesStore store,
  ) async {
    final options = DefaultFirebaseOptions.currentPlatform;
    if (!_hasRealFirebaseValues(options)) {
      return AppBootstrapResult(
        repository: await DemoAuthRepository.seeded(store: store),
        chatRepository: DemoChatRepository(store: store),
        backend: AuthBackend.demo,
        statusLabel: 'Firebase Legacy 不可用，已回退演示模式',
        statusMessage:
            '当前尚未配置可用的 Firebase 参数，应用已回退为演示模式。后续替换 `lib/firebase_options.dart` 后可重新启用。',
      );
    }

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(options: options);
      }
      return AppBootstrapResult(
        repository: FirebaseAuthRepository(
          auth: FirebaseAuth.instance,
          store: store,
        ),
        chatRepository: DemoChatRepository(store: store),
        backend: AuthBackend.firebase,
        statusLabel: '${AppBrand.appName} Firebase Legacy',
        statusMessage: '当前已启用 Firebase 兼容模式。为兼容手机号主链，系统会用合成邮箱承载旧版会话。',
      );
    } catch (_) {
      return AppBootstrapResult(
        repository: await DemoAuthRepository.seeded(store: store),
        chatRepository: DemoChatRepository(store: store),
        backend: AuthBackend.demo,
        statusLabel: 'Firebase 初始化失败，已回退演示模式',
        statusMessage: 'Firebase 初始化未成功，应用已自动切回演示模式，避免影响当前功能体验。',
      );
    }
  }

  static bool _hasRealFirebaseValues(FirebaseOptions options) {
    return !_isPlaceholder(options.apiKey) &&
        !_isPlaceholder(options.appId) &&
        !_isPlaceholder(options.messagingSenderId) &&
        !_isPlaceholder(options.projectId);
  }

  static bool _isPlaceholder(String? value) {
    return value == null || value.startsWith('REPLACE_WITH_');
  }
}
