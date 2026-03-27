import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../firebase_options.dart';
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
    final options = DefaultFirebaseOptions.currentPlatform;
    if (!_hasRealFirebaseValues(options)) {
      return AppBootstrapResult(
        repository: DemoAuthRepository.seeded(),
        chatRepository: DemoChatRepository(),
        backend: AuthBackend.demo,
        statusLabel: 'Demo auth mode',
        statusMessage:
            'Firebase is not configured yet. Replace lib/firebase_options.dart or run flutterfire configure to enable real email and password sign-in.',
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
        ),
        chatRepository: DemoChatRepository(),
        backend: AuthBackend.firebase,
        statusLabel: 'Firebase auth active',
        statusMessage:
            'Email and password sign-in is connected to Firebase Authentication.',
      );
    } catch (_) {
      return AppBootstrapResult(
        repository: DemoAuthRepository.seeded(),
        chatRepository: DemoChatRepository(),
        backend: AuthBackend.demo,
        statusLabel: 'Demo auth mode',
        statusMessage:
            'Firebase initialization failed, so the app fell back to demo auth. Check your Firebase options and rerun flutterfire configure.',
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
