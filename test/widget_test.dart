import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codex_one/src/core/bootstrap/app_bootstrap.dart';
import 'package:codex_one/src/features/auth/data/demo_auth_repository.dart';
import 'package:codex_one/src/features/auth/presentation/auth_gate.dart';
import 'package:codex_one/src/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:codex_one/src/features/chat/data/demo_chat_repository.dart';
import 'package:codex_one/src/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:codex_one/src/features/circle/data/demo_circle_repository.dart';
import 'package:codex_one/src/features/circle/presentation/bloc/circle_bloc.dart';

import 'widget_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Codex One app can bootstrap and render', (
    WidgetTester tester,
  ) async {
    final bootstrap = (await tester.runAsync(() async {
      final store = await createTestStore(tester);
      return AppBootstrapResult(
        repository: await DemoAuthRepository.seeded(store: store),
        chatRepository: DemoChatRepository(store: store),
        circleRepository: DemoCircleRepository(store: store),
        backend: AuthBackend.demo,
        statusLabel: 'Demo mode',
        statusMessage: 'Demo auth is active for tests.',
      );
    }))!;

    await tester.pumpWidget(MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => AuthBloc(repository: bootstrap.repository)),
        BlocProvider<ChatBloc>(create: (_) => ChatBloc(repository: bootstrap.chatRepository)),
        BlocProvider<CircleBloc>(create: (_) => CircleBloc(repository: bootstrap.circleRepository)),
      ],
      child: MaterialApp(
        home: AuthGate(
          backend: bootstrap.backend,
          statusLabel: bootstrap.statusLabel,
          statusMessage: bootstrap.statusMessage,
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(AuthGate), findsOneWidget);
  });
}
