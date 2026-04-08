import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:codex_one/app.dart';
import 'package:codex_one/src/core/bootstrap/app_bootstrap.dart';
import 'package:codex_one/src/core/persistence/json_preferences_store.dart';
import 'package:codex_one/src/features/auth/data/demo_auth_repository.dart';
import 'package:codex_one/src/features/chat/data/demo_chat_repository.dart';
import 'package:codex_one/src/features/circle/data/demo_circle_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Codex One app can bootstrap and render', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final store = await JsonPreferencesStore.create();
    final bootstrap = AppBootstrapResult(
      repository: await DemoAuthRepository.seeded(store: store),
      chatRepository: DemoChatRepository(store: store),
      circleRepository: DemoCircleRepository(store: store),
      backend: AuthBackend.demo,
      statusLabel: 'Demo mode',
      statusMessage: 'Demo auth is active for tests.',
    );

    await tester.pumpWidget(CodexOneApp(bootstrap: bootstrap));
    await tester.pumpAndSettle();

    expect(find.byType(CodexOneApp), findsOneWidget);
  });
}
